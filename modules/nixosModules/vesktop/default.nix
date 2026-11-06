{
  flake.modules.homeManager.vesktop = {
    modules.homeManager.mango.apps = [ "vesktop" ];

    home.persistence."/persistent".directories = [
      ".config/vesktop"
      ".config/Vencord"
    ];

    programs.vesktop = {
      enable = true;
      
      settings = {
        arRPC = true;
        checkUpdates = false;
        minimizeToTray = true;
        disableMinSize = true;
        
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
            /* Keep a solid copy for text on colored elements */
            --solid-bg-4: hsl(223, 14%, 10%) !important;

            --bg-4: hsla(223, 14%, 10%, 0.4) !important;
            --bg-3: hsla(223, 14%, 10%, 0.7) !important;
          }

          body {
            --remove-bg-layer: off;
            --transparency-tweaks: true;
            --bg-floating: hsla(223, 14%, 10%, 0,7);  
          }

          members {
              background: invisible !important;
          }
        '';
      };
    };
  };
}
