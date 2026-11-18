<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./svg/nikrun-lockup-dark-mono.svg">
    <img alt="Nikrun" src="./svg/nikrun-lockup-light.svg" height="52">
  </picture>
</p>

# Nikrun — Shared Brand & Icon Assets (`nikrun/brand`)

Single Source of Truth for **Nikrun** logos, favicons, application icons, and social preview cards, consumed as a Git submodule (`brand/`) across:

- **[`nikrun/cli`](https://github.com/nikrun/cli)** — Standalone `nik` CLI (`ico/nikrun.ico` embedded into `nik.exe` at build time)
- **[`nikrun/web`](https://github.com/nikrun/web)** — Official `nikrun.dev` website & documentation
- **[`nikrun/vscode`](https://github.com/nikrun/vscode)** — Official `vscode-nikrun` Visual Studio Code extension

## Directory Layout

- **`svg/`** — Canonical vector masters:
  - `nikrun-icon-light.svg` — Pure negative-space emblem (`#111111`) for light surfaces
  - `nikrun-icon-dark-mono.svg` — Dark-surface emblem (`#0b0e14` interior with `#f1f5f9` contour & highlights)
  - `nikrun-favicon.svg` — Tight-cropped vector icon for small viewport rendering (`16×16`–`32×32`)
  - `favicon.svg` — Adaptive browser favicon (`prefers-color-scheme: light / dark`)
  - `nikrun-lockup-light.svg` & `nikrun-lockup-dark-mono.svg` — Horizontal lockups with outlined `nikrun` wordmark (`Cascadia Code Bold`, OFL-1.1)
  - `nikrun-icon-dark-color.svg` & `nikrun-lockup-dark-color.svg` — Optional accent-color variants
- **`ico/`**
  - `nikrun.ico` — Multi-resolution icon (`16`, `24`, `32`, `48`, `256 px` 32-bit PNG frames) for Windows executables and browser favicons
- **`png/`**
  - `nikrun-icon-256.png` — `256×256` transparent PNG (VS Code Marketplace & extension sidebar)
  - `apple-touch-icon-180.png` — `180×180` opaque touch icon (`#0b0e14`)
  - `nikrun-avatar-512.png` — `512×512` GitHub organization avatar (`#0b0e14`)
  - `og-image-1200x630.png` — Website OpenGraph social preview card (`1200×630`)
  - `github-social-{nikrun,cli,sdk,vscode}.png` — GitHub repository Social Preview cards (`1280×640`)
- **`github/profile-README.md`** — Ready-to-use GitHub organization profile README (`nikrun/.github` -> `profile/README.md`)
- **`scripts/generate.ps1`** — Regenerates `ico/` and `png/` deterministically from `svg/`.

## License

Copyright (c) 2026 The Nikrun Contributors.

Licensed under the **GNU General Public License v3.0 or later** (`GPL-3.0-or-later`) — see [LICENSE](./LICENSE).
