{
  flake.modules.homeManager.gtk = { pkgs, ... }: {
    # Noctalia's GTK templates only add the Noctalia colors through gtk.css.
    # GTK applications still need a base theme selected, and Noctalia's apply
    # hook picks adw-gtk3-dark once that theme is available.
    gtk = {
      enable = true;

      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };

      gtk3.enable = true;

      # Noctalia owns gtk-4.0/gtk.css (it imports its generated colors there).
      # Do not let Home Manager replace it with a GTK4 theme import.
      gtk4 = {
        enable = true;
        theme = null;
      };
    };
  };
}
