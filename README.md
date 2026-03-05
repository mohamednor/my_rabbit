# 🐰 My Rabbit - Candy Adventure Game

A colorful mobile game for kids featuring a cute bunny collecting candies!

## Features
- 🎮 50 Levels across 5 candy worlds
- 🍬 Collect candies to grow your bunny
- ⚡ Speed increases with each level
- 🛍️ Shop for hats and colors
- 📺 AdMob integration (Banner + Rewarded ads)

## Build APK

```bash
flutter pub get
flutter build apk --release
```

## AdMob Setup

Replace the App ID in `android/app/src/main/AndroidManifest.xml`:
```xml
android:value="ca-app-pub-XXXXXXXX~YYYYYYYYYY"
```

## Ad Unit IDs
- Banner: `ca-app-pub-4380269071153281/4882324106`
- Rewarded: `ca-app-pub-4380269071153281/5629117921`
- Rewarded: `ca-app-pub-4380269071153281/3562667293`
