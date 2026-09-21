# Raycast

The app itself comes from `Brewfile` (`cask "raycast"`). This directory holds
the parts of Raycast's configuration that a git repo can actually own.

## What `make raycast` does

| Piece | Where it lands |
| --- | --- |
| `scripts/` | Symlinked to `~/.raycast-scripts` |
| `defaults.sh` | `defaults write com.raycast.macos ...` |

## What it cannot do

Raycast stores aliases, hotkeys per command, quicklinks, snippets, extension
settings, and AI presets in an encrypted sqlite database at
`~/Library/Application Support/com.raycast.macos/raycast-enc.sqlite`. The file
is opaque, rewritten constantly, and useless in version control.

Move that state between Macs one of two ways.

1. **Cloud Sync** (Raycast Settings > Advanced > Cloud Sync). Sign in on the new
   machine and the database restores itself. This is the practical route.
2. **`.rayconfig` export** (Settings > Advanced > Export). Produces an encrypted
   archive you import on the new Mac. Fine as a backup, but do not commit it
   here, since it is opaque and holds credentials.

## Fresh-Mac steps after `make raycast`

1. Launch Raycast, sign in, let Cloud Sync restore.
2. Open Settings > Extensions, press `+`, choose **Add Script Directory**, and
   pick `~/.raycast-scripts`. Raycast keeps that path in its database, so this
   click cannot be scripted.
3. Quit Raycast and run `make raycast-defaults` if it was running during setup.

## Adding a script command

Drop an executable script in `scripts/` with a Raycast metadata header. See
`scripts/dotfiles-update.sh` for the shape. Raycast picks up new files in the
registered directory without a restart.
