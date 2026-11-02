{ config, ... }:
let
  userName = config.vars.userName;
in
{
  # Fallback for live/impermanent-less hosts: log in with 123.
  # Persisted hosts use the hashedPasswordFile written by the installer instead.
  flake.modules.nixos.temporary-password = { config, lib, ... }: {
    users.users.root.initialPassword = lib.mkIf
      (!(config.environment.persistence."/persistent".enable or false))
      "123";
    users.users.${userName}.initialPassword = lib.mkIf
      (!(config.environment.persistence."/persistent".enable or false))
      "123";
  };
}
