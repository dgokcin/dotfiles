# abra

A Claude Code mod that draws a pixel Abra at the right edge of the band above
the prompt. It bobs in place while you're idle and paces back and forth while
Claude works.

## Requirements

- Claude Code v2.1.287 or later
- The terminal app. The Desktop app has no `Raster`, so the mod draws nothing there.
- A truecolor terminal (iTerm2, Ghostty, kitty, WezTerm)

## Usage

| Command | Effect |
| --- | --- |
| `/abra` | Toggle between default and shiny, saved across sessions |
| `/abra shiny`, `/abra default` | Pick a variant |
| Ctrl+X Ctrl+A | Collapse or expand the band (Claude Code's own binding) |

## Layout

| Path | Contents |
| --- | --- |
| `hooks/register.js` | Band renderer, animation timer, `/abra` command |
| `hooks/frames.js` | Generated pixel frames. Don't edit by hand. |
| `sprites/*.gif` | Source GIFs, 32x32 at 2 frames each |
| `scripts/build-frames.mjs` | Regenerates `frames.js` from the GIFs with ffmpeg |
| `tests/abra.test.ts` | `claude plugin test` suite |

## Development

```bash
node scripts/build-frames.mjs      # after changing sprites/
claude plugin validate .
claude plugin test
claude --plugin-dir .              # live-reloading session
```

The sprite is 19x19 pixels. Each terminal cell holds two vertical pixels with
`▀`/`▄` half blocks, so Abra takes 19 columns by 10 rows inside a 40 column strip.

## Credits

Sprites come from [jakobhoeg/vscode-pokemon](https://github.com/jakobhoeg/vscode-pokemon/tree/main/media/gen1/abra).
Pokémon sprites are © The Pokémon Company / Nintendo / Game Freak, used here
for a personal, non-commercial fan project.
