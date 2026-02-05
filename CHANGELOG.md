# Changelog

All notable changes to **Conky HUD** will be documented in this file.

---

## v1.0.0 — Initial Universal Release

### Added

* Universal installer with HUD position selection
* Optional GNOME keyboard shortcut (Alt + R)
* NVIDIA GPU monitoring via `.conky_gpu.py`
* Safe uninstall script
* Transparent dock-style HUD

### Changed

* Removed all hardcoded system paths
* GPU script moved to `~/.conky_gpu.py` for portability
* Conky config made location-independent

### Fixed

* Conky parsing issues with GPU execbar
* Path-related runtime errors
* Installer portability problems

---

## Pre-release (Local Development)

* Initial HUD prototype using local HUD_BACKUP path
* Manual script placement
* Early color and bar logic experimentation
