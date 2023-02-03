// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import UIKit
import YahooAds

/// The Chartboost Mediation Yahoo adapter banner ad.
final class YahooAdapterBannerAd: YahooAdapterAd, PartnerAd {
    
    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    var inlineView: UIView?
    
    /// The current UIViewController for ad presentation purposes.
    weak var viewController: UIViewController?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)
        
        guard let viewController = viewController else {
            let error = error(.showFailureViewControllerNotFound)
            log(.loadFailed(error))
            return completion(.failure(error))
        }
        
        self.viewController = viewController
        
        let adSize = YASInlineAdSize(
            width: UInt(request.size?.width ?? IABStandardAdSize.width),
            height: UInt(request.size?.height ?? IABStandardAdSize.height)
        )
        let config = YASInlinePlacementConfig(placementId: request.partnerPlacement, requestMetadata: nil, adSizes: [adSize])
        
        guard let ad = YASInlineAdView(placementId: request.partnerPlacement) else {
            let error = error(.loadFailureNoInlineView, description: "Failed to create YASInlineAdView")
            log(.loadFailed(error))
            return completion(.failure(error))
        }
        
        loadCompletion = completion
        inlineView = ad
        ad.delegate = self
        ad.load(with: config)
    }
    
    /// Shows a loaded ad.
    /// It will never get called for banner ads. You may leave the implementation blank for that ad format.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        // no-op
    }
}
    
// MARK: - YASInlineAdViewDelegate

extension YahooAdapterBannerAd: YASInlineAdViewDelegate {
    
    func inlineAdDidLoad(_ inlineAd: YASInlineAdView) {
        log(.loadSucceeded)
        loadCompletion?(.success([:])) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func inlineAdLoadDidFail(_ inlineAd: YASInlineAdView, withError errorInfo: YASErrorInfo) {
        log(.loadFailed(errorInfo))
        loadCompletion?(.failure(errorInfo)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func inlineAdDidFail(_ inlineAd: YASInlineAdView, withError errorInfo: YASErrorInfo) {
        /// Banner ads do not have a separate "show" mechanism so we will only log this event.
        log(.delegateCallIgnored)
    }
    
    func inlineAdPresentingViewController() -> UIViewController? {
        viewController
    }
    
    func inlineAd(_ inlineAd: YASInlineAdView, event eventId: String, source: String, arguments: [String : Any]) {
        if (eventId == .impressionKey) {
            log(.didTrackImpression)
            delegate?.didTrackImpression(self, details: [:]) ?? log(.delegateUnavailable)
        }
    }
    
    func inlineAdDidExpand(_ inlineAd: YASInlineAdView) {
        log(.delegateCallIgnored)
    }
    
    func inlineAdDidCollapse(_ inlineAd: YASInlineAdView) {
        log(.delegateCallIgnored)
    }
    
    func inlineAdClicked(_ inlineAd: YASInlineAdView) {
        log(.didClick(error: nil))
        delegate?.didClick(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func inlineAdDidLeaveApplication(_ inlineAd: YASInlineAdView) {
        log(.delegateCallIgnored)
    }
    
    func inlineAdDidResize(_ inlineAd: YASInlineAdView) {
        log(.delegateCallIgnored)
    }
    
    func inlineAdDidRefresh(_ inlineAd: YASInlineAdView) {
        log(.delegateCallIgnored)
    }
}
