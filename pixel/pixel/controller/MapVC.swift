//
//  ViewController.swift
//  pixel
//
//  Created by ths on 2/6/18.
//  Copyright © 2018 ths. All rights reserved.
//

import UIKit
import  MapKit
import CoreLocation

class MapVC: UIViewController {

    
    
    @IBOutlet weak var mapView: MKMapView!
   
    //MARK:Variables
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 500
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
    }

    @IBAction func userLocationCenterBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways ||  authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }

}
extension MapVC : MKMapViewDelegate{
    
    func centerMapOnUserLocation()
    {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegn = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegn, animated: true)
    }
    
}
extension MapVC : CLLocationManagerDelegate{
    
    func configureLocationServices()
    {
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
    
}

