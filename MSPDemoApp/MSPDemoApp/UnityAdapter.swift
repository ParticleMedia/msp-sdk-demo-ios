import Foundation
import MSPiOSCore
import IronSource

@objc public class UnityAdapter : NSObject, AdNetworkAdapter {
    public weak var adListener: AdListener?
    public var adRequest: AdRequest?
    public var bidderPlacementId: String?
    
    public weak var bannerAd: BannerAd?
    public var bannerView: LPMBannerAdView?
    
    private var adMetricReporter: AdMetricReporter?
    
    public func loadAdCreative(bidResponse: Any, adListener: any AdListener, context: Any, adRequest: AdRequest) {
        
        DispatchQueue.main.async {
            
            self.adListener = adListener
            self.adRequest = adRequest
        
            self.bannerView = LPMBannerAdView(adUnitId: "iep3rxsyp9na3rw8")
            self.bannerView?.setDelegate(self)
            if let adSize = adRequest.adSize {
                self.setBannerAdSize(adSize: adSize)
            }
            if let viewController = adListener.getRootViewController() {
                self.bannerView?.loadAd(with: viewController)
            }
            
        }
    }
    
    
    
    public func initialize(initParams: any MSPiOSCore.InitializationParameters, adapterInitListener: any MSPiOSCore.AdapterInitListener, context: Any?) {
        
    }
    
    public func destroyAd() {
        
    }
    
    public func prepareViewForInteraction(nativeAd: MSPiOSCore.NativeAd, nativeAdView: Any) {
        
        
    }
    
    public func setAdMetricReporter(adMetricReporter: any MSPiOSCore.AdMetricReporter) {
        self.adMetricReporter = adMetricReporter
    }
    
    private func setBannerAdSize(adSize: AdSize) {
        if adSize.width == 320, adSize.height == 50 {
            bannerView?.setAdSize(LPMAdSize.banner())
        } else if adSize.width == 320, adSize.height == 90 {
            bannerView?.setAdSize(LPMAdSize.large())
        } else if adSize.width == 300, adSize.height == 250 {
            bannerView?.setAdSize(LPMAdSize.mediumRectangle())
        }
    }
    
    
}

extension UnityAdapter: LPMBannerAdViewDelegate {
    public func didLoadAd(with adInfo: LPMAdInfo) {
        
        DispatchQueue.main.async {
            
            self.bannerView?.pauseAutoRefresh()
            
            if let bannerView = self.bannerView,
               let adListener = self.adListener,
               let adRequest = self.adRequest {
                let bannerAd = BannerAd(adView: bannerView, adNetworkAdapter: self)
                self.bannerAd = bannerAd
                bannerAd.adInfo["price"] = adInfo.revenue
                handleAdLoaded(ad: bannerAd, listener: adListener, adRequest: adRequest)
            }
             
        }
    }
    
    public func didFailToLoadAd(withAdUnitId adUnitId: String, error: any Error) {
        self.bannerView?.pauseAutoRefresh()
        
    }
    
    public func didClickAd(with adInfo: LPMAdInfo) {
        if let bannerAd = self.bannerAd {
            adListener?.onAdClick(ad: bannerAd)
        }
    }
    
    public func didDisplayAd(with adInfo: LPMAdInfo) {
        
    }
    
    
}

