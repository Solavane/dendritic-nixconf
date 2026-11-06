{
  flake.modules.homeManager.obs = { lib, osConfig, pkgs, ... }: {
    modules.homeManager.mango.apps = [ "obs" ];

    home.persistence."/persistent".directories = [
      ".config/obs-studio"
      ".local/share/obs"
    ];

    programs.obs-studio = {
      enable = true;

      package = #Installs CUDA support if Nvidia enabled
        if (osConfig.modules.nixos.nvidia.enable or false) then
          pkgs.obs-studio.override {
            cudaSupport = true;
          }
        else
          pkgs.obs-studio;

      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-pipewire-audio-capture
        obs-gstreamer
        obs-vkcapture
      ];
    };

    # Noctalia produces the theme file, but OBS does not load it until its
    # own user.ini selects it. OBS rewrites that file while running, so use
    # crudini to update only the theme key and preserve everything else.
    home.activation.configureObsTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      obs_config_dir="$HOME/.config/obs-studio"
      obs_user_ini="$obs_config_dir/user.ini"

      mkdir -p "$obs_config_dir"
      ${pkgs.crudini}/bin/crudini --set "$obs_user_ini" "Appearance" "Theme" "com.obsproject.matugen"
    '';
  };
}
