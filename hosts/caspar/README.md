# Caspar

## Overview

NixOS Workstation

## Installation

1. Disable Secure Boot and boot a NixOS installer UEFI ISO

> [!TIP]
> You can detect if you're booted in UEFI with:
> `[ -d /sys/firmware/efi ] && echo "UEFI Boot Detected" || echo "Legacy BIOS Boot Detected"`

1. Set up disks

```sh
nix-shell -p nvme-cli
nvme format -s1 /dev/nvme0n1

# Create partitions
parted /dev/nvme0n1 -- mklabel gpt
parted /dev/nvme0n1 -- mkpart ESP fat32 1MiB 1GiB
parted /dev/nvme0n1 -- set 1 esp on
parted /dev/nvme0n1 -- mkpart NixOS 1GiB 100%

# Format EFI System Partition
mkfs.fat -n ESP -F32 /dev/nvme0n1p1

# Create and open an encrypted persistent data container
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup open /dev/nvme0n1p2 cryptroot --allow-discards

# Format the persistent data container
mkfs.btrfs -L root /dev/mapper/cryptroot

# mount root subvolume and create subvolumes
mount /dev/mapper/cryptroot /mnt
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/persist/home
btrfs subvolume create /mnt/swap
btrfs subvolume create /mnt/snapshots

# Create directories for persistent storage
mkdir -p /mnt/persist/var/log

# Create swapfile
btrfs filesystem mkswapfile --size 16G /mnt/swap/swapfile

umount /mnt
```

2. Mount filesystems
```sh
# Mount tmpfs root
mount -t tmpfs -o size=2G,mode=755 none /mnt

# Create mountpoints
mkdir -p /mnt/{boot,nix,var/{log,persist,swap}}

# Mount ESP
mount /dev/nvme0n1p1 /mnt/boot

# Mount persistent storages
mount -o subvol=nix /dev/mapper/cryptroot /mnt/nix
mount -o subvol=persist /dev/mapper/cryptroot /mnt/var/persist
mount -o subvol=swap /dev/mapper/cryptroot /mnt/var/swap

# Bind mount persistent /var/log
mount --bind /mnt/var/persist/var/log /mnt/var/log

# Enable swap
swapon /mnt/var/swap/swapfile
```

3. Install secret keys
```sh
mkdir /mnt/var/persist/secrets

cat <<'EOS' >/mnt/var/persist/secrets/age.key
(age secret key)
EOS

chmod 400 /mnt/var/persist/secrets/*
```

4. Install NixOS
```sh
nix-shell -p git nixFlakes
git clone https://github.com/openfinch/dotfiles
cd dotfiles
vim hosts/caspar/default.nix
(Update filesystems UUIDs)
nixos-install --root /mnt --flake ".#caspar" --no-root-passwd --impure
```

5. Configure hibernation
```sh
btrfs inspect-internal map-swapfile /var/swap/swapfile
Physical start:   2186280960
Resume offset:        533760
nvim hosts/peregrine/default.nix
```

```ini
boot.kernelParams = [ "resume_offset=533760" ];
```

```sh
switch
```

6. Setup TPM2 LUKS Unlock
```sh
systemd-cryptenroll --recovery-key /dev/nvme0n1p2
systemd-cryptenroll --wipe-slot=tpm2 --tpm2-device=auto --tpm2-pcrs=0+2+3+7 --tpm2-with-pin=yes /dev/nvme0n1p2
cryptsetup luksKillSlot /dev/nvme0n1p2 0 # delete password set by luksFormat
```
