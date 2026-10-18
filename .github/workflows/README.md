# Radio Online Pro
Native SwiftUI iOS radio starter. Includes station editing, search, favorites and AVPlayer audio.

## Important
This package is **source code**, not an installable or signed IPA. GitHub workflow validates a simulator build only. To install on an iPhone, configure Apple Developer signing and a distribution pipeline (Xcode Cloud or a signed GitHub Actions workflow) and distribute via TestFlight.

## iPhone-only setup
1. Create an Apple Developer Program account using the Apple Developer iPhone app.
2. In Safari, create an App Store Connect app with bundle ID `com.radioonlinepro.player` (or change to a unique ID in project.yml).
3. Create a GitHub repository. Upload contents of this ZIP keeping `.github/workflows/build.yml` folder structure.
4. Go to Actions and run `Build iOS (simulator validation)`; it does NOT upload to TestFlight.
5. Configure cloud signing, provisioning and App Store Connect API key in a separate secure workflow before attempting TestFlight.
6. After uploading a signed build to App Store Connect, invite yourself as an internal tester, install TestFlight, accept invitation and install.

## Stations
Press + in app and add station name, genre and a direct HTTPS audio stream URL. The included example.com URL is a placeholder and won't play. Do not retransmit radio stations without necessary permissions.

## Monetization
Not yet implemented. AdMob and StoreKit require additional integration, account setup, privacy disclosures, compliance and testing. No ads or paid subscriptions are active in this build.
