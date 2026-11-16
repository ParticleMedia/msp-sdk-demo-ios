# MSP SDK — iOS Integration Guide (Swift Package Manager, SDK 3.5.2)

> **This is the `spm_3.5.2` branch.** The demo app and this guide use **MSP SDK 3.5.2 installed with
> Swift Package Manager (SPM)**, not CocoaPods. For the CocoaPods guide for the latest SDK, see the
> [`main` branch](https://github.com/ParticleMedia/msp-sdk-demo-ios/tree/main).

## Overview

This guide covers how to add the MSP iOS SDK 3.5.2 to your app with Swift Package Manager, initialize the SDK, and load and display ads.

The guide also provides some best practices which help you avoid common pitfalls and achieve the best performance.

**System requirements**

| Requirement | Version |
|---|---|
| iOS deployment target | 15.0+ |
| Xcode | 26.1+ (the 3.5.2 binaries were built with Swift 6.2.1; older Xcode versions cannot read their module interfaces) |
| Swift | 5.0+ |
| Swift Package Manager | swift-tools-version 5.9+ (bundled with Xcode) |

---

## Installation (Swift Package Manager)

The MSP SDK is a binary Swift package. It wraps the unmodified xcframeworks published in the
[3.5.2 release of `msp-ios-sdk-public`](https://github.com/ParticleMedia/msp-ios-sdk-public/releases/tag/3.5.2),
the same binaries CocoaPods installs for `pod 'MSPCore', '3.5.2'`.

### Package products

Add `MSPCore` and the adapter products for the ad networks you want to monetize with.

| Product | Required | Contains | Pulls in automatically |
|---|---|---|---|
| `MSPCore` | Yes | MSP core, Prebid demand (`MSPPrebidAdapter`, `PrebidMobile`), Open Measurement | — |
| `MSPNovaAdapter` | No | Nova adapter and `NovaCore` | — |
| `MSPGoogleAdapter` | No | Google Ad Manager / AdMob adapter | [Google Mobile Ads](https://github.com/googleads/swift-package-manager-google-mobile-ads) 12.x |
| `MSPFacebookAdapter` | No | Meta Audience Network adapter | [FBAudienceNetwork](https://github.com/facebook/FBAudienceNetwork) 6.x |

Not available as SPM products for 3.5.2: the Moloco, Liftoff and Amazon adapters. The AppLovin MAX adapter does not exist in 3.5.2 (it was added in 3.7.0).

### Add the package

The package is hosted at [`ParticleMedia/msp-ios-sdk-spm`](https://github.com/ParticleMedia/msp-ios-sdk-spm). SwiftPM downloads the binaries from the 3.5.2 release and verifies each one against the checksum in the package manifest.

1. In Xcode, choose **File → Add Package Dependencies…** and enter:

   ```
   https://github.com/ParticleMedia/msp-ios-sdk-spm
   ```

2. Choose the dependency rule **Exact Version** `3.5.2`.
3. Add the products you need to your app target.
4. Commit `Package.resolved` (in your `.xcodeproj` or `.xcworkspace`) so every machine and CI build uses the same version.

If your app is itself described by a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ParticleMedia/msp-ios-sdk-spm", exact: "3.5.2"),
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "MSPCore", package: "msp-ios-sdk-spm"),
            .product(name: "MSPNovaAdapter", package: "msp-ios-sdk-spm"),
            .product(name: "MSPGoogleAdapter", package: "msp-ios-sdk-spm"),
            .product(name: "MSPFacebookAdapter", package: "msp-ios-sdk-spm"),
        ]
    ),
]
```

#### Already using the local `MSPSDK/` package?

The hosted package contains the same xcframeworks, byte for byte, with the same products and dependency ranges, so no code changes are needed:

1. Remove the local `MSPSDK` package from your project and delete the `MSPSDK/` folder and the `fetch-binaries.sh` step from CI.
2. Add the package URL at **Exact Version** `3.5.2` as above, with the same products.

### Notes for apps moving from CocoaPods

- Remove the MSP pods (`MSPCore`, `MSPSharedLibraries`, `MSPPrebidAdapter`, the adapter pods) and the `SwiftProtobuf` pod you added for MSP, then run `pod install` (or `pod deintegrate` if MSP was your only pod). Keep both installs out of the same app: it would link two copies of the SDK.
- Do not add `SwiftProtobuf`, `Kingfisher` or `SnapKit` for MSP: the SDK binaries already contain what they need (`MSPCore` embeds SwiftProtobuf, `NovaCore` embeds Kingfisher, and both use a private, renamed copy of SnapKit). Your app can still use its own copies of these libraries.
- `use_frameworks!` and `:modular_headers => true` have no SPM equivalent and are not needed.
- Do not add `PrebidMobile` through SPM in the same app. MSP ships its own build of Prebid under the module name `PrebidMobile`, so a second copy clashes.
- Your app code does not change: the module names (`MSPCore`, `MSPiOSCore`, `MSPNovaAdapter`, `MSPGoogleAdapter`, `MSPFacebookAdapter`) are the same as with CocoaPods.

### Run this demo app

Open `MSPDemoApp/MSPDemoApp.xcodeproj` (there is no `.xcworkspace` or `Podfile` on this branch) and run the `MSPDemoApp` scheme. Xcode resolves the package on first open.

---

## Info.plist Configuration

### App Tracking Transparency (iOS 14+)

Add the usage description key. The system displays this string in the ATT permission prompt:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

Network-specific `Info.plist` entries (GAD identifier, SKAdNetwork IDs) are covered per network in the [Mediation Networks Guide](#mediation-networks-guide).

---

## Initialize the SDK

Initialize the MSP SDK as early as possible — ideally in `application(_:didFinishLaunchingWithOptions:)`. The SDK uses the initialization window to prefetch ad configurations and warm up adapter networks.

**AppDelegate.swift**

```swift
import AppTrackingTransparency
import MSPCore
import MSPiOSCore
import MSPNovaAdapter
import MSPGoogleAdapter
import MSPFacebookAdapter

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    // Declare adapter managers for the networks you want to activate
    private let adNetworkManagers: [AdNetworkManager] = [
        NovaManager(),
        GoogleManager(),
        FacebookManager(),
    ]

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        initializeMSP()

        // Request ATT permission after a brief delay so your UI is visible
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { _ in }
            }
        }

        return true
    }

    private func initializeMSP() {
        // Optional: pass a publisher-provided user identifier for frequency capping
        MSP.shared.ppid = "your-user-id"

        // Required for Google client-side bidding and for Facebook bidding.
        // Without the Facebook bid token provider, Facebook never bids.
        MSP.shared.bidLoaderProvider.googleQueryInfoFetcher = GoogleQueryInfoFetcherHelper()
        MSP.shared.bidLoaderProvider.facebookBidTokenProvider = FacebookBidTokenProviderHelper()

        // Build initialization parameters
        let initParams = InitializationParametersImp(
            prebidAPIKey: "YOUR_PREBID_API_KEY",
            sourceApp: "YOUR_APP_STORE_ID", // Your app's numeric App Store ID
            orgId: 12345,                   // Your org ID provisioned by Particle Inc.
            appId: 67890                    // Your app ID provisioned by Particle Inc.
        )
        initParams.params = [:]

        // Initialize
        MSP.shared.initMSP(
            initParams: initParams,
            sdkInitListener: self,          // optional — set to nil if not needed
            adNetworkManagers: adNetworkManagers
        )
    }
}

