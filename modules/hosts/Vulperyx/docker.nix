{ ... }: {
  flake.nixosModules.docker = { pkgs, ... }: {
    virtualisation.docker.enable = true;
    users.users.luna.extraGroups = [ "docker" ];
  };
}
