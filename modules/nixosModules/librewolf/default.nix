{
  flake.modules.homeManager.librewolf = {
    modules.homeManager.mango.apps = [ "librewolf" ];

    home.persistence."/persistent".directories = [
      ".config/librewolf"
      ".librewolf"
      ".mozilla"
    ];

    programs.librewolf = {
      enable = true;
      settings = {
      }; 

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        
        PasswordManagerEnabled = false;
        OfferToSaveLogins = false;
        DisableMasterPasswordCreation = true;
        PrimaryPassword = false;
        
        DontCheckDefaultBrowser = true;

        AIControls.default = "blocked";
        GenerativeAI = false;

        #BlockAboutConfig = true;
        
        SkipTermsOfUse = true;
        FirefoxHome = {
          SponsoredTopSites = false;
          SponsoredPocket = false;
          SponsoredStories = false;
          Pocket = false;
        };

        EnableTrackingProtection = {
          Value = true;
          Category = "strict";

          BaselineExceptions = true;
          ConvenienceExceptions = true;
        };

        ExtensionSettings = {
          
        };
      };
    };
  };
}
