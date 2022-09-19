//
//  YahooAdAdapter+Banner.swift
//  ChartboostHeliumAdapterYahoo
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import YahooAds

/// Collection of banner-sepcific API implementations
extension YahooAdAdapter: YASInlineAdViewDelegate {
    /// Attempt to load a banner ad.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    func loadBannerAd(request: PartnerAdLoadRequest) {
        let adSize = YASInlineAdSize(width: UInt(request.size?.width ?? 320), height: UInt(request.size?.height ?? 50))
        let config = YASInlinePlacementConfig(placementId: request.partnerPlacement, requestMetadata: nil, adSizes: [adSize])
        
        guard let ad = YASInlineAdView(placementId: request.partnerPlacement) else {
            loadCompletion?(.failure(self.error(.noBidPayload(request))))
            loadCompletion = nil
            
            return
        }
        
        partnerAd = PartnerAd(ad: ad, details: [:], request: request)
        
        ad.delegate = self
        ad.load(with: config)
    }
    
    // MARK: - YASInlineAdViewDelegate
    
    func inlineAdDidLoad(_ inlineAd: YASInlineAdView) {
        loadCompletion?(.success(partnerAd)) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func inlineAdLoadDidFail(_ inlineAd: YASInlineAdView, withError errorInfo: YASErrorInfo) {
        loadCompletion?(.failure(self.error(.loadFailure(request), error: errorInfo))) ?? log(.loadResultIgnored)
        loadCompletion = nil
    }
    
    func inlineAdDidFail(_ inlineAd: YASInlineAdView, withError errorInfo: YASErrorInfo) {
        /// Banner ads do not have a separate "show" mechanism so we will only log this event.
        log("inlineAdDidFail for placement \(inlineAd.placementId) and error \(errorInfo.description)")
    }
    
    func inlineAdPresentingViewController() -> UIViewController? {
        return self.viewController
    }
    
    func inlineAd(_ inlineAd: YASInlineAdView, event eventId: String, source: String, arguments: [String : Any]) {
        if (eventId == impressionKey) {
            log(.didTrackImpression(partnerAd))
            partnerAdDelegate?.didTrackImpression(partnerAd) ?? log(.delegateUnavailable)
        }
    }
    
    func inlineAdDidExpand(_ inlineAd: YASInlineAdView) {
        log("inlineAdDidExpand for placement \(inlineAd.placementId).")
    }
    
    func inlineAdDidCollapse(_ inlineAd: YASInlineAdView) {
        log("inlineAdDidCollapse for placement \(inlineAd.placementId).")
    }
    
    func inlineAdClicked(_ inlineAd: YASInlineAdView) {
        log(.didClick(partnerAd, error: nil))
        partnerAdDelegate?.didClick(partnerAd) ?? log(.delegateUnavailable)
    }
    
    func inlineAdDidLeaveApplication(_ inlineAd: YASInlineAdView) {
        log("inlineAdDidLeaveApplication for placement \(inlineAd.placementId).")
    }
    
    func inlineAdDidResize(_ inlineAd: YASInlineAdView) {
        log("inlineAdDidResize for placement \(inlineAd.placementId).")
    }
    
    func inlineAdDidRefresh(_ inlineAd: YASInlineAdView) {
        log("inlineAdDidRefresh for placement \(inlineAd.placementId).")
    }
}
