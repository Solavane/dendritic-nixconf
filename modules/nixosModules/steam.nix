{
  flake.modules.nixos.steam = { config, lib, ... }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    home-manager.sharedModules = [
      { modules.homeManager.mango.apps = [ "steam" ]; }
    ];

    environment.persistence."/persistent".users.solavane.directories = lib.mkIf (
      config.environment.persistence."/persistent".enable or false
    ) [
      ".steam"
      ".local/share/Steam"
      ".local/share/SteamVR"
      "steamvr"

      ".factorio"
    ];
  };
}
