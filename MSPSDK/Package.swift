// swift-tools-version: 5.9
// MSP iOS SDK 3.5.2 as a local binary Swift package.
//
// It wraps the unmodified xcframeworks from the 3.5.2 release of
// https://github.com/ParticleMedia/msp-ios-sdk-public. Run ./fetch-binaries.sh once to download
// them into Binaries/ before opening the demo project.
//
// Temporary: once MSP publishes a hosted Swift package, replace this local package with that
// package's URL at version 3.5.2.

import PackageDescription

let package = Package(
    name: "MSPSDK",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "MSPCore", targets: ["MSPCoreSPM"]),
        .library(name: "MSPNovaAdapter", targets: ["MSPNovaAdapterSPM"]),
        .library(name: "MSPGoogleAdapter", targets: ["MSPGoogleAdapterSPM"]),
        .library(name: "MSPFacebookAdapter", targets: ["MSPFacebookAdapterSPM"]),
    ],
    dependencies: [
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", "12.0.0"..<"13.0.0"),
        .package(url: "https://github.com/facebook/FBAudienceNetwork.git", "6.15.0"..<"7.0.0"),
    ],
    targets: [
        // Binary targets cannot declare dependencies, so each product is a thin source wrapper
        // that pulls in its binaries and third-party packages.
        .binaryTarget(name: "MSPiOSCore", path: "Binaries/MSPiOSCore.xcframework"),
        .binaryTarget(name: "MSPSharedLibraries", path: "Binaries/MSPSharedLibraries.xcframework"),
        .binaryTarget(name: "MSPPrebidAdapter", path: "Binaries/MSPPrebidAdapter.xcframework"),
        .binaryTarget(name: "MSPCore", path: "Binaries/MSPCore.xcframework"),
        .binaryTarget(name: "PrebidMobile", path: "Binaries/PrebidMobile.xcframework"),
        .binaryTarget(name: "OMSDK_Newsbreak1", path: "Binaries/OMSDK_Newsbreak1.xcframework"),
        .binaryTarget(name: "NovaCore", path: "Binaries/NovaCore.xcframework"),
        .binaryTarget(name: "MSPNovaAdapter", path: "Binaries/MSPNovaAdapter.xcframework"),
        .binaryTarget(name: "MSPGoogleAdsTypes", path: "Binaries/MSPGoogleAdsTypes.xcframework"),
        .binaryTarget(name: "MSPGoogleAdapter", path: "Binaries/MSPGoogleAdapter.xcframework"),
        .binaryTarget(name: "MSPFacebookAdapter", path: "Binaries/MSPFacebookAdapter.xcframework"),

        .target(
            name: "MSPCoreSPM",
            dependencies: [
                "MSPCore", "MSPiOSCore", "MSPSharedLibraries", "MSPPrebidAdapter",
                "PrebidMobile", "OMSDK_Newsbreak1",
            ]
        ),
        .target(
            name: "MSPNovaAdapterSPM",
            dependencies: ["MSPCoreSPM", "NovaCore", "MSPNovaAdapter"]
        ),
        .target(
            name: "MSPGoogleAdapterSPM",
            dependencies: [
                "MSPCoreSPM", "MSPGoogleAdsTypes", "MSPGoogleAdapter",
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]
        ),
        .target(
            name: "MSPFacebookAdapterSPM",
            dependencies: [
                "MSPCoreSPM", "MSPFacebookAdapter",
                .product(name: "FBAudienceNetwork", package: "FBAudienceNetwork"),
            ]
        ),
    ]
)
