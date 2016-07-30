//
//  Global.swift
//  SmartPathClient
//
//  Created by Glenn Schmidt on 29/07/2016.
//

import UIKit
import CoreLocation

func runOnMainThread(closure: () -> ()) {
    if (NSThread.isMainThread()) {
        closure()
    } else {
        dispatch_sync(dispatch_get_main_queue(), closure)
    }
}

func runInBackground(block: dispatch_block_t) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
}

func dispatchAfter(seconds: NSTimeInterval, asyncBlock block: dispatch_block_t) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))),
                   dispatch_get_main_queue(), block);
}


extension UIViewController {
    
    func showAlert(title: String, message: String? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .Alert
        )
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func requestConfirmation(title: String, message: String? = nil, actionTitle: String,
        actionStyle: UIAlertActionStyle = .Default, popoverSource: AnyObject? = nil,
        then onConfirm: (()->()))
    {
        var alert: UIAlertController!
        if let view = popoverSource as? UIView {
            alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            alert.popoverPresentationController?.sourceView = view
            alert.popoverPresentationController?.sourceRect = view.bounds
        } else if let item = popoverSource as? UIBarButtonItem {
            alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            alert.popoverPresentationController?.barButtonItem = item
        } else {
            alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        }
        let okAction = UIAlertAction(title: actionTitle, style: actionStyle) { _ in
            onConfirm()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleLocationDenied() -> Bool {
        let status = CLLocationManager.authorizationStatus()
        if status == .Denied {
            self.requestConfirmation("Location Denied",
            message: "You have previously denied this app access to your location. You can change this in Settings.", actionTitle: "Settings", actionStyle: .Default)
            {
                dispatchAfter(0.1) {
                    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
            return true
        } else if status == .Restricted {
            self.showAlert("Location Restricted",
                message: "Due to the settings on your device, this app is not allowed to access your location.")
            return true
        }
        return false
    }
}