#!/usr/bin/env python3
import os
import re
import shutil
import subprocess
import traceback

import libcalamares


REPO_URL = "@repoUrl@"
REPO_BRANCH = "@repoBranch@"
USER_NAME = "@userName@"
CONFIG_LOCATION = "@configLocation@"
PERSISTENCE_ROOT = "@persistenceRoot@"
HOSTS_DIRECTORY = "@hostsDirectory@"

WORK_DIR = "/tmp/solavane-installer"
REPO_DIR = os.path.join(WORK_DIR, "repo")
INSTALL_FLAKE = os.path.join(WORK_DIR, "install-flake")
PASS_FILE = os.path.join(WORK_DIR, "luks.key")
ROOT = "/mnt"
PASSWORD_DIR = os.path.join(ROOT, PERSISTENCE_ROOT.lstrip("/"), "secrets")
PASSWORD_FILE = os.path.join(PASSWORD_DIR, USER_NAME + ".password")

NEW_HOST_DEFAULT = """{
  config,
  inputs,
  self,
  ...
}:
let
  hostName = baseNameOf (toString ./.);

  hostConfig = { pkgs, ... }: {
    networking.hostName = hostName;
    system.stateVersion = "25.11";

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    boot.kernelPackages = pkgs.linuxPackages_zen;
  };
in
{
  flake.nixosConfigurations."${hostName}" = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };

    modules = [
      inputs.omniflake.flakes.disko.nixosModules.disko
      ./_disko.nix
      ./_hardware-configuration.nix
    ] ++ (with config.flake.modules.nixos; [
      audio-latency
      desktop
      hostConfig
      impermanence
      localsend
      network
      optimizations
      virtualization

      users-solavane
      users-solavane-desktop
      users-solavane-persist
    ]);
  };
}
"""

NEW_HOST_DISKO = """{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=25%"
        "mode=755"
      ];
    };

    disk.main = {
      device = "__DISK__";
      type = "disk";

      content = {
        type = "gpt";

        partitions = {
          ESP = {
            name = "ESP";
            size = "1G";
            type = "EF00";

            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };

          luks = {
            name = "luks";
            size = "100%";
            type = "8309";

            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;

              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };

                  "@persistent" = {
                    mountpoint = "/persistent";
                    mountOptions = [ "compress=zstd:1" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
"""

NEW_HOST_HARDWARE = """{ lib, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
}
"""

status = "Installing the NixOS configuration."


class InstallerError(Exception):
    pass


def pretty_name():
    return "Installing the NixOS configuration."


def pretty_status_message():
    return status


def _set_status(message, progress=None):
    global status
    status = message
    if progress is not None:
        libcalamares.job.setprogress(progress)


def _environment():
    environment = os.environ.copy()
    environment["HOME"] = "/root"
    environment["PATH"] = (
        "/run/current-system/sw/bin:/run/current-system/sw/sbin:"
        + environment.get("PATH", "")
    )
    environment["NIX_CONFIG"] = "experimental-features = nix-command flakes"
    return environment


def _run(command, cwd=None, input_text=None):
    libcalamares.utils.debug("flake-installer: " + " ".join(command))
    process = subprocess.Popen(
        command,
        cwd=cwd,
        env=_environment(),
        stdin=subprocess.PIPE if input_text is not None else None,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )
    output, _ = process.communicate(input_text)

    if output:
        for line in output.splitlines()[-300:]:
            libcalamares.utils.debug("flake-installer: " + line)

    if process.returncode != 0:
        tail = "\n".join(output.splitlines()[-40:]) if output else "no output"
        raise InstallerError(f"{' '.join(command)} failed.\n\n{tail}")

    return output


def _error(title, message):
    return (title, message)


def _deobscure(value):
    if not value:
        return ""

    result = []
    for character in value:
        code = ord(character)
        result.append(character if code <= 0x21 else chr(0x1001F - code))
    return "".join(result)


def _zenity(arguments):
    try:
        result = subprocess.run(
            ["zenity", *arguments],
            check=False,
            capture_output=True,
            text=True,
        )
    except OSError:
        return ""

    if result.returncode != 0:
        return ""
    return result.stdout.rstrip("\n")


