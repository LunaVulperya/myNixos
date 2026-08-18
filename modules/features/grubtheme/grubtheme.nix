{ ... }: {
  flake.nixosModules.grubtheme = { pkgs, ... }: {
    boot.loader.grub = {
      enable = true;
      theme = ./blackice;
      gfxmodeEfi = "1920x1080,auto";
      gfxmodeBios = "1920x1080,auto";
    };
  };
}
