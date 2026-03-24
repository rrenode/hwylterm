import ./rendermodes

type
  Console* = object
    file*: File
    bbMode: BbMode ## \
    ## The rendering mode used
    colorSystem: ColorSystem ## \
    ## The color system used

proc determineEffectiveColorSystem(c: Console): ColorSystem = 
  let clrCapability = checkColorCapability(c.file)
  let clrPolicy = checkColorPolicy()

proc determineEffectiveBbMode(c: Console): BbMode = 
  discard

proc newConsole*(file: File = stdout): Console =
  result.file = file
  result.colorSystem = result.determineEffectiveColorSystem()
  result.bbMode = result.determineEffectiveBbMode()