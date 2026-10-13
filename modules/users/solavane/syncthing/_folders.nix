{ home }:
{
  secrets = {
    path = "${home}/.secrets/sync";
  };

  obsidian = {
    path = "${home}/Documents/Obsidian";
    ignorePatterns = [
      ".obsidian"
    ];
  };
}
