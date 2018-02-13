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
import AlamofireImage
import Alamofire

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
    var imageUrlArr  = [String]()
    var imageArr = [UIImage]()
    var imageInfoUrl = [String]()

    var imageTitile = [String]()
    var imageDescription = [String]()
    var postDate = [String]()
    var postAtt = [String]()
    var postLong = [String]()
    
    
    
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
        
        registerForPreviewing(with: self, sourceView: collectionView!)
    }

    
   
    //MARK: Add And Remove ProgressLabel
    func AddProgressLabel()
    {
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width)/2-120, y: 175, width: 240, height: 40)
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        progressLabel?.textAlignment = .center
        progressLabel?.text = "0/\(numberOfImages) IMAGES ARE LOADING"
        collectionView?.addSubview(progressLabel!)
        
    }
    
    func RemoveProgressLabel()
    {
        if progressLabel != nil{
            progressLabel?.removeFromSuperview()
        }
    }
    
    //MARK: Add and Remove Spinner
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
    
    //MARK: animateViewDown
    @objc func animateViewDown()
    {
        cancleAllSessions()
        pullUpViewHighConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
     //MARK: userLocationCenterBtnPressed
    @IBAction func userLocationCenterBtnPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways ||  authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
    //MARK: Retrieve Url and Image
    func retrieveUrl(forAnnotation annotion: Droppable , henlder :@escaping (_ status: Bool)->())
    {
     
        Alamofire.request(flickrUrl(forApiKye: apiKey, withAnnotation: annotion, numberOfPhoto: numberOfImages)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String,AnyObject> else { return }
            
            //for phot0
            let photoDict = json["photos"] as! Dictionary<String,AnyObject>
            let photoDictArray = photoDict["photo"] as! [Dictionary<String,AnyObject>]
          //  print(response)
           for photo in photoDictArray {
                let postURL = "http://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_b_d.jpg"
                
                let photoId = photo["id"]! as! String
                let secretId = photo["secret"]! as! String
                let   infoUrl = "\(ImageInfoUrl(forImageId: photoId , forSecredId: secretId))"
                
                
                self.imageInfoUrl.append(infoUrl)
                self.imageUrlArr.append(postURL)
            }
            henlder(true)
        }
    }
    func RetrieveImage(handler : @escaping (_ status : Bool)->())
    {
       
        var index : Int = 0;
        for url in imageUrlArr{
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                index = index+1
                
                guard let image = response.result.value  else { return }
                self.imageArr.append(image)
                self.progressLabel?.text = "\(self.imageArr.count)/\(numberOfImages) IMAGES DOWNLOADS"
                print("\(self.imageArr.count)/\(numberOfImages) .........")
                
               
                if index == self.imageUrlArr.count{
                    handler(true)
                }
        
                
            })
        }
        
    }
    func RetrieveImageInfo(handler :@escaping (_ status : Bool) -> ())
    {
        var index : Int = 0;
        for url in imageInfoUrl{
            
            Alamofire.request(url).responseJSON { (response) in
                guard let json = response.result.value as? Dictionary<String,AnyObject> else { return }
               //for phot0
                let photoDict = json["photo"] as! Dictionary<String,AnyObject>
              let photoTitle = photoDict["title"] as! [String:String]
                let Desciption = photoDict["description"] as! [String:String]
           
                let location = photoDict["location"] as! [String:AnyObject]
                let Date = photoDict["dates"] as! [String:String]
              
               
                
                self.imageTitile.append(photoTitle["_content"]!)
                self.imageDescription.append(photoTitle["_content"]!)
                self.postDate.append(Date["taken"]!)
                
                for  obj in location{
                    if obj.key == "latitude"
                    {
                        self.postAtt.append(obj.value as! String)
                        print("\(obj.value as! String)")
                    }
                    if obj.key == "longitude"
                    {
                        self.postLong.append(obj.value as! String)
                        print("\(obj.value as! String)")
                    }
                }
              
                print("info : \(self.imageArr.count)/\(numberOfImages) .........")
                
                
                
                
             }
        }
         handler(true)
    }
    
    
    func cancleAllSessions()
    {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadDatas, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    

}







extension MapVC : MKMapViewDelegate{
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation{
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: DroppalbePinId)
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
    
    
    
    
    //MARK: dropPin
    @objc func dropPin(sender : UITapGestureRecognizer)
    {
        RemovePin()
        RemoveSpinner()
        RemoveProgressLabel()
        cancleAllSessions()
        imageArr = []
        imageUrlArr = []
        imageInfoUrl = []
        postDate = []
        postAtt = []
        postLong = []
        collectionView?.reloadData()
        
        
        
        
        
        animatedViewUP()
        addSwipe()
        AddSpinner()
        AddProgressLabel()
     
        
        
        let touchPoint = sender.location(in: mapView)
        //print(touchPoint)
        //CG point from screen convert coordinate
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotiation = Droppable(coordinate: touchCoordinate, identifier: DroppalbePinId)
        mapView.addAnnotation(annotiation)
        
        
        print(flickrUrl(forApiKye: apiKey, withAnnotation: annotiation, numberOfPhoto: numberOfImages))
        
        let coordinateReg = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateReg, animated: true)
        
        retrieveUrl(forAnnotation: annotiation) { (response) in
            if response
            {
                print("finished urls")
                
                self.RetrieveImage(handler: { (finishedimage) in
                    self.RetrieveImageInfo(handler: { (real) in
                        print("Everything is ok")
                        self.RemoveSpinner()
                        self.RemoveProgressLabel()
                        self.collectionView?.reloadData()
                    })
                })
            }
        }
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


extension MapVC : UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard  let indexPath = collectionView?.indexPathForItem(at: location) , let cell = collectionView?.cellForItem(at: indexPath) else {return nil}
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: popUPVCId) as? PopUpVC else {return nil}
        
        popVC.initData(forImage: imageArr[indexPath.row], forImageName: imageTitile[indexPath.row], forDescription: imageDescription[indexPath.row], forDate: postDate[indexPath.row], forAtt: postAtt[indexPath.row],forLong : postLong[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
        
    }
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
}


//MARK : Collection
extension MapVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArr.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard  let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
        let imageFromIndex = imageArr[indexPath.row]
        var imageView = UIImageView(image : imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: popUPVCId)as? PopUpVC else{ return }
        //print("\(imageTitile[indexPath.row])<<<<<\(imageDescription[indexPath.row])<<<<\(postDate[indexPath.row])<<<")
        popVC.initData(forImage: imageArr[indexPath.row], forImageName: imageTitile[indexPath.row],forDescription: imageDescription[indexPath.row],forDate: postDate[indexPath.row],forAtt: postAtt[indexPath.row],forLong:  postLong[indexPath.row])
        
        print("...............................")
        print("\(indexPath.row) <<< selected")
        
        present(popVC, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var numOfColumns : CGFloat = 3
        if UIScreen.main.bounds.width > 320
        {
            numOfColumns = 4
        }
        let spaceBetweenCell : CGFloat = 40
        let padding :CGFloat = 10
        let cellDimension = ((collectionView.bounds.width - padding ) - (numOfColumns - 1) * spaceBetweenCell)/numOfColumns
        
        return CGSize(width : cellDimension ,height : cellDimension)
    }
}

