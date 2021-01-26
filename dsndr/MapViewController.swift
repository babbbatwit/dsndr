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
    //all this does is show the user's pin on a map
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
    }
    

}
