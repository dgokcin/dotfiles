import { SPRITES } from './frames.js'

// One pixel Pokémon lives at the right edge of the band above the prompt. It
// bobs in place while you're idle and paces back and forth while Claude works.

const TICK_MS = 50
const MOVE_TICKS = 3
const STRIP_COLUMNS = 40
const DEFAULT_COLOR = 0x01000000
const UPPER_HALF = 0x2580
const LOWER_HALF = 0x2584
const SPACE = 0x20
const MONS = Object.keys(SPRITES)
const VARIANTS = ['default', 'shiny']

let mon = MONS.includes('abra') ? 'abra' : MONS[0]
let variant = 'default'
let working = false
let bandId = null
let columns = STRIP_COLUMNS
let tick = 0
let x = STRIP_COLUMNS
let facing = 'left'

// Palette letter to 0xRRGGBB, per mon and variant
const COLORS = Object.fromEntries(
  MONS.map((name) => [
    name,
    Object.fromEntries(
      VARIANTS.map((v) => [
        v,
        Object.fromEntries(
          SPRITES[name].variants[v].palette.map((hex, i) => [String.fromCharCode(97 + i), parseInt(hex.slice(1), 16)]),
        ),
      ]),
    ),
  ]),
)

const rowsOf = (name) => Math.ceil(SPRITES[name].height / 2)

// The frame showing after elapsed milliseconds, looping over each frame's own duration
function frameAt(anim, elapsed) {
  const total = anim.reduce((sum, f) => sum + f.ms, 0)
  let t = elapsed % total
  for (const f of anim) {
    if (t < f.ms) return f.rows
    t -= f.ms
  }
  return anim[0].rows
}

// Pack the current frame into Raster cells, two pixels per cell with half blocks
function cellsNow() {
  const sprite = SPRITES[mon]
  const sheet = sprite.variants[variant]
  const frame = frameAt(working ? sheet.walk : sheet.idle, tick * TICK_MS)
  const colors = COLORS[mon][variant]
  const flip = working && facing === 'left'
  const pixel = (px, py) => {
    if (px < 0 || px >= sprite.width) return null
    const row = frame[py]
    if (!row) return null
    return colors[row[flip ? sprite.width - 1 - px : px]] ?? null
  }

  const rows = rowsOf(mon)
  const words = new Uint32Array(columns * rows * 3)
  for (let cy = 0; cy < rows; cy++) {
    for (let cx = 0; cx < columns; cx++) {
      const top = pixel(cx - x, cy * 2)
      const bottom = pixel(cx - x, cy * 2 + 1)
      const i = (cy * columns + cx) * 3
      if (top !== null) words.set([UPPER_HALF, top, bottom ?? DEFAULT_COLOR], i)
      else if (bottom !== null) words.set([LOWER_HALF, bottom, DEFAULT_COLOR], i)
      else words.set([SPACE, DEFAULT_COLOR, DEFAULT_COLOR], i)
    }
  }
  return new Uint8Array(words.buffer).toBase64()
}

// Keep the sprite inside the strip
function clampX() {
  x = Math.max(0, Math.min(columns - SPRITES[mon].width, x))
}

// Advance the clock, and while working move one column every few ticks, turning at the edges
function step() {
  tick += 1
  if (!working || tick % MOVE_TICKS !== 0) return
  const maxX = columns - SPRITES[mon].width
  if (facing === 'left' && x <= 0) facing = 'right'
  else if (facing === 'right' && x >= maxX) facing = 'left'
  x += facing === 'left' ? -1 : 1
  clampX()
}

export function register(on) {
  on('session.start', async ($, e, next) => {
    await $.command.register({
      name: 'pokemon',
      description: 'Pick the Pokémon above the prompt, or switch it to shiny',
      argumentHint: '[' + [...MONS, ...VARIANTS].join('|') + ']',
      immediate: true,
    })
    const savedMon = await $.store.get('mon')
    if (MONS.includes(savedMon)) mon = savedMon
    const savedVariant = await $.store.get('variant')
    if (VARIANTS.includes(savedVariant)) variant = savedVariant
    $.clock.every(TICK_MS, () => {
      step()
      if (bandId !== null) {
        $.ui.blit({ requestId: bandId, key: 'pokemon', columns, rows: rowsOf(mon), cells: cellsNow() })
      }
    })
    return next(e)
  })

  on('command.run', { command: 'pokemon' }, async ($, e) => {
    const asked = e.args.trim().toLowerCase()
    if (MONS.includes(asked)) {
      mon = asked
      clampX()
      await $.store.set('mon', mon)
    } else if (VARIANTS.includes(asked)) {
      variant = asked
      await $.store.set('variant', variant)
    } else if (asked) {
      return { text: 'Unknown option "' + asked + '". Try one of: ' + [...MONS, ...VARIANTS].join(', ') + '.' }
    } else {
      return { text: 'Showing ' + variant + ' ' + mon + '. Options: ' + [...MONS, ...VARIANTS].join(', ') + '.' }
    }
    $.ui.invalidate('ui.render')
    return { text: 'Now showing ' + variant + ' ' + mon + '.' }
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    if (e.surface !== 'terminal' || e.props.hasSurvey) {
      bandId = null
      return next(e)
    }
    const { Box, Raster } = $.ui.resolve(e)
    working = e.props.isWorking
    bandId = e.requestId
    columns = Math.max(SPRITES[mon].width, Math.min(STRIP_COLUMNS, e.props.bodyColumns))
    clampX()

    const sprite = Raster({ key: 'pokemon', columns, rows: rowsOf(mon), cells: cellsNow() })
    const theirs = await next(e)
    return Box({
      flexDirection: 'row',
      justifyContent: theirs ? 'space-between' : 'flex-end',
      children: theirs ? [Box({ flexGrow: 1, children: [theirs] }), sprite] : [sprite],
    })
  })
}
