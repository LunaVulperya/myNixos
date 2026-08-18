{ ... }: {
  flake.nixosModules.grub-theme = { pkgs, ... }: {
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = false;

      theme = ./blackice;   # if vendoring locally, see below

      gfxmodeEfi = "1920x1080,auto";
      gfxmodeBios = "1920x1080,auto";
    };
  };
}
