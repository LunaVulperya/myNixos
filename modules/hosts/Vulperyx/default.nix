{ self, inputs, ... }: {
  flake.nixosConfigurations.Vulperyx = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.VulperyxConfiguration
    ];
  };
}
