<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://nikrun.dev/brand/nikrun-lockup-dark-mono.svg">
    <img alt="Nikrun" src="https://nikrun.dev/brand/nikrun-lockup-light.svg" height="52">
  </picture>
</p>

> **Modern, zero-config toolchain for Free Pascal** — portable multi-arch compiler SDKs, declarative `nik.yaml` builds, decentralized `nik.lock` packages, built-in Language Server (`nik lsp`), and Visual Studio Code integration in a single dependency-free native binary.

[nikrun.dev](https://nikrun.dev) · [`nik` CLI](https://github.com/nikrun/cli) · [Free Pascal SDKs](https://github.com/nikrun/sdk) · [VS Code Extension](https://github.com/nikrun/vscode) · [Website & Docs](https://github.com/nikrun/web) · [Brand Assets](https://github.com/nikrun/brand) · [Build Library](https://github.com/nikrun/build-lib)

---

### Quick Install

**Windows (PowerShell):**
```powershell
irm https://nikrun.dev/install.ps1 | iex
```

**Linux & macOS:**
```bash
curl -fsSL https://nikrun.dev/install.sh | bash
```

*(Installs strictly in user scope under `~/.nikrun` — no root/Administrator privileges, never pollutes global `PATH` or `/etc/fpc.cfg`.)*

---

### Ecosystem Repositories

| Repository | Description |
| :--- | :--- |
| **[`nikrun/cli`](https://github.com/nikrun/cli)** | **Nikrun CLI (`nik`)** — Zero-config toolchain, SDK manager, `nik.yaml` build system, package manager, and LSP for Free Pascal |
| **[`nikrun/sdk`](https://github.com/nikrun/sdk)** | **Nikrun SDKs** — Portable, prebuilt multi-version & multi-arch Free Pascal toolchains (`3.2.2`..`3.3.1`) for Windows, Linux, and macOS |
| **[`nikrun/vscode`](https://github.com/nikrun/vscode)** | **Nikrun for VS Code** — Official Visual Studio Code extension (`nikrun.vscode`) for zero-config Free Pascal & Object Pascal development powered by `nik lsp` |
| **[`nikrun/web`](https://github.com/nikrun/web)** | **Nikrun Website & Docs** — Official [nikrun.dev](https://nikrun.dev) landing page, documentation, and CLI installer endpoints |
| **[`nikrun/brand`](https://github.com/nikrun/brand)** | **Nikrun Brand Assets** — Official logos, icons, favicons, and social preview cards for the Nikrun ecosystem |
| **[`nikrun/build-lib`](https://github.com/nikrun/build-lib)** | **Nikrun Build Library** — Shared PowerShell build, packaging, SBOM, and release automation for Nikrun repositories |
