import UIKit
import MSPCore
import GoogleAdapter
import NovaAdapter
import AppTrackingTransparency
import MSPiOSCore

import FacebookAdapter


@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let mspInitParameters = InitializationParametersImp(prebidAPIKey: "af7ce3f9-462d-4df1-815f-09314bb87ca3",
                                                            sourceApp: "0000000000", // Your App's numeric ID on App Store
                                                            orgId: 1061,
                                                            appId: 1)
        mspInitParameters.params = [:]
        //Note: for pubmatic ad you may need to config your NSAllowsArbitraryLoads key in App's Info.list to get a full experience, see details in https://help.pubmatic.com/openwrap/docs/home-get-started-with-ios-openwrap-sdk-as-primary-ad-sdk#app-transport-security-ats
        var adNetworkManagers = [NovaManager(), GoogleManager(), FacebookManager()]
        //MSP.shared.setNovaManager(novaManager: NovaManager())
        
        //MSP.shared.setGoogleManager(googleManager: GoogleManager())
        MSP.shared.bidLoaderProvider.googleQueryInfoFetcher = GoogleQueryInfoFetcherHelper()
        
        //MSP.shared.setMetaManager(metaManager: FacebookManager())
        MSP.shared.bidLoaderProvider.facebookBidTokenProvider = FacebookBidTokenProviderHelper()
        
        //MSP.shared.setUnityManager(unityManager: UnityManager())
        MSPLogger.shared.setLogLevel(level: MSPLogger.DEBUG)
        MSP.shared.initMSP(initParams: mspInitParameters, sdkInitListener: nil, adNetworkManagers: adNetworkManagers)
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { result in
                    
                }
            } else {
                // Fallback on earlier versions
            }
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

