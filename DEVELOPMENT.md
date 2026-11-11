# Working on Omarchy

Each folder under `mods/` is a self-contained Herdr mod, with its own copy of every icon it draws: nothing refers to Herdr's shipped mods, which are replaced at every start. `main.js` is its entry point. Keep helper imports within that folder so the mod can be installed independently. Herdr runs the UI with `gpui-kit`, `gpui-base`, and `herdr`; Node APIs are available only in tests.

## Where to make changes

| Change | File |
| --- | --- |
| Layout, tile sizes, spacing | `layouts/omarchy.json` |
| Theme colors | `themes/*.json` |
| Theme wallpapers | `backgrounds/omarchy/<theme>/` |
| Wallpaper follows theme, next-wallpaper key | `mods/omarchy-bar/main.js` |
| Theme picker | `mods/omarchy-themes/main.js` |
| Commit graph table, header, Manygit list | `mods/omarchy-changes/graph/graph.js` |
| Git commands, parsing, menus, dialogs | `mods/omarchy-changes/graph/git.js` |
| Settings state, persistence, machine actions | `mods/omarchy-settings/main.js` |
| Layout, theme, appearance, font pickers | `mods/omarchy-settings/look.js` |
| Settings buttons, rows, toggles, steppers | `mods/omarchy-settings/controls.js` |
| Usage endpoints, credentials, agent/provider routing | `mods/omarchy-ai-usage/providers.js` |
| Usage countdowns and quota-window timing | `mods/omarchy-ai-usage/time.js` |
| Usage display, refresh scheduling, cached results | `mods/omarchy-ai-usage/main.js` |
| Mod installation, updates, removal | `mods/omarchy-mod-manager/core.js` |
| Mod Manager text contrast and colors | `mods/omarchy-mod-manager/palette.js` |
| Mod Manager navigation and display | `mods/omarchy-mod-manager/main.js` |
| Changes view: diff, wrap, split, branches, commit | `mods/omarchy-changes/main.js` |
| Reopen closed tab: snapshot and reopen key | `mods/omarchy-tabs/main.js` |
| Reopen: agent resume commands | `mods/omarchy-tabs/reopen.js` |
| Reopen: process scan, exact pane tree restore | `mods/omarchy-tabs/reopen.py` |
| Keybindings list | `mods/omarchy-keys/main.js` |
| Browser toolbar: reload on save, DevTools, Chrome window | `mods/omarchy-pane/main.js` |
| Browser helper changes (outside this repo) | `patches/herdr-browser.patch` |
| Applying the helper patch | `patches/apply-herdr-browser.sh` |
| Notifications (layout root `toast`) | `mods/omarchy-toast/main.js` |
| Terminal right-click menu (layout root `terminal_menu`), space and tab menus | `mods/omarchy-menu/main.js` |
| Go-to picker (search button, palette) | `mods/omarchy-picker/main.js` |
| Add a machine dialog | `mods/omarchy-machine-add/main.js` |
| Theme switcher and its previews | `mods/omarchy-themes/main.js`, `mods/omarchy-themes/previews/` |

## Check changes

From the repo root, run `npm test`. Tests use Node's built-in runner with no installation step. Provider tests use fake login files and HTTP responses.

From the repo root, check each changed mod, for example:

```sh
herdr-app check mods/omarchy-settings
herdr-app check mods/omarchy-ai-usage
herdr-app check mods/omarchy-mod-manager
```

`check` loads the entry point, helper imports, and initial UI. It does not exercise later clicks or asynchronous states. When changing UI behavior, also exercise the affected picker, panel, or dialog in Herdr. Repo edits and installed copies under `~/.config/herdr-app` are separate unless explicitly linked.

## Browser helper patch

Herdr's browser lives in `~/.local/share/herdr-browser`, and a Herdr update replaces it. `patches/herdr-browser.patch` holds the changes this layout makes to it:

- `helper.mjs`: Chrome also opens a local debugging port, and each page's state carries its DevTools address (`inspect`) and its count of console errors since the last navigation (`errors`). The pane toolbar reads both.
- `view.mjs`: wheel ticks that arrive within 16 ms go to the page as one scroll, and frames are capped at 30 a second instead of 20.

Run the script after installing the layout and again after every Herdr update:

```sh
sh patches/apply-herdr-browser.sh
```

It applies the patch only when it is not applied yet and says so when it is. When the helper has changed so much that the patch no longer fits, it changes nothing, prints one line and exits with 1. After applying, it restarts the helper if it is running (`herdr-browser` needs `node` on PATH; without it the script says so and skips the restart). Give it a folder to patch a copy instead of the live helper: `sh patches/apply-herdr-browser.sh /tmp/helper-copy`. With a folder it never restarts the helper.

The debugging port listens on 127.0.0.1 only and Chrome refuses connections from web pages, but any program on the machine can drive that browser through it.

Herdr's terminal draws only inline kitty images: frames sent as a file or through shared memory (`t=f`, `t=t`, `t=s`) are not drawn, so the page stream cannot skip the terminal.
