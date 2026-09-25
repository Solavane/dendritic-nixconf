{
  flake.modules.homeManager.vesktop = {
    programs.vesktop = {
      enable = true;
      vencord = {
        settings = {
          autoUpdate = false;
          autoUpdateNotification = false;
          disableMinSize = true;
          notifyAboutUpdates = false;
          minimizeToTray = true;
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
            VoumeBooster = true;
            WebKeybinds = true;
            WebScreenShareFixes = true;
            YoutubeAdblock.enabled = true;
            petpet.enabled = true;
          };
        };
      };
    };
  };
}
