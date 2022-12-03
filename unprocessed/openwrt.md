# OpenWRT

[OpenWRT](https://openwrt.org/) is a great open source router operating system. See their website to get it installed. Here are a few post-install steps that I typically do to get it fully functional:

1. Go to http://192.168.1.1 (note: it's http, not https). Or maybe HTTPS works by default now?
1. Log in with no password.
1. Go to System, Administration, Router Password, and set a password.
1. SSH to `root@192.168.1.1` with the new password.
1. Upgrade everything with:
   ```bash
   opkg update && opkg list-upgradable | cut -f 1 -d ' ' | xargs opkg upgrade
   ```
1. Set System, Administration, SSH-Keys, and add ed25519 public key.
1. Set up guest WiFi named openwireless.org with OWE security: https://openwrt.org/docs/guide-user/network/wifi/guestwifi/guest-wlan
1. Set up dual-band guest access as well: https://openwrt.org/docs/guide-user/network/wifi/guestwifi/extras#dual-band
1. Ensure that both guest wireless services are isolating clients: https://openwrt.org/docs/guide-user/network/wifi/guestwifi/extras#isolating_clients
1. Enable IPv6 on guest wireless networks: https://openwrt.org/docs/guide-user/network/wifi/guestwifi/extras#ipv6
1. Forward ports on firewall.









1. Install ACME? https://github.com/acmesh-official/acme.sh/wiki/How-to-run-on-OpenWRT
1. Add MAC filter for private networks?
1. Disable router access from guest network?
1. Add static DHCP for server.
1. Setup port forwarding to server. Ports?

## Setup DNS over HTTPS (DoH) with Quad9

https://openwrt.org/docs/guide-user/services/dns/doh_dnsmasq_https-dns-proxy
https://quad9.net/doh-quad9-dns-servers/

## IPv6

https://openwrt.org/docs/guide-user/network/ipv6/start
Set WAN6 to /56 prefix so you can use /64s for guest and LAN interfaces




