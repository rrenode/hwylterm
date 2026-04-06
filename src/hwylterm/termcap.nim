##[
  ## rendermodes
  
  Responsible for determining terminal capability and user policy of BBCode and colors in term.

]##

import std/[strutils]

when defined(windows):
  import ./mswindows/termcap

# Rich uses a table, perhaps the same instead of this mess...
const KNOWN_TRUECOLOR_PROGRAM = ["vscode"]

const KNOWN_TRUECOLOR_TERM = ["wezterm", "alacritty", "xtermdirect", "truecolor", "24bit"]
const KNOWN_8BIT_TERM = ["kitty", "256color"]

type
  BbMode* = enum
    Auto # Auto-determined
    Off
    On
    Markup

  ColorSystem* = enum
    Auto # Auto-determines
    None # no color
    Basic # ANSI 4-bit | 8 colors + 8 brights
    EightBit # 8 bit | 256 colors
    TrueColor # 24-bit | truecolor

proc cleanEnvVal(s: string): string =
  s.strip().toLowerAscii().replace("-", "")

proc isDumbTerminal(): bool =
  let term = getEnv("TERM").cleanEnvVal
  if term in ["dumb", "unknown"]:
    return true
  false

proc envHasAnsiHints(): bool =
  if isDumbTerminal():
    return false
  if getEnv("WT_SESSION").len > 0: return true
  if getEnv("ANSICON").len > 0: return true
  if getEnv("ConEmuANSI").toUpperAscii() == "ON": return true

  let termProgram = getEnv("TERM_PROGRAM").cleanEnvVal
  if termProgram in KNOWN_TRUECOLOR_PROGRAM: return true
  return false

proc envHasTrueColorHints(): bool =
  if isDumbTerminal():
    return false
  let colorterm = getEnv("COLORTERM").cleanEnvVal
  if colorterm in KNOWN_TRUECOLOR_TERM:
    return true

  if getEnv("WT_SESSION").len > 0:
    return true

  let term = getEnv("TERM").cleanEnvVal
  if term in KNOWN_TRUECOLOR_TERM:
    return true

  let termProgram = getEnv("TERM_PROGRAM").cleanEnvVal
  if termProgram in KNOWN_TRUECOLOR_PROGRAM:
    return true
  return false

proc checkColorCapability*(file = stdout): ColorSystem =
  ## What the terminal is capable with color.
  ## Uses Win APIs on Windows; uses env vars elsewise.
  if not isatty(file) or isDumbTerminal():
    return csNone
  let term = getEnv("TERM", "").cleanEnvVal
  when defined(windows):
    let feats = getWinConsoleFeatures()
    if feats.truecolor:
      return csTrueColor
    elif feats.vt:
      return csEightBit
    else:
      return csBasic
  else:
    if envHasTrueColorHints():
      return csTrueColor
    elif "256color" in term or term in KNOWN_8BIT_TERM:
      return csEightBit
    elif envHasAnsiHints():
      return csBasic
    else:
      return csNone

proc checkColorPolicy*(): ColorSystem =
  ## What the user wants with color
  if getEnv("NO_COLOR") != "":
    return csNone
  if getEnv("HWYLTERM_NO_COLOR") != "":
    return csNone
  return
    case getEnv("HWYLTERM_FORCE_COLOR").cleanEnvVal
    of "tc", "truecolor": csTrueColor
    of "256", "256color": csEightBit
    of "16", "16color": csBasic
    else: csAuto

proc checkBbCapability*(file = stdout): BbMode =
  ## Basically tries to determine the term's capability with ANSI
  discard

proc checkBbPolicy*(): BbMode =
  ## What the user wants for BbMode
  discard