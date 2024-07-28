Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Load the SetDisplayConfig function from Win32Api
$cscode = @"
    [DllImport("user32.dll")]
    public static extern UInt32 SetDisplayConfig(
        UInt32 numPathArrayElements, 
        IntPtr pathArray, 
        UInt32 numModeInfoArrayElements, 
        IntPtr modeInfoArray, 
        UInt32 flags
    );
"@
$Win32Functions = Add-Type -Name Win32SetDisplayConfig -MemberDefinition $cscode -PassThru

# Bit values used in the argument 'flags'.
$SDC_APPLY = 0x00000080
$SDC_TOPOLOGY_CLONE = 0x00000002
$SDC_TOPOLOGY_EXTEND = 0x00000004
$SDC_TOPOLOGY_INTERNAL = 0x00000001
$SDC_TOPOLOGY_EXTERNAL = 0x00000008

# System error codes
$ERROR_SUCCESS = 0x0
$ERROR_ACCESS_DENIED = 0x5
$ERROR_GEN_FAILURE = 0x1F
$ERROR_NOT_SUPPORTED = 0x32
$ERROR_INVALID_PARAMETER = 0x57
$ERROR_BAD_CONFIGURATION = 0x64A 

function Switch-DisplayMode {
    param(
        [Parameter(Mandatory)]
        [string[]]$DisplayMode
    )

    # Calculate bit values based on arguments
    $action = switch ($DisplayMode) {
        # Set the last clone configuration from the persistence database
        "clone" { $SDC_TOPOLOGY_CLONE }
        # Set the last extend configuration from the persistent database
        "extend" { $SDC_TOPOLOGY_EXTEND }
        # Set the last known display configuration of the currently connected monitor
        default { $SDC_TOPOLOGY_INTERNAL -bor $SDC_TOPOLOGY_CLONE -bor $SDC_TOPOLOGY_EXTEND -bor $SDC_TOPOLOGY_EXTERNAL }
    }

    # Execute the SetDisplayConfig function
    $result = $Win32Functions::SetDisplayConfig(0, [IntPtr]::Zero, 0, [IntPtr]::Zero, $action -bor $SDC_APPLY)

    # Error handling
    $err = switch ($result) {
        $ERROR_SUCCESS { return }
        $ERROR_ACCESS_DENIED { "Unable to access the current desktop or possibly running in a remote session." }
        $ERROR_GEN_FAILURE { "An unspecified error occurred." }
        $ERROR_NOT_SUPPORTED { "The graphics driver that is written according to the Windows Display Driver Model (WDDM) is not running." }
        $ERROR_INVALID_PARAMETER { "The combination of parameters and flags specified is invalid." } 
        $ERROR_BAD_CONFIGURATION { "A workable solution for the source and target modes specified by the caller could not be found." }
        default { "An unknown error occurred. Error code: $result" }
    }
    throw $err
}