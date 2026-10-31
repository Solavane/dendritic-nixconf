{
  lib,
  ...
}:
{
  options.vars = lib.mkOption {
    type = lib.types.submodule {
      options = {
        userName = lib.mkOption {
          type = lib.types.str;
          default = "solavane";
        };

        repoOwner = lib.mkOption {
          type = lib.types.str;
          default = "Solavane";
        };

        repoName = lib.mkOption {
          type = lib.types.str;
          default = "dendritic-nixconf";
        };

        repoBranch = lib.mkOption {
          type = lib.types.str;
          default = "main";
        };

        repoUrl = lib.mkOption {
          type = lib.types.str;
          default = "https://github.com/Solavane/dendritic-nixconf.git";
        };

        configLocation = lib.mkOption {
          type = lib.types.str;
          default = "/home/solavane/nixconfig";
        };

        persistenceRoot = lib.mkOption {
          type = lib.types.str;
          default = "/persistent";
        };

        hostsDirectory = lib.mkOption {
          type = lib.types.str;
          default = "modules/hosts";
        };
      };
    };

    default = { };
  };
}
