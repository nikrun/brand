<p align="left">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://nikrun.dev/brand/nikrun-lockup-dark-mono.svg">
    <img alt="Nikrun" src="https://nikrun.dev/brand/nikrun-lockup-light.svg" height="56">
  </picture>
</p>

**Modern, zero-config toolchain for Free Pascal** — portable multi-arch compiler SDKs, declarative `nik.yaml` builds, packages, built-in Language Server (`nik lsp`), and Visual Studio Code integration in a single dependency-free native binary.

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

*(Installs strictly in user scope under `~/.nikrun` — no root/Administrator rights, never pollutes global `PATH` or `/etc/fpc.cfg`.)*

---

### Ecosystem Repositories

| Repository | Description |
| :--- | :--- |
| **[`nikrun/cli`](https://github.com/nikrun/cli)** | Standalone **`nik` CLI** (`nik sdk`, `nik init`, `nik build`, `nik lsp`) & zero-dependency `nikrun-lsp-protocol` |
| **[`nikrun/sdk`](https://github.com/nikrun/sdk)** | Portable, SHA-256 verified **Free Pascal SDKs** (`3.2.2`..`3.3.1`) for `win64`, `linux`, and `darwin` (`x86_64` & `aarch64`) |
| **[`nikrun/vscode`](https://github.com/nikrun/vscode)** | Official **`vscode-nikrun`** Visual Studio Code extension for Object Pascal & Free Pascal |
| **[`nikrun/web`](https://github.com/nikrun/web)** | **[nikrun.dev](https://nikrun.dev)** website, documentation & installer endpoints |
| **[`nikrun/brand`](https://github.com/nikrun/brand)** | Official Nikrun logos, icons & social preview cards |
