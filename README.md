# Switch-DisplayMode

## Usage

```powershell
# import the Switch-DisplayMode cmdlet
. .\Switch-DisplayMode.ps1

# Set the last internal configuration from the persistent database
Switch-DisplayMode -DisplayMode internal

# Set the last extend configuration from the persistent database
Switch-DisplayMode -DisplayMode extend

# Set the last clone configuration from the persistent database
Switch-DisplayMode -DisplayMode clone

# Set the last external configuration from the persistent database
Switch-DisplayMode -DisplayMode external
```
