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
                button1.setTitle("Unity Banner View", for: .normal)
                button1.addAction(UIAction { [weak self] _ in
                    self?.openDemoAdPage(adType: .Banner)
                }, for: .touchUpInside)
                button1.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
                view.addSubview(button1)
       
    }

    func openDemoAdPage(adType: AdType) {
        let demoAdVC = DemoAdViewController(adType: adType)
        navigationController?.pushViewController(demoAdVC, animated: true)
    }

}
