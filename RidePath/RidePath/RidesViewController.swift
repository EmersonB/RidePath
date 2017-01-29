//
//  RidesViewController.swift
//  RidePath
//
//  Created by Spencer Atkin on 1/28/17.
//  Copyright © 2017 Berlik. All rights reserved.
//

import UIKit
import Firebase

class RidesViewController: UITableViewController {
    
var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kRidesUpdatedNotification), object: nil, queue: OperationQueue.main) { (note) in
            print("recieved notification")
            print(RideModel.sharedInstance.rides)
            self.tableView.reloadData()
        }
        RideModel.sharedInstance.loadRides()
        print("RIDESRIDESRIASDFIJAOSFJA;SLDFJALSDJFALSDJF;LASDJF;ASDJF;LASJDF;LASJDFAJSF;LJASDF;LAJSDDF;LAJSDF;LAJSDF;LJASDF;LJSF \(RideModel.sharedInstance.rides)")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rideFor(indexPath: IndexPath) -> Ride {
        print("hi")
        return RideModel.sharedInstance.rides[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RideModel.sharedInstance.rides.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        let ride = rideFor(indexPath: indexPath)
        print(ride.partnerID)
        cell.textLabel?.text = ride.email
        
        return cell
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
