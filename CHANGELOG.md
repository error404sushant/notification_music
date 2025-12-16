# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-16

### Added
- Initial release of generic_audio_notification package
- Android Foreground Service for looping audio playback
- FCM data message handling for background/terminated states
- Automatic audio stop on notification tap or app resume
- Comprehensive logging for all FCM scenarios
- Example app with FCM token display and testing UI
- Support for custom notification title, body, and icon
- Full documentation with setup and usage instructions
- **Loop control parameter**: `should_loop` to control whether audio loops or plays once

### Features
- Works in foreground, background, and terminated app states
- Data-only FCM message support
- High-priority message handling for reliable delivery
- MediaPlayer-based audio looping with configurable loop behavior
- Notification channel management
- Lifecycle-aware audio control
- Auto-stop when `should_loop=false` and audio completes

### Supported Platforms
- Android (API 26+)

### Known Limitations
- Android-only (iOS not supported due to platform restrictions)
- Requires publicly accessible audio URLs
- Data-only messages may not trigger foreground listener on Android
