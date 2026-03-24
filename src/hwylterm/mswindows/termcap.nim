import std/winlean

type
  USHORT = uint16
  WCHAR = distinct int16
  UCHAR = uint8
  NTSTATUS = int32

  OSVersionInfoExW {.importc: "OSVERSIONINFOEXW", header: "<windows.h>".} = object
    dwOSVersionInfoSize: ULONG
    dwMajorVersion: ULONG
    dwMinorVersion: ULONG
    dwBuildNumber: ULONG
    dwPlatformId: ULONG
    szCSDVersion: array[128, WCHAR]
    wServicePackMajor: USHORT
    wServicePackMinor: USHORT
    wSuiteMask: USHORT
    wProductType: UCHAR
    wReserved: UCHAR
  
  OSVersion = object
    major: int
    minor: int
    build: int

proc rtlGetVersion(lpVersionInformation: var OSVersionInfoExW): NTSTATUS
  {.cdecl, importc: "RtlGetVersion", dynlib: "ntdll.dll".}

proc getConsoleMode(hConsoleHandle: HANDLE, lpMode: ptr DWORD): WINBOOL
  {.importc: "GetConsoleMode", stdcall, dynlib: "kernel32".}

const MIN_VTSUPPORT_VER = OSVersion(major:10, minor:0, build:15063)

const
  ENABLE_PROCESSED_OUTPUT = 0x0001
  ENABLE_WRAP_AT_EOL_OUTPUT = 0x0002
  ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004
  DISABLE_NEWLINE_AUTO_RETURN = 0x0008
  ENABLE_LVB_GRID_WORLDWIDE = 0x0010

proc cmp(a, b: OSVersion): int =
  system.cmp((a.major, a.minor, a.build),
             (b.major, b.minor, b.build))

proc `<`(a, b: OSVersion): bool = cmp(a, b) < 0
proc `>`(a, b: OSVersion): bool = cmp(a, b) > 0
proc `<=`(a, b: OSVersion): bool = cmp(a, b) <= 0
proc `>=`(a, b: OSVersion): bool = cmp(a, b) >= 0
proc `==`(a, b: OSVersion): bool = cmp(a, b) == 0

proc getVer(): OSVersion =
  ## Uses Window's ntdll to get 'major.minor.build' version
  var versionInfo: OSVersionInfoExW
  versionInfo.dwOSVersionInfoSize = sizeof(versionInfo).ULONG
  if rtlGetVersion(versionInfo) != 0:
    # API mismatch so... assume old win version?
    raise newException(OSError, "Unable to determine version using ntdll.dll")
  return OSVersion(
    major:versionInfo.dwMajorVersion,
    minor:versionInfo.dwMinorVersion,
    build:versionInfo.dwBuildNumber
  )

type
  WindowsConsoleFeatures* = object
    vt*: bool = false
    truecolor*: bool = false

proc queryConsoleMode(): int =
  let hOut = getStdHandle(STD_OUTPUT_HANDLE)
  if hOut == INVALID_HANDLE_VALUE or hOut == 0:
    raise newException(OSError, "Unable to get stdout handle")
  var dwOutMode: DWORD = 0
  if getConsoleMode(hOut, addr dwOutMode) == 0:
    raise newException(OSError, "Unable to query console mode")
  result = int(dwOutMode)

proc getWinConsoleFeatures*(): WindowsConsoleFeatures =
  ## Best determines Windows OS console features using some Win API procedures.
  ## Mirrors textualize.Rich's logic.
  var consoleMode = 0
  var success = false

  try:
    consoleMode = queryConsoleMode()
    success = true
  except OSError:
    # Based off textualize.Rich's logic, but the query can fail on new systems as well.
    # Consider this just a fallback until more is learned...
    success = false

  result.vt = success and ((consoleMode and ENABLE_VIRTUAL_TERMINAL_PROCESSING.int) != 0)
  result.truecolor = false
  if result.vt:
    result.truecolor = getVer() >= MIN_VTSUPPORT_VER