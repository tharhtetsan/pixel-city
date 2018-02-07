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

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    
    
    @IBOutlet weak var mapView: MKMapView!
   
    //MARK:Variables
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 1000
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
    }

    
    func addDoubleTap()
    {
        let doubleTap = UITapGestureRecognizer(target : self , action : #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
        
    }
    @IBAction func userLocationCenterBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways ||  authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }

}
extension MapVC : MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation{
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9994240403, green: 0.7280104242, blue: 0.1165115747, alpha: 1)
        pinAnnotation.animatesDrop = true
        
        return pinAnnotation
    }
    
    
    
    
    
    
    func centerMapOnUserLocation()
    {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegn = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegn, animated: true)
    }
    
    @objc func dropPin(sender : UITapGestureRecognizer)
    {
        rempvePin()
        
        let touchPoint = sender.location(in: mapView)
        //print(touchPoint)
        //CG point from screen convert coordinate
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotiation = Droppable(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotiation)
        
        let coordinateReg = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateReg, animated: true)
    }
    
    func rempvePin()
    {
        for annotion in mapView.annotations{
            mapView.removeAnnotation(annotion)
        }
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

