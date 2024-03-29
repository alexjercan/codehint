# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1]

### Added

- Include option of evaluating llama2 request instead of using wrapper server

## [1.1.0]

### Added

- Llama 2 model

### Changed

- Simplify the config
- If using ChatGPT call the login function once you first use the plugin, not on start

## [1.0.0]

### Added

- Integrate Chain of Thought into the system prompt

### Changed

- Modify the default system prompt to output JSON
- Modify the diagnostics to use the hint and the line from JSON

### Removed

- Removed the system_prompt from the config of the plugin

## [0.2.0]

### Added

- Integrate with diagnostics api

### Changed

- Upgrade API to Chat

### Removed

- Printing hints support
- Floating window support

## [0.1.0]

### Added

- Codex API support

