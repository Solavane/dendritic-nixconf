{
  lib,
  ...
}:
let
  mediaTypes = [
    # Audio
    "audio/aac"
    "audio/flac"
    "audio/m4a"
    "audio/mp3"
    "audio/mp4"
    "audio/mpeg"
    "audio/ogg"
    "audio/opus"
    "audio/vorbis"
    "audio/wav"
    "audio/webm"
    "audio/x-m4a"
    "audio/x-wav"
    # Video
    "video/3gpp"
    "video/mp4"
    "video/mpeg"
    "video/ogg"
    "video/quicktime"
    "video/webm"
    "video/x-flv"
    "video/x-m4v"
    "video/x-matroska"
    "video/x-msvideo"
  ];
in
{
  flake.modules.homeManager.mpv = { pkgs, ... }: {
    modules.homeManager.mango.apps = [ "mpv" ];

    home.persistence."/persistent".directories = [
      ".config/mpv"
      ".local/state/mpv"
    ];

    home.packages = [ pkgs.mpv ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = lib.genAttrs mediaTypes (_: "mpv.desktop");
    };
  };
}
