# Instructions to add Info.plist to Xcode project

## Steps to add Info.plist to your Xcode project:

1. **Open Xcode** and select your AtlasIQ Mobile project
2. **Right-click** on the "AtlasIQ Mobile" folder in the project navigator
3. **Select "Add Files to 'AtlasIQ Mobile'"**
4. **Navigate to** the AtlasIQ Mobile folder and select `Info.plist`
5. **Make sure** "Add to target: AtlasIQ Mobile" is checked
6. **Click "Add"**

## Alternative method:
1. **Select** the AtlasIQ Mobile project in the navigator
2. **Select** the AtlasIQ Mobile target
3. **Go to** the "Info" tab
4. **Add** the following key-value pairs:
   - Key: `NSLocationWhenInUseUsageDescription`
   - Value: `AtlasIQ needs access to your location to analyze local sentiment from social media posts in your area.`

## After adding Info.plist:
1. **Clean** the project (Product → Clean Build Folder)
2. **Build** and run the app
3. **Test** the location permission flow

The system permission dialog should now appear when you tap "Enable Location Access".
