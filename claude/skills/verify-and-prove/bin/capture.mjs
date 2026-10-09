import { chromium } from 'playwright'
import { mkdir, rename } from 'node:fs/promises'
import { join } from 'node:path'

const USAGE = `usage: node capture.mjs --out <dir> [--video <name>] [--size 1280x800] [--allow-host <host>] <steps...>

steps (each verb takes a fixed number of arguments):
  goto <url>              file://, localhost or 127.0.0.1 unless --allow-host names the host
  click <selector>
  fill <selector> <text>
  press <key>             e.g. Enter, Escape
  hover <selector>
  wait <ms|selector>
  shot <name>             saves <out>/<name>.png
  fullshot <name>         saves the whole scrolling page`

const ARITY = { goto: 1, click: 1, fill: 2, press: 1, hover: 1, wait: 1, shot: 1, fullshot: 1 }
const LOCAL_HOSTS = new Set(['localhost', '127.0.0.1'])

function fail(message) {
  console.error(`${message}\n\n${USAGE}`)
  process.exit(2)
}

function parseArgs(argv) {
  const options = { out: undefined, video: undefined, width: 1280, height: 800, allowedHosts: new Set(LOCAL_HOSTS) }
  const steps = []
  for (let i = 0; i < argv.length; i++) {
    const arg = argv[i]
    if (arg === '--out') options.out = argv[++i]
    else if (arg === '--video') options.video = argv[++i]
    else if (arg === '--allow-host') options.allowedHosts.add(argv[++i])
    else if (arg === '--size') [options.width, options.height] = argv[++i].split('x').map(Number)
    else if (arg in ARITY) {
      const args = argv.slice(i + 1, i + 1 + ARITY[arg])
      if (args.length < ARITY[arg]) fail(`${arg} needs ${ARITY[arg]} argument(s)`)
      steps.push({ verb: arg, args })
      i += ARITY[arg]
    } else fail(`unknown argument: ${arg}`)
  }
  if (!options.out) fail('--out is required')
  if (steps.length === 0) fail('no steps given')
  return { options, steps }
}

function checkUrl(raw, allowedHosts) {
  const url = new URL(raw)
  if (url.protocol === 'file:') return url.href
  if (!['http:', 'https:'].includes(url.protocol)) fail(`unsupported protocol: ${url.protocol}`)
  if (!allowedHosts.has(url.hostname)) fail(`${url.hostname} isn't local; pass --allow-host ${url.hostname} if you mean it`)
  return url.href
}

async function run(page, { verb, args }, options) {
  const [first, second] = args
  switch (verb) {
    case 'goto':
      return page.goto(checkUrl(first, options.allowedHosts), { waitUntil: 'networkidle' })
    case 'click':
      return page.click(first)
    case 'fill':
      return page.fill(first, second)
    case 'press':
      return page.keyboard.press(first)
    case 'hover':
      return page.hover(first)
    case 'wait':
      return /^\d+$/.test(first) ? page.waitForTimeout(Number(first)) : page.waitForSelector(first)
    case 'shot':
    case 'fullshot': {
      const path = join(options.out, `${first}.png`)
      await page.screenshot({ path, fullPage: verb === 'fullshot' })
      return console.log(path)
    }
  }
}

const { options, steps } = parseArgs(process.argv.slice(2))
await mkdir(options.out, { recursive: true })

const viewport = { width: options.width, height: options.height }
const browser = await chromium.launch()
const context = await browser.newContext({
  viewport,
  deviceScaleFactor: 2,
  recordVideo: options.video ? { dir: options.out, size: viewport } : undefined,
})
const page = await context.newPage()

let failed = false
try {
  for (const step of steps) await run(page, step, options)
} catch (error) {
  failed = true
  console.error(`step failed: ${error.message}`)
  await page.screenshot({ path: join(options.out, 'failure.png') }).catch(() => {})
} finally {
  const video = page.video()
  await context.close()
  await browser.close()
  if (video) {
    const path = join(options.out, `${options.video}.webm`)
    await rename(await video.path(), path)
    console.log(path)
  }
}
process.exit(failed ? 1 : 0)
