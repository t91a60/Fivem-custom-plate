# FiveM Custom Plates

A client-side FiveM resource for replacing **license plate background artwork** in GTA V. It replaces configured diffuse textures and, optionally, normal maps. It does not change license plate text.

## Release status

Version 2.1.0 is prepared for review and in-game testing. The Lua tests pass, but rendering and resource restarts have not been verified in FiveM. See [Validation](docs/VALIDATION.md) before deploying or publishing a stable release.

## How it works

`config.lua` -> DUI (`CreateDui`) -> runtime texture -> `AddReplaceTexture` for each configured dictionary/texture pair. The defaults cover `vehshare/plate01` through `plate05` and their `_n` normal maps.

Replacement is global on each client for those texture names: every vehicle using them receives the same artwork. This is not a per-vehicle or per-registration image system. Vehicles with custom texture dictionaries need matching targets in the configuration.

No server scripts, database, network events, or mandatory framework dependencies are required. ESX, QBCore and Ox Core can be detected for compatibility with the previous configuration. Texture replacement itself is standalone. Ox Lib is neither required nor used.

## Installation

1. Place the resource in your server's resources directory, for example `resources/[local]/custom-plate`.
2. Put your own artwork at `assets/plate.png`, then configure it:

```lua
Config.DiffuseImageUrl = 'assets/plate.png'
Config.NormalMapUrl = '' -- Keep the original normal maps.
```

No plate artwork is included. Local images can use lowercase `.png`, `.jpg`, `.jpeg` or `.webp` extensions, including subdirectories under `assets/`. Use ASCII letters, numbers, underscores, hyphens and dots in paths, without spaces. Paths are case-sensitive on Linux servers. The manifest includes these images in the resource packfile; no YTD streaming or `stream` directory is needed.

3. Add the resource to `server.cfg`, using its actual folder name:

```text
ensure custom-plate
```

4. Check the client's F8 console and inspect several vehicles in-game. Run `refresh` first when adding a new resource to an already running server.

## Configuration

Existing public HTTP/HTTPS image URLs remain supported:

```lua
Config.DiffuseImageUrl = 'https://example.com/plate.png'
Config.NormalMapUrl = 'https://example.com/plate-normal.png'
Config.Framework = 'standalone' -- Also: auto, esx, qbcore, ox.
Config.DuiWidth = 540
Config.DuiHeight = 300
Config.DuiTimeoutMs = 10000
Config.Debug = false
```

Configure at least one source. You can replace diffuse textures, normal maps, or both. An empty string disables a channel and skips its target list. Each enabled channel needs a non-empty array of targets:

```lua
Config.PlateTextures = {
    { dictionary = 'vehshare', texture = 'plate01' },
    { dictionary = 'vehshare', texture = 'plate02' },
}
Config.PlateNormalTextures = {
    { dictionary = 'vehshare', texture = 'plate01_n' },
}
```

Each dictionary/texture pair may occur only once across enabled channels. The original five default plate variants are retained; they do not necessarily cover every model or game build.

DUI dimensions must be integers from 1 to 4096. The browser creation timeout must be an integer from 1 to 60000 milliseconds. Larger texture surfaces require more memory. Each enabled channel creates one DUI browser and one runtime texture. The default resolution remains 540 x 300.

Match your artwork's composition, aspect ratio and normal map to the vehicle's plate UVs. DUI renders the image through a browser: inspect scaling, borders, colors and lighting in-game rather than assuming that an arbitrary image will fit.

`DuiTimeoutMs` limits the wait for browser creation. `IsDuiAvailable` does **not** confirm that an image has downloaded or decoded successfully. A browser displaying a 404 page can still be available. After a failed start, fix the configuration and restart the resource.

## Client exports

Use the installed resource folder name when calling exports:

```lua
local ready = exports['custom-plate']:IsInitialized()
local state = exports['custom-plate']:GetPlateState()
```

| Field | Meaning |
| --- | --- |
| `initialized` | All configured channels completed their runtime setup and replacement calls without an exception. |
| `replacementsApplied` | Replacement setup completed; this is not visual confirmation. |
| `diffuseUrl` | Configured diffuse source, unchanged, including a local path if used. |
| `normalUrl` | Configured normal-map source, unchanged. |
| `initializing` | Initialization is in progress. |
| `error` | Configuration error or failed initialization stage; `nil` when no error is recorded. |
| `replacementCount` | Number of registered replacement targets. |

The native replacement function does not report whether a model actually uses the target texture. Neither export proves that the image is visible or correctly rendered. Existing export names and the original four fields remain available.

## Compatibility and security

- The resource uses `fxmanifest.lua`, `cerulean`, `gta5` and the current Cfx Lua 5.4 runtime. No additional in-game libraries are needed.
- Do not run other resources replacing the same dictionary/texture pairs. The native API does not provide a stack of previous replacements to restore when this resource stops.
- Configuration and artwork are available to clients. Do not put passwords or secret tokens in image URLs.
- A remote URL navigates a DUI browser. Use a direct image on a host you control, preferably over HTTPS. A remote host can change its content and observe players' IP addresses. HTTP remains accepted for compatibility but does not protect transport. URL validation does not inspect remote content or redirects.
- Local files avoid dependency on an external image host. The resource does not accept image URLs from players or download and execute Lua code.
- The internal `Framework.HasPermission()` helper returns `false`. Its former unconditional `true` was not authorization. `Framework.GetPlayerIdentifier()` returns `nil` instead of calling server-only functions on a client. Handle player identification and authorization in server-side code.
- Cfx documents `AddReplaceTexture` and `RemoveReplaceTexture` as experimental. This refresh retains the existing technique and requires validation on the intended client version.

## Troubleshooting

If the background does not appear, check the source file or URL, manifest entries, filename case and target texture names. A remote source must return an image, not a login or preview page. Set `Config.Debug = true` to log replacement targets in the F8 console.

A missing framework should not prevent replacement. If the normal map looks wrong, disable that channel and compare the result. Test a standard GTA V vehicle and check for competing texture replacement resources.

## Project structure and tests

```text
fxmanifest.lua         Resource manifest and client file list
config.lua             Image sources, targets and runtime settings
script/plate.lua       Startup, DUI lifecycle, replacement, rollback and exports
script/validation.lua  Configuration and local path validation
script/framework.lua   Optional framework compatibility helpers
assets/                Your artwork; no images are bundled
tests/run.lua          Tests using FiveM API stubs
```

Run `lua tests/run.lua` from the repository root using Lua 5.4. Alternatively, with Python and the `lupa` package installed, run `python tests/run_with_lupa.py`. Lupa is a development dependency only; it is not required on the FiveM server. These tests do not run CEF or GTA V.

See [Validation](docs/VALIDATION.md), [Migration](docs/MIGRATION.md), [Modernization plan](docs/MODERNIZATION.md) and [Changelog](CHANGELOG.md).

## Technical references

- [Cfx resource manifest](https://docs.fivem.net/docs/scripting-reference/resource-manifest/resource-manifest/)
- [Direct-rendered UI](https://docs.fivem.net/docs/scripting-manual/nui-development/dui/)
- [AddReplaceTexture dictionary names](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/AddReplaceTexture.md)
- [IsDuiAvailable browser readiness](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/IsDuiAvailable.md)
- [Cfx Lua 5.4 runtime](https://docs.fivem.net/docs/scripting-manual/introduction/creating-your-first-script/)

## License

The code and documentation are available under the [MIT License](LICENSE). No plate artwork is bundled. Keep the rights and license terms of any images you add separate from the code license.
