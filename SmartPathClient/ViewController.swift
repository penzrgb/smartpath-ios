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

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet private weak var mapContainer: UIView!
    @IBOutlet private weak var locateMeButton: UIButton!
    
    private var mapView: GMSMapView!
    
    private var isVisible: Bool = false
    private var hasLocation: Bool = false
    
    private var userTrackingEnabled: Bool = false {
        didSet {
            self.locateMeButton.selected = userTrackingEnabled
            if userTrackingEnabled {
                self.locationManager.startUpdatingLocation()
            } else {
                self.locationManager.stopUpdatingLocation()
            }
        }
    }
    
    private lazy var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        let camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 6.0)
        
        // Create the map view
        self.mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        self.mapView.delegate = self
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.mapView.frame = self.mapContainer.bounds
        self.mapContainer.addSubview(mapView)
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.isVisible = true
        
        self.locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.mapView.myLocationEnabled = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.isVisible = false
    }
    
    
    //MARK: GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            self.userTrackingEnabled = false
        }
    }
    
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == .AuthorizedAlways || status == .AuthorizedWhenInUse) {
            self.mapView.myLocationEnabled = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.userTrackingEnabled {
            self.mapView.animateToLocation(locations[0].coordinate)
        }
    }
    
    
    //MARK: Actions
    
    @IBAction func toggleUserTracking(sender: AnyObject) {
        if self.userTrackingEnabled {
            self.userTrackingEnabled = false
        } else if (!self.handleLocationDenied()) {
            self.userTrackingEnabled = true
        }
    }
    
}

