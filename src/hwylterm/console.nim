import ./rendermodes
import std/[options]

type
  Console = ref object
    file*: File
    bbMode: BbMode ## \
    ## The rendering mode used
    ##colorSystem: ColorSystem ## \
    ## The color system used
    forcedColorSystem: Option[ColorSystem] ## \
    ## This value ignores all other checks except env `NO_COLOR"`

proc determineEffectiveColorSystem(c: Console): ColorSystem = 
  ## Determines the colorsystem for a console in priority of:
  ##    1. env: `NO_COLOR`
  ##    2. env: `HWYLTERM_NO_COLOR`
  ##    3. env: `HWYLTERM_FORCE_COLOR` <- (within term capability)
  ##    4..end based on capability from system APIs and convention envs
  let clrCapability = checkColorCapability(c.file)
  let clrPolicy = checkColorPolicy()

  proc clampPolicyToCapability(cap , pol: ColorSystem): ColorSystem =
    case pol:
    of csBasic:
      if cap in {csBasic, csEightBit, csTrueColor}: return pol
    of csEightBit:
      if cap in {csEightBit, csTrueColor}: return pol
    of csTrueColor:
      if cap == csTrueColor: return pol
    else:
      discard
    return cap
  
  let forcedSys = c.forcedColorSystem
  if forcedSys.isSome() and forcedSys.get() != csAuto: return forcedSys.get()
  case clrPolicy
  of csAuto: return clrCapability
  of csNone: return csNone
  else: return clampPolicyToCapability(clrCapability, clrPolicy)

proc determineEffectiveBbMode(c: Console): BbMode = 
  let bbCapability = checkBbCapability(c.file)
  let checkBbPolicy = checkBbPolicy()

proc newConsole*(file: File = stdout): Console =
  new(result)
  result.file = file
  result.bbMode = result.determineEffectiveBbMode()

proc forceColorSystem*(c: Console, clrSys: ColorSystem) =
  c.forcedColorSystem = some(clrSys)

proc removeForcedSystem*(c: Console) =
  c.forcedColorSystem = none(ColorSystem)

proc bbMode*(c: Console): BbMode =
  c.bbMode

proc colorSystem*(c: Console): ColorSystem =
  c.determineEffectiveColorSystem()