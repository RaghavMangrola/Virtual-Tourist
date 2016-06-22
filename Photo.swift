//
//  Photo.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/20/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
  convenience init(imageURL: String, context: NSManagedObjectContext) {
    if let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context) {
      self.init(entity: entity, insertIntoManagedObjectContext: context)
      self.imageURL = imageURL
      self.imageData = nil
    } else {
      fatalError("Unable to find entity 'Photo'")
    }
  }

}
