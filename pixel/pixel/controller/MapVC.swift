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

class MapVC: UIViewController,UIGestureRecognizerDelegate{

    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHighConstraint: NSLayoutConstraint!
    @IBOutlet weak var BtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUIView: UIView!
    
    //MARK:Variables
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius : Double = 1000
    var spinner : UIActivityIndicatorView?
    var progressLabel  : UILabel?
    var screenSize = UIScreen.main.bounds
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView : UICollectionView?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTap()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        pullUIView.addSubview(collectionView!)
    }

    
   
    
    func AddProgressLabel()
    {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width)/2-120, y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "4/20 images are loading"
        collectionView?.addSubview(progressLabel!)
        
    }
    
    func RemoveProgressLabel()
    {
        if progressLabel != nil{
            progressLabel?.removeFromSuperview()
        }
    }
    
    
    func AddSpinner()
    {  spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width/2)-((spinner?.frame.width)!/2), y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.06274510175, green: 0, blue: 0.1921568662, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    func RemoveSpinner()
    {
        if spinner != nil
        {
            spinner?.removeFromSuperview()
        }
    }
   
    func addDoubleTap()
    {let doubleTap = UITapGestureRecognizer(target : self , action : #selector(dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    func addSwipe() {
      
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        self.pullUIView.addGestureRecognizer(swipe)
    }
    func animatedViewUP(){
        pullUpViewHighConstraint.constant = 300
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown()
    {
        pullUpViewHighConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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
        RemovePin()
        RemoveSpinner()
        RemoveProgressLabel()
        
        animatedViewUP()
        addSwipe()
        AddSpinner()
        AddProgressLabel()
     
        let touchPoint = sender.location(in: mapView)
        //print(touchPoint)
        //CG point from screen convert coordinate
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotiation = Droppable(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotiation)
        
        let coordinateReg = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateReg, animated: true)
    }
    
    func RemovePin()
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

extension MapVC : UICollectionViewDelegate,UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        return cell
    }
}

