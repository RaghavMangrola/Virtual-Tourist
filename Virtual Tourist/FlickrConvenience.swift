//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/18/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import Foundation

extension FlickrClient {
  func searchPhotos(latitude: String, longitude: String, completionHandlerForSearchPhotos: (success: Bool, error: NSError?) -> Void) {
    let parameters = [
      FlickrClient.ParameterKeys.Method: FlickrClient.Methods.SearchPhotos,
      FlickrClient.ParameterKeys.Latitude: latitude,
      FlickrClient.ParameterKeys.Longitude: longitude
    ]
    
    taskForGetMethod(parameters: parameters) { result, error in
      if let error = error {
        completionHandlerForSearchPhotos(success: false, error: error)
      } else {
        if let photosDictionary = result[FlickrClient.JSONResponseKeys.PhotosDictionary] as? [String:AnyObject],
          photosArray = photosDictionary[FlickrClient.JSONResponseKeys.PhotosArray] as? [[String:AnyObject]] {
          
          
          completionHandlerForSearchPhotos(success: true, error: nil)
        } else {
          completionHandlerForSearchPhotos(success: false, error: NSError(domain: "searchPhotos", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse info"]))
        }
      }
    }
  }
}