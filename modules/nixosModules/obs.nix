{
  flake.modules.homeManager.obs = { osConfig, pkgs, ... }: {
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
  };
}
