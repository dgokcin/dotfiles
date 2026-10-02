import { expect, mock, test } from 'claude-code/testing'

const BAND = {
  plugin: 'abra',
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

test('draws Abra as a half-block raster in the terminal band', async ($, on) => {
  on('ui.render', () => THEIRS)
  const ui = await $.ui.mount({ ...BAND, surface: 'terminal' })
  const raster = await ui.find({ key: 'abra' })
  expect(raster).toBeDefined()
  expect(raster.props.columns).toBe(40)
  expect(raster.props.rows).toBe(10)
  expect(codePoints(raster.props.cells)).toContain(0x2580)
})

test('leaves the band alone on desktop and during a survey', async ($, on) => {
  on('ui.render', () => THEIRS)
  const desktop = await $.ui.mount({ ...BAND, surface: 'desktop' })
  expect(await desktop.find({ key: 'abra' })).toBeUndefined()
  await desktop.unmount()
  const survey = await $.ui.mount({ ...BAND, surface: 'terminal', props: { ...BAND.props, hasSurvey: true } })
  expect(await survey.find({ key: 'abra' })).toBeUndefined()
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
  await clock.advance(150 * 6)
  expect(blits.length).toBe(6)
  expect(new Set(blits).size).toBe(6)
})

test('/abra toggles shiny and saves it', async ($, on) => {
  const saved = new Map<string, unknown>()
  on('store.set', ($, e) => {
    saved.set(e.key, e.value)
    return { value: undefined }
  })
  const first = await $.command.run({ command: 'abra', args: '' })
  expect(first.text).toBe('Abra is now shiny.')
  const second = await $.command.run({ command: 'abra', args: 'default' })
  expect(second.text).toBe('Abra is now default.')
  expect(saved.get('variant')).toBe('default')
})
