//
//  MapViewController.swift
//  RidePath
//
//  Created by Spencer Atkin on 1/28/17.
//  Copyright © 2017 Berlik. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var startCoordinate: CLLocationCoordinate2D?
    var startItem: MKMapItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        let trackingButton = MKUserTrackingBarButtonItem(mapView: mapView)
        navigationItem.leftBarButtonItem = trackingButton
        /*MKUserTrackingBarButtonItem *trackingButton = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
        NSMutableArray *items = [[NSMutableArray alloc] initWithArray:[self.toolbar items]];
        [items insertObject:trackingButton atIndex:0];
        [self.toolbar setItems:items];*/
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(longPressRecognizer)
        guard (FIRAuth.auth()?.currentUser) != nil else {
            self.performSegue(withIdentifier: "showLoginSegue", sender: self)
            return
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocationAuthorized()
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
            if startCoordinate == nil {
                let alertController = UIAlertController(title: "Add Route", message: "Would you like to add a new route starting at this location?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    self.mapView.removeAnnotation(annotation)
                })
                let addAction = UIAlertAction(title: "Add", style: .default, handler: { (action) in
                    self.startCoordinate = annotation.coordinate
                    let sourcePlacemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
                    self.startItem = MKMapItem(placemark: sourcePlacemark)
                    //let homeAddress = UserDefaults.standard.object(forKey: kHomeAddressKey) as! CLLocationCoordinate2D
                    //RouteModel.sharedInstance.addRoute(start: homeAddress, end: annotation.coordinate)
                })
                alertController.addAction(cancelAction)
                alertController.addAction(addAction)
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Add Route", message: "Would you like to create the route ending at this location?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
                    self.mapView.removeAnnotation(annotation)
                })
                let addAction = UIAlertAction(title: "Add", style: .default, handler: { (action) in
                    let directionRequest = MKDirectionsRequest()
                    directionRequest.source = self.startItem!
                    let sourcePlacemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
                    let endItem = MKMapItem(placemark: sourcePlacemark)
                    directionRequest.destination = endItem
                    directionRequest.transportType = .automobile
                    
                    let directions = MKDirections(request: directionRequest)
                    
                    directions.calculate {
                        (response, error) -> Void in
                        
                        guard let response = response else {
                            if let error = error {
                                print("Error: \(error)")
                            }
                            
                            return
                        }
                        
                        let route = response.routes[0]
                        print("route: \(route)")
                        self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
                        
                        let rect = route.polyline.boundingMapRect
                        self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
                    }
                    
                    RouteModel.sharedInstance.addRoute(start: self.startCoordinate!, end: annotation.coordinate)
                    self.startCoordinate = nil
                })
                alertController.addAction(cancelAction)
                alertController.addAction(addAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    /*CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
    NSLog(@"Denied");
    NSString *title =  (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
    NSString *message = @"To use background location you must turn on 'Always' in the Location Services Settings";
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController animated:YES completion:nil];
    }
    
    else if (status == kCLAuthorizationStatusNotDetermined) {
    NSLog(@"Not determined");
    if([self.manager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
    [self.manager requestAlwaysAuthorization];
    }
    }*/
    let manager = CLLocationManager()
    func checkLocationAuthorized() {
        let status = CLLocationManager.authorizationStatus()
        //if (status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.notDetermined) {
            manager.requestWhenInUseAuthorization()
        //}
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
