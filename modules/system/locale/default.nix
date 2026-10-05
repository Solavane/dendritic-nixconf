{
  flake.modules.nixos.locale = {
    i18n.defaultLocale = "sv_SE.UTF-8";

    i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";

    console.keyMap = "se-lat6";
    services.xserver.xkb.layout = "se";

    time.timeZone = "Europe/Stockholm";
  };
}
