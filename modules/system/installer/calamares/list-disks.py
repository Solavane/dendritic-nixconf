#!/usr/bin/env python3
import json
import os
import subprocess
import sys

LSBLK = "@lsblk@"
BY_ID = "/dev/disk/by-id"


def human_size(value):
    try:
        size = float(value)
    except (TypeError, ValueError):
        return "unknown size"

    for unit in ("B", "KiB", "MiB", "GiB", "TiB", "PiB"):
        if size < 1024.0 or unit == "PiB":
            return f"{size:.1f} {unit}"
        size /= 1024.0


def by_id_aliases():
    aliases = {}
    try:
        entries = os.listdir(BY_ID)
    except OSError:
        return aliases

    for entry in entries:
        if "-part" in entry:
            continue
        path = os.path.join(BY_ID, entry)
        real = os.path.realpath(path)
        aliases.setdefault(real, []).append(entry)
    return aliases


def alias_rank(entry):
    prefixes = ("nvme-", "ata-", "wwn-", "virtio-", "scsi-", "usb-")
    for index, prefix in enumerate(prefixes):
        if entry.startswith(prefix):
            return index
    return len(prefixes)


def main():
    if len(sys.argv) != 2:
        print("usage: list-disks.py OUTPUT", file=sys.stderr)
        return 2

    result = subprocess.run(
        [
            LSBLK,
            "-J",
            "-b",
            "-o",
            "NAME,PATH,TYPE,SIZE,MODEL,TRAN,RM",
        ],
        check=False,
        capture_output=True,
        text=True,
    )

    if result.returncode != 0:
        print(result.stdout, file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        return 1

    try:
        blockdevices = json.loads(result.stdout).get("blockdevices", [])
    except json.JSONDecodeError as error:
        print(f"cannot parse lsblk output: {error}", file=sys.stderr)
        return 1

    aliases = by_id_aliases()
    disks = []

    for device in blockdevices:
        if device.get("type") != "disk":
            continue

        path = device.get("path") or f"/dev/{device.get('name', '')}"
        real = os.path.realpath(path)
        available = sorted(aliases.get(real, []), key=alias_rank)

        if available:
            disk_id = os.path.join(BY_ID, available[0])
        else:
            disk_id = path

        model = (device.get("model") or "Unknown disk").strip()
        transport = (device.get("tran") or "unknown").strip()
        removable = str(device.get("rm", "0")).lower() in ("1", "true")
        size = human_size(device.get("size"))

        disks.append(
            {
                "id": disk_id,
                "name": f"{model} ({size})",
                "description": (
                    f"Path: {disk_id} | Transport: {transport} | "
                    f"Removable: {'yes' if removable else 'no'}"
                ),
            }
        )

    if not disks:
        print("no installable disks found", file=sys.stderr)
        return 1

    disks.sort(key=lambda item: item["id"])
    lines = [
        "mode: required",
        "method: legacy",
        "labels:",
        '  step: "Disk"',
        "items:",
    ]

    for disk in disks:
        lines.extend(
            [
                f"  - id: {json.dumps(disk['id'])}",
                "    packages: []",
                f"    name: {json.dumps(disk['name'])}",
                f"    description: {json.dumps(disk['description'])}",
            ]
        )

    output = os.path.abspath(sys.argv[1])
    os.makedirs(os.path.dirname(output), exist_ok=True)
    temporary = output + ".tmp"

    with open(temporary, "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines) + "\n")

    os.replace(temporary, output)
    return 0


if __name__ == "__main__":
    sys.exit(main())
