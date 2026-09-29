# nightscout-tui

A lightweight, high-resolution Unicode terminal monitor for [Nightscout](https://nightscout.github.io/) continuous glucose monitoring (CGM) telemetry.

Designed specifically for headless laptops, terminal dashboards, Raspberry Pis, or dedicated monitoring TTY consoles.

---

## Features

- **Zero Python Dependencies**: Pure Python 3 standard library (`urllib`, `json`, `argparse`). No `pip install` required.
- **Braille Dot-Matrix Scatter Plot**: Uses Unicode 2x4 Braille cells (`\u2800`–`\u28FF`) to render 8x virtual pixel resolution directly in ANSI terminals.
- **Dynamic Color Coding & Thresholds**: Instant ANSI color feedback (Green for in-range, Yellow for high, Red for low) with dashed threshold guide lines.
- **Delta & Trend Direction**: Displays delta differences (`+4 mg/dL`, `-0.2 mmol/L`) and standard CGM trend arrows (`↑`, `↗`, `→`, `↘`, `↓`, `⇈`, `⇊`).
- **Flexible Units**: Supports both `mg/dl` and `mmol/l` with automatic conversion.
- **Privacy & Security First**: Works with Nightscout Role-Based Access Control (RBAC) via `--token` or `--token-file` (compatible with Agenix, SOPS, and environment variables).
- **Flicker-Free Live Refresh**: Uses terminal cursor repositioning rather than destructive screen clearing.
- **Native Nix & Home Manager Integration**: Packaged as a Nix Flake with ready-to-use NixOS and Home Manager systemd modules.

---

## Quick Start

### Direct Execution with Nix

```bash
# Run immediately via Nix Flake
nix run github:deepwatrcreatur/nightscout-tui -- --url https://nightscout.example.com --token YOUR_TOKEN
```

### Standalone Python Execution

```bash
git clone https://github.com/deepwatrcreatur/nightscout-tui.git
cd nightscout-tui
python3 bin/nightscout-tui --url https://nightscout.example.com
```

---

## Command-Line Options

| Option | Environment Variable | Default | Description |
|---|---|---|---|
| `--url` | `NIGHTSCOUT_URL` | `https://nightscout.deepwatercreature.com` | Base URL of your Nightscout instance |
| `--token` | `NIGHTSCOUT_TOKEN` | `None` | API authentication token or secret |
| `--token-file` | `NIGHTSCOUT_TOKEN_FILE` | `None` | Path to file containing API token |
| `--units` | `DISPLAY_UNITS` | `mg/dl` | Display units: `mg/dl` or `mmol/l` |
| `--low` | `TARGET_LOW` | `70` | Lower target threshold in mg/dL |
| `--high` | `TARGET_HIGH` | `180` | Upper target threshold in mg/dL |
| `--count` | `ENTRIES_COUNT` | `48` | Number of historical 5m entries (~4h) |
| `--refresh` | `REFRESH_SECONDS` | `60` | Refresh interval in seconds |
| `--once` | - | `false` | Fetch and render once, then exit |

---

## Home Manager Integration

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nightscout-tui.url = "github:deepwatrcreatur/nightscout-tui";
  };

  outputs = { self, nixpkgs, home-manager, nightscout-tui, ... }: {
    # In your home-manager configuration:
    # imports = [ nightscout-tui.homeManagerModules.default ];
  };
}
```

In your Home Manager configuration:

```nix
services.nightscout-tui = {
  enable = true;
  url = "https://nightscout.example.com";
  tokenFile = "/run/user/1000/secrets/nightscout-token";
  units = "mg/dl";
  targetLow = 70;
  targetHigh = 180;
  refreshInterval = 60;

  # Optional systemd user service
  systemd = {
    enable = true;
    # tty = "/dev/tty1"; # Optional direct TTY output
  };
};
```

---

## NixOS System Module (Headless TTY Kiosk)

To dedicate a virtual terminal (e.g. `/dev/tty1`) on a headless server or laptop:

```nix
services.nightscout-tui = {
  enable = true;
  url = "https://nightscout.example.com";
  tokenFile = config.age.secrets.nightscout-token.path;
  tty = "/dev/tty1";
  user = "deepwatrcreatur";
};
```

---

## License

MIT License. See [LICENSE](./LICENSE) for details.
