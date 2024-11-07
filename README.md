# GoogleMapsDemo
Demo of using GoogleMaps-SDK in framework
Bonus: App does not require GoogleMaps

## Project Structure
- Core uses GoogleMaps via SPM
- App uses Core 

## Issues:
Without further adjustments Core could not be run. 
```
Command SwiftVerifyEmittedModuleInterface failed with a nonzero exit code
```
## Adjustments:
Build Settings vom Core Target
- "Build Libraries for Distribution" -> NO
- "Dead Code Stripping" -> NO
- "Other Linker Flags" -> add "-ObjC" 
- "Enable Modules (C and Objective-C)" -> YES
With these Adjustments App and Core can be run.
