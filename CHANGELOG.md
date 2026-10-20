# Changelog

## 2.1.0 - Unreleased

### Fixed

- Pass the runtime dictionary name to `AddReplaceTexture`; use its handle only when creating runtime textures.
- Create one runtime texture per channel rather than recreating it for every target.
- Wait for DUI browser availability with a timeout and cancel initialization when the resource stops.
- Remove registered replacements before destroying DUI objects, including rollback after a partial startup failure.
- Avoid reporting successful initialization after a replacement exception or a configured normal-map channel failure.
- Validate dimensions, image sources, duplicate targets and target array structure.
- Keep optional framework errors from blocking texture replacement.
- Stop invoking server-only player identification functions on clients and make the internal permission helper deny access by default.

### Added

- Local `assets/` image sources resolved through Cfx NUI HTTPS URLs.
- Optional `DuiTimeoutMs`, defaulting to 10000 milliseconds.
- Diagnostic fields in the existing state export and Lua 5.4 tests.
- MIT license for code and documentation.

### Changed

- Replace `__resource.lua` with `fxmanifest.lua` and load modules as files instead of running them twice.
- Rewrite the README, migration guide, modernization plan and validation instructions in English.

### Compatibility

Existing configuration keys, default targets and both exports remain available, including their original four state fields. Remote HTTP/HTTPS sources still work. `Config.Debug` logs targets. A normal-map-only configuration is supported.

Remove the old `__resource.lua` when deploying the new manifest. The internal `Framework.HasPermission` helper now returns `false`, and `GetPlayerIdentifier` returns `nil`; review any custom callers of that module. Invalid configuration or a failed configured channel aborts initialization and cleans up runtime state. See [Migration](docs/MIGRATION.md).

No user artwork was changed. In-game validation and stable release publication remain pending.
