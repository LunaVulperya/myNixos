#{ self, inputs, ... }: {
#  perSystem = { pkgs, ... }: {
#    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
#      inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
#      settings = (builtins.fromJSON (builtins.readFile ./noctalia.json));
#      outOfStoreConfig = "/home/luna/.config/noctalia";
#    };
#  };
#

{ inputs, ... }: {
  flake.homeModules.noctalia = { pkgs, ... }: {
    imports = [ inputs.noctalia.homeModules.default ];

    programs.noctalia = {
      enable = true;
      # v5 config is TOML-based with a different schema than the old v4
      # JSON export sitting in noctalia.json — that file won't map onto
      # this cleanly. Start empty (defaults) and rebuild settings against:
      # https://docs.noctalia.dev/v5/
      settings = { };
      #outOfStoreConfig = "/home/luna/.config/noctalia";
    };
  };
}
