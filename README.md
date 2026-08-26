# xmr-termux-miner

Scripts to build and run [XMRig](https://github.com/xmrig/xmrig) (an open-source
Monero/XMR CPU miner) inside [Termux](https://termux.dev) on Android.

> ⚠️ **Read this before using**
> - Only run this on a device **you own**. Mining on shared, rented, employer-owned,
>   or otherwise not-fully-yours hardware without explicit permission is theft of
>   resources and, in many places, a crime.
> - Only mine to a **wallet address you control**. Never point this at someone
>   else's pool account.
> - Phone CPUs are slow at RandomX (XMR's proof-of-work). Expect a few hundred
>   H/s at best, heavy battery drain, and heat. This is a learning project, not
>   a profitable miner.
> - Sustained 100% CPU load can shorten battery lifespan and, in rare cases,
>   trigger thermal shutdowns. Use the throttling options below.
> - Respect the terms of service of any pool, cloud host, or workplace network
>   you use. Mining is banned on many free-tier cloud/CI services and some
>   corporate/campus Wi-Fi.

## What this repo contains

| File | Purpose |
|---|---|
| `install.sh` | Installs build deps in Termux and compiles XMRig from source |
| `config.example.json` | XMRig config template — copy to `config.json` and fill in your wallet/pool |
| `start.sh` | Starts mining in the foreground (or backgrounded with `tmux`) |
| `stop.sh` | Stops a running miner cleanly |
| `battery-guard.sh` | Optional watcher that pauses mining below a battery threshold or when unplugged |

## Requirements

- Android phone/tablet with Termux installed from **F-Droid** (not Google Play —
  that build is outdated and can't compile modern packages).
  Get it here: https://f-droid.org/packages/com.termux/
- ~2 GB free storage for build tools + source
- A Monero wallet address (e.g. from the official [Monero GUI/CLI wallet](https://www.getmonero.org/downloads/)
  or a reputable exchange that supports XMR deposits)
- A mining pool account/address (e.g. supportxmr.com, xmrpool.eu, or solo mining
  against your own node)

## Quick start

```bash
pkg update -y && pkg install -y git
git clone https://github.com/<your-username>/xmr-termux-miner.git
cd xmr-termux-miner
bash install.sh
cp config.example.json config.json
nano config.json   # set your pool URL and wallet address
bash start.sh
```

To stop:

```bash
bash stop.sh
```

## Running in the background

Termux kills processes when the app closes unless you keep a wakelock and use
a session manager. `start.sh` uses `tmux` for this — install once with
`pkg install tmux`, then:

```bash
bash start.sh --background
```

Reattach anytime with `tmux attach -t xmrig`.

Also run `termux-wake-lock` (from the `termux-api` package) before starting a
long session so Android doesn't suspend the process, and keep the phone
plugged in and ventilated.

## Throttling / heat management

`config.json` exposes `"max-threads-hint"` and CPU affinity options — start
low (e.g. 25–50%) and monitor `termux-battery-status` / device temperature
before increasing. `battery-guard.sh` will auto-pause the miner if the battery
drops below a threshold or the charger is unplugged; see comments in that
script for configuration.

## License

MIT for the scripts in this repo. XMRig itself is licensed under GPLv3 — see
https://github.com/xmrig/xmrig/blob/master/LICENSE.
