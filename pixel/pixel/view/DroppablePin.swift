//
//  DroppablePin.swift
//  pixel
//
//  Created by ths on 2/6/18.
//  Copyright © 2018 ths. All rights reserved.
//

import Foundation
import MapKit

class Droppable : NSObject,MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D
    var identifier : String
    
    init(coordinate : CLLocationCoordinate2D , identifier : String)
    {
        self.coordinate = coordinate
        self.identifier = identifier
    }
}
