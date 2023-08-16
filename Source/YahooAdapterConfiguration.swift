// Copyright 2022-2023 Chartboost, Inc.
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

import Foundation
import YahooAds
import os.log

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class YahooAdapterConfiguration: NSObject {
    
    private static let log = OSLog(subsystem: "com.chartboost.mediation.adapter.yahoo", category: "Configuration")

    /// Flag that can optionally be set to enable Yahoo's verbose logging.
    /// Disabled by default.
    @objc public static var verboseLogging: Bool = false {
        didSet {
            YASAds.logLevel = verboseLogging ? .verbose : .info
            if #available(iOS 12.0, *) {
                os_log(.debug, log: log, "Yahoo SDK verbose logging set to %{public}s", "\(verboseLogging)")
            }
        }
    }
}
