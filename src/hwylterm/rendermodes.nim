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