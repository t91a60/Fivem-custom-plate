# Migration from 2.0.0

1. Back up the working resource directory, your `config.lua` and your artwork. Record the installed resource name and any other scripts using its exports or the same textures.
2. Stop the resource on a test server. Do not run the old and new versions side by side against the same texture targets.
3. Install the new `fxmanifest.lua`, `script` directory, license and documentation. Remove the old `__resource.lua`. Preserve your configuration and images rather than overwriting them with the empty source values in the example configuration.
4. Existing URLs, dimensions, target lists and export calls remain supported. `Config.DuiTimeoutMs = 10000` is optional. No framework change is required; `standalone` is available.
5. Optionally copy your image to `assets/plate.png` and set `Config.DiffuseImageUrl = 'assets/plate.png'`. Do the same for a normal map if needed. Preserve the original artwork and aspect ratio. This package does not include replacement artwork.
6. Fix invalid types, dimensions outside 1 to 4096 and duplicate targets. Disable an unused channel with an empty string. If a configured normal-map channel cannot be created, initialization is rolled back rather than leaving a partially initialized resource.
7. If custom code loads `script.framework`, move player identification and authorization to server-side code. `HasPermission` no longer returns unconditional `true`, and `GetPlayerIdentifier` returns `nil` instead of invoking server APIs from the client. The public resource exports retain their names.
8. Run `refresh`, start the resource and follow [Validation](VALIDATION.md). Verify the actual plate appearance before production deployment.

## Rollback

Stop the new resource and restore the complete previous version, including its manifest, configuration and images. Remove the new manifest if restoring `__resource.lua`, run `refresh` and start the resource again. Do not keep both manifests as alternative versions.

If competing texture resources leave an unexpected visual state, disable the conflict and check again after reconnecting the client.

## Behavior changes

The previous `initialized = true` state could mask failed replacements. It now means all configured channels completed their setup calls without errors; it still does not prove that the image rendered correctly.

Stricter validation may reject a configuration that previously passed through without producing a correct result. Version 2.1 targets the current Cfx Lua 5.4 runtime rather than claiming support for historical client versions.

The project code and documentation now use the MIT license. Artwork added separately retains its own rights and license terms.
