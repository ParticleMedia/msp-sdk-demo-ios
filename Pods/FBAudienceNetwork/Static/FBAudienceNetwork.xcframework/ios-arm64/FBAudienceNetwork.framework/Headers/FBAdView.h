/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <UIKit/UIKit.h>

#import <FBAudienceNetwork/FBAdExtraHint.h>
#import <FBAudienceNetwork/FBAdSize.h>
#import "FBAdDefines.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FBAdViewDelegate;

/**
 A customized UIView to represent a Facebook ad (a.k.a. banner ad).
 */
FB_CLASS_EXPORT
@interface FBAdView : UIView

/**
 Initializes an instance of FBAdView matching the given placement id.


 @param placementID The id of the ad placement. You can create your placement id from Facebook developers page.
 @param adSize The size of the ad; for example, kFBAdSizeHeight50Banner or kFBAdSizeHeight90Banner.
 @param rootViewController The view controller that will be used to present the ad and the app store view.
 */
- (instancetype)initWithPlacementID:(NSString *)placementID
                             adSize:(FBAdSize)adSize
                 rootViewController:(nullable UIViewController *)rootViewController NS_DESIGNATED_INITIALIZER;

/**
 Initializes an instance of FBAdView matching the given placement id with a given bidding payload.

 @param placementID The id of the ad placement. You can create your placement id from Facebook developers page.
 @param bidPayload The bid payload sent from the server.
 @param rootViewController The view controller that will be used to present the ad and the app store view.
 @param error An out value that returns any error encountered during init.
 */
- (nullable instancetype)initWithPlacementID:(NSString *)placementID
                                  bidPayload:(NSString *)bidPayload
                          rootViewController:(nullable UIViewController *)rootViewController
                                       error:(NSError *__autoreleasing *)error;

/**
 Begins loading the FBAdView content.



 You can implement `adViewDidLoad:` and `adView:didFailWithError:` methods
 of `FBAdViewDelegate` if you would like to be notified as loading succeeds or fails.
 */
- (void)loadAd FB_DEPRECATED_WITH_MESSAGE(
    "This method will be removed in future version. Use -loadAdWithBidPayload instead."
    "See https://www.facebook.com/audiencenetwork/resources/blog/bidding-moves-from-priority-to-imperative-for-app-monetization"
    "for more details.");

/**
 Begins loading the FBAdView content from a bid payload attained through a server side bid.



 You can implement `adViewDidLoad:` and `adView:didFailWithError:` methods
 of `FBAdViewDelegate` if you would like to be notified as loading succeeds or fails.


 @param bidPayload The payload of the ad bid. You can get your bid id from Facebook bidder endpoint.
 */
- (void)loadAdWithBidPayload:(NSString *)bidPayload;

/**
 Disables auto-refresh for the ad view. There is no reason to call this method anymore. Autorefresh is disabled by
 default.

 */
- (void)disableAutoRefresh FB_DEPRECATED;

/**
 Sets the rootViewController.
 */
- (void)setRootViewController:(UIViewController *)rootViewController;

/**
 Typed access to the id of the ad placement.
 */
@property (nonatomic, copy, readonly) NSString *placementID;
/**
 Typed access to the app's root view controller.
 */
@property (nonatomic, weak, readonly, nullable) UIViewController *rootViewController;
/**
 Call isAdValid to check whether ad is valid
 */
@property (nonatomic, getter=isAdValid, readonly) BOOL adValid;
/**
 the delegate
 */
@property (nonatomic, weak, nullable) id<FBAdViewDelegate> delegate;
/**
 FBAdExtraHint to provide extra info. Note: FBAdExtraHint is deprecated in AudienceNetwork. See FBAdExtraHint for more
 details

 */
@property (nonatomic, strong, nullable) FBAdExtraHint *extraHint;

@end

/**
 The methods declared by the FBAdViewDelegate protocol allow the adopting delegate to respond
 to messages from the FBAdView class and thus respond to operations such as whether the ad has
 been loaded, the person has clicked the ad.
 */
@protocol FBAdViewDelegate <NSObject>

@optional

/**
 Sent after an ad has been clicked by the person.


 @param adView An FBAdView object sending the message.
 */
- (void)adViewDidClick:(FBAdView *)adView;

/**
 When an ad is clicked, the modal view will be presented. And when the user finishes the
 interaction with the modal view and dismiss it, this message will be sent, returning control
 to the application.


 @param adView An FBAdView object sending the message.
 */
- (void)adViewDidFinishHandlingClick:(FBAdView *)adView;

/**
 Sent when an ad has been successfully loaded.


 @param adView An FBAdView object sending the message.
 */
- (void)adViewDidLoad:(FBAdView *)adView;

/**
 Sent after an FBAdView fails to load the ad.


 @param adView An FBAdView object sending the message.
 @param error An error object containing details of the error.
 */
- (void)adView:(FBAdView *)adView didFailWithError:(NSError *)error;

/**
 Sent immediately before the impression of an FBAdView object will be logged.


 @param adView An FBAdView object sending the message.
 */
- (void)adViewWillLogImpression:(FBAdView *)adView;

/**
 Sent when the dynamic height of an FBAdView is set dynamically.


 @param adView An FBAdView object sending the message.
 @param dynamicHeight The height that needs to be set dynamically.
 */
- (void)adView:(FBAdView *)adView setDynamicHeight:(double)dynamicHeight;

/**
 Sent when the position of an FBAdView is set dynamically.


 @param adView An FBAdView object sending the message.
 @param dynamicPosition CGPoint that indicates the new point of origin for the adView.
 */
- (void)adView:(FBAdView *)adView setDynamicPosition:(CGPoint)dynamicPosition;

/**
 Sent when the origin of an FBAdView is to be changed during an animation lasting a specific
 amount of time.


 @param position CGPoint specifying the new origin of the FBAdView
 @param duration CGFloat specifying the duration in seconds of the animation.
 */
- (void)adView:(FBAdView *)controller animateToPosition:(CGPoint)position withDuration:(CGFloat)duration;

/**
 Sent after an FBAdView fails to load the fullscreen view of an ad.


 @param adView An FBAdView object sending the message.
 @param error An error object containing details of the error.
 */
- (void)adView:(FBAdView *)adView fullscreenDidFailWithError:(NSError *)error;

/**
 Asks the delegate for a view controller to present modal content, such as the in-app
 browser that can appear when an ad is clicked.


 @return A view controller that is used to present modal content.
 */
@property (nonatomic, readonly, strong) UIViewController *viewControllerForPresentingModalView;

@end

NS_ASSUME_NONNULL_END
