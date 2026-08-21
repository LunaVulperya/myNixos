# myNixos — Architecture

A NixOS + Home Manager configuration built on the **dendritic pattern**: instead of one
big `configuration.nix` tree with manual imports, every concern lives in its own
self-contained `.nix` file, and a single mechanism (`import-tree`) auto-discovers all of
them. `flake.nix` never has to change when a new feature is added.

## The core mechanism

```nix
# flake.nix
inputs = {
  nixpkgs.url        = "github:nixos/nixpkgs/nixos-unstable";
  flake-parts.url    = "github:hercules-ci/flake-parts";
  import-tree.url    = "github:vic/import-tree";
  noctalia = { url = "github:noctalia-dev/noctalia"; inputs.nixpkgs.follows = "nixpkgs"; };
  wrapper-modules.url = "github:BirdeeHub/nix-wrapper-modules";
  home-manager = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
  bunny-yazi = { url = "github:stelcodes/bunny.yazi"; flake = false; };
};

outputs = inputs: inputs.flake-parts.lib.mkFlake
  {inherit inputs;}
  (inputs.import-tree ./modules);
```

- **`flake-parts`** turns the flake's `outputs` into a module system: any file can
  contribute `flake.*` attributes, `perSystem.*` attributes, `systems`, etc., and
  flake-parts merges them all.
- **`import-tree ./modules`** recursively finds every `.nix` file under `modules/` and
  feeds the whole list into flake-parts as its module list. Drop a new `.nix` file
  anywhere under `modules/` → it's automatically part of the evaluation. No manual
  wiring, no `../../../` relative imports between files.
- Every file is therefore a **top-level flake-parts module**. A file doesn't just
  configure one thing — it *contributes* pieces of the overall flake output
  (`flake.nixosModules.X`, `flake.homeModules.X`, `flake.wrappersModules.X`,
  `perSystem.packages.X`, `checks.X`, …), and those contributions get consumed
  elsewhere by explicit reference (`self.nixosModules.X`), not by folder location.

This is what "dendritic" means here: modules branch outward from one root
(`import-tree`), each is self-contained, but they can all reference each other via
`self.*` and `inputs.*` since they're evaluated as one config.

## Directory layout

```
flake.nix / flake.lock
modules/
  parts.nix                       # global flake-parts config (systems, home-manager flakeModule)
  theme.nix                       # shared wallpaper path + base16 color palette
  checks/
    nvim-packages.nix             # `nix flake check` guard for nvim's package list
  features/
    cursor/       cursor.nix          (+ kuro_cursor/ icon theme assets)
    dolphin/      dolphin.nix
    fastfetch/    fastfetch.nix        + pngs/ (logo variants)
    fish/         fish.nix
    git/          git.nix
    grubtheme/    grubtheme.nix        (+ blackice/ GRUB theme assets)
    kitty/        kitty.nix
    lazygit/      lazygit.nix
    niri/         niri.nix
    noctalia/     noctalia.nix + noctalia-config.toml + noctalia.json
    nvim/         nvim.nix
    starship/     starship.nix + starship.toml
    thunar/       thunar.nix
    yazi/         yazi.nix
  hosts/
    <hostname>/
      default.nix              # nixosSystem entry point
      configuration.nix        # the actual system config
      hardware-configuration.nix
      home.nix                 # wires home-manager into the NixOS module
      docker.nix
      hostblock.nix            # /etc/hosts entries
assets/
  wallpaper image (referenced by modules/theme.nix)
```

The `cursor/kuro_cursor/`, `grubtheme/blackice/`, and top-level `assets/` wallpaper are
binary asset directories referenced by their `.nix` files but weren't included in what
you sent for review — the modules that consume them (`cursor.nix`, `grubtheme.nix`,
`theme.nix`) still assume they exist at those paths.

## `modules/parts.nix` — global config

```nix
{ inputs, ... }: {
  imports = [ inputs.home-manager.flakeModules.home-manager ];
  config.systems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
}
```

Pulls in home-manager's flake-parts module (so `home-manager.*` options are usable
inside NixOS modules) and declares which systems `perSystem` blocks build for.

