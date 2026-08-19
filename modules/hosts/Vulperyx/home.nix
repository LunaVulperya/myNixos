{ self, inputs, ... }: {
  flake.nixosModules.VulperyxHomeManager = { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "hm-bak";

    home-manager.users.luna = { pkgs, ... }: {
      imports = [
        self.homeModules.kitty
        self.homeModules.fish
        self.homeModules.starship
        self.homeModules.dolphin
        self.homeModules.noctalia
        self.homeModules.git
        self.homeModules.fastfetch
        self.homeModules.cursor
        self.homeModules.nvim
      ];
      home.stateVersion = "26.05";

      home.packages = with pkgs; [
        # add user-level packages here
      ];

      #programs.git = {
      #  enable = true;
      #  userName = "Luna Vulperya";
      #  userEmail = "lunavulperya@gmail.com";
      #};
    };
  };
}