def _ask_password(title, text, environment_name):
    preset = os.environ.get(environment_name)
    if preset:
        return preset

    for _ in range(3):
        first = _zenity(["--password", f"--title={title}", f"--text={text}"])
        if not first:
            return ""

        second = _zenity(["--password", f"--title={title}", f"--text={text} (confirm)"])
        if first == second:
            return first

        _zenity(
            [
                "--error",
                f"--title={title}",
                "--text=The passwords do not match.",
            ]
        )

    return ""


def _nix_string(value):
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"').replace("${", "\\${") + '"'


def _hostname(global_storage):
    value = (global_storage.value("hostname") or "").strip().lower()
    value = re.sub(r"[^a-z0-9-]", "-", value)
    value = re.sub(r"-+", "-", value).strip("-")
    return value[:63] or "nixos"


def _patch_disko(host_directory, disk):
    for name in ("_disko.nix", "default.nix"):
        path = os.path.join(host_directory, name)
        if not os.path.isfile(path):
            continue

        with open(path, encoding="utf-8") as handle:
            content = handle.read()

        index = content.find("disk.main")
        if index < 0:
            continue

        match = re.search(r'device\s*=\s*"[^"]*"', content[index:])
        if not match:
            continue

        start = index + match.start()
        end = index + match.end()
        replacement = f'device = "{disk}"'
        updated = content[:start] + replacement + content[end:]

        with open(path, "w", encoding="utf-8") as handle:
            handle.write(updated)
        return

    raise InstallerError(f"Could not find a disko disk in {host_directory}.")


def _create_host(host, disk):
    host_directory = os.path.join(REPO_DIR, HOSTS_DIRECTORY, host)
    os.makedirs(host_directory)

    with open(os.path.join(host_directory, "default.nix"), "w", encoding="utf-8") as handle:
        handle.write(NEW_HOST_DEFAULT)

    with open(os.path.join(host_directory, "_disko.nix"), "w", encoding="utf-8") as handle:
        handle.write(NEW_HOST_DISKO.replace("__DISK__", disk))

    with open(
        os.path.join(host_directory, "_hardware-configuration.nix"),
        "w",
        encoding="utf-8",
    ) as handle:
        handle.write(NEW_HOST_HARDWARE)


def _write_install_flake(host, disk):
    os.makedirs(INSTALL_FLAKE, exist_ok=True)

    flake = f"""\
{{
  inputs.repo.url = {_nix_string("path:" + REPO_DIR)};
  outputs = {{ self, repo }}: {{
    nixosConfigurations.install = repo.nixosConfigurations.{_nix_string(host)}.extendModules {{
      modules = [
        ({{ lib, ... }}: {{
          disko.devices.disk.main.device = lib.mkForce {_nix_string(disk)};
          disko.devices.disk.main.content.partitions.luks.content.passwordFile = {_nix_string(PASS_FILE)};
        }})
      ];
    }};
  }};
}}
"""

    with open(os.path.join(INSTALL_FLAKE, "flake.nix"), "w", encoding="utf-8") as handle:
        handle.write(flake)


def _write_user_password(password):
    password_hash = _run(
        ["mkpasswd", "--method=yescrypt", "--stdin"],
        input_text=password + "\n",
    ).strip()
    if not password_hash:
        raise InstallerError("Could not hash the user password.")

    os.makedirs(PASSWORD_DIR, exist_ok=True)
    os.chmod(PASSWORD_DIR, 0o700)
    with open(PASSWORD_FILE, "w", encoding="utf-8") as handle:
        handle.write(password_hash + "\n")
    os.chmod(PASSWORD_FILE, 0o600)


def _lock_root_password():
    _run(["nixos-enter", "--root", ROOT, "--command", "passwd -l root"])


def _save_configuration():
    target = os.path.join(
        ROOT,
        PERSISTENCE_ROOT.lstrip("/"),
        CONFIG_LOCATION.lstrip("/"),
    )
    if os.path.exists(target):
        shutil.rmtree(target)

    parent = os.path.dirname(target)
    os.makedirs(parent, exist_ok=True)
    _run(["chown", "1000:100", parent])
    _run(["chmod", "700", parent])

    _run(["cp", "-a", REPO_DIR + "/.", target])
    _run(["chown", "-R", "1000:100", target])


def _install():
    global_storage = libcalamares.globalstorage
    selected_host = (global_storage.value("packagechooser_host") or "").strip()
    selected_disk = (global_storage.value("packagechooser_disk") or "").strip()
    selected_user = (global_storage.value("username") or "").strip()

    if not selected_host:
        return _error("No host selected", "Choose an existing host or create a new host.")
    if not selected_disk.startswith("/dev/"):
        return _error("No disk selected", "Choose a disk to install NixOS on.")
    if not os.path.exists(selected_disk):
        return _error("Disk not found", f"The selected disk does not exist: {selected_disk}")
    if selected_user and selected_user != USER_NAME:
        return _error(
            "Unsupported username",
            f"This configuration requires the username {USER_NAME}. Change the username and try again.",
        )

    user_password = _deobscure(global_storage.value("password") or "")
    if not user_password:
        user_password = _ask_password(
            "User password",
            f"Enter the password for {USER_NAME}.",
            "SOLAVANE_USER_PASSWORD",
        )
    if not user_password:
        return _error("No user password", "A user password is required.")

    luks_password = _ask_password(
        "Disk encryption",
        "Enter the disk encryption passphrase.",
        "SOLAVANE_LUKS_PASSPHRASE",
    )
    if not luks_password:
        return _error("No encryption passphrase", "A disk encryption passphrase is required.")

    shutil.rmtree(WORK_DIR, ignore_errors=True)
    os.makedirs(WORK_DIR)

    _set_status("Downloading the configuration.", 0.05)
    _run(["git", "clone", "--depth", "1", "--branch", REPO_BRANCH, REPO_URL, REPO_DIR])

    if selected_host == "__new__":
        host = _hostname(global_storage)
        if os.path.exists(os.path.join(REPO_DIR, HOSTS_DIRECTORY, host)):
            return _error(
                "Host already exists",
                f"A host named {host} already exists. Choose a different name.",
            )
        _create_host(host, selected_disk)
    else:
        host = selected_host
        host_directory = os.path.join(REPO_DIR, HOSTS_DIRECTORY, host)
        if not os.path.isdir(host_directory):
            return _error("Host not found", f"The selected host does not exist: {host}")
        _patch_disko(host_directory, selected_disk)

    with open(PASS_FILE, "w", encoding="utf-8") as handle:
        handle.write(luks_password)
    os.chmod(PASS_FILE, 0o600)

    _write_install_flake(host, selected_disk)

    _set_status("Partitioning and formatting the disk.", 0.15)
    _run(
        [
            "disko",
            "--mode",
            "destroy,format,mount",
            "--yes-wipe-all-disks",
            "--root-mountpoint",
            ROOT,
            "--flake",
            INSTALL_FLAKE + "#install",
        ]
    )

    if selected_host == "__new__":
        _set_status("Detecting hardware.", 0.4)
        _run(["nixos-generate-config", "--root", ROOT, "--no-filesystems"])
        generated = os.path.join(ROOT, "etc/nixos/hardware-configuration.nix")
        destination = os.path.join(
            REPO_DIR,
            HOSTS_DIRECTORY,
            host,
            "_hardware-configuration.nix",
        )
        shutil.copy2(generated, destination)
        shutil.rmtree(os.path.join(ROOT, "etc/nixos"), ignore_errors=True)

    _set_status("Writing the user password.", 0.45)
    _write_user_password(user_password)

    global_storage.insert("rootMountPoint", ROOT)
    _set_status("Installing NixOS.", 0.5)
    _run(
        [
            "nixos-install",
            "--no-root-passwd",
            "--root",
            ROOT,
            "--flake",
            INSTALL_FLAKE + "#install",
        ]
    )

    _set_status("Locking the root account.", 0.9)
    _lock_root_password()

    _set_status("Saving the configuration.", 0.95)
    _save_configuration()

    shutil.rmtree(WORK_DIR, ignore_errors=True)
    libcalamares.job.setprogress(1.0)
    return None


def run():
    try:
        return _install()
    except InstallerError as error:
        libcalamares.utils.error(f"flake-installer: {error}")
        return _error("Installation failed", str(error))
    except Exception as error:
        libcalamares.utils.error(f"flake-installer: {traceback.format_exc()}")
        return _error("Installation failed", str(error))
