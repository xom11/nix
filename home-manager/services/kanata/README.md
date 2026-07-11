# kanata as an unprivileged user service

For Linux hosts where Nix is a guest — Ubuntu and friends, where `nixos/services/kanata`
is unavailable and `system-manager/services/kanata` would mean running kanata as root.
This module instead writes a `systemd.user.service` that runs kanata as **you**.

The binary is plain `pkgs.kanata` — the config uses no `(cmd …)` actions, so the
`kanata-with-cmd` build isn't needed. It is in the binary cache for both
`x86_64-linux` and `aarch64-linux`, so nothing is compiled.

Enable it per-host:

```nix
modules.home-manager.services.kanata.enable = true;
```

## It still needs root once, and only once

"kanata works without sudo" is true of *running* it, not of *setting it up*. Out of
the box `/dev/uinput` is `root:root 0600` and `/dev/input/event*` is `root:input
0660`, so an unprivileged kanata can neither read the real keyboard nor create its
virtual one. Nothing home-manager can do changes that. Run once, per machine:

```bash
sudo groupadd -f uinput
sudo usermod -aG input,uinput "$USER"
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' \
  | sudo tee /etc/udev/rules.d/99-kanata.rules
sudo udevadm control --reload-rules && sudo udevadm trigger --sysname-match=uinput
```

`OPTIONS+="static_node=uinput"` is the part that matters. It re-applies the group and
mode on every boot *without* anything having to autoload — which is what you need when
`uinput` is built into the kernel (`CONFIG_INPUT_UINPUT=y`) rather than a module, as it
is on Ubuntu.

## The trap: `home-manager switch` starts kanata before you can use it

Adding yourself to a group does **not** change any process that is already running, and
`user@$UID.service` — the systemd user manager that will own `kanata.service` — was
started at your last login. So right after the `groupadd`, `home-manager switch` reports
`Starting units: kanata.service` and the service dies:

```
[ERROR] Failed to open the output uinput device. Make sure you added the user
        executing kanata to the 'uinput' group …
[ERROR] Permission denied (os error 13)
kanata.service: Failed with result 'exit-code'.
```

A user systemd unit cannot grant itself supplementary groups — that is privileged — so a
fresh `user@$UID.service` is the only fix. Do not go looking for a bug in the unit.

**Logging out of the desktop is not enough**, and this wastes time if you believe it is.
With `Linger=no` the user manager exits only when your *last* session closes, so a single
open SSH connection keeps the stale one alive right across a logout/login. Check before
trusting it — `ActiveEnterTimestamp` must be later than the `usermod`:

```bash
systemctl show user@$UID.service -p ActiveEnterTimestamp
loginctl show-user "$USER" -p Linger -p Sessions
```

Restart it explicitly instead:

```bash
sudo systemctl restart "user@$UID.service"
```

That kills a graphical session if one is running — you land back at the display manager —
but it needs no reboot, and no login either: `kanata.service` is `WantedBy=default.target`
of the *user* manager, so it comes up the moment the manager does.

The obvious sanity check *lies*, which is why this is worth stating. A new SSH session
goes through PAM and therefore already carries the new groups, so running the exact
`ExecStart` by hand succeeds while the service keeps failing. Compare the two:

```bash
sudo -u "$USER" -i id -nG | tr ' ' '\n' | grep -E '^(input|uinput)$'   # fresh login: both
grep -a Groups /proc/$(pgrep -u "$USER" -f 'systemd --user' | head -1)/status
#   the input and uinput gids must both appear here — if not, log out
```

## Verify

```bash
systemctl --user status kanata.service        # active (running)
journalctl --user -u kanata.service | grep -E 'registering|Starting kanata proper'
```

A healthy start creates a virtual device and grabs the real keyboard:

```
[INFO] Created device "/dev/input/event7"
[INFO] registering /dev/input/event1: "hid-over-i2c 0B05:0220"
[INFO] Starting kanata proper
```

kanata grabs every device it takes for a keyboard, which on a laptop can include oddities
like a headset-jack button node. That is harmless; pin `linux-dev` in
`configs/kanata/defcfg.kbd` if you want only the keyboard.

Escape hatch: `lctl+spc+esc` (keys as they are *before* remapping) force-exits kanata.
Over SSH, `systemctl --user stop kanata.service`.

> Membership of `input` lets **any** process running as you read every keystroke on the
> machine, including passwords typed into other applications. That is the price of
> running kanata unprivileged, and it is why the alternative — a system service as root,
> as `nixos/` and `system-manager/` do — is not obviously worse.
