//
//  SmartPathAPIManager.swift
//  SmartPathClient
//
//  Created by Rodger Benham on 31/07/2016.
//  Copyright © 2016 SmartPath. All rights reserved.
//

import Foundation
import Alamofire

protocol SmartPathAPIManagerDelegate {
    func TreesUpdated(trees: NSArray)
    func LightsUpdated(lights: NSArray)
}

class SmartPathAPIManager {
    
    var delegate: SmartPathAPIManagerDelegate?
    
    func getTreesInBounds(latTopLeft: Double, longTopLeft: Double, latBottomRight: Double, longBottomRight: Double) {
        Alamofire.request(.POST, ApiPath + "/trees/bounds", parameters: [
            "data":
                [
                    "latTopLeft": latTopLeft,
                    "longTopLeft": longTopLeft,
                    "latBottomRight": latBottomRight,
                    "longBottomRight": longBottomRight
                ]
            ], encoding: .JSON)
            .responseJSON { response in
                if let JSON = response.result.value {
                    self.delegate?.TreesUpdated(JSON as! NSArray)
                }
        }
    }
    
    func getLightsInBounds(latTopLeft: Double, longTopLeft: Double, latBottomRight: Double, longBottomRight: Double) {
        Alamofire.request(.POST, ApiPath + "/lights/bounds", parameters: [
            "data":
                [
                    "latTopLeft": latTopLeft,
                    "longTopLeft": longTopLeft,
                    "latBottomRight": latBottomRight,
                    "longBottomRight": longBottomRight
            ]
            ], encoding: .JSON)
            .responseJSON { response in
                if let JSON = response.result.value {
                    self.delegate?.LightsUpdated(JSON as! NSArray)
                }
        }
    }
}