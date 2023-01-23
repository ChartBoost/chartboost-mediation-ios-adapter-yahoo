// Copyright 2022-2023 Chartboost, Inc.
// 
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file.

//
//  YahooAdapterConfiguration.swift
//  ChartboostHeliumAdapterYahoo
//
//  Created by Vu Chau on 9/13/22.
//

import Foundation
import YahooAds

/// A list of externally configurable properties pertaining to the partner SDK that can be retrieved and set by publishers.
@objc public class YahooAdapterConfiguration: NSObject {
    
    /// Flag that can optionally be set to enable Yahoo's verbose logging.
    /// Disabled by default.
    @objc public static var verboseLogging: Bool = false {
        didSet {
            YASAds.logLevel = verboseLogging ? .verbose : .info
            print("Yahoo SDK verbose logging set to \(verboseLogging)")
        }
    }
}
