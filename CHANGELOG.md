# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.0.2] - 2026-10-28

### Added
- Automatic `dev -> main` PR opened after `dev` passes CI; PR body lists the commits being released.
- Release notifications are sent on version tags (`v*`) via `.github/workflows/release.yml`.

### Changed
- Release version is the git tag; `config/version.rb` removed.
- Telegram release notes are plain text: headings become `Added:`, list items become `•`.
- Telegram notes drop `Co-Authored-By` trailers and are marked with `…` when truncated.
- Telegram commit link points to GitHub.
- Release notes are taken from the CHANGELOG section matching the tag version.

### Fixed
- Production image build failed: dev-only gems were loaded by `bootsnap precompile` and `assets:precompile`.
- Telegram notification no longer uses the GitLab MR API.

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
