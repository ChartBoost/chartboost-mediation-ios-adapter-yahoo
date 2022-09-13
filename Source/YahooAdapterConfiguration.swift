//
//  YahooAdapterConfiguration.swift
//  ChartboostHeliumAdapterYahoo
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import YahooAds

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
public class YahooAdapterConfiguration {
    /// Flag that can optionally be set to enable Yahoo's verbose logging.
    /// Disabled by default.
    private static var _verboseLogging = false
    public static var verboseLogging: Bool {
        get {
            return _verboseLogging
        }
        set {
            _verboseLogging = newValue
            YASAds.logLevel = _verboseLogging ? YASLogLevel.verbose : YASLogLevel.info
            
            print("The Yahoo Mobile SDK's verbose logging is \(_verboseLogging ? "enabled" : "disabled").")
        }
    }
}
