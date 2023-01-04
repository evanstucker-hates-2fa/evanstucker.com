# Secure Shell (SSH)

## SSH Jump Server (aka tunnel)

This uses a server named `bastion` as a jump host to connect to the `private` server, then runs the `free -m` command on the private server.

```bash
ssh -q -o StrictHostKeyChecking=no -J evans@bastion evans@private -- free -m
```
