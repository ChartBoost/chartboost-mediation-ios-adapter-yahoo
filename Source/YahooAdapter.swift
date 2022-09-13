//
//  YahooAdapter.swift
//  ChartboostHeliumAdapterYahoo
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import YahooAds
import UIKit

/// The Helium Yahoo adapter
final class YahooAdapter: PartnerAdapter {    
    /// Get the version of the Yahoo Mobile SDK.
    let partnerSDKVersion = kYASSDKVersionKey
    
    /// Get the version of the mediation adapter. To determine the version, use the following scheme to indicate compatibility:
    /// [Helium SDK Major Version].[Partner SDK Major Version].[Partner SDK Minor Version].[Partner SDK Patch Version].[Adapter Version]
    ///
    /// For example, if this adapter is compatible with Helium SDK 4.x.y and partner SDK 1.0.0, and this is its initial release, then its version should be 4.1.0.0.0.
    let adapterVersion = "4.1.1.0.0"
    
    /// Get the internal name of the partner.
    let partnerIdentifier = "yahoo"
    
    /// Get the external/official name of the partner.
    let partnerDisplayName = "Yahoo"
    
    /// The key name for parsing the Yahoo Site ID
    let siteIdKey = "site_id"
    
    /// Storage of adapter instances.  Keyed by the request identifier.
    var adapters: [String: YahooAdAdapter] = [:]
    
    /// Override this method to initialize the Yahoo Mobile SDK so that it's ready to request and display ads.
    /// - Parameters:
    ///   - configuration: The necessary initialization data provided by Helium.
    ///   - completion: Handler to notify Helium of task completion.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void) {
        log(.setUpStarted)
        
        guard let siteId = configuration.credentials[siteIdKey], !siteId.isEmpty else {
            let error = self.error(.setUpFailure, description: "Site ID is null or empty.")
            self.log(.setUpFailed(error))
            
            completion(error)
            return
        }
        
        // Yahoo's initialization needs to be done on the main thread
        DispatchQueue.main.async {
            let succeeded = YASAds.initialize(withSiteId:siteId)
            
            self.log(succeeded ? .setUpSucceded : .setUpFailed(self.error(.setUpFailure)))
            completion(succeeded ? nil : self.error(.setUpFailure))
        }
    }
    
    /// Override this method to compute and return a bid token for the bid request.
    /// - Parameters:
    ///   - request: The necessary data associated with the current bid request.
    ///   - completion: Handler to notify Helium of task completion.
    func fetchBidderInformation(request: PreBidRequest, completion: @escaping ([String : String]) -> Void) {
        log(.fetchBidderInfoStarted(request))
        log(.fetchBidderInfoSucceeded(request))
        
        completion([:])
    }
    
    /// Override this method to notify your partner SDK of GDPR applicability as determined by the Helium SDK.
    /// - Parameter applies: true if GDPR applies, false otherwise.
    func setGDPRApplies(_ applies: Bool) {
        if (applies) {
            YASAds.sharedInstance.applyGdpr()
        }
    }
    
    /// Override this method to notify your partner SDK of the GDPR consent status as determined by the Helium SDK.
    /// - Parameter status: The user's current GDPR consent status.
    func setGDPRConsentStatus(_ status: GDPRConsentStatus) {
        // NO-OP as Helium does not support the TCF consent string.
    }
    
    /// Override this method to notify your partner SDK of the COPPA subjectivity as determined by the Helium SDK.
    /// - Parameter isSubject: True if the user is subject to COPPA, false otherwise.
    func setUserSubjectToCOPPA(_ isSubject: Bool) {
        if (isSubject) {
            YASAds.sharedInstance.applyCcpa()
        }
    }
    
    /// Override this method to notify your partner SDK of the CCPA privacy String as supplied by the Helium SDK.
    /// - Parameters:
    ///   - hasGivenConsent: True if the user has given CCPA consent, false otherwise.
    ///   - privacyString: The CCPA privacy String.
    func setCCPAConsent(hasGivenConsent: Bool, privacyString: String?) {
        guard let privacyString = privacyString, !privacyString.isEmpty else {
            return
        }
        
        YASAds.sharedInstance.add(YASCcpaConsent(consentString: privacyString))
    }
    
    /// Override this method to make an ad request to the partner SDK for the given ad format.
    /// - Parameters:
    ///   - request: The relevant data associated with the current ad load call.
    ///   - partnerAdDelegate: Delegate for ad lifecycle notification purposes.
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: Handler to notify Helium of task completion.
    func load(request: PartnerAdLoadRequest, partnerAdDelegate: PartnerAdDelegate, viewController: UIViewController?,
              completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        log(.loadStarted(request))
        
        /// Create and persist a new adapter instance
        let adapter = YahooAdAdapter(adapter: self, request: request, partnerAdDelegate: partnerAdDelegate)
        adapter.load(viewController: viewController, completion: completion)
        
        adapters[request.identifier] = adapter
    }
    
    /// Override this method to show the currently loaded ad.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be shown.
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: Handler to notify Helium of task completion.
    func show(_ partnerAd: PartnerAd, viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        log(.showStarted(partnerAd))
        
        /// Retrieve the adapter instance to show the ad
        if let adapter = adapters[partnerAd.request.identifier] {
            adapter.show(viewController: viewController, completion: completion)
        } else {
            let error = error(.noAdReadyToShow(partnerAd))
            log(.showFailed(partnerAd, error: error))
            
            completion(.failure(error))
        }
    }
    
    /// Override this method to discard current ad objects and release resources.
    /// - Parameters:
    ///   - partnerAd: The PartnerAd instance containing the ad to be invalidated.
    ///   - completion: Handler to notify Helium of task completion.
    func invalidate(_ partnerAd: PartnerAd, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        log(.invalidateStarted(partnerAd))
        
        if adapters[partnerAd.request.identifier] != nil {
            adapters.removeValue(forKey: partnerAd.request.identifier)
            
            log(.invalidateSucceeded(partnerAd))
            completion(.success(partnerAd))
        } else {
            let error = error(.noAdToInvalidate(partnerAd))
            
            log(.invalidateFailed(partnerAd, error: error))
            completion(.failure(error))
        }
    }
}
