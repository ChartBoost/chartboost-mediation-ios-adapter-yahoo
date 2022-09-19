//
//  YahooAdAdapter.swift
//  ChartboostHeliumAdapterYahoo
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import HeliumSdk
import YahooAds
import UIKit

final class YahooAdAdapter: NSObject, PartnerLogger, PartnerErrorFactory {
    /// The current adapter instance
    let adapter: PartnerAdapter
    
    /// The current PartnerAdLoadRequest containing data relevant to the curent ad request
    let request: PartnerAdLoadRequest
    
    /// A PartnerAd object with a placeholder (nil) ad object.
    lazy var partnerAd = PartnerAd(ad: nil, details: [:], request: request)
    
    /// The partner ad delegate to send ad life-cycle events to.
    weak var partnerAdDelegate: PartnerAdDelegate?
    
    /// The key name for the impression event.
    let impressionKey = "adImpression"
    
    /// The key name for the video completion event.
    let videoCompletionKey = "onVideoComplete"
    
    /// The current UIViewController for ad presentation purposes.
    weak var viewController: UIViewController?
    
    /// The completion handler to notify Helium of ad load completion result.
    var loadCompletion: ((Result<PartnerAd, Error>) -> Void)?
    
    /// The completion handler to notify Helium of ad show completion result.
    var showCompletion: ((Result<PartnerAd, Error>) -> Void)?
    
    /// Create a new instance of the adapter.
    /// - Parameters:
    ///   - adapter: The current adapter instance
    ///   - request: The current AdLoadRequest containing data relevant to the curent ad request
    ///   - partnerAdDelegate: The partner ad delegate to notify Helium of ad lifecycle events.
    init(adapter: PartnerAdapter, request: PartnerAdLoadRequest, partnerAdDelegate: PartnerAdDelegate) {
        self.adapter = adapter
        self.request = request
        self.partnerAdDelegate = partnerAdDelegate
        
        super.init()
    }
    
    /// Attempt to load an ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad load completion result.
    func load(viewController: UIViewController?, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        if (viewController == nil) {
            completion(.failure(error(.noViewController)))
            return
        }
        
        self.viewController = viewController
        
        loadCompletion = { [weak self] result in
            if let self = self {
                do {
                    self.log(.loadSucceeded(try result.get()))
                } catch {
                    self.log(.loadFailed(self.request, error: error))
                }
            }
            
            self?.loadCompletion = nil
            completion(result)
        }
        
        switch request.format {
        case .banner:
            loadBannerAd(request: request)
        case .interstitial, .rewarded:
            loadFullscreenAd(request: request)
        }
    }
    
    /// Attempt to show the currently loaded ad.
    /// - Parameters:
    ///   - viewController: The ViewController for ad presentation purposes.
    ///   - completion: The completion handler to notify Helium of ad show completion result.
    func show(viewController: UIViewController, completion: @escaping (Result<PartnerAd, Error>) -> Void) {
        showCompletion = { [weak self] result in
            if let self = self {
                do {
                    self.log(.showSucceeded(try result.get()))
                } catch {
                    self.log(.showFailed(self.partnerAd, error: error))
                }
            }
            
            self?.showCompletion = nil
            completion(result)
        }
        
        switch request.format {
        case .banner:
            /// Banner does not have a separate show mechanism
            log(.showSucceeded(partnerAd))
            completion(.success(partnerAd))
        case .interstitial, .rewarded:
            showFullscreenAd(viewController: viewController)
        }
    }
}
