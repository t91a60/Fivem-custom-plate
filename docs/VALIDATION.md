# Validation

## Completed locally

- All 19 test scenarios pass in Lua 5.4 through Lupa 2.8.
- All `.lua` files pass Lua syntax compilation; the manifest is not executed as game code.
- Tests cover legacy settings without a timeout, local paths, rejected sources/dimensions/targets, both channels, one runtime texture per channel, exports, unrelated resource events, repeated startup/shutdown, browser timeout, stop during initialization, replacement exceptions, normal-map failure after diffuse preparation, dictionary/DUI/handle/runtime texture failures and a missing framework.
- The `AddReplaceTexture` stub requires a string dictionary name; runtime texture creation requires the numeric dictionary handle.

Run `lua tests/run.lua` from the repository root. Alternatively, use Python with `lupa` installed and run `python tests/run_with_lupa.py`. The final result should be `PASS: 19 tests; Lua Lua 5.4`.

## Required in-game validation

FiveM client/server, CEF and GTA V have not been run during this refresh. The local test result does not confirm plate appearance. Keep this checklist incomplete until each item has actually been verified.

- [ ] Start with your own local PNG and no normal map. Check artwork placement, borders and registration text readability.
- [ ] Inspect all configured `plate01..05` variants, several standard GTA V models and an addon vehicle using different textures. Record the models and plate variants actually tested.
- [ ] Compare normal-map rendering in daylight, at night and at different lighting angles. Test a normal-map-only configuration.
- [ ] Repeat with a controlled HTTPS image URL. Test HTTP separately on the intended client if your installation still needs it.
- [ ] Test an unavailable URL, a 404 response and a missing local file. Do not treat `initialized` as proof that an image loaded. Inspect browser diagnostics and the actual vehicle.
- [ ] Stop the resource with a vehicle visible and confirm the original textures return. Restart it and confirm custom artwork returns.
- [ ] Repeat several resource restarts and reconnect the client. Observe F8 errors and resource usage; record measurements before making performance claims.
- [ ] Test standalone mode and any frameworks actually used: ESX, QBCore or Ox Core. Also test when the configured framework is missing.
- [ ] Rename the resource directory, then verify local artwork and export calls using the new resource name.
- [ ] Test a controlled conflict with another replacement resource. Remove the conflict before deployment; resource start order does not isolate competing replacements.

Record server/client artifact versions, the GTA build, model names, image sources, DUI dimensions and observed limitations. Stable release publication should follow this validation, not just the Lua test result.
