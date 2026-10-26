# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Automatic `dev -> main` PR opened after `dev` passes CI.

## [0.0.1] - 2026-10-26

### Added
- Telegram release notification script (`ci-cd/prod/telegram_release_notify.sh`).

### Changed
- CI/CD: build and test split into separate jobs; runner switched to `ubuntu-latest`.
- Deployment branch changed from `main` to `dev`.

### Removed
- Unused `Profile` model.
- Dependabot version update PRs.

### Fixed
- Hardcoded test DB credentials in CI; DB username now comes from `vars`.
- Model spec issue and Devise credentials fix.
