# BrainMaps CLI

The command-line tool for the [BrainMaps platform](https://brainmaps.xyz).
Upload and manage brain imaging data, convert imaging formats, run registration
workflows, and work with cloud storage from your terminal.

## Install

On macOS or Linux:

```sh
curl -fsSL https://brainmaps.xyz/install.sh | sh
```

The installer selects the matching ARM64 or AMD64 release, verifies its SHA256
checksum, and installs `brainmaps` into `~/.local/bin` without sudo. Add that
directory to your `PATH` if it is not already present.

For Windows, download the matching ZIP from
[Releases](https://github.com/brainmapsplatform/brainmaps/releases/latest),
extract it, and place `brainmaps.exe` on your `PATH`.

Prebuilt binaries are available for macOS, Linux, and Windows on ARM64 and AMD64.
API commands do not require Go or Python. Scientific imaging commands need `uv`
or Python 3.11 with venv support to prepare their pinned dependencies. Windows
scientific commands require a compatible prepared Python environment.

## Get started

```sh
brainmaps --version
brainmaps --help
brainmaps login
brainmaps species list
```

## Update

```sh
brainmaps update --check
brainmaps update
```

The updater verifies release checksums and preserves your existing executable
if download or verification fails. Configuration remains in `~/.brainmaps/config.json`.

For an older installation that uses the previous release repository, migrate once:

```sh
BRAINMAPS_REPOSITORY=brainmapsplatform/brainmaps brainmaps update
```

## Verify a download

Every release includes `checksums.txt`, the six platform archives, and `install.sh`.
Use `sha256sum` or `shasum -a 256` to compare your archive with its listed checksum.

Releases in this repository are built and uploaded manually.
