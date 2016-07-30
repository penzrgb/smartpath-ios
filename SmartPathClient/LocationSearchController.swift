//
//  LocationSearchController.swift
//  SmartPathClient
//
//  Created by Glenn Schmidt on 30/07/2016.
//  Copyright © 2016 SmartPath. All rights reserved.
//

import UIKit
import GoogleMaps

class LocationSearchController: NSObject, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, GMSAutocompleteFetcherDelegate {
    
    @IBOutlet var searchField: UITextField!
    @IBOutlet weak var delegate: LocationSearchControllerDelegate?
    
    var searchRegion: GMSCoordinateBounds?
    var tableView: UITableView {
        if (self._tableView == nil) {
            self.createTableView()
        }
        return self._tableView!
    }
    var resultsViewHeight: CGFloat = 150 {
        didSet {
            if let constraint = self.heightConstraint {
                constraint.constant = self.resultsViewHeight
            }
        }
    }
    
    
    //MARK: Private
    
    private var _tableView: UITableView?
    private var heightConstraint: NSLayoutConstraint?
    private var fetcher: GMSAutocompleteFetcher?
    private var results: [GMSAutocompletePrediction] = [] {
        didSet {
            self._tableView?.reloadData()
        }
    }
    
    private let CellIdentifier = "Cell"
    
    private func createTableView() {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.layer.borderColor = UIColor.lightGrayColor().CGColor
        tableView.layer.borderWidth = 1.0
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.heightConstraint = NSLayoutConstraint(item: tableView, attribute: .Height,
            relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1,
            constant: self.resultsViewHeight)
        
        self._tableView = tableView
    }
    
    private func showTableView() {
        let tableView = self.tableView
        if (tableView.superview != nil) {
            return
        }
        guard let superview = self.searchField?.superview else {
            return
        }

        self.results = []
        superview.addSubview(tableView)
        superview.bringSubviewToFront(tableView)
        
        let leftConstraint = NSLayoutConstraint(item: tableView, attribute: .Left,
            relatedBy: .Equal, toItem: self.searchField, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint =  NSLayoutConstraint(item: tableView, attribute: .Right,
            relatedBy: .Equal, toItem: self.searchField, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: tableView, attribute: .Top,
            relatedBy: .Equal, toItem: self.searchField, attribute: .Bottom, multiplier: 1, constant: 1)
        
        NSLayoutConstraint.activateConstraints([
            leftConstraint, rightConstraint, self.heightConstraint!, topConstraint
        ])
    }
    
    private func hideTableView() {
        if (self.tableView.superview == nil) {
            return
        }
        self.tableView.removeFromSuperview()
    }
    
    private func search(query: String) {
        if self.fetcher == nil {
            let filter = GMSAutocompleteFilter()
            filter.country = "AU"
            self.fetcher = GMSAutocompleteFetcher(bounds: self.searchRegion, filter: filter)
            self.fetcher?.delegate = self
        }
        self.fetcher?.sourceTextHasChanged(query)
    }
    
    
    //MARK: GMSAutocompleteFetcherDelegate
    
    func didAutocompleteWithPredictions(predictions: [GMSAutocompletePrediction]) {
        self.results = predictions
    }
    
    func didFailAutocompleteWithError(error: NSError) {
        NSLog("\(self.dynamicType): Autocomplete failed: \(error)")
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let searchText = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if (!searchText.isEmpty) {
            self.showTableView()
            self.search(searchText)
        } else {
            self.hideTableView()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField.text?.isEmpty == false) {
            self.showTableView()
            self.search(textField.text!)
        }
        self.delegate?.searchControllerDidActivate?(self)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.hideTableView()
        self.fetcher = nil
        self.delegate?.searchControllerDidDeactivate?(self)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    //MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.results.count
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
            ?? UITableViewCell(style: .Value1, reuseIdentifier: CellIdentifier)
        
        let object = self.results[indexPath.row]
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.textLabel?.attributedText = object.attributedPrimaryText
        cell.detailTextLabel?.attributedText = object.attributedSecondaryText
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let result = self.results[indexPath.row]
        self.delegate?.searchController(self, didSelectResult: result)
        self.searchField.text = result.attributedPrimaryText.string
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.searchField.resignFirstResponder()
    }
}

@objc protocol LocationSearchControllerDelegate: AnyObject {
    func searchController(controller: LocationSearchController, didSelectResult result: GMSAutocompletePrediction)
    
    optional func searchControllerDidActivate(controller: LocationSearchController)
    
    optional func searchControllerDidDeactivate(controller: LocationSearchController)
}