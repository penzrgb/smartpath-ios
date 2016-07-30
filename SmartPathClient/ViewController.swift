//
//  ViewController.swift
//  SmartPathClient
//
//  Created by Rodger Benham on 30/07/2016.
//  Copyright © 2016 SmartPath. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    private var mapView: GMSMapView!
    
    private var isVisible: Bool = false
    private var hasLocation: Bool = false
    
    private lazy var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.cameraWithLatitude(-38.197111, longitude: 144.70274, zoom: 6.0)
        self.mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.mapView.frame = self.view.bounds
        self.view.addSubview(mapView)
        
        for lightSource in ArrayOfLightPoints {
            let circle: GMSCircle = GMSCircle(position: CLLocationCoordinate2DMake(lightSource.lat, lightSource.long), radius: 10.0)
            circle.strokeColor = UIColor.yellowColor()
            circle.fillColor = UIColor.yellowColor().colorWithAlphaComponent(0.5)
            circle.map = self.mapView
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.isVisible = true
        
        if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.mapView.myLocationEnabled = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.isVisible = false
    }
    
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedAlways || status == .AuthorizedWhenInUse) {
            self.mapView.myLocationEnabled = true
        }
    }
    
}

