# Changelog
All notable changes to **TTSTT (Text-to-Speech Test Tool)** will be documented here.

This project follows [Semantic Versioning](https://semver.org/).

---

## [2.1.0] - 2025-11-06
### Added
- Execution time measurement per spoken text
- Enhanced logging with timestamps and structured error outputs

### Improved
- Cleaner interactive prompts
- Better fallback handling when voice selection is invalid

---

## [2.0.0] - Previous Release
### Added
- Initial interactive TTS workflow  
- Voice discovery (name + language)
- Basic logging system

---

## [1.0.0] - First Release
### Added
- First working Text-to-Speech script using System.Speech
- Validation of numeric voice selection input
- Mid-session voice switching
- Automatic SSML tag insertion (`<p><s> ... </s></p>`)
