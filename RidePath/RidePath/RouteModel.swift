//
//  RouteModel.swift
//  RidePath
//
//  Created by Spencer Atkin on 1/28/17.
//  Copyright © 2017 Berlik. All rights reserved.
//

import Foundation
import MapKit

class RouteModel {
    static let sharedInstance = RouteModel()
    
    var routes: [Route]!
    
    func loadRoutes() {
        // TODO: Load routes from file
    }
    
    func saveRoutes() {
        // TODO: Save routes to file
    }
}

class Route : NSObject, NSCoding {
    var startCoordinate: CLLocationCoordinate2D
    var endCoordinate: CLLocationCoordinate2D
    
    init(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        startCoordinate = start
        endCoordinate = end
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        startCoordinate = aDecoder.decodeObject(forKey: "self.startCoordinate") as! CLLocationCoordinate2D
        endCoordinate = aDecoder.decodeObject(forKey: "self.endCoordinate") as! CLLocationCoordinate2D
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(startCoordinate, forKey: "self.startCoordinate")
        aCoder.encode(endCoordinate, forKey: "self.endCoordinate")
    }
}