## `modules/theme.nix` — shared values

Exposes two flake-level values any other module can read via `self.*`:

- `flake.wallpaper` — a path to the wallpaper image.
- `flake.themeNoHash` — a base16 color palette (16 hex colors). `niri.nix` reads
  `base09` for its focus-ring color; other modules could pull from the same palette
  instead of hardcoding colors, keeping the look consistent across tools.

## `modules/checks/nvim-packages.nix` — CI-style safety net

Not a feature — a `perSystem.checks` entry. It keeps a second copy of the package-name
list from `nvim.nix` and, at `nix flake check` time, verifies every name still resolves
in the pinned `nixpkgs`. If nixpkgs renames or removes a package (e.g. an LSP server),
this fails fast at `flake check` instead of silently breaking `home-manager switch`.
It's a manual sync, not automatic — a comment in the file says to update both lists
together.

## Feature modules (`modules/features/*`)

Each file follows the same shape:

```nix
{ ... }: {
  flake.nixosModules.<name> = { pkgs, ... }: { /* system-level config */ };
  flake.homeModules.<name>  = { pkgs, ... }: { /* per-user config */ };
}
```

A module can define one or both, depending on whether the concern is system-wide or
per-user. Examples of the split:

| Module | nixosModule | homeModule |
|---|---|---|
| `dolphin` | `services.gvfs`, `udisks2`, `polkit` (system services) | the actual package, KDE theming wrapper, color scheme |
| `thunar` | same system services (gvfs/udisks2/polkit — home-manager can't declare these) | package + plugins |
| `fish` | `programs.fish.enable` at system level (needed for it to be a valid login shell) | actual per-user shell config, aliases, greeting |
| `cursor` | — | cursor theme package + gtk/x11 pointer config |
| `git` | — | git identity, SSH signing, ssh-agent |
| `grubtheme` | GRUB bootloader theme + EFI settings | — |
| `kitty`, `lazygit`, `starship`, `yazi` | — | terminal tool configs, all home-manager only |

Things worth calling out:

- **`dolphin.nix`** wraps the KDE file manager with `symlinkJoin` + `makeWrapper` so KDE
  platform theming (`QT_QPA_PLATFORMTHEME=kde`) only applies to Dolphin's process, not
  the whole niri/Noctalia session — avoids KDE Qt styling leaking into everything else.
- **`noctalia.nix`** has a commented-out `perSystem.packages` block from an earlier
  approach (wrapping Noctalia as a standalone package with `wrapper-modules`), replaced
  by importing Noctalia's own `homeModules.default` and feeding it a TOML settings file.
  A comment notes the old `noctalia.json` was Noctalia v4's JSON schema and doesn't map
  onto v5's TOML schema — that file is now dead/reference-only.
- **`niri.nix`** is the biggest module: it defines the nixosModule enabling niri, *and*
  a `flake.wrappersModules.niri` (consumed by `nix-wrapper-modules`) that adds custom
  `terminal`/`fileManager`/`browser` options, then a full keybinding/layout/output
  config, then a `perSystem.packages.myNiri` that actually builds the wrapped niri
  binary via `inputs.wrapper-modules.wrappers.niri.wrap`. Several keybind comments flag
  Noctalia IPC panel names as unconfirmed against the running version — worth
  double-checking with `niri msg layers` / Noctalia's own IPC docs before relying on them.

## nvim — the split you asked about

`nvim.nix` deliberately only owns **what's on the system**, not **how the editor
behaves**:

**Nix layer (`home.packages` + `programs.neovim`)**
- Installs Neovim itself, plus every LSP server, formatter, and linter LazyVim would
  otherwise fetch via Mason: `lua-language-server`, `nil`, `rust-analyzer`, `pyright`,
  `typescript-language-server`, `vscode-langservers-extracted`, `stylua`, `alejandra`,
  `ruff`, `rustfmt`, `prettier`, `eslint` — plus `ripgrep`, `fd`, `gcc`, `nodejs`,
  `tree-sitter` that LazyVim/Telescope expect on `$PATH`.
- Writes the actual Lua files via `xdg.configFile`, so `~/.config/nvim/*` is generated
  by Home Manager, not hand-edited.

**LazyVim layer (bootstrapped, not Nix-managed)**
- `init.lua` clones `lazy.nvim` on first run if it's not already present, then
  `require("config.lazy")`.
- `lua/config/lazy.lua` is the actual plugin spec: pulls in `LazyVim/LazyVim` core plus
  a curated set of LazyVim "extras" (mini-animate, mini-files, dashboard, dap, test,
  mini-surround, yanky, prettier, eslint, and language presets for
  typescript/json/python/rust/nix).
- `lua/plugins/disable-mason.lua` explicitly disables `mason.nvim`,
  `mason-lspconfig.nvim`, and `mason-tool-installer.nvim` — since every binary those
  would install is already provided by Nix and pinned in `flake.lock`. `nvim-lspconfig`'s
  default server definitions call the tool by name (e.g. `"rust-analyzer"`), which now
  resolves to the already-on-`$PATH` Nix store binary — no per-server `cmd` overrides
  needed.
- `lua/plugins/theme.lua` and `lua/plugins/breadcrumbs.lua` are small standalone
  plugin-spec files (tokyonight colorscheme, dropbar.nvim breadcrumbs).

So: **Nix guarantees reproducible binaries** (same LSP/formatter/linter versions every
rebuild, pinned in `flake.lock`), and **lazy.nvim owns editor behavior** (keymaps, UI,
which plugins are enabled) without fighting Nix's purity model for fast iteration. The
`checks/nvim-packages.nix` module exists specifically to keep the Nix side honest as
nixpkgs evolves.

## Host wiring (`modules/hosts/<hostname>/`)

- **`default.nix`** — the actual flake output entry point:
  ```nix
  flake.nixosConfigurations.<hostname> = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.<Hostname>Configuration ];
  };
  ```
- **`configuration.nix`** — defines `<Hostname>Configuration`, which explicitly
  `imports` the nixosModules it wants:
  ```nix
  imports = [
    self.nixosModules.<Hostname>Hardware
    self.nixosModules.<Hostname>HomeManager
    self.nixosModules.hosts-blocklist
    self.nixosModules.docker
    self.nixosModules.niri
    self.nixosModules.fish
    self.nixosModules.grubtheme
  ];
  ```
  This is the manual "attach" step the dendritic pattern still requires:
  `import-tree` makes every module *available* as a flake output, but nothing is
  *applied* to a host until it's listed here. Also sets hostname, locale/timezone,
  NVIDIA driver config, KDE Plasma + niri as the session, PipeWire audio, the user
  account, `programs.firefox`/`programs.steam`, and `system.stateVersion`.
- **`hardware-configuration.nix`** — the standard `nixos-generate-config` output,
  wrapped as `flake.nixosModules.<Hostname>Hardware` instead of a plain imported file.
- **`home.nix`** — defines `<Hostname>HomeManager`: imports the home-manager NixOS
  module, sets `useGlobalPkgs`/`useUserPackages`, and lists which `homeModules.*` the
  user gets:
  ```nix
  home-manager.users.<user> = { pkgs, ... }: {
    imports = [
      self.homeModules.kitty  self.homeModules.fish   self.homeModules.starship
      self.homeModules.dolphin self.homeModules.noctalia self.homeModules.git
      self.homeModules.fastfetch self.homeModules.cursor self.homeModules.nvim
      self.homeModules.yazi   self.homeModules.lazygit
    ];
  };
  ```
- **`docker.nix`** — small standalone nixosModule (`virtualisation.docker.enable`, adds
  the user to the `docker` group).
- **`hostblock.nix`** — `networking.extraHosts` blocking a handful of Steam CDN cache
  nodes (likely a bandwidth-throttling workaround, not a security block).

## Rebuilding

```
sudo nixos-rebuild switch --flake .#<hostname>
```

First `nvim` launch after a rebuild bootstraps `lazy.nvim` (clones the plugin manager,
installs plugins) — expect it to take a little longer than usual just that once.