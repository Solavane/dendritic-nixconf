{
  flake.modules.nixos.ly = { config, lib, ... }: { 
    services.displayManager.ly = {
      enable = true;
    };
    
    environment.persistence."/persistent".users.solavane.files = lib.mkIf (
      config.environment.persistence."/persistent".enable or false
    ) [
      ".ly-session.log"
    ];
  };
}
