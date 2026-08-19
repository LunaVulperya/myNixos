{ ... }: {
  flake.homeModules.lazygit = { pkgs, ... }: {
    programs.lazygit = {
      enable = true;
      settings = {
        gui = {
          theme = {
            activeBorderColor = [ "#ff2fd6" "bold" ];
            inactiveBorderColor = [ "#4a3b6b" ];
            selectedLineBgColor = [ "#2a2140" ];
            optionsTextColor = [ "#c77dff" ];
          };
          nerdFontsVersion = "3";
        };
      };
    };
  };
}
