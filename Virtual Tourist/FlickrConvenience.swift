//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/18/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import Foundation

extension FlickrClient {
  func searchPhotos(latitude: String, longitude: String, completionHandlerForSearchPhotos: (error: NSError?) -> Void) {
    let parameters = [
      FlickrClient.ParameterKeys.Method: FlickrClient.Methods.SearchPhotos,
      FlickrClient.ParameterKeys.Latitude: latitude,
      FlickrClient.ParameterKeys.Longitude: longitude
    ]
    
    taskForGetMethod(parameters: parameters) { results, error in
      
    }
  }
}