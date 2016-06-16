//
//  Pin+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/16/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var longitude: Double
    @NSManaged var latitude: Double

}
