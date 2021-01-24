//
//  MapViewController.swift
//  dsndr
//
//  Created by Brenton Babb on 12/18/20.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        // Do any additional setup after loading the view.
    }
    

}