// MARK: - MSPInitListener (optional)
extension AppDelegate: MSPInitListener {
    func onComplete(status: MSPInitStatus, message: String) {
        print("[MSP] Initialization complete. Status: \(status), message: \(message)")
    }
}
```

**Key initialization parameters**

| Parameter | Type | Description |
|---|---|---|
| `prebidAPIKey` | `String` | API key issued by Particle Inc. for your app |
| `sourceApp` | `String?` | Your app's numeric App Store ID |
| `orgId` | `Int64?` | Organization ID provisioned by Particle Inc. |
| `appId` | `Int64?` | App ID provisioned by Particle Inc. |
| `params` | `[String: Any]?` | Additional network-specific initialization parameters (none needed for Nova, Google or Facebook) |

**MSP.shared properties used above**

| Property | Default | Description |
|---|---|---|
| `ppid` | `nil` | Publisher-provided user ID |
| `bidLoaderProvider.googleQueryInfoFetcher` | `nil` | Set to `GoogleQueryInfoFetcherHelper()` (from `MSPGoogleAdapter`) |
| `bidLoaderProvider.facebookBidTokenProvider` | `nil` | Set to `FacebookBidTokenProviderHelper()` (from `MSPFacebookAdapter`) |

---

## Load and Display Ads

The pattern for every ad format is the same:

1. Create an `MSPAdLoader` and an `AdRequest`.
2. Call `loadAd(placementId:adListener:adRequest:)`.
3. In `onAdLoaded`, call `loader.getAd(placementId:)` to retrieve the ad object.
4. Present the Ad(for interstitial Ad) or attach the ad to the App view hierarchy.

### Set a Bid Floor (optional)

To set a minimum price for a request, add the `bid_floor` custom parameter: the eCPM floor in USD, **as a String** (`"1.25"` means $1.25 per 1,000 impressions). It applies to that request only and replaces the placement's configured floor. Leave the key out to use the configured floor.

```swift
let request = AdRequest(
    customParams: ["bid_floor": String(format: "%.2f", 1.25)], // "1.25"
    geo: nil,
    context: nil,
    adaptiveBannerSize: nil,
    adSize: nil,
    placementId: "YOUR_PLACEMENT_ID",
    adFormat: .native
)
loader.loadAd(placementId: "YOUR_PLACEMENT_ID", adListener: self, adRequest: request)
```

- The value must be a `String`. The SDK only forwards String custom params to the ad server, so a `Double` such as `1.25` is silently dropped.
- The floor applies to server-side (MSP) bidding. Client-side-only placements do not use it.

---

## Call NotifyLoss API
Call `MSP.shared.notifyLoss` API when: 
1. MSP Ad loses the auction, or
2. MSP SDK does not fill while other bidder wins

`public func notifyLoss(winnerBidderName: String, winnerPrice: Float, ad: MSPAd?, requestId: String?)`

- `winnerBidderName`: name of the winning bidder other than MSP
- `winnerPrice`: Ad price of the winning bid other than MSP
- `ad`: MSP Ad that loses the auction.(pass `nil` for the No fill case)
- `requestId`: The `"request_id"` entry of the `loadInfo` dictionary passed to `onAdLoaded(placementId:loadInfo:)` and `onError(msg:loadInfo:)`, for example `loadInfo["request_id"] as? String`. (SDK 3.5.2 has no `MSPConstants` key for it.)

---

## Ad Formats

### Banner Ads

```swift
import MSPCore
import MSPiOSCore

