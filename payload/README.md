# iOS IPA Payload Package

This directory contains the iOS `.ipa` archive with the standard Apple `Payload/Runner.app` bundle structure.

- **File**: `VPN_One_Release.ipa`
- **Internal Structure**:
  ```
  VPN_One_Release.ipa (ZIP)
  └── Payload/
      └── Runner.app/
          ├── Info.plist
          └── Assets.xcassets/
  ```

### Inspecting the Payload Structure
You can inspect the contents on any platform using `unzip` or any ZIP utility:
```bash
unzip -l VPN_One_Release.ipa
```
