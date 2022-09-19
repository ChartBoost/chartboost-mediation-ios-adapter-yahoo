//
//  YahooAdAdapter+Interstitial.swift
//  ChartboostHeliumAdapterYahoo
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import YahooAds

/// Collection of interstitial-sepcific API implementations
extension YahooAdAdapter: YASInterstitialAdDelegate {
    /// Attempt to load a fullscreen ad.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    func loadFullscreenAd(request: PartnerAdLoadRequest) {
        let config = YASInterstitialPlacementConfig(placementId: request.partnerPlacement, requestMetadata: nil)
        let ad = YASInterstitialAd(placementId: request.partnerPlacement)
        
        partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        
        ad.delegate = self
        ad.load(with: config)
    }
    
    /// Attempt to show the currently loaded fullscreen ad.
    /// - Parameter viewController: The ViewController for ad presentation purposes.
    func showFullscreenAd(viewController: UIViewController) {
        if let ad = partnerAd.ad as? YASInterstitialAd {
            ad.show(from: viewController)
        } else {
            showCompletion?(.failure(error(.showFailure(partnerAd), description: "Ad instance is nil/not a YASInterstitialAd.")))
            showCompletion = nil
        }
    }
    
    // MARK: - YASInterstitialAdDelegate
    
    func interstitialAdDidLoad(_ interstitialAd: YASInterstitialAd) {
        loadCompletion?(.success(partnerAd)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func interstitialAdLoadDidFail(_ interstitialAd: YASInterstitialAd, withError errorInfo: YASErrorInfo) {
        loadCompletion?(.failure(self.error(.loadFailure(request), error: errorInfo))) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func interstitialAdDidFail(_ interstitialAd: YASInterstitialAd, withError errorInfo: YASErrorInfo) {
        showCompletion?(.failure(self.error(.showFailure(partnerAd), error: errorInfo))) ?? log(.showResultIgnored)
        showCompletion = nil
    }
    
    func interstitialAdDidShow(_ interstitialAd: YASInterstitialAd) {
        showCompletion?(.success(partnerAd)) ?? log(.showResultIgnored)
        showCompletion = nil
    }
    
    func interstitialAdDidClose(_ interstitialAd: YASInterstitialAd) {
        log(.didDismiss(partnerAd, error: nil))
        partnerAdDelegate?.didDismiss(partnerAd, error: nil) ?? log(.delegateUnavailable)
    }
    
    func interstitialAdClicked(_ interstitialAd: YASInterstitialAd) {
        log(.didClick(partnerAd, error: nil))
        partnerAdDelegate?.didClick(partnerAd) ?? log(.delegateUnavailable)
    }
    
    func interstitialAdDidLeaveApplication(_ interstitialAd: YASInterstitialAd) {
        log("interstitialAdDidLeaveApplication for placement \(String(describing: interstitialAd.placementId)).")
    }
    
    func interstitialAdEvent(_ interstitialAd: YASInterstitialAd, source: String, eventId: String, arguments: [String : Any]?) {
        if (eventId == impressionKey) {
            log(.didTrackImpression(partnerAd))
            partnerAdDelegate?.didTrackImpression(partnerAd) ?? log(.delegateUnavailable)
        }
        
        if (eventId == videoCompletionKey) {
            let reward = Reward(amount: 0, label: "")
            log(.didReward(partnerAd, reward: reward))
            partnerAdDelegate?.didReward(partnerAd, reward: reward) ?? log(.delegateUnavailable)
        }
    }
}