class BannerViewController: UIViewController {

    private let loader = MSPAdLoader()
    private var bannerContainerView: UIView?

    private func loadBanner() {
        let size = AdSize(width: 320, height: 50)
        let request = AdRequest(
            customParams: [:],
            geo: nil,
            context: nil,
            adaptiveBannerSize: nil,
            adSize: size,
            placementId: "YOUR_BANNER_PLACEMENT_ID",
            adFormat: .banner
        )
        loader.loadAd(placementId: "YOUR_BANNER_PLACEMENT_ID", adListener: self, adRequest: request)
    }
}

extension BannerViewController: AdListener {

    func onAdLoaded(placementId: String, loadInfo: [String: Any]) {
        guard let bannerAd = loader.getAd(placementId: placementId) as? BannerAd else { return }

        let adView = bannerAd.adView
        adView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adView)

        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            adView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            adView.widthAnchor.constraint(equalToConstant: 320),
            adView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    func onError(msg: String, loadInfo: [String: Any]) {
        print("[MSP] Banner error: \(msg)")
    }

    func onAdImpression(ad: MSPAd) {}
    func onAdClick(ad: MSPAd) {}
    func onAdDismissed(ad: InterstitialAd) {}

    func getRootViewController() -> UIViewController? { self }
}
```

**Standard banner sizes**

| Size | Width | Height |
|---|---|---|
| Banner | 320 | 50 |
| Medium rectangle | 300 | 250 |
| Leaderboard | 728 | 90 |

### Interstitial Ads

Load the interstitial before you need to show it. Display it at a natural transition point — level completion, article end, etc.

Always call `show(rootViewController:)` with the view controller to present from. In SDK 3.5.2, calling `show()` without a view controller crashes when the winning ad is a Facebook interstitial.

```swift
import MSPCore
import MSPiOSCore

