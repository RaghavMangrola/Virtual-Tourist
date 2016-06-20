//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/20/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var imageData: NSData?
    @NSManaged var imageURL: String?
    @NSManaged var pin: Pin?

}
