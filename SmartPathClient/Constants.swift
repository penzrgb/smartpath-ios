//
//  Constants.swift
//  SmartPathClient
//
//  Created by Glenn Schmidt on 29/07/2016.
//

import Foundation
import CoreLocation
import UIKit

enum LightType {
    case CCMercuryVapor
    case HPSodium
}

let ArrayOfLightPoints: [(lat: CLLocationDegrees, long: CLLocationDegrees, type: LightType)] = [
    (-38.197111, 144.70274, .CCMercuryVapor),
    (-38.195572, 144.70308, .CCMercuryVapor),
    (-38.196415, 144.70311, .CCMercuryVapor),
    (-38.197078, 144.70381, .CCMercuryVapor),
    (-38.196549, 144.70419, .CCMercuryVapor),
    (-38.146425, 144.70553, .HPSodium)
]

let LightRadius: CLLocationDistance = 10.0

let LightStrokeColor: UIColor = UIColor.yellowColor()
let LightFillColor: UIColor = UIColor.yellowColor().colorWithAlphaComponent(0.5)

let TreeStrokeColor: UIColor = UIColor.greenColor()
let TreeFillColor: UIColor = UIColor.greenColor().colorWithAlphaComponent(0.5)