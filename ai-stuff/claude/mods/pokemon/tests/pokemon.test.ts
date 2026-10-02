import { expect, mock, test } from 'claude-code/testing'

const BAND = {
  plugin: 'pokemon',
  component: 'AbovePrompt',
  requestId: 'band',
  viewport: { columns: 120, rows: 40 },
  props: {
    hasSurvey: false,
    isWorking: false,
    maxRows: 20,
    bodyColumns: 120,
    scroll: { offset: 0, bodyRows: 20 },
    view: {},
  },
} as const

const THEIRS = { type: 'Text', props: {}, children: ['drawn by Claude Code'] }

function codePoints(cells: string): number[] {
  const words = new Uint32Array(Uint8Array.fromBase64(cells).buffer)
  return Array.from(words).filter((_, i) => i % 3 === 0)
}

test('draws Abra by default as a half-block raster in the terminal band', async ($, on) => {
  on('ui.render', () => THEIRS)
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  const raster = await ui.find({ key: 'pokemon' })
  expect(raster).toBeDefined()
  expect(raster.props.columns).toBe(40)
  expect(raster.props.rows).toBe(10)
  expect(codePoints(raster.props.cells)).toContain(0x2580)
})

test('leaves the band alone on desktop and during a survey', async ($, on) => {
  on('ui.render', () => THEIRS)
  const desktop = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await desktop.find({ key: 'pokemon' })).toBeUndefined()
  await desktop.unmount()
  const survey = await $.ui.mount({ ...BAND, surface: 'terminal', props: { ...BAND.props, hasSurvey: true } })
  expect(await survey.find({ key: 'pokemon' })).toBeUndefined()
})

test('paces while Claude works', async ($, on) => {
  const clock = mock.clock(on)
  const blits: string[] = []
  on('ui.render', () => THEIRS)
  on('ui.blit', ($, e) => {
    blits.push(e.cells)
    return { value: {} }
  })
  on('session.start', () => ({ cwd: '/work' }))
  on('command.register', () => ({ value: undefined }))
  on('store.get', () => ({ value: undefined }))

  await $.session.start({ surface: 'terminal', isInteractive: true, cwd: '/work' })
  await $.ui.mount({ ...BAND, surface: 'terminal', props: { ...BAND.props, isWorking: true } })
  await clock.advance(50 * 30)
  expect(blits.length).toBe(30)
  expect(new Set(blits).size).toBeGreaterThan(5)
})

test('/pokemon switches the mon and the variant, and saves both', async ($, on) => {
  const saved = new Map<string, unknown>()
  on('ui.render', () => THEIRS)
  on('store.set', ($, e) => {
    saved.set(e.key, e.value)
    return { value: undefined }
  })

  const mon = await $.command.run({ command: 'pokemon', args: 'bulbasaur' })
  expect(mon.text).toBe('Now showing default bulbasaur.')
  const shiny = await $.command.run({ command: 'pokemon', args: 'shiny' })
  expect(shiny.text).toBe('Now showing shiny bulbasaur.')
  expect(saved.get('mon')).toBe('bulbasaur')
  expect(saved.get('variant')).toBe('shiny')

  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect((await ui.find({ key: 'pokemon' })).props.rows).toBe(9)
})

test('/pokemon rejects an unknown name', async ($) => {
  const answer = await $.command.run({ command: 'pokemon', args: 'mewtwo' })
  expect(answer.text).toMatch(/^Unknown option "mewtwo"/)
})

test('/pokemon charmander draws Charmander', async ($, on) => {
  on('ui.render', () => THEIRS)
  on('store.set', () => ({ value: undefined }))
  const answer = await $.command.run({ command: 'pokemon', args: 'charmander' })
  expect(answer.text).toBe('Now showing default charmander.')
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  expect((await ui.find({ key: 'pokemon' })).props.rows).toBe(9)
})

// The rightmost column that holds part of the sprite
function rightEdge(cells: string, columns: number): number {
  const points = codePoints(cells)
  let edge = -1
  points.forEach((cp, i) => {
    if (cp !== 0x20) edge = Math.max(edge, i % columns)
  })
  return edge
}

test('walks back to the right edge after a turn and idles there', async ($, on) => {
  const clock = mock.clock(on)
  const blits: string[] = []
  on('ui.render', () => THEIRS)
  on('ui.blit', ($, e) => {
    blits.push(e.cells)
    return { value: {} }
  })
  on('session.start', () => ({ cwd: '/work' }))
  on('command.register', () => ({ value: undefined }))
  on('store.get', () => ({ value: undefined }))
  await $.session.start({ surface: 'terminal', isInteractive: true, cwd: '/work' })

  const idle = await $.ui.mount({ ...BAND, surface: 'terminal' })
  const home = rightEdge((await idle.find({ key: 'pokemon' })).props.cells, 40)
  await idle.unmount()

  const busy = await $.ui.mount({ ...BAND, surface: 'terminal', props: { ...BAND.props, isWorking: true } })
  await clock.advance(150 * 10)
  expect(rightEdge(blits[blits.length - 1], 40)).toBeLessThan(home)
  await busy.unmount()

  await $.ui.mount({ ...BAND, surface: 'terminal' })
  await clock.advance(150 * 40)
  expect(rightEdge(blits[blits.length - 1], 40)).toBe(home)
})
