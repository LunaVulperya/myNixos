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
        # syntax highlighting palette
        set -g fish_color_command         magenta --bold
        set -g fish_color_param           cyan
        set -g fish_color_error           red --bold
        set -g fish_color_autosuggestion  brblack
        set -g fish_color_comment         brblack

        function fish_greeting
          set -l user (whoami)
          set -l host (hostname)
          set_color magenta --bold
          echo -n "  $user"
          set_color normal
          echo -n "@"
          set_color cyan --bold
          echo -n "$host"
          set_color normal
          echo ""
        end
      '';
    };
  };
}
