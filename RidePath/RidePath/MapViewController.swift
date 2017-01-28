//
//  MapViewController.swift
//  RidePath
//
//  Created by Spencer Atkin on 1/28/17.
//  Copyright © 2017 Berlik. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayRoutes() {
        // Load routes
        // Add pins, draw routes between them
    }
    
    func didLongPressOnMap(sender: UILongPressGestureRecognizer) {
        /*if sender.state == UIGestureRecognizerState.began {
            var touchPoint = sender.location(in: mapView)
            var newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let pm = placemarks?[0]
                    
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    annotation.title = (pm?.thoroughfare)! + ", " + (pm?.subThoroughfare!)!
                    annotation.subtitle = pm?.subLocality
                    self.mapView.addAnnotation(annotation)
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
                pm?.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
            })*/
        if sender.state == UIGestureRecognizerState.began {
            let touchPoint = sender.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
            let alertController = UIAlertController(title: "Add Route", message: "Would you like to add a new route with this location?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                self.mapView.removeAnnotation(annotation)
            })
            let addAction = UIAlertAction(title: "Add", style: .default, handler: { (action) in
                let homeAddress = UserDefaults.standard.object(forKey: kHomeAddressKey) as! CLLocationCoordinate2D
                RouteModel.sharedInstance.addRoute(start: homeAddress, end: annotation.coordinate)
            })
            alertController.addAction(cancelAction)
            alertController.addAction(addAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
