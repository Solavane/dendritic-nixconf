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
        
        enableRoundedCorners = true;
        enableSplashScreen = 0;

        spellCheckLanguages = [
          "english"
          "swedish"
        ];
      };

      vencord = {
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          notifyAboutUpdates = false;
          enabledThemes = [ "noctalia.theme.css" ];

          transparent = true;

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

        # TODO: Change this shit
        extraQuickCss = ''
          :root {
            --background-primary: rgba(43, 45, 49, 0.8) !important;
            --background-secondary: rgba(30, 31, 34, 0.8) !important;
            --background-tertiary: rgba(17, 18, 20, 0.8) !important;
            --background-secondary-alt: rgba(43, 45, 49, 0.8) !important;
            --chat-background: transparent !important;
            --background-floating: rgba(22, 23, 25, 0.85) !important;
          }
        '';
      };
    };
  };
}
