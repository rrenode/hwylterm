##[
  ## rendermodes
  
  Responsible for determining terminal capability and user policy of BBCode and colors in term.

]##

type
  BbMode* = enum
    bbAuto # Auto-determined
    bbOff
    bbOn
    bbMarkup

  ColorSystem* = enum
    csAuto # Auto-determines
    csNone # no color
    csBasic # ANSI 4-bit | 8 colors + 8 brights
    csEightBit # 8 bit | 256 colors
    csTrueColor # 24-bit | truecolor

proc checkColorCapability*(file = stdout): ColorSystem =
  ## What the terminal is capable with color.
  ## Uses Win APIs on Windows; uses env vars elsewise.
  discard

proc checkColorPolicy*(): ColorSystem =
  ## What the user wants with color
  discard

proc checkBbCapability*(file = stdout): BbMode =
  ## Basically tries to determine the term's capability with ANSI
  discard

proc checkBbPolicy*(): BbMode =
  ## What the user wants for BbMode
  discard