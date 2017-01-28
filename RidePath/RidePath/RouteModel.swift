//
//  RouteModel.swift
//  RidePath
//
//  Created by Spencer Atkin on 1/28/17.
//  Copyright © 2017 Berlik. All rights reserved.
//

import Foundation
import MapKit
import Firebase
import FirebaseAuth

class RouteModel {
    static let sharedInstance = RouteModel()
    
    var routes: [Route]!
    
    init() {
        loadRoutes()
    }
    
    func addRoute(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) {
        let route = Route(start: start, end: end)
        routes.append(route)
        saveRoutes()
    }
    
    func loadRoutes() {
        routes = [Route]()
        // TODO: Load routes from file
    }
    
    func saveRoutes() {
        if let userID = FIRAuth.auth()?.currentUser?.uid {
            ref = FIRDatabase.database().reference().child("users/\(userID)/routes")
            for route in routes {
                let childRef = ref.childByAutoId()
                childRef.child("start").updateChildValues(["lat": route.startCoordinate.latitude, "long": route.startCoordinate.longitude])
                childRef.child("end").updateChildValues(["lat": route.endCoordinate.latitude, "long": route.endCoordinate.longitude])
            }
        }
        // TODO: Save routes to file
    }
}

class RideModel {
    static let sharedInstance = RideModel()
    
    var rides: [Ride]!
    
    func loadRides() {
        // TODO: Load rides from file
    }
    
    func saveRides() {
        // TODO: Save rides to file
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

class Ride : NSObject, NSCoding {
    var route: Route!
    var partnerID: String! // UID that can retrieve user from Firebase
    
    init(r: Route, partner: String) {
        route = r
        partnerID = partner
    }
    
    required init?(coder aDecoder: NSCoder) {
        route = aDecoder.decodeObject(forKey: "self.route") as! Route
        partnerID = aDecoder.decodeObject(forKey: "self.partnerID") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(route, forKey: "self.route")
        aCoder.encode(partnerID, forKey: "self.partnerID")
    }
}
