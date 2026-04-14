# MSP SDK (iOS) integration guide
## Privisioning
A *Prebid API Key* needs to be provided offline by Particles. Please search `"af7ce3f9-462d-4df1-815f-09314bb87ca3"` in the demo app and replace it with your own. 

Publisher App developers need to pass an *placement id* provisioned by Particles to `LoadAd` API to load an Ad. Please search `"demo-ios-article-top"` in the demo app and replace it with your own.

## Dependencies
For now MSP SDK is distributed as Cocoapods, you can introduce MSP SDKs with the following code in your Podfile:
```
pod 'MSPCore', '3.5.2', :modular_headers => true
# if you want Nova Ads 
pod 'MSPNovaAdapter', '3.5.2', :modular_headers => true
# if you want Google Ads
pod 'MSPGoogleAdapter', '3.5.2', :modular_headers => true
# if you want Facebook Ads
pod 'MSPFacebookAdapter', '3.5.2', :modular_headers => true
```
Please specify the version numbers for the pods in your pod file, in case future updates bringing compatible issues. For the exact version number to choose, please refer to the [Podfile](https://github.com/ParticleMedia/msp-sdk-demo-ios/blob/main/Podfile) in this repo to use the latest versions which are compatible with the demo code. 

## SDK Initialization
Initialize MSP SDK once before loading any ads:

```swift
import MSPiOSCore
import MSPNovaAdapter
import MSPGoogleAdapter
import MSPFacebookAdapter

// 1. Create initialization parameters
let mspInitParameters = InitializationParametersImp(
    prebidAPIKey: "YOUR_PREBID_API_KEY",
    sourceApp: "YOUR_APP_STORE_ID",   // Your App's numeric ID on App Store
    orgId: YOUR_ORG_ID,               // Organization ID provided by Particles
    appId: YOUR_APP_ID                // App ID provided by Particles
)

// 2. Configure ad network managers you want to use
var adNetworkManagers = [NovaManager(), GoogleManager(), FacebookManager()]

// 3. Set up bid provider helpers for Google and Facebook
MSP.shared.bidLoaderProvider.googleQueryInfoFetcher = GoogleQueryInfoFetcherHelper()
MSP.shared.bidLoaderProvider.facebookBidTokenProvider = FacebookBidTokenProviderHelper()

// 4. (Optional) Enable debug logging during development
MSPLogger.shared.setLogLevel(level: MSPLogger.DEBUG)

// 5. Initialize the SDK
MSP.shared.initMSP(
    initParams: mspInitParameters,
    sdkInitListener: nil,
    adNetworkManagers: adNetworkManagers
)
```

> **Note:** Only include the ad network managers and bid provider helpers for the networks you have integrated. For example, if you only use Nova and Google, omit `FacebookManager()` and the Facebook bid token provider line.

You can optionally pass an `MSPInitListener` to receive a callback when initialization completes:
```swift
// Implement MSPInitListener
func onComplete(status: MSPInitStatus, message: String) {
    print("MSP SDK init completed with status: \(status), message: \(message)")
}

// Then pass the listener instead of `nil`:
MSP.shared.initMSP(
    initParams: mspInitParameters,
    sdkInitListener: self,
    adNetworkManagers: adNetworkManagers
)
```

## Loading & Displaying Interstitial Ads
Interstitial ads are full-screen ads displayed at natural transition points. Below is a complete example:

### 1. Create the AdLoader and load an interstitial ad
```swift
import MSPiOSCore

class MyViewController: UIViewController {
    var adLoader: MSPAdLoader?

    func loadInterstitialAd() {
        let adLoader = MSPAdLoader()
        self.adLoader = adLoader

        let adRequest = AdRequest(
            customParams: [:],
            geo: nil,
            context: nil,
            adaptiveBannerSize: nil,
            adSize: nil,
            placementId: "YOUR_PLACEMENT_ID",
            adFormat: .interstitial,
            testParams: [:]
        )

        adLoader.loadAd(
            placementId: "YOUR_PLACEMENT_ID",
            adListener: self,
            adRequest: adRequest
        )
    }
}
```

### 2. Implement `AdListener` to display the interstitial
```swift
extension MyViewController: AdListener {
    func getRootViewController() -> UIViewController? {
        return self
    }

    func onAdLoaded(placementId: String, loadInfo: [String: Any]) {
        if let ad = self.adLoader?.getAd(placementId: placementId) {
            self.onAdLoaded(ad: ad)
        }
    }

    func onAdLoaded(ad: MSPAd) {
        if let interstitialAd = ad as? InterstitialAd {
            DispatchQueue.main.async {
                interstitialAd.show()
            }
        }
    }

    func onAdDismissed(ad: MSPAd) {
        print("Ad dismissed")
    }

    func onAdClick(ad: MSPAd) {
        print("Ad clicked")
    }

    func onAdImpression(ad: MSPAd) {
        print("Ad impression recorded")
    }

    func onError(msg: String, loadInfo: [String: Any]) {
        print("Ad load error: \(msg)")
    }
}
```

## Loading & Displaying Multiformat Ads
MSP SDK supports multiple ad formats—**Banner**, **Native**, **Interstitial**, and **Rewarded**—through the same `AdLoader` API. The `adFormat` parameter in `AdRequest` determines which format is loaded.

### Banner Ad
```swift
let adRequest = AdRequest(
    customParams: [:],
    geo: nil,
    context: nil,
    adaptiveBannerSize: AdSize(width: 320, height: 50, isInlineAdaptiveBanner: false, isAnchorAdaptiveBanner: false),
    adSize: AdSize(width: 320, height: 50, isInlineAdaptiveBanner: false, isAnchorAdaptiveBanner: false),
    placementId: "YOUR_PLACEMENT_ID",
    adFormat: .banner,
    testParams: [:]
)
```
Display a banner in `onAdLoaded(ad:)`:
```swift
if let bannerAd = ad as? BannerAd {
    DispatchQueue.main.async {
        let adView = bannerAd.adView
        adView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(adView)
        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            adView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
            adView.widthAnchor.constraint(equalToConstant: 320),
            adView.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
```

### Native Ad
```swift
let adRequest = AdRequest(
    customParams: [:],
    geo: nil,
    context: nil,
    adaptiveBannerSize: nil,
    adSize: nil,
    placementId: "YOUR_PLACEMENT_ID",
    adFormat: .native,
    testParams: [:]
)
```
Display a native ad by providing a container that implements `MSPNativeAdContainer`:
```swift
if let nativeAd = ad as? NativeAd {
    DispatchQueue.main.async {
        let container = YourNativeAdContainer(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        let nativeAdView = NativeAdView(nativeAd: nativeAd, nativeAdContainer: container)
        self.view.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nativeAdView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            nativeAdView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 200),
            nativeAdView.widthAnchor.constraint(equalToConstant: 300)
        ])
    }
}
```

Your `MSPNativeAdContainer` implementation should return UI elements for the native ad layout:
```swift
class YourNativeAdContainer: UIView, MSPNativeAdContainer {
    func getTitle() -> UILabel?       { /* return title label */ }
    func getbody() -> UILabel?        { /* return body label */ }
    func getAdvertiser() -> UILabel?  { /* return advertiser label */ }
    func getCallToAction() -> UIButton? { /* return CTA button */ }
    func getMedia() -> UIView?        { /* return media view for image/video */ }
    func getIcon() -> UIImageView?    { /* return icon image view */ }
    func getCustomClickableViews() -> [UIView]? { return nil }
}
```

See [DemoNativeAdContainer.swift](https://github.com/ParticleMedia/msp-sdk-demo-ios/blob/main/MSPDemoApp/MSPDemoApp/Native/DemoNativeAdContainer.swift) for a complete example.

## SDK Best Practices
- **Initialize once:** Call `MSP.shared.initMSP` once in `AppDelegate`. Do not re-initialize per ad request.
- **One AdLoader per request:** Create a new `MSPAdLoader()` instance for each ad load. Do not reuse a single loader across multiple concurrent requests.
- **UI updates on main thread:** All ad display operations (adding views, calling `show()`) must be dispatched to `DispatchQueue.main`.
- **Call `notifyLoss` when MSP loses:** Always call `MSP.shared.notifyLoss` when another bidder wins or MSP does not fill. This is critical for accurate auction reporting.
- **Disable debug logging in production:** Remove or set `MSPLogger.shared.setLogLevel(level: MSPLogger.NONE)` before releasing to the App Store.
- **Pin SDK versions:** Always specify exact version numbers in your Podfile to prevent unexpected breaking changes from updates.

## API usage 
1. Init SDK using ` MSP.shared.initMSP`
2. Load an Ad using `AdLoader`
3. Got notified via `AdListener.onAdLoaded(placementId: String)` when Ad finished loading.
4. Fetch the loaded Ad from cache using `AdLoader.getAd` API

### notifyLoss API
Call `MSP.shared.notifyLoss` API when: 
1. MSP Ad loses the auction, or
2. MSP SDK does not fill while other bidder wins

`public func notifyLoss(winnerBidderName: String, winnerPrice: Float, ad: MSPAd?, requestId: String?)`

- `winnerBidderName`: name of the winning bidder other than MSP
- `winnderPrice`: Ad price of the winning bid other than MSP
- `ad`: MSP Ad that loses the auction.(pass `nil` for the No fill case)
- `requestId`: Provided by `onSuccess` and `onError` callback parameter `loadInfo["request_id"]`

Please checkout the demo app for [sample code](https://github.com/ParticleMedia/msp-sdk-demo-ios/blob/main/MSPDemoApp/MSPDemoApp/DemoViewControllers/DemoAdViewController.swift)

## Privacy & CCPA
Please follow Prebid's documentation to set user's IAB US Privacy signal: https://docs.prebid.org/prebid-mobile/prebid-mobile-privacy-regulation.html#notice-and-opt-out-signal 

## Verify your integration
If everything goes well, you should be able to get below sample Ad from Prebid.
<img width="354" alt="Screenshot 2024-09-30 at 1 14 00 PM" src="https://github.com/user-attachments/assets/8416fb52-5073-43d4-aa0d-431b28ab127e">

