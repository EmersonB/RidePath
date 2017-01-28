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
            let ref = FIRDatabase.database().reference().child("users/\(userID)/routes")
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
    var ref: FIRDatabaseReference!
    var rides: [Ride]!
    
    func loadRides() {
        rides = [Ride]()
        var myRoutes = [(CLLocation,CLLocation)]()
        ref = FIRDatabase.database().reference()
        let userID = FIRAuth.auth()?.currentUser?.uid
        ref.child("users").child(userID!).child("routes").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let routes = snapshot.value as? NSDictionary{
                for route in routes{
                    let myRoute = route as! NSDictionary
                    let startCoord = myRoute["start"] as! NSDictionary
                    let endCoord = myRoute["end"] as! NSDictionary
                    
                    let start = CLLocation(latitude: startCoord["lat"] as! Double!, longitude: startCoord["long"] as! Double!)
                    let end = CLLocation(latitude: endCoord["lat"] as! Double!, longitude: endCoord["long"] as! Double!)
                    
                    myRoutes.append(start,end)
                }
            }
        let otherRides = self.otherUserRides()
            
        self.checkRides(myRoutes: myRoutes, otherRides: otherRides)
        // for each other user
            // otherUserRides.append(Ride(Route(start, end), uuid))
            
        // for each otherUserRides
            // if close to each other:
                // self.rides.append(other ride)
        }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let routes = snapshot.value as? NSDictionary{
                for route in routes{
                    let myRoute = route as! NSDictionary
                    let startCoord = myRoute["start"] as! NSDictionary
                    let endCoord = myRoute["end"] as! NSDictionary
                    
                    let start = CLLocation(latitude: startCoord["lat"] as! Double!, longitude: startCoord["long"] as! Double!)
                    let end = CLLocation(latitude: endCoord["lat"] as! Double!, longitude: endCoord["long"] as! Double!)
                    
                    myRoutes.append(start,end)
                }
            }
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        // TODO: Load rides from file
    }
    
    func otherUserRides() -> [Ride] {
        var otherRides = [Ride]()
        
        return otherRides
    }
    
    func checkRides(myRoutes: [(CLLocation,CLLocation)], otherRides: [Ride]) {
        
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
