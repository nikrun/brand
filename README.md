<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://nikrun.dev/brand/nikrun-lockup-dark-mono.svg">
    <img alt="Nikrun" src="https://nikrun.dev/brand/nikrun-lockup-light.svg" height="52">
  </picture>
</p>

# Nikrun Brand Assets

[![License: GPL-3.0-or-later](https://img.shields.io/badge/license-GPL--3.0--or--later-blue.svg)](./LICENSE)
[![Website: nikrun.dev](https://img.shields.io/badge/website-nikrun.dev-0b0e14)](https://nikrun.dev)

> **Official logos, icons, favicons, and social preview cards for the Nikrun ecosystem.**

[nikrun.dev](https://nikrun.dev) · [`nik` CLI](https://github.com/nikrun/cli) · [Free Pascal SDKs](https://github.com/nikrun/sdk) · [VS Code Extension](https://github.com/nikrun/vscode) · [Website & Docs](https://github.com/nikrun/web) · **[Brand Assets](https://github.com/nikrun/brand)** · [Build Library](https://github.com/nikrun/build-lib)

---

**Nikrun Brand Assets** serves as the canonical Single Source of Truth for **Nikrun** vector marks, horizontal wordmark lockups, multi-resolution application icons, favicons, and OpenGraph / GitHub social preview cards.

It is consumed as a Git submodule (`brand/`) across [`nikrun/cli`](https://github.com/nikrun/cli) (embedding `ico/nikrun.ico` into `nik.exe`), [`nikrun/vscode`](https://github.com/nikrun/vscode), and [`nikrun/web`](https://github.com/nikrun/web) (hosted at `https://nikrun.dev/brand/*`).

---

## Overview

- **`svg/` — Canonical Vector Masters:**
  - `nikrun-icon-light.svg` — Pure negative-space emblem (`#111111`) for light surfaces.
  - `nikrun-icon-dark-mono.svg` — Dark-surface emblem (`#0b0e14` interior with `#f1f5f9` contour & highlights).
  - `nikrun-favicon.svg` & `favicon.svg` — Tight-cropped small-viewport vector mark (`16×16`–`32×32`) and adaptive `prefers-color-scheme` browser favicon.
  - `nikrun-lockup-light.svg` & `nikrun-lockup-dark-mono.svg` — Horizontal lockups with outlined `nikrun` wordmark (`Cascadia Code Bold`, OFL-1.1).
  - `nikrun-icon-dark-color.svg` & `nikrun-lockup-dark-color.svg` — Optional accent-color variants.
- **`ico/` — Application & Browser Icon:**
  - `nikrun.ico` — Multi-resolution icon (`16`, `24`, `32`, `48`, `256 px` 32-bit PNG frames) for Windows executables and browser favicons.
- **`png/` — Deterministic Raster Exports & Social Cards:**
  - `nikrun-icon-256.png` (`256×256` transparent PNG for VS Code Marketplace), `apple-touch-icon-180.png` (`180×180`), and `nikrun-avatar-512.png` (`512×512` GitHub organization avatar).
  - `nikrun-lockup-light.png` & `nikrun-lockup-dark-mono.png` — `2×` Retina lockups for surfaces restricting external SVGs (such as VS Code Marketplace).
  - `og-image-1200x630.png` — Website OpenGraph social preview card (`1200×630`).
  - `github-social-{nikrun,cli,sdk,vscode,web,brand,build-lib}.png` — GitHub repository Social Preview cards (`1280×640`).
- **`github/profile-README.md`:** Ready-to-use GitHub organization profile README (`nikrun/.github` -> `profile/README.md`).

---

## Quick Start

Regenerate all derived `.ico` and `.png` assets deterministically from the canonical `svg/` masters:

```powershell
.\scripts\generate.ps1
```

---

## Repository Structure

```text
brand/
├── github/
│   └── profile-README.md          # Organization profile README template (github.com/nikrun)
├── ico/
│   └── nikrun.ico                 # Multi-frame 16/24/32/48/256 px Windows & favicon icon
├── png/                           # Generated icons, 2x lockups, OpenGraph & GitHub social cards
├── scripts/
│   └── generate.ps1               # Deterministic SVG -> ICO/PNG/Social Card generator
└── svg/                           # Canonical hand-tuned vector master files
```

---

## License

Copyright (c) 2026 The Nikrun Contributors.

Licensed under the **GNU General Public License v3.0 or later** (`GPL-3.0-or-later`) — see [LICENSE](./LICENSE).
