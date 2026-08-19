# myNixos pack — lazygit, yazi, nvim, grub-theme

Unzip this directly over your `myNixos` repo root — the folder
structure matches your dendritic layout, so files land in the
right place automatically:

```
modules/features/lazygit/lazygit.nix
modules/features/yazi/yazi.nix
modules/features/nvim/nvim.nix
modules/features/grub-theme/grub-theme.nix
modules/features/grub-theme/blackice/         (theme.txt + 23 assets)
```

`flake.nix` is also included with the `bunny-yazi` input added —
merge it with your current `flake.nix` if you've made other changes
since (diff the `inputs` block, this only adds one entry).

## Wiring into your host

`import-tree` auto-discovers all of the above once the files exist
under `modules/`. You still need to explicitly attach them to your
host:

- `lazygit`, `yazi`, `nvim` → homeModules — add to wherever
  `home-manager.users.<you>.imports` lives (likely `home.nix`)
- `grub-theme` → nixosModule — add to
  `modules/hosts/Vulperyx/configuration.nix`'s `imports`, alongside
  `VulperyxHardware`

```nix
imports = [
  self.nixosModules.VulperyxHardware
  self.nixosModules.grub-theme
];
```

```nix
home-manager.users.<you>.imports = [
  self.homeModules.lazygit
  self.homeModules.yazi
  self.homeModules.nvim
];
```

## Bootloader

If you haven't already swapped from systemd-boot, in
`configuration.nix`:

```nix
# boot.loader.systemd-boot.enable = true;   # remove
boot.loader.efi.canTouchEfiVariables = true;
```

(`grub-theme.nix` handles the rest of `boot.loader.grub.*`.)

## After rebuild

```
sudo nixos-rebuild switch --flake .#Vulperyx
```

First `nvim` launch will bootstrap lazy.nvim + Mason (LSPs,
formatters, linters for TS/Python/Rust/Nix) — expect it to take
a minute the first time only.
