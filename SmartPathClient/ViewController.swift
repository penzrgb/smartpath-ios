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
    
    private let DefaultZoomLevel: Float = 18.0
    private let DefaultMapCenter = CLLocationCoordinate2D(latitude: -38.149918, longitude: 144.361719)
    
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
    
    private var circles: [GMSCircle] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create default camera position
        let camera = GMSCameraPosition.cameraWithLatitude(DefaultMapCenter.latitude,
            longitude: DefaultMapCenter.longitude, zoom: 10.0)
        
        // Create the map view
        self.mapView = GMSMapView.mapWithFrame(CGRect.zero, camera: camera)
        self.mapView.settings.rotateGestures = false
        self.mapView.settings.tiltGestures = false
        self.mapView.delegate = self
        self.mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.mapView.frame = self.mapContainer.bounds
        self.mapContainer.addSubview(mapView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.isVisible = true
        
        self.locationManager.delegate = self
        if (CLLocationManager.authorizationStatus() == .NotDetermined) {
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.userTrackingEnabled = true
            self.mapView.myLocationEnabled = true
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.isVisible = false
    }
    
    //MARK: GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        // Clear previously generated circles
        for circle in self.circles {
            circle.map = nil
        }
        
        // Clean up any circle references that don't have a map anymore.
        self.circles = self.circles.filter { $0.map == nil }
        
        let mapBounds = self.getVisibleMapBoundaries()
        
        // TODO: Make request to the backend server to get the map data for this bounding box.
        
        for lightSource in ArrayOfLightPoints {
            self.generateLight(CLLocationCoordinate2DMake(lightSource.lat, lightSource.long), radius: LightRadius)
        }
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
            self.userTrackingEnabled = true
            self.mapView.myLocationEnabled = true
        }
    }
     func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.userTrackingEnabled || !self.hasLocation {
            self.mapView.animateToLocation(locations[0].coordinate)
            if !self.hasLocation {
                self.hasLocation = true
                self.mapView.animateToZoom(DefaultZoomLevel)
            }
        }
    }
    
    //Private methods
    
    private func generateLight(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        let circle: GMSCircle = GMSCircle(position: coordinate, radius: radius)
        circle.strokeColor = UIColor.yellowColor()
        circle.fillColor = UIColor.yellowColor().colorWithAlphaComponent(0.5)
        circle.map = self.mapView
        self.circles.append(circle)
    }
    
    private func getVisibleMapBoundaries() -> (CLLocationCoordinate2D, CLLocationCoordinate2D) {
        let visibleRegion: GMSVisibleRegion = self.mapView.projection.visibleRegion()
        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(region: visibleRegion)
        // we've got what we want, but here are NE and SW points
        let northEast: CLLocationCoordinate2D = bounds.northEast
        let southWest: CLLocationCoordinate2D = bounds.southWest
        
        return (northEast, southWest)
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
