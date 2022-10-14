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

/// The Helium Yahoo adapter.
final class YahooAdapter: PartnerAdapter {
    
    /// The version of the partner SDK, e.g. "5.13.2"
    let partnerSDKVersion = kYASSDKVersionKey
    
    /// The version of the adapter, e.g. "2.5.13.2.0"
    /// The first number is Helium SDK's major version. The next 3 numbers are the partner SDK version. The last number is the build version of the adapter.
    let adapterVersion = "4.1.1.0.0"
    
    /// The partner's identifier.
    let partnerIdentifier = "yahoo"
    
    /// The partner's name in a human-friendly version.
    let partnerDisplayName = "Yahoo"
    
    /// The designated initializer for the adapter.
    /// Helium SDK will use this constructor to create instances of conforming types.
    /// - parameter storage: An object that exposes storage managed by the Helium SDK to the adapter.
    /// It includes a list of created `PartnerAd` instances. You may ignore this parameter if you don't need it.
    init(storage: PartnerAdapterStorage) {}
    
    /// Does any setup needed before beginning to load ads.
    /// - parameter configuration: Configuration data for the adapter to set up.
    /// - parameter completion: Closure to be performed by the adapter when it's done setting up. It should include an error indicating the cause for failure or `nil` if the operation finished successfully.
    func setUp(with configuration: PartnerConfiguration, completion: @escaping (Error?) -> Void) {
        log(.setUpStarted)
        
        guard let siteId = configuration.siteID, !siteId.isEmpty else {
            let error = error(.missingSetUpParameter(key: .siteIDKey))
            log(.setUpFailed(error))
            completion(error)
            return
        }
        
        // Yahoo's initialization needs to be done on the main thread
        DispatchQueue.main.async {
            let succeeded = YASAds.initialize(withSiteId: siteId)
            
            self.log(succeeded ? .setUpSucceded : .setUpFailed(self.error(.setUpFailure)))
            completion(succeeded ? nil : self.error(.setUpFailure))
        }
    }
    
    /// Fetches bidding tokens needed for the partner to participate in an auction.
    /// - parameter request: Information about the ad load request.
    /// - parameter completion: Closure to be performed with the fetched info.
    func fetchBidderInformation(request: PreBidRequest, completion: @escaping ([String : String]?) -> Void) {
        completion(nil)
    }
    
    /// Indicates if GDPR applies or not.
    /// - parameter applies: `true` if GDPR applies, `false` otherwise.
    func setGDPRApplies(_ applies: Bool) {
        if (applies) {
            YASAds.sharedInstance.applyGdpr()
            log(.privacyUpdated(setting: "GDPR", value: "applied"))
        } else {
            // YASAds does not support setting applyGDPR to false
        }
    }
    
    /// Indicates the user's GDPR consent status.
    /// - parameter status: One of the `GDPRConsentStatus` values depending on the user's preference.
    func setGDPRConsentStatus(_ status: GDPRConsentStatus) {
        // NO-OP as Helium does not support the TCF consent string.
    }
    
    /// Indicates if the user is subject to COPPA or not.
    /// - parameter isSubject: `true` if the user is subject, `false` otherwise.
    func setUserSubjectToCOPPA(_ isSubject: Bool) {
        if (isSubject) {
            YASAds.sharedInstance.applyCoppa()
            log(.privacyUpdated(setting: "COPPA", value: "applied"))
        } else {
            // YASAds does not support setting applyCOPPA to false
        }
    }
    
    /// Indicates the CCPA status both as a boolean and as a IAB US privacy string.
    /// - parameter hasGivenConsent: A boolean indicating if the user has given consent.
    /// - parameter privacyString: A IAB-compliant string indicating the CCPA status.
    func setCCPAConsent(hasGivenConsent: Bool, privacyString: String?) {
        guard let privacyString = privacyString, !privacyString.isEmpty else {
            log("Privacy string was empty, CCPA consent setting was not changed")
            return
        }
        YASAds.sharedInstance.add(YASCcpaConsent(consentString: privacyString))
        log(.privacyUpdated(setting: "YASCcpaConsent", value: privacyString))
    }
    
    /// Creates a new ad object in charge of communicating with a single partner SDK ad instance.
    /// Helium SDK calls this method to create a new ad for each new load request. Ad instances are never reused.
    /// Helium SDK takes care of storing and disposing of ad instances so you don't need to.
    /// `invalidate()` is called on ads before disposing of them in case partners need to perform any custom logic before the object gets destroyed.
    /// If for some reason a new ad cannot be provided an error should be thrown.
    /// - parameter request: Information about the ad load request.
    /// - parameter delegate: The delegate that will receive ad life-cycle notifications.
    func makeAd(request: PartnerAdLoadRequest, delegate: PartnerAdDelegate) throws -> PartnerAd {
        switch request.format {
        case .interstitial, .rewarded:
            return YahooAdapterFullscreenAd(adapter: self, request: request, delegate: delegate)
        case .banner:
            return YahooAdapterBannerAd(adapter: self, request: request, delegate: delegate)
        }
    }
}

/// Convenience extension to access Yahoo credentials from the configuration.
private extension PartnerConfiguration {
    var siteID: String? { credentials[.siteIDKey] as? String }
}

extension String {
    /// The key name for parsing the Yahoo Site ID
    static let siteIDKey = "site_id"
    /// The key name for the impression event.
    static let impressionKey = "adImpression"
    /// The key name for the video completion event.
    static let videoCompletionKey = "onVideoComplete"
}
