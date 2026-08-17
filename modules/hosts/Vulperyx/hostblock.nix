{ ... }: {
  flake.nixosModules.hosts-blocklist = { ... }: {
    networking.extraHosts = ''
      127.0.0.1 cache12-gru1.steamcontent.com
      127.0.0.1 cache16-gru1.steamcontent.com
      127.0.0.1 cache14-gru1.steamcontent.com
      127.0.0.1 cache8-gru1.steamcontent.com
      127.0.0.1 cache18-gru1.steamcontent.com
      127.0.0.1 cache10-gru1.steamcontent.com
      127.0.0.1 cache7-gru1.steamcontent.com
    '';
  };
}
