{
  flake.modules.nixos.localsend = { config, lib, ... }: {
    programs.localsend = {
      enable = true;
      openFirewall = true;
    };

    environment.persistence."/persistent".users.solavane.directories = lib.mkIf (
      config.environment.persistence."/persistent".enable or false
    ) [
      ".config/LocalSend"
      ".local/share/org.localsend.localsend_app"
    ];
  };
}
