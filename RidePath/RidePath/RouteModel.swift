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

let kRidesUpdatedNotification = "kRidesUpdatedNotification"

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
    let kMaxDistance = 8046.72
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
                for key in routes.allKeys {
                    let myRoute = routes[key] as! NSDictionary
                    let startCoord = myRoute["start"] as! NSDictionary
                    let endCoord = myRoute["end"] as! NSDictionary
                    
                    let start = CLLocation(latitude: startCoord["lat"] as! Double!, longitude: startCoord["long"] as! Double!)
                    let end = CLLocation(latitude: endCoord["lat"] as! Double!, longitude: endCoord["long"] as! Double!)
                    print("appending motherfucker")
                    myRoutes.append(start,end)
                }
            }
            self.otherUserRides(myRoutes: myRoutes)
        }) { (error) in
            print(error.localizedDescription)
        }
        // for each other user
            // otherUserRides.append(Ride(Route(start, end), uuid))
            
        // for each otherUserRides
            // if close to each other:
                // self.rides.append(other ride)
        
        // TODO: Load rides from file
        print(self.rides)
    }
    
    func otherUserRides(myRoutes: [(CLLocation,CLLocation)]) {
        var otherRides = [Ride]()
        ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let users = snapshot.value as? NSDictionary{
                for key in users.allKeys {
                    print("1")
                    if key as? String != FIRAuth.auth()?.currentUser?.uid {
                        let user = users[key] as? NSDictionary
                        if let userRoutes = user?["routes"] as? NSDictionary {
                            for userRoutesKey in userRoutes.allKeys {
                                print("2")
                                print("2.25 \(userRoutes[userRoutesKey]) //////// \(userRoutes)")
                                if let route = userRoutes[userRoutesKey] as? NSDictionary {
                                    print("2.5")
                                    //for routeKey in routes.allKeys {
                                        print("3")
                                        //let route = routes[routeKey]
                                        print("4 \(route)")
                                        let myRoute = route as! NSDictionary
                                        let startCoord = myRoute["start"] as! NSDictionary
                                        let endCoord = myRoute["end"] as! NSDictionary
                                        
                                        let start = CLLocation(latitude: startCoord["lat"] as! Double!, longitude: startCoord["long"] as! Double!)
                                        let end = CLLocation(latitude: endCoord["lat"] as! Double!, longitude: endCoord["long"] as! Double!)
                                        
                                    otherRides.append(Ride(r: Route(start: start.coordinate, end: end.coordinate),partner: key as! String, e:""))
                                    //}
                                }
                            }
                        }
                    }
                }
            }
            self.checkRides(myRoutes: myRoutes, otherRides: otherRides)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func checkRides(myRoutes: [(CLLocation,CLLocation)], otherRides: [Ride]) {
        print("myroutes \(myRoutes)")
        print("otherrides \(otherRides)")
        for route in myRoutes {
            for otherRide in otherRides {
                let myStart = route.0
                let otherStart = CLLocation(latitude: otherRide.route.startCoordinate.latitude, longitude: otherRide.route.startCoordinate.longitude)
                
                let startDistance = myStart.distance(from: otherStart)
                
                let myEnd = route.1
                let otherEnd = CLLocation(latitude: otherRide.route.endCoordinate.latitude, longitude: otherRide.route.endCoordinate.longitude)
                
                let endDistance = myEnd.distance(from: otherEnd)
                
                if startDistance <= kMaxDistance && endDistance <= kMaxDistance {
                    print(otherRide.partnerID)
                    ref.child("ids").child(otherRide.partnerID).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? String
                        print("elb"+value!)
                        //let email = value?["username"] as! String
                        self.rides.append(Ride(r: Route(start: route.0.coordinate, end: route.1.coordinate), partner: otherRide.partnerID, e:value!))
                        print("appending \(self.rides)")
                        print("email \(value!)")
                        // ...
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRidesUpdatedNotification), object: nil)
                    }) { (error) in
                        print(error.localizedDescription)
                    }
                    
                }
            }
        }
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
    var email: String!
    var partnerID: String! // UID that can retrieve user from Firebase
    
    init(r: Route, partner: String, e:String) {
        route = r
        partnerID = partner
        email = e
    }
    
    required init?(coder aDecoder: NSCoder) {
        route = aDecoder.decodeObject(forKey: "self.route") as! Route
        partnerID = aDecoder.decodeObject(forKey: "self.partnerID") as! String
        email = aDecoder.decodeObject(forKey: "self.email") as! String

        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(route, forKey: "self.route")
        aCoder.encode(partnerID, forKey: "self.partnerID")
        aCoder.encode(email, forKey: "self.email")
    }
}
