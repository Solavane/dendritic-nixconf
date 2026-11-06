{
  flake.modules.nixos.ly = { config, lib, ... }:
  let
    persist = config.environment.persistence."/persistent".enable or false;
  in
  {
    services.displayManager.ly = {
      enable = true;
      settings = lib.mkMerge [
        {
          save = true;
          load = true;

          #bigclock = "en";
          #clock = "%a %d %b  %H:%M";

          animation = "dur_file";
          dur_file_path = "${./_blackhole-smooth-240x67.dur}";
          dur_offset_alignment = "center";
          full_color = true;
        }
        (lib.mkIf persist {
          save_file = "/persistent/ly/save.ini";
        })
      ];
    };

    systemd.tmpfiles.rules = lib.mkIf persist [
      "d /persistent/ly 0755 root root -"
    ];
  };
}
