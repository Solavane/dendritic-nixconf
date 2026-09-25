{
  flake.modules.homeManager.prismlauncher = { config, lib, pkgs, ... }: {
    options.modules.homeManager.prismlauncher = {
      jdk = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "jdk25" ];
        description = "List of JDK package names to make available to Prism Launcher";
      };
    };

    config.home.packages = [
      (pkgs.prismlauncher.override {
        additionalPrograms = [ pkgs.ffmpeg ];
        jdks = map (name: pkgs.${name}) config.modules.homeManager.prismlauncher.jdk;
      })
    ];
  };
}
