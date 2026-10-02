# pokemon

A Claude Code mod that draws one pixel Pokémon at the right edge of the band
above the prompt. It paces back and forth while Claude works, walks home to the
right edge when the turn ends, and bobs in place there while you're idle.

## Requirements

- Claude Code v2.1.287 or later
- The terminal app. The Desktop app has no `Raster`, so the mod draws nothing there.
- A truecolor terminal (iTerm2, Ghostty, kitty, WezTerm)

## Usage

| Command | Effect |
| --- | --- |
| `/pokemon` | Show which mon and variant are active, and the options |
| `/pokemon abra`, `/pokemon bulbasaur`, `/pokemon charmander` | Pick a mon, saved across sessions |
| `/pokemon shiny`, `/pokemon default` | Pick a variant, saved across sessions |
| Ctrl+X Ctrl+A | Collapse or expand the band (Claude Code's own binding) |

## Mons

| Mon | Pixels | Band rows | Frames (default) |
| --- | --- | --- | --- |
| abra | 19x19 | 10 | 2 idle, 2 walk at 300 ms |
| bulbasaur | 20x17 | 9 | 6 idle, 6 walk at 100 ms |
| charmander | 19x17 | 9 | 2 idle, 2 walk at 300 ms |

## Add a mon

1. Copy the four GIFs from `media/gen<N>/<mon>/` in [jakobhoeg/vscode-pokemon](https://github.com/jakobhoeg/vscode-pokemon/tree/main/media) into `sprites/<mon>/`.
   The files are `default_idle_8fps.gif`, `default_walk_8fps.gif`, `shiny_idle_8fps.gif`, and `shiny_walk_8fps.gif`.
2. Run `node scripts/build-frames.mjs`.
3. Run `/reload-plugins`. The mod loads in place from the repo, so no version bump or reinstall is needed.

## Layout

| Path | Contents |
| --- | --- |
| `hooks/register.js` | Band renderer, animation timer, `/pokemon` command |
| `hooks/frames.js` | Generated pixel frames. Don't edit by hand. |
| `sprites/<mon>/*.gif` | Source GIFs, 32x32 |
| `scripts/build-frames.mjs` | Regenerates `frames.js` from the GIFs with ffmpeg |
| `tests/pokemon.test.ts` | `claude plugin test` suite |

## Development

```bash
node scripts/build-frames.mjs      # after changing sprites/
claude plugin validate .
claude plugin test
claude --plugin-dir .              # live-reloading session
```

Each terminal cell holds two vertical pixels with `▀`/`▄` half blocks. The
sprite paces inside a 40 column strip.

## Credits

Sprites come from [jakobhoeg/vscode-pokemon](https://github.com/jakobhoeg/vscode-pokemon/tree/main/media).
Pokémon sprites are © The Pokémon Company / Nintendo / Game Freak, used here
for a personal, non-commercial fan project.
