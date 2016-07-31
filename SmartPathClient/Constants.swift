//
//  Constants.swift
//  SmartPathClient
//
//  Created by Glenn Schmidt on 29/07/2016.
//

import Foundation
import CoreLocation
import UIKit

let GoogleAPIKey = "AIzaSyAM2PI58TjKpsyu038eW8wdbC-StauLw7g"

enum LightType {
    case CCMercuryVapor
    case HPSodium
}

struct StreetLight {
    var coordinate: CLLocationCoordinate2D
    var coverageRadius: CLLocationDistance
    var type: LightType
}

let ExampleStreetLights: [StreetLight] = [
    StreetLight(coordinate: CLLocationCoordinate2D(latitude: -38.197111, longitude: 144.70274), coverageRadius: 10.0, type: .CCMercuryVapor),
    StreetLight(coordinate: CLLocationCoordinate2D(latitude: -38.195572, longitude: 144.70308), coverageRadius: 10.0, type: .CCMercuryVapor),
    StreetLight(coordinate: CLLocationCoordinate2D(latitude: -38.196415, longitude: 144.70311), coverageRadius: 10.0, type: .CCMercuryVapor),
    StreetLight(coordinate: CLLocationCoordinate2D(latitude: -38.197078, longitude: 144.70381), coverageRadius: 10.0, type: .CCMercuryVapor),
    StreetLight(coordinate: CLLocationCoordinate2D(latitude: -38.196549, longitude: 144.70419), coverageRadius: 10.0, type: .CCMercuryVapor),
    StreetLight(coordinate: CLLocationCoordinate2D(latitude: -38.146425, longitude: 144.70553), coverageRadius: 10.0, type: .HPSodium)
]

let LightStrokeColor: UIColor = UIColor.yellowColor()
let LightFillColor: UIColor = UIColor.yellowColor().colorWithAlphaComponent(0.5)

let TreeStrokeColor: UIColor = UIColor.greenColor()
let TreeFillColor: UIColor = UIColor.greenColor().colorWithAlphaComponent(0.5)