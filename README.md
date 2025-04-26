# MSP SDK (iOS) integration guide
## Privisioning
A *Prebid API Key* needs to be provided offline by Particles. Please search `"af7ce3f9-462d-4df1-815f-09314bb87ca3"` in the demo app and replace it with your own. 

Publisher App developers need to pass an *placement id* provisioned by Particles to `LoadAd` API to load an Ad. Please search `"demo-ios-article-top"` in the demo app and replace it with your own.

## Dependencies
For now MSP SDK is distributed as Cocoapods, you can introduce MSP SDKs with the following code in your Podfile:
```
pod 'MSPCore', '0.0.109', :modular_headers => true
# if you want Nova Ads 
pod 'NovaAdapter', '0.0.111', :modular_headers => true
# if you want Google Ads
pod 'GoogleAdapter', '0.0.109', :modular_headers => true
# if you want Facebook Ads
pod 'FacebookAdapter', '0.0.109', :modular_headers => true
```
Please specify the version numbers for the pods in your pod file, in case future updates bringing compatible issues. For the exact version number to choose, please refer to the [Podfile](https://github.com/ParticleMedia/msp-sdk-demo-ios/blob/main/Podfile) in this repo to use the latest versions which are compatible with the demo code. 

## API usage 
1. Init SDK using ` MSP.shared.initMSP`
2. Load an Ad using `AdLoader`
3. Got notified via `AdListener.onAdLoaded(placementId: String)` when Ad finished loading.
4. Fetch the loaded Ad from cache using `AdCache.getAd` API

Please checkout the demo app for [sample code](https://github.com/ParticleMedia/msp-sdk-demo-ios/blob/main/MSPDemoApp/MSPDemoApp/DemoViewControllers/DemoAdViewController.swift)

## Privacy & CCPA
Please follow Prebid's documentation to set user's IAB US Privacy signal: https://docs.prebid.org/prebid-mobile/prebid-mobile-privacy-regulation.html#notice-and-opt-out-signal 

## Verify your integration
If everything goes well, you should be able to get below sample Ad from Prebid.
<img width="354" alt="Screenshot 2024-09-30 at 1 14 00 PM" src="https://github.com/user-attachments/assets/8416fb52-5073-43d4-aa0d-431b28ab127e">

