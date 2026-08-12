{ ... }: {
  flake.nixosModules.fish = { pkgs, ... }: {
    programs.fish.enable = true;
  };

  flake.homeModules.fish = { pkgs, ... }: {
    programs.fish = {
      enable = true;
      shellAliases = {
        ll = "ls -la";
        gs = "git status";
      };
      interactiveShellInit = ''
        set -g fish_greeting
      '';
    };
  };
}
