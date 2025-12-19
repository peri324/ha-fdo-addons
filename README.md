# Intel FDO Device Add-on

This add-on runs the DOSS FDO (FIDO Device Onboard) Device service.

## Configuration

**MUD URL**: The Manufacturer Usage Description URL.
**DI URL**: The Device Initialization URL (Owner/Manufacturing server).
**Reset Credentials**: Toggle this ON and restart to wipe the device identity (factory reset). Once this reset its turned off it not going to turn off automatically so it needs to be switched off after DI message.

## Persistence
All keys and credentials are saved in `/data/app-data` and survive restarts.