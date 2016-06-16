//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/16/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {

  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2DMake(latitude, longitude)
  }
  
  convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
    if let ent = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context) {
      self.init(entity: ent, insertIntoManagedObjectContext: context)
      self.latitude = latitude
      self.longitude = longitude
    } else {
      fatalError("Unable to find Entity name!")
    }
  }
}
