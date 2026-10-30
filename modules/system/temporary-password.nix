{
  flake.modules.nixos.temporary-password = {
    users.users.root.initialPassword = "123";
    users.users.solavane.initialPassword = "123";
  };
}
