// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import ChartboostMediationSDK
import Foundation
import YahooAds

/// The Chartboost Mediation Yahoo adapter fullscreen ad.
final class YahooAdapterFullscreenAd: YahooAdapterAd, PartnerAd {
    
    /// The partner ad view to display inline. E.g. a banner view.
    /// Should be nil for full-screen ads.
    var inlineView: UIView? { nil }
    
    /// The Yahoo ad instance.
    private var ad: YASInterstitialAd?
    
    /// Loads an ad.
    /// - parameter viewController: The view controller on which the ad will be presented on. Needed on load for some banners.
    /// - parameter completion: Closure to be performed once the ad has been loaded.
    func load(with viewController: UIViewController?, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.loadStarted)
        
        loadCompletion = completion
        
        let config = YASInterstitialPlacementConfig(placementId: request.partnerPlacement, requestMetadata: nil)
        let ad = YASInterstitialAd(placementId: request.partnerPlacement)
        self.ad = ad
        ad.delegate = self
        ad.load(with: config)
    }
    
    /// Shows a loaded ad.
    /// It will never get called for banner ads. You may leave the implementation blank for that ad format.
    /// - parameter viewController: The view controller on which the ad will be presented on.
    /// - parameter completion: Closure to be performed once the ad has been shown.
    func show(with viewController: UIViewController, completion: @escaping (Result<PartnerEventDetails, Error>) -> Void) {
        log(.showStarted)
        
        if let ad = ad {
            showCompletion = completion
            ad.show(from: viewController)
        } else {
            let error = error(.showFailureAdNotReady)
            log(.showFailed(error))
            completion(.failure(error))
        }
    }
}

// MARK: - YASInterstitialAdDelegate

extension YahooAdapterFullscreenAd: YASInterstitialAdDelegate {
    
    func interstitialAdDidLoad(_ interstitialAd: YASInterstitialAd) {
        log(.loadSucceeded)
        loadCompletion?(.success([:])) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func interstitialAdLoadDidFail(_ interstitialAd: YASInterstitialAd, withError errorInfo: YASErrorInfo) {
        log(.loadFailed(errorInfo))
        loadCompletion?(.failure(errorInfo)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func interstitialAdDidFail(_ interstitialAd: YASInterstitialAd, withError errorInfo: YASErrorInfo) {
        log(.showFailed(errorInfo))
        showCompletion?(.failure(errorInfo)) ?? log(.showResultIgnored)
        showCompletion = nil
    }
    
    func interstitialAdDidShow(_ interstitialAd: YASInterstitialAd) {
        log(.showSucceeded)
        showCompletion?(.success([:])) ?? log(.showResultIgnored)
        showCompletion = nil
    }
    
    func interstitialAdDidClose(_ interstitialAd: YASInterstitialAd) {
        log(.didDismiss(error: nil))
        delegate?.didDismiss(self, details: [:], error: nil) ?? log(.delegateUnavailable)
    }
    
    func interstitialAdClicked(_ interstitialAd: YASInterstitialAd) {
        log(.didClick(error: nil))
        delegate?.didClick(self, details: [:]) ?? log(.delegateUnavailable)
    }
    
    func interstitialAdDidLeaveApplication(_ interstitialAd: YASInterstitialAd) {
        log(.delegateCallIgnored)
    }
    
    func interstitialAdEvent(_ interstitialAd: YASInterstitialAd, source: String, eventId: String, arguments: [String : Any]?) {
        if (eventId == .impressionKey) {
            log(.didTrackImpression)
            delegate?.didTrackImpression(self, details: [:]) ?? log(.delegateUnavailable)
        }
        
        if (eventId == .videoCompletionKey) {
            log(.didReward)
            delegate?.didReward(self, details: [:]) ?? log(.delegateUnavailable)
        }
    }
}
