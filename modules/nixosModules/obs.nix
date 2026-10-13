{
  flake.modules.homeManager.obs = { osConfig, pkgs, ... }: {
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
