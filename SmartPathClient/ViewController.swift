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

class ViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, LocationSearchControllerDelegate {
    
    private let DefaultZoomLevel: Float = 18.0
    private let DefaultMapCenter = CLLocationCoordinate2D(latitude: -38.149918, longitude: 144.361719)
    private let ZoomEdgeInsets = UIEdgeInsetsMake(140, 30, 30, 30)
    
    @IBOutlet private weak var mapContainer: UIView!
    @IBOutlet private weak var locateMeButton: UIButton!
    @IBOutlet private weak var summaryLabel: UILabel!
    @IBOutlet private var searchController: LocationSearchController!
    
    private var mapView: GMSMapView!
    
    private var destMarker: GMSMarker? {
        willSet {
            if newValue != destMarker {
                destMarker?.map = nil
            }
        }
        didSet {
            destMarker?.map = self.mapView
        }
    }
    
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
        
        self.searchController.delegate = self
        self.summaryLabel.text = nil
        
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

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    

    //MARK: GMSMapViewDelegate
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        self.searchController.searchRegion = GMSCoordinateBounds(region: self.mapView.projection.visibleRegion())
        
        // Clear previously generated circles
        for circle in self.circles {
            circle.map = nil
        }
        
        // Clean up any circle references that don't have a map anymore.
        self.circles = self.circles.filter { $0.map == nil }
        
        let mapBounds = self.getVisibleMapBoundaries()
        
        // TODO: Make request to the backend server to get the map data for this bounding box.
        
        // TODO: Determine mode the user is in. Is the user in the Light mode or Trees mode?
        
        for lightSource in ArrayOfLightPoints {
            self.generateLight(CLLocationCoordinate2DMake(lightSource.lat, lightSource.long), radius: LightRadius)
        }
    }
    
    func mapView(mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            self.userTrackingEnabled = false
        }
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        self.searchController.searchField.resignFirstResponder()
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
    
    
    //MARK: LocationSearchControllerDelegate
    
    func searchController(controller: LocationSearchController,
                          didSelectResult result: GMSAutocompletePrediction)
    {
        guard let placeID = result.placeID else {
            return
        }
        GMSPlacesClient.sharedClient().lookUpPlaceID(placeID) { place, error in
            if let error = error {
                NSLog("\(self.dynamicType): Unable to look up place ID \(placeID): \(error))")
                return
            }
            if let place = place {
                NSLog("Place selected: \(place.coordinate) \(place.name)")
                
                //Create map marker for chosen destination
                let marker = GMSMarker()
                marker.position = place.coordinate
                marker.title = place.name
                marker.snippet = place.formattedAddress
                self.destMarker = marker
                
                //Pan and zoom the map so that the source and dest are both visible
                let startCoord = self.locationManager.location?.coordinate ?? self.mapView.camera.target
                let bounds = GMSCoordinateBounds(coordinate: startCoord, coordinate: place.coordinate)
                if let camera = self.mapView.cameraForBounds(bounds, insets: self.ZoomEdgeInsets) {
                    self.userTrackingEnabled = false
                    self.mapView.animateToCameraPosition(camera)
                }
            }
        }
    }
    
    func searchControllerDidActivate(controller: LocationSearchController) {
        self.summaryLabel.alpha = 0
        self.summaryLabel.text = "It’s dark out, so we’ll take you on the path with the most street lighting.\n\nWhere would you like to walk to?\n"
        
        UIView.animateWithDuration(0.5, animations: { 
            self.view.layoutIfNeeded()
        }) { _ in
            UIView.animateWithDuration(0.1, animations: { 
                self.summaryLabel.alpha = 1.0
            })
        }
    }
    
    func searchControllerDidDeactivate(controller: LocationSearchController) {
        self.summaryLabel.text = nil
        UIView.animateWithDuration(0.5) {
            self.view.layoutIfNeeded()
        }
    }

    
    //Private methods
    
    private func generateLight(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        self.placeCircleOnMap(coordinate, radius: radius, strokeColor: LightStrokeColor, fillColor: LightFillColor)
    }
    
    private func generateTree(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance) {
        self.placeCircleOnMap(coordinate, radius: radius, strokeColor: TreeStrokeColor, fillColor: TreeFillColor)
    }
    
    private func placeCircleOnMap(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, strokeColor: UIColor, fillColor: UIColor) {
        let circle: GMSCircle = GMSCircle(position: coordinate, radius: radius)
        circle.strokeColor = strokeColor
        circle.fillColor = fillColor
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
