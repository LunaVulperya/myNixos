{ ... }: {
  perSystem = { pkgs, lib, ... }:
    let
      # keep this list in sync with modules/features/nvim/nvim.nix's
      # home.packages — this check exists so a nixpkgs rename/removal
      # shows up at `nix flake check` time instead of at rebuild time
      requiredPackages = [
        "ripgrep"
        "fd"
        "gcc"
        "nodejs"

        "lua-language-server"
        "nil"
        "rust-analyzer"
        "pyright"
        "typescript-language-server"
        "vscode-langservers-extracted"

        "stylua"
        "alejandra"
        "ruff"
        "rustfmt"
        "prettier"

        "eslint"
      ];

      missing = lib.filter (name: !(pkgs ? ${name})) requiredPackages;
    in
    {
      checks.nvim-packages-exist =
        if missing == [ ] then
          pkgs.runCommand "nvim-packages-exist" { } ''
            echo "all ${toString (lib.length requiredPackages)} nvim.nix package attributes resolved" > $out
          ''
        else
          throw ''
            nvim.nix references nixpkgs attributes that no longer exist
            in your pinned nixpkgs (check flake.lock / run `nix flake update`):

              ${lib.concatStringsSep "\n  " missing}

            Search for the new attribute name with:
              nix search nixpkgs <name>

            Then update modules/features/nvim/nvim.nix's home.packages
            AND this file's requiredPackages list to match.
          '';
    };
}
