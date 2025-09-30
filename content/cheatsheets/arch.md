---
title: "Arch Linux"
draft: false
---
## Search for the package that contains a file
```bash
pacman -F whois
```

## Upgrading

```
sudo pacman -Syu # to upgrade everything
yay -Syu # to upgrade AUR packages
for package in $(pacman -Qdtq); do sudo pacman -Rns "$package"; done # to clean up packages that are no longer needed
```

## Unicode fonts

This might work? I forget.
https://wiki.archlinux.org/title/Fonts
yay bdf-unifont

## Connecting to shitty WiFi captive portals
You need to comment out the "Added by Evans" sections of resolved.conf:
```
sudo vim /etc/systemd/resolved.conf
```
Then restart systemd-resolved:
```
sudo systemctl restart systemd-resolved.service 
```
Don't forget to undo this when you're off the horrible network.
