# FluxCD Cheat Sheet

https://fluxcd.io/flux/cheatsheets/troubleshooting/
flux reconcile kustomization flux-system --with-source
flux get all -A --status-selector ready=false
flux events -Aw
flux reconcile source git flux-system
flux diff kustomization -n flux-system apps --path . --recursive --verbose
flux diff kustomization -n flux-deployments apps --path zz_generated/clusters/ch1-intdev1/apps --recursive

flux build kustomization cert-manager --path .
