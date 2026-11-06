{
  flake.modules.homeManager.vesktop = {
    modules.homeManager.mango.apps = [ "vesktop" ];

    home.persistence."/persistent".directories = [
      ".config/vesktop"
      ".config/Vencord"
      ".local/share/vesktop"
    ];

    programs.vesktop = {
      enable = true;
      
      settings = {
        arRPC = true;
        checkUpdates = false;
        minimizeToTray = true;
        disableMinSize = true;
      };

      vencord = {
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;
          enabledThemes = [ "noctalia.theme.css" ];
          plugins = {
            AddAttachments.enabled = true;
            CallTimer.enabled = true;
            ClearURLs.enabled = true;
            CrashHandler.enabled = true;
            FakeNitro.enabled = true;
            FixYoutubeEmbeds.enabled = true;
            GameActivityToggle.enabled = true;
            GreetStickerPicker.enabled = true;
            ImageZoom.enabled = true;
            MessageLogger.enabled = true;
            PermissionFreeWill.enabled = true;
            RelationshipNotifier.enabled = true;
            ReplaceGoogleSearch.enabled = true;
            ShowHiddenChannels.enabled = true;
            SilentMessageToggle.enabled = true;
            SpotifyCrack.enabled = true;
            Translate.enabled = true;
            TypingIndicator.enabled = true;
            UnlockedAvatarZoom.enabled = true;
            UserMessagesPronouns.enabled = true;
            ViewIcons.enabled = true;
            VoiceDownload.enabled = true;
            VolumeBooster.enabled = true;
            YoutubeAdblock.enabled = true;
            petpet.enabled = true;
          };
        };
      };
    };
  };
}
