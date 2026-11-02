{
  lib,
  ...
}:
{
  # Always imported by the base user module so every application module can
  # register itself, whether or not Mango is enabled on the current host.
  flake.modules.homeManager.mango-shortcuts = {
    options.modules.homeManager.mango.apps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Home-manager module names whose application shortcut should be added
        to Mango. Application modules add themselves to this list when they
        are enabled.
      '';
      example = [
        "kitty"
        "librewolf"
        "obsidian"
      ];
    };
  };
}