class InterstitialViewController: UIViewController {

    private let loader = MSPAdLoader()

    private func loadInterstitial() {
        let request = AdRequest(
            customParams: [:],
            geo: nil,
            context: nil,
            adaptiveBannerSize: nil,
            adSize: nil,
            placementId: "YOUR_INTERSTITIAL_PLACEMENT_ID",
            adFormat: .interstitial
        )
        loader.loadAd(placementId: "YOUR_INTERSTITIAL_PLACEMENT_ID", adListener: self, adRequest: request)
    }

    private func showInterstitialIfReady() {
        guard let interstitialAd = loader.getAd(placementId: "YOUR_INTERSTITIAL_PLACEMENT_ID") as? InterstitialAd else {
            loadInterstitial() // not ready yet — start loading
            return
        }
        interstitialAd.show(rootViewController: self)
    }
}

extension InterstitialViewController: AdListener {

    func onAdLoaded(placementId: String, loadInfo: [String: Any]) {
        print("[MSP] Interstitial ready")
        showInterstitialIfReady()
    }

    func onError(msg: String, loadInfo: [String: Any]) {
        print("[MSP] Interstitial error: \(msg)")
    }

    func onAdDismissed(ad: InterstitialAd) {
        print("[MSP] Interstitial ad dismissed")
        loadInterstitial() // preload the next one
    }

    func onAdImpression(ad: MSPAd) {}
    func onAdClick(ad: MSPAd) {}

    func getRootViewController() -> UIViewController? { self }
}
```

### Rewarded Ads

Rewarded ads are not available in SDK 3.5.2. They were added in SDK 4.5.0 (`AdFormat.rewarded`, `RewardedAd`, `onAdRewardReceived`).

### Native Ads

Native ads return a `NativeAd` object you render with your own layout. Implement `MSPNativeAdContainer` to wire up your UI elements, then pass it to `NativeAdView`.

```swift
import MSPCore
import MSPiOSCore

class NativeViewController: UIViewController {

    private let loader = MSPAdLoader()

    private func loadNativeAd() {
        let request = AdRequest(
            customParams: [:],
            geo: nil,
            context: nil,
            adaptiveBannerSize: nil,
            adSize: nil,
            placementId: "YOUR_NATIVE_PLACEMENT_ID",
            adFormat: .native
        )
        loader.loadAd(placementId: "YOUR_NATIVE_PLACEMENT_ID", adListener: self, adRequest: request)
    }
}

extension NativeViewController: AdListener {

    func onAdLoaded(placementId: String, loadInfo: [String: Any]) {
        guard let nativeAd = loader.getAd(placementId: placementId) as? NativeAd else { return }
        DispatchQueue.main.async {
            let container = MyNativeAdContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
            let nativeAdView = NativeAdView(nativeAd: nativeAd, nativeAdContainer: container)
            nativeAdView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(nativeAdView)
            NSLayoutConstraint.activate([
                nativeAdView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                nativeAdView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                nativeAdView.widthAnchor.constraint(equalToConstant: 300),
            ])
        }
    }

