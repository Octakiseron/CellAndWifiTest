//
//  IJReachability+Monitoring.swift
//  iflix
//
//  Created by Tobias Lie Andersen on 27.05.15.
//  Copyright (c) 2015 Knowit. All rights reserved.
//

import Foundation

extension IJReachability {

    class func startReachabilityMonitoring() {
        AFNetworkReachabilityManager.sharedManager().startMonitoring()
    }
    
    class func stopReachabilityMonitoring() {
        AFNetworkReachabilityManager.sharedManager().stopMonitoring()
    }
    
    class func setReachabilityChangedClosures(networkState: IJReachabilityType? = nil, toWifi: ()->(), toWAN: ()->(), lostConnection: ()->() ) {

        var initState: IJReachabilityType? = networkState
        
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock {(status: AFNetworkReachabilityStatus) in
            switch status {
            case .NotReachable, .Unknown:
                lostConnection()
                
            case .ReachableViaWWAN:
                if initState != .WWAN {
                    initState = nil
                    toWAN()
                }
                
            case .ReachableViaWiFi:
                if initState != .WiFi {
                    initState = nil
                    toWifi()
                }
            }
        }
    }
    
    class func clearReachabilityChangedClosures() {
        AFNetworkReachabilityManager.sharedManager().setReachabilityStatusChangeBlock {(_) in }
    }
}





