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
