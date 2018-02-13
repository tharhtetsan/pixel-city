//
//  PopUpVC.swift
//  pixel
//
//  Created by ths on 2/9/18.
//  Copyright © 2018 ths. All rights reserved.
//

import UIKit
import MapKit
import  CoreLocation

class PopUpVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var popUpImageView: UIImageView!
    
    @IBOutlet weak var titlleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var postDateLabel: UILabel!
    
    @IBOutlet weak var secondMapView: MKMapView!
    
    
    
    var presentImage : UIImage!
    var Name : String!
    var Description : String!
    var Date : String!
    var latt : String!
    var Long : String!
    
    
    func initData(forImage image:UIImage,forImageName name : String,forDescription description:String,forDate date : String,forAtt Latt : String, forLong forlong :String)
    {
        self.presentImage = image
        self.Name = name
        self.Description = description
        self.Date = "Posted : \(date)"
        self.latt = Latt
        self.Long = forlong
//        print("\(name)<<")
//        print("\(description)<<")
//        print("\(date)<<")
       
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        popUpImageView.image = presentImage
        titlleLabel.text = Name
        descriptionLabel.text = Description
        postDateLabel.text = Date
        CenterImageLocation()
        addDoubleTap()
    }

    func CenterImageLocation()
    {  // guard let coordinate = locationManager.location?.coordinate else { return }
        var coordinate = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(latt)!, longitude: CLLocationDegrees(Long)!)
        let coordinateRegn = MKCoordinateRegionMakeWithDistance(coordinate, 200.0, 200.0)
        secondMapView.setRegion(coordinateRegn, animated: true)
    }
    
    
    
    func addDoubleTap()
    {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }

    @objc func screenWasDoubleTap()
    {
        dismiss(animated: true, completion: nil)
    }

}
