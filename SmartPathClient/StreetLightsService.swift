//
//  StreetLightsService.swift
//  SmartPathClient
//
//  Created by Glenn Schmidt on 31/07/2016.
//  Copyright © 2016 SmartPath. All rights reserved.
//

import Foundation
import CoreLocation

let StreetLightsServiceErrorDomain = "StreetLightsServiceErrorDomain"

class StreetLightsService: NSObject {
    
    private let baseUrl = NSURL(string: "http://data.gov.au/api/action/datastore_search_sql")!
    
    private var lastTask: NSURLSessionDataTask?
    

    func findLightsInRegion(topLeft: CLLocationCoordinate2D, bottomRight: CLLocationCoordinate2D,
                            completion: (([StreetLight], NSError?)->()))
    {
        let latMin = min(topLeft.latitude, bottomRight.latitude)
        let latMax = max(topLeft.latitude, bottomRight.latitude)
        let lonMin = min(topLeft.longitude, bottomRight.longitude)
        let lonMax = max(topLeft.longitude, bottomRight.longitude)
        
        let params = [
            "sql": "SELECT * from \"fe8c4602-db7c-4fba-96f7-7c747b82ca61\" WHERE \"AGD66Latitude\" > \(latMin) AND \"AGD66Longitude\" > \(lonMin) AND \"AGD66Latitude\" < \(latMax) AND \"AGD66Longitude\" < \(lonMax)"
        ]
        
        let request = NSMutableURLRequest(URL: self.baseUrl)
        request.HTTPMethod = "POST"
        
        let body = try! NSJSONSerialization.dataWithJSONObject(params, options: [])
        request.HTTPBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let task = self.lastTask {
            task.cancel()
        }
        self.lastTask = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) in
            guard let httpResponse = response as? NSHTTPURLResponse else {
                return
            }
            
            if let data = data, body = String(data: data, encoding: NSUTF8StringEncoding) {
                let bodyObj = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
                
                if (httpResponse.statusCode < 200 || httpResponse.statusCode > 299) {
                    let message = "Server returned status \(httpResponse.statusCode) with data: "
                        + body
                    NSLog("\(self.dynamicType): \(message)")
                    let error = NSError(
                        domain: StreetLightsServiceErrorDomain,
                        code: httpResponse.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: message
                        ]
                    )
                    completion([], error)
                    
                } else {
                    if let dict = bodyObj as? [String: AnyObject] {
                        let lights = self.decodeLights(dict)
                        completion(lights, nil)
                    } else {
                        let error = NSError(
                            domain: StreetLightsServiceErrorDomain,
                            code: 0,
                            userInfo: [NSLocalizedDescriptionKey:
                                "Unable to decode server response body"]
                        )
                        completion([], error)
                    }
                }
                
            } else {
                let error = NSError(
                    domain: StreetLightsServiceErrorDomain,
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey:
                        "Server returned status \(httpResponse.statusCode) with no body"]
                )
                completion([], error)
            }
        }
        lastTask?.resume()
    }
    
    private func decodeLights(dict: [String: AnyObject]) -> [StreetLight] {
        guard let container = dict["result"] as? [String: AnyObject] else {
            return []
        }
        guard let results = container["records"] as? [[String: AnyObject]] else {
            return []
        }
        var lights: [StreetLight] = []
        for result in results {
            let lat = Double(result["AGD66Latitude"] as! String)!
            let lon = Double(result["AGD66Longitude"] as! String)!
            let coord = CLLocationCoordinate2DMake(lat, lon)
            lights.append(StreetLight(
                coordinate: coord,
                coverageRadius: 20.0,
                type: .CCMercuryVapor
            ))
        }
        return lights
    }
    
}
