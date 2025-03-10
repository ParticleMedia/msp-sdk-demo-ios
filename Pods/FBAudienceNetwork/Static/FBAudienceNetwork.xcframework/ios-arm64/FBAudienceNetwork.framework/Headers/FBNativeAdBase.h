/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <FBAudienceNetwork/FBAdExtraHint.h>
#import <FBAudienceNetwork/FBAdSettings.h>

typedef NS_ENUM(NSInteger, FBAdFormatType) {
    FBAdFormatTypeUnknown = 0,
    FBAdFormatTypeImage,
    FBAdFormatTypeVideo,
    FBAdFormatTypeCarousel
};

NS_ASSUME_NONNULL_BEGIN

@class FBAdImage;
@class FBAdPlacementDefinition;
@class FBAdProvider;
@class FBMediaView;
@class FBNativeAdDataModel;
@class FBNativeAdViewAttributes;

/**
 Determines if caching of the ad's assets should be done before calling adDidLoad
 */
typedef NS_ENUM(NSInteger, FBNativeAdsCachePolicy) {
    /// No ad content is cached
    FBNativeAdsCachePolicyNone,
    /// All content is cached
    FBNativeAdsCachePolicyAll,
};

/**
 The Internal representation of an Ad
 */
@interface FBNativeAdBase : NSObject <NSCopying>
/**
 Typed access to the id of the ad placement.
 */
@property (nonatomic, copy, readonly) NSString *placementID;
/**
 Typed access to the headline that the advertiser entered when they created their ad. This is usually the ad's main
 title.
 */
@property (nonatomic, copy, readonly, nullable) NSString *headline;
/**
 Typed access to the link description which is additional information that the advertiser may have entered.
 */
@property (nonatomic, copy, readonly, nullable) NSString *linkDescription;
/**
 Typed access to the name of the Facebook Page or mobile app that represents the business running the ad.
 */
@property (nonatomic, copy, readonly, nullable) NSString *advertiserName;
/**
 Typed access to the ad social context, for example "Over half a million users".
 */
@property (nonatomic, copy, readonly, nullable) NSString *socialContext;
/**
 Typed access to the call to action phrase of the ad, for example "Install Now".
 */
@property (nonatomic, copy, readonly, nullable) NSString *callToAction;
/**
 Typed access to the body raw untruncated text, Contains the text that the advertiser entered when they created their
 ad. This often tells people what the ad is promoting.
 */
@property (nonatomic, copy, readonly, nullable) NSString *rawBodyText;
/**
 Typed access to the body text, truncated at length 90, which contains the text that the advertiser entered when they
 created their ad. This often tells people what the ad is promoting.
 */
@property (nonatomic, copy, readonly, nullable) NSString *bodyText;
/**
 Typed access to the word 'sponsored', translated into the language being used by the person viewing the ad.
 */
@property (nonatomic, copy, readonly, nullable) NSString *sponsoredTranslation;
/**
 Typed access to  the word 'ad', translated into the language being used by the person viewing the ad.
 */
@property (nonatomic, copy, readonly, nullable) NSString *adTranslation;
/**
 Typed access to the word 'promoted', translated into the language being used by the person viewing the ad.
 */
@property (nonatomic, copy, readonly, nullable) NSString *promotedTranslation;
/**
 Typed access to the AdChoices icon. See `FBAdImage` for details. See `FBAdChoicesView` for an included implementation.
 */
@property (nonatomic, strong, readonly, nullable) FBAdImage *adChoicesIcon;
/**
 Typed access to the icon image. Only available after ad is successfully loaded.
 */
@property (nonatomic, strong, readonly, nullable) UIImage *iconImage;
/**
 Aspect ratio of the ad creative.
 */
@property (nonatomic, assign, readonly) CGFloat aspectRatio;
/**
 Typed access to the AdChoices URL. Navigate to this link when the icon is tapped. See `FBAdChoicesView` for an included
 implementation.
 */
@property (nonatomic, copy, readonly, nullable) NSURL *adChoicesLinkURL;
/**
 Typed access to the AdChoices text, usually a localized version of "AdChoices". See `FBAdChoicesView` for an included
 implementation.
 */
@property (nonatomic, copy, readonly, nullable) NSString *adChoicesText;
/**
 Typed access to the ad format type. See `FBAdFormatType` enum for more details.
 */
@property (nonatomic, assign, readonly) FBAdFormatType adFormatType;
/**
 Read only access to native ad caching policy, it is set in loadAWithMediaCachePolicy:
 */
@property (nonatomic, readonly) FBNativeAdsCachePolicy mediaCachePolicy;

/**
 Call isAdValid to check whether native ad is valid & internal consistent prior rendering using its properties. If
 rendering is done as part of the loadAd callback, it is guarantee to be consistent
 */
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;

@property (nonatomic, getter=isRegistered, readonly) BOOL registered;
/**
 FBAdExtraHint to provide extra info. Note: FBAdExtraHint is deprecated in AudienceNetwork. See FBAdExtraHint for more
 details

 */
@property (nonatomic, strong, nullable) FBAdExtraHint *extraHint;
/**
 This is a method to disconnect a FBNativeAd with the UIView you used to display the native ads.
 */
- (void)unregisterView;

/**
 Begins loading the FBNativeAd content.

 You can implement `nativeAdDidLoad:` and `nativeAd:didFailWithError:` methods
 of `FBNativeAdDelegate` if you would like to be notified as loading succeeds or fails.
 */
- (void)loadAd FB_DEPRECATED_WITH_MESSAGE(
    "This method will be removed in future version. Use -loadAdWithBidPayload instead."
    "See https://www.facebook.com/audiencenetwork/resources/blog/bidding-moves-from-priority-to-imperative-for-app-monetization"
    "for more details.");

/**
 Begins loading the FBNativeAd content.

 You can implement `nativeAdDidLoad:` and `nativeAd:didFailWithError:` methods
 of `FBNativeAdDelegate` if you would like to be notified as loading succeeds or fails.

 @param mediaCachePolicy controls which media (images, video, etc) from the native ad are cached before the native ad
 calls nativeAdLoaded on its delegate. The default is to cache everything. Note that impression is not logged until the
 media for the ad is visible on screen (Video or Image for FBNativeAd / Icon for FBNativeBannerAd) and setting this to
 anything else than FBNativeAdsCachePolicyAll will delay the impression call.
 */
- (void)loadAdWithMediaCachePolicy:(FBNativeAdsCachePolicy)mediaCachePolicy
    FB_DEPRECATED_WITH_MESSAGE(
        "This method will be removed in future version. Use -loadAdWithBidPayload:mediaCachePolicy: instead."
        "See https://www.facebook.com/audiencenetwork/resources/blog/bidding-moves-from-priority-to-imperative-for-app-monetization"
        "for more details.");
;

/**
 Begins loading the FBNativeAd content from a bid payload attained through a server side bid.

 @param bidPayload The payload of the ad bid. You can get your bid payload from Facebook bidder endpoint.
 */
- (void)loadAdWithBidPayload:(NSString *)bidPayload;

/**
 Begins loading the FBNativeAd content from a bid payload attained through a server side bid.

 @param bidPayload The payload of the ad bid. You can get your bid payload from Facebook bidder endpoint.

 @param mediaCachePolicy controls which media (images, video, etc) from the native ad are cached before the native ad
 calls nativeAdLoaded on its delegate. The default is to cache everything. Note that impression is not logged until the
 media for the ad is visible on screen (Video or Image for FBNativeAd / Icon for FBNativeBannerAd) and setting this to
 anything else than FBNativeAdsCachePolicyAll will delay the impression call.
 */
- (void)loadAdWithBidPayload:(NSString *)bidPayload mediaCachePolicy:(FBNativeAdsCachePolicy)mediaCachePolicy;

/**
 Creates a new instance of a FBNativeAdBase from a bid payload. The actual subclass returned will depend on the contents
 of the payload.

 @param placementId The placement ID of the ad.

 @param bidPayload The bid payload received from the server.

 @param error An out value that returns any error encountered during init.
 */
+ (nullable instancetype)nativeAdWithPlacementId:(NSString *)placementId
                                      bidPayload:(NSString *)bidPayload
                                           error:(NSError *__autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