    func onError(msg: String, loadInfo: [String: Any]) {}
    func onAdImpression(ad: MSPAd) {}
    func onAdClick(ad: MSPAd) {}
    func onAdDismissed(ad: InterstitialAd) {}

    func getRootViewController() -> UIViewController? { self }
}
```

Implement `MSPNativeAdContainer` to provide the UI elements the SDK will populate:

```swift
class MyNativeAdContainer: UIView, MSPNativeAdContainer {
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let advertiserLabel = UILabel()
    private let ctaButton = UIButton()
    private let mediaView = UIView()
    private let iconView = UIImageView()

    func getTitle() -> UILabel? { titleLabel }
    func getbody() -> UILabel? { bodyLabel }
    func getAdvertiser() -> UILabel? { advertiserLabel }
    func getCallToAction() -> UIButton? { ctaButton }
    func getMedia() -> UIView? { mediaView }
    func getIcon() -> UIImageView? { iconView }
    func getCustomClickableViews() -> [UIView]? { nil }
}
```

### Native-Banner Multi-format

`.multi_format` allows both native and banner ads to fill the same placement. In `onAdLoaded`, check which type was returned and render accordingly.

```swift
import MSPCore
import MSPiOSCore

class MultiFormatViewController: UIViewController {

    private let loader = MSPAdLoader()

    private func loadAd() {
        let request = AdRequest(
            customParams: [:],
            geo: nil,
            context: nil,
            adaptiveBannerSize: nil,
            adSize: nil,
            placementId: "YOUR_MULTI_FORMAT_PLACEMENT_ID",
            adFormat: .multi_format
        )
        loader.loadAd(placementId: "YOUR_MULTI_FORMAT_PLACEMENT_ID", adListener: self, adRequest: request)
    }
}

extension MultiFormatViewController: AdListener {

    func onAdLoaded(placementId: String, loadInfo: [String: Any]) {
        let ad = loader.getAd(placementId: placementId)
        DispatchQueue.main.async {
            if let nativeAd = ad as? NativeAd {
                let container = MyNativeAdContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
                let nativeAdView = NativeAdView(nativeAd: nativeAd, nativeAdContainer: container)
                nativeAdView.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(nativeAdView)
                NSLayoutConstraint.activate([
                    nativeAdView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    nativeAdView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    nativeAdView.widthAnchor.constraint(equalToConstant: 300),
                ])
            } else if let bannerAd = ad as? BannerAd {
                let adView = bannerAd.adView
                adView.translatesAutoresizingMaskIntoConstraints = false
                self.view.addSubview(adView)
                NSLayoutConstraint.activate([
                    adView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    adView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                    adView.widthAnchor.constraint(equalToConstant: 320),
                    adView.heightAnchor.constraint(equalToConstant: 50),
                ])
            }
        }
    }

    func onError(msg: String, loadInfo: [String: Any]) {}
    func onAdImpression(ad: MSPAd) {}
    func onAdClick(ad: MSPAd) {}
    func onAdDismissed(ad: InterstitialAd) {}

    func getRootViewController() -> UIViewController? { self }
}
```

## Mediation Networks Guide

Network-specific `Info.plist` entries required for each adapter are listed below. Formats are those supported by the SDK 3.5.2 adapters.

| Product | Ad Network | Formats |
|---|---|---|
| `MSPCore` (Prebid) | Prebid demand (PubMatic and other server-side bidders) | Banner, Interstitial |
| `MSPGoogleAdapter` | Google Ad Manager / AdMob | Banner, Interstitial, Native |
| `MSPFacebookAdapter` | Meta Audience Network | Interstitial, Native |
| `MSPNovaAdapter` | Nova | Interstitial, Native |

---

### Google

**Info.plist — GAD identifier**

Add your app's GAD identifier from the Google AdMob dashboard:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX</string>
```

