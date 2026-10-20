# Review findings and modernization plan

## Baseline

The review covered the local repository on `main` at commit `f2e851d`. Its working tree was clean. It contained six tracked files: a manifest, configuration, two Lua modules, a README and `.gitattributes`.

There were no artwork files, YTD assets, `stream` directory, server scripts, tests or license file. These findings describe the checked-out implementation, not files that may exist elsewhere outside the repository.

## Architecture and fixes

| Area | Baseline finding | Version 2.1 action |
| --- | --- | --- |
| Background replacement | DUI from URLs, one image for `vehshare/plate01..05` and one for `_n` targets | Preserve the technique and default targets |
| Runtime dictionary | `CreateRuntimeTxd` returns a handle, but `AddReplaceTexture` expects a name | Keep the name separate from the handle |
| DUI lifecycle | A function was described as asynchronous but never waited for browser availability | Add a startup thread, readiness polling and a timeout |
| Runtime textures | The same runtime texture was created inside each target iteration | Create one texture per enabled channel |
| State | Target errors could still report success; the normal-map result was ignored | Roll back failed startup and expose the failed stage |
| Shutdown | DUI objects were destroyed without removing replacements | Remove replacements before destroying DUI objects |
| Manifest | Legacy filename; configuration and framework loaded both as scripts and modules | Use `fxmanifest.lua`, one entry script and packaged modules |
| Framework | Not needed for replacement; an export exception could abort startup | Keep optional integration with standalone fallback |
| Permissions | Unused helper returned unconditional `true` | Return `false` and document the change |
| Identifiers | Client module called server-only functions | Return `nil`; keep server identity handling outside this resource |
| Artwork | No bundled images, only configurable URLs | Support user-supplied local `assets/` images |

## Compatibility and security boundaries

Replacement is global on each client for the configured dictionary/texture pairs. Vehicles with different materials and additional plate variants are not automatically covered. The resource does not select artwork per vehicle, synchronize vehicle state or modify registration text. The replacement itself does not depend on a database, ESX, QBCore, Ox Core or Ox Lib.

The resource does not accept player-provided URLs. A configured remote source still navigates a browser, and HTTPS does not establish that its content is a trustworthy image. Validation restricts schemes and local paths but does not inspect the remote response or redirects. Local assets are delivered to clients and are not confidential.

No administrative commands, network events or image editing interface were added. Those would introduce authorization requirements that this resource currently does not have. Client-side helpers cannot authorize server-side actions.

## Delivery stages

1. **Completed locally:** native API correction, startup/shutdown handling, validation, rollback, current manifest, local image support, tests and English documentation. Existing configuration and exports remain usable. The owner selected MIT for the code and documentation; the license is included.
2. **Before stable release:** run the resource in the intended FiveM environment with real artwork, vehicle models, resource restarts and controlled conflict cases using [Validation](VALIDATION.md). Record the actual client/server artifact versions and game build. Do not claim untested compatibility or invent a minimum build number.
3. **Possible later work:** separate diffuse/normal profiles for different plate variants; a local image rendering page with explicit image `load/error` acknowledgement; and, only after measurements, comparison with a streamed YTD package. An image page could provide more predictable sizing and diagnostics but needs separate DUI communication tests. YTD changes delivery and conflict behavior, so it was not added without evidence of a benefit.

No new artwork, mandatory framework or automatic updater was added. There is no measured basis for FPS or VRAM improvement claims. Empty image sources intentionally require configuration before the resource can initialize.

## Publication assessment

The source is suitable for review and an explicitly labeled test build. It is not yet verified for a stable release: Lua stubs cannot test CEF image rendering, GTA materials, lighting or the real effect of stopping and restarting the resource.

The remaining release gate is the documented in-game validation. MIT licensing is now in place, and no artwork has been bundled that needs separate distribution permission.

## References

Native signatures and lifecycle behavior were checked against Cfx documentation on 2026-10-20:

- [Resource manifest](https://docs.fivem.net/docs/scripting-reference/resource-manifest/resource-manifest/)
- [Direct-rendered UI](https://docs.fivem.net/docs/scripting-manual/nui-development/dui/)
- [CreateRuntimeTxd](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/CreateRuntimeTxd.md)
- [CreateRuntimeTextureFromDuiHandle](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/CreateRuntimeTextureFromDuiHandle.md)
- [AddReplaceTexture](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/AddReplaceTexture.md)
- [RemoveReplaceTexture](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/RemoveReplaceTexture.md)
- [IsDuiAvailable](https://github.com/citizenfx/fivem/blob/master/ext/native-decls/IsDuiAvailable.md)

Cfx marks `AddReplaceTexture` and `RemoveReplaceTexture` as experimental. Passing stubbed tests does not change that API status.
