# ClawdNotch

<sub>🇫🇷 [Lire en français](README.fr.md)</sub>

<p align="center"><img src="demo.gif" alt="ClawdNotch — halo around the notch" width="720"></p>

[![Release](https://img.shields.io/github/v/release/jherduin/ClawdNotch?include_prereleases&sort=semver)](https://github.com/jherduin/ClawdNotch/releases)
[![License: MIT](https://img.shields.io/github/license/jherduin/ClawdNotch)](LICENSE)
[![Build](https://img.shields.io/github/actions/workflow/status/jherduin/ClawdNotch/build.yml?branch=main&label=build)](https://github.com/jherduin/ClawdNotch/actions/workflows/build.yml)
[![macOS](https://img.shields.io/badge/macOS-14%2B-black?logo=apple)](https://www.apple.com/macos/)

**ClawdNotch is a tiny macOS app that paints an ambient halo around your MacBook's notch to mirror what Claude Code is doing right now.**
No window, no Dock icon — just a discreet glow that tells you, at a glance, whether the agent is working, waiting on you, or idle.

| State | Value in `~/.claude/notch_status` | Visual |
|---|---|---|
| **Working** | `working` | animated orange halo |
| **Waiting for you** | `waiting` | gentle blue pulse |
| **Idle** | `idle` | invisible |

> On a Mac without a notch, the app stays in memory and simply draws nothing — no crash, no clutter.

---

## Install

### Homebrew

```sh
brew install --cask jherduin/tap/clawdnotch
```

> ClawdNotch isn't notarized, so on first launch macOS Gatekeeper may block it. Right-click the app
> → **Open** → **Open**, or run `xattr -dr com.apple.quarantine "/Applications/ClawdNotch.app"`.

### Manual download

1. Grab the latest `ClawdNotch.dmg` from the [Releases](https://github.com/jherduin/ClawdNotch/releases) page.
2. Open the `.dmg` and drag **ClawdNotch** into `/Applications`.
3. On first launch, macOS may block the app (the build isn't signed with a Developer ID):
   right-click the app → **Open** → **Open** to confirm.

## Launch

The app runs in the background with no window and no Dock icon. Launch it with:

```sh
open -a ClawdNotch
```

To start it automatically at login, add it under
**System Settings → General → Login Items → Open at Login**.

> Nothing visible? That's expected when Claude Code is idle. Trigger some activity, or write a test
> value directly: `echo working > ~/.claude/notch_status` should light up the orange halo.

## Stop

Because the app has no Dock icon or menu bar item, quit it from the terminal:

```sh
killall ClawdNotch
```

(Or use **Activity Monitor**, search for `ClawdNotch`, and quit the process.) If you added it to Login
Items, remove it there too so it doesn't come back at next login.

## Uninstall

```sh
killall ClawdNotch                 # stop the app
rm -rf /Applications/ClawdNotch.app # remove the app
rm -f ~/.claude/notch_status        # remove the status file (optional)
```

Then delete the ClawdNotch entry from **System Settings → General → Login Items**, and remove the
ClawdNotch hooks you added to `~/.claude/settings.json` (see below).

---

## Hooks setup

ClawdNotch is **passive**: it reads `~/.claude/notch_status` and renders the matching halo.
The **Claude Code hooks** are what keep that file up to date in real time.

The easiest way to set them up: open Claude Code (in any project) and paste the prompt below. It edits
`~/.claude/settings.json` for you and **merges** with any hooks you already have instead of
overwriting them:

```text
Set up the ClawdNotch hooks in my ~/.claude/settings.json so that ~/.claude/notch_status reflects
what you're doing in real time. Edit the JSON in place, keep it valid, and APPEND to any existing
hook arrays — do not remove or overwrite my other hooks or settings.

Add these four hooks, each running a single shell command:
- UserPromptSubmit       → echo working > "$HOME/.claude/notch_status"
- PreToolUse (matcher "") → echo working > "$HOME/.claude/notch_status"
- Stop                   → echo waiting > "$HOME/.claude/notch_status"
- SessionEnd             → echo idle > "$HOME/.claude/notch_status"

If a hook pointing at notch_status already exists, leave it as-is rather than duplicating it.
When you're done, show me the resulting "hooks" block.
```

The halo stays orange for the whole turn (even across multiple tool calls), turns blue when Claude
hands control back to you, and disappears when the session ends.

> Prefer to wire it up by hand? The full JSON block, coexistence notes, and verification steps live in
> **[docs/hooks.md](docs/hooks.md)**.

---

## Contributing

Contributions are welcome — see **[CONTRIBUTING.md](CONTRIBUTING.md)** for commit conventions, the
branching model, and the PR process. This project follows a [Code of Conduct](CODE_OF_CONDUCT.md).

## License

[MIT](LICENSE) — © 2026 jherduin.
