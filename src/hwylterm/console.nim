## We have three layers of color mode:
##  - capability (what terminal supports)
##  - policy (what the user wants)
##  - effective (what's actually rendered)

type
  ColorSystem* = enum
    csNone      # no color
    csAuto      # Auto-determines
    csAnsi16    # 30–37 / 90–97
    csAnsi256   # 38;5;n
    csTrueColor # 38;2;r;g;

  Console* = object
    colorSystem*: ColorSystem ## \
    ## Effective system used by the console
    