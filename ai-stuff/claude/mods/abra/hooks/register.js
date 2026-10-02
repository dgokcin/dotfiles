import { SPRITE } from './frames.js'

// Abra lives at the right edge of the band above the prompt. It bobs in place
// while you're idle and paces back and forth while Claude works.

const TICK_MS = 150
const FRAME_TICKS = 2
const STRIP_COLUMNS = 40
const DEFAULT_COLOR = 0x01000000
const UPPER_HALF = 0x2580
const LOWER_HALF = 0x2584
const SPACE = 0x20

let variant = 'default'
let working = false
let bandId = null
let columns = STRIP_COLUMNS
let tick = 0
let x = STRIP_COLUMNS - SPRITE.width
let facing = 'left'

const rows = Math.ceil(SPRITE.height / 2)

// Palette letter to 0xRRGGBB, per variant
const COLORS = Object.fromEntries(
  Object.entries(SPRITE.variants).map(([name, sheet]) => [
    name,
    Object.fromEntries(sheet.palette.map((hex, i) => [String.fromCharCode(97 + i), parseInt(hex.slice(1), 16)])),
  ]),
)

// Look up a pixel's color in a frame, or null where it's transparent
function pixelsOf(frame, colors, flip) {
  return (px, py) => {
    const row = frame[py]
    if (!row) return null
    return colors[row[flip ? SPRITE.width - 1 - px : px]] ?? null
  }
}

// Pack the current frame into Raster cells, two pixels per cell with half blocks
function cellsNow() {
  const sheet = SPRITE.variants[variant]
  const anim = working ? sheet.walk : sheet.idle
  const frame = anim[Math.floor(tick / FRAME_TICKS) % anim.length]
  const pixel = pixelsOf(frame, COLORS[variant], working && facing === 'left')
  const words = new Uint32Array(columns * rows * 3)
  for (let cy = 0; cy < rows; cy++) {
    for (let cx = 0; cx < columns; cx++) {
      const px = cx - x
      const top = px >= 0 && px < SPRITE.width ? pixel(px, cy * 2) : null
      const bottom = px >= 0 && px < SPRITE.width ? pixel(px, cy * 2 + 1) : null
      const i = (cy * columns + cx) * 3
      if (top !== null) words.set([UPPER_HALF, top, bottom ?? DEFAULT_COLOR], i)
      else if (bottom !== null) words.set([LOWER_HALF, bottom, DEFAULT_COLOR], i)
      else words.set([SPACE, DEFAULT_COLOR, DEFAULT_COLOR], i)
    }
  }
  return new Uint8Array(words.buffer).toBase64()
}

// Move one column per tick while working, turning at the strip's edges
function step() {
  tick += 1
  if (!working) return
  const maxX = columns - SPRITE.width
  if (facing === 'left' && x <= 0) facing = 'right'
  else if (facing === 'right' && x >= maxX) facing = 'left'
  x = Math.max(0, Math.min(maxX, x + (facing === 'left' ? -1 : 1)))
}

export function register(on) {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'abra',
      description: 'Switch Abra between default and shiny',
      argumentHint: '[default|shiny]',
      immediate: true,
    })
    const saved = await $.store.get('variant')
    if (saved in SPRITE.variants) variant = saved
    $.clock.every(TICK_MS, () => {
      step()
      if (bandId !== null) $.ui.blit({ requestId: bandId, key: 'abra', columns, rows, cells: cellsNow() })
    })
    return next(e)
  })

  on('command.run', { command: 'abra' }, async ($, e) => {
    const asked = e.args.trim()
    variant = asked in SPRITE.variants ? asked : variant === 'shiny' ? 'default' : 'shiny'
    await $.store.set('variant', variant)
    $.ui.invalidate('ui.render')
    return { text: 'Abra is now ' + variant + '.' }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.surface !== 'terminal' || e.props.hasSurvey) {
      bandId = null
      return next(e)
    }
    const { Box, Raster } = $.ui.resolve(e)
    working = e.props.isWorking
    bandId = e.requestId
    columns = Math.max(SPRITE.width, Math.min(STRIP_COLUMNS, e.props.bodyColumns))
    x = Math.max(0, Math.min(columns - SPRITE.width, x))

    const abra = Raster({ key: 'abra', columns, rows, cells: cellsNow() })
    const theirs = await next(e)
    return Box({
      flexDirection: 'row',
      justifyContent: theirs ? 'space-between' : 'flex-end',
      children: theirs ? [Box({ flexGrow: 1, children: [theirs] }), abra] : [abra],
    })
  })
}