**Info.plist — SKAdNetwork**

```xml
<dict>
  <key>SKAdNetworkIdentifier</key>
  <string>cstr6suwn9.skadnetwork</string>
</dict>
```

---

### Meta (Facebook)

**Info.plist — SKAdNetwork**

```xml
<dict>
  <key>SKAdNetworkIdentifier</key>
  <string>v9wttpbfk9.skadnetwork</string>
</dict>
<dict>
  <key>SKAdNetworkIdentifier</key>
  <string>n38lu8286q.skadnetwork</string>
</dict>
```

---

### Meta (Facebook): bidding setup

Facebook only bids when `MSP.shared.bidLoaderProvider.facebookBidTokenProvider` is set before `initMSP` (see [Initialize the SDK](#initialize-the-sdk)). In our testing, Facebook also returned no bids while App Tracking Transparency was denied, and filled once tracking was allowed.

---

## Best Practices

### Preloading

The auction takes time. Suggest Call `loadAd` before the moment you need to show the ad:

- **Banners**: Load when the view controller loads (`viewDidLoad`).
- **Interstitials**: Load at app launch or immediately after the previous interstitial is dismissed.

### Destroying Ads

When an ad is no longer needed, call `destroy()` to release adapter resources and prevent memory leaks:

```swift
override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    currentAd?.destroy()
    currentAd = nil
}
```

### Memory Management

Keep a strong reference to your `MSPAdLoader` instance for the lifetime of the placement. The `AdListener` is held weakly by the loader — your view controller or delegate object must remain alive until `onAdLoaded` or `onError` fires.

---

## Troubleshooting

**No ads filling**

- Verify the placement IDs match what is provisioned by Particle Inc.
- Confirm `initMSP` completes before `loadAd` is called.
- Enable verbose logging during development: `MSPLogger.shared.setLogLevel(level: MSPLogger.DEBUG)`.

**`onAdLoaded` fires but `getAd` returns nil**

`getAd` removes the ad from cache. Call it exactly once per load cycle and hold the returned ad strongly until you are done with it.

**ATT prompt not appearing**

`ATTrackingManager.requestTrackingAuthorization` must be called from the main thread after your root view controller is visible. The 1-second delay in the sample above handles the most common case; adjust as needed for your presentation flow.

**Package resolution fails or reports a checksum mismatch**

Make sure the machine can download from `github.com` (proxies included), then in Xcode choose **File → Packages → Reset Package Caches** and build again.

**"compiled module was created by a newer version of the compiler"**

The 3.5.2 binaries were built with Swift 6.2.1. Use Xcode 26.1 or later.

**Facebook never fills**

Set `facebookBidTokenProvider` (and `googleQueryInfoFetcher`) before `initMSP`, and check the App Tracking Transparency status.

**Console warnings: `Class _TtC10MSPSnapKit… is implemented in both MSPCore and NovaCore`**

Known and harmless in 3.5.2: both binaries carry the SDK's private copy of SnapKit. CocoaPods installs of 3.5.2 log the same warning.

## Privacy
### CCPA
Prebid SDK which is included in the MSP SDK will read `UserDefaults` (iOS) or `SharedPreferences` (Android) key `IABUSPrivacy_String` for US Privacy signal. [Prebid SDK CCPA doc](https://docs.prebid.org/prebid-mobile/prebid-mobile-privacy-regulation.html#notice-and-opt-out-signal)

### GDPR
Prebid SDK which is included in the MSP SDK will read `UserDefaults` (iOS) or `SharedPreferences` (Android) keys `IABTCF_gdprApplies` and `IABTCF_TCString` for GDPR privacy signals. [Prebid SDK GDPR doc](https://docs.prebid.org/prebid-mobile/prebid-mobile-privacy-regulation.html#framework-apis)

### COPPA
SDK 3.5.2 does not let you set a COPPA signal: `InitializationParametersImp.isAgeRestrictedUser()` always returns `false`. Later SDK versions add consent APIs for it.
