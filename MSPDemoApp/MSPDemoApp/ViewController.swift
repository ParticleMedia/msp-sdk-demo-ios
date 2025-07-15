import UIKit
import MSPCore
import MSPiOSCore
import AppTrackingTransparency

class ViewController: UIViewController {
    
    @IBOutlet var appBannerView: UIView!
    weak var adLoader: MSPAdLoader?
    public var nativeAdView: NativeAdView?
    public var isCtaShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button1 = UIButton(type: .system)
                button1.setTitle("Prebid Banner View", for: .normal)
                button1.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .prebidBanner)
                }, for: .touchUpInside)
                button1.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
                view.addSubview(button1)
        
        let button2 = UIButton(type: .system)
                button2.setTitle("Google Banner View", for: .normal)
                button2.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .googleBanner)
                }, for: .touchUpInside)
                button2.frame = CGRect(x: 100, y: 150, width: 200, height: 50)
                view.addSubview(button2)
        let button3 = UIButton(type: .system)
                button3.setTitle("Google Native View", for: .normal)
                button3.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .googleNative)
                }, for: .touchUpInside)
                button3.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
                view.addSubview(button3)
        let button4 = UIButton(type: .system)
                button4.setTitle("Nova Native View", for: .normal)
                button4.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .novaNative)
                }, for: .touchUpInside)
                button4.frame = CGRect(x: 100, y: 250, width: 200, height: 50)
                view.addSubview(button4)
        let button5 = UIButton(type: .system)
                button5.setTitle("Google Interstitial View", for: .normal)
                button5.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .googleInterstitial)
                }, for: .touchUpInside)
                button5.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
                view.addSubview(button5)
        let button6 = UIButton(type: .system)
                button6.setTitle("Nova Interstitial View", for: .normal)
                button6.frame = CGRect(x: 100, y: 350, width: 200, height: 50)
                view.addSubview(button6)
                let novaInterstitialMenuItems = [
                    UIAction(title: "Horizontal Image", handler: { _ in self.openDemoAdPage(adType: .novaInterstitialHorizontalImage) }),
                    UIAction(title: "Vertical Image", handler: { _ in self.openDemoAdPage(adType: .novaInterstitialVerticalImage) }),
                    UIAction(title: "Horizontal Video", handler: { _ in self.openDemoAdPage(adType: .novaInterstitialHorizontalVideo) }),
                    UIAction(title: "Vertical Video", handler: { _ in self.openDemoAdPage(adType: .novaInterstitialVerticalVideo) }),
                    UIAction(title: "High Engagement", handler: { _ in self.openDemoAdPage(adType: .novaInterstitialHighEngagement) }),
                    UIAction(title: "End Card 2 Parts", handler: { _ in self.openDemoAdPage(adType: .novaInterstitialEndCard) })
                ]
                button6.menu = UIMenu(title: "Choose an option", children: novaInterstitialMenuItems)
                button6.showsMenuAsPrimaryAction = true
        
        let button7 = UIButton(type: .system)
                button7.setTitle("Facebook Native View", for: .normal)
                button7.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .facebookNative)
                }, for: .touchUpInside)
                button7.frame = CGRect(x: 100, y: 400, width: 200, height: 50)
                view.addSubview(button7)
        
        let button8 = UIButton(type: .system)
                button8.setTitle("Facebook Interstitial View", for: .normal)
                button8.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .facebookInterstitial)
                }, for: .touchUpInside)
                button8.frame = CGRect(x: 100, y: 450, width: 200, height: 50)
                view.addSubview(button8)
  
        
        
        let button13 = UIButton(type: .system)
                button13.setTitle("Prebid Interstitial", for: .normal)
                button13.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .prebidInterstitial)
                }, for: .touchUpInside)
                button13.frame = CGRect(x: 100, y: 500, width: 200, height: 50)
                view.addSubview(button13)
        
        let debugButton = UIButton(type: .system)
                debugButton.setTitle("Debug Ad Load", for: .normal)
                debugButton.backgroundColor = .systemOrange
                debugButton.setTitleColor(.white, for: .normal)
                debugButton.layer.cornerRadius = 8
                debugButton.addAction(UIAction {_ in
                    MSP.shared.showMediationDebugger()
                }, for: .touchUpInside)
                debugButton.frame = CGRect(x: 100, y: 550, width: 200, height: 50)
                view.addSubview(debugButton)
    }

    
    func openDemoAdPage(adType: AdType) {
        let demoAdVC = DemoAdViewController(adType: adType)
        navigationController?.pushViewController(demoAdVC, animated: true)
    }
}
