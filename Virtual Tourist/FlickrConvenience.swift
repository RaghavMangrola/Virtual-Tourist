//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/18/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import Foundation

extension FlickrClient {
  func searchPhotos(latitude: String, longitude: String, completionHandlerForSearchPhotos: (photoURLS: [String]?, error: NSError?) -> Void) {
    let parameters = [
      FlickrClient.ParameterKeys.Method: FlickrClient.Methods.SearchPhotos,
      FlickrClient.ParameterKeys.Latitude: latitude,
      FlickrClient.ParameterKeys.Longitude: longitude
    ]
    
    taskForGetMethod(parameters: parameters) { result, error in
      if let error = error {
        completionHandlerForSearchPhotos(photoURLS: nil, error: error)
      } else {
        if let photosDictionary = result[FlickrClient.JSONResponseKeys.PhotosDictionary] as? [String:AnyObject],
          photosArray = photosDictionary[FlickrClient.JSONResponseKeys.PhotosArray] as? [[String:AnyObject]] {
          
          var photoURLS = [String]()
          
          for photo in photosArray {
            if let photoURL = photo[FlickrClient.JSONResponseKeys.MediumURL] as? String {
              photoURLS.append(photoURL)
            }
            completionHandlerForSearchPhotos(photoURLS: photoURLS, error: nil)
          }
          
        } else {
          completionHandlerForSearchPhotos(photoURLS: nil, error: NSError(domain: "searchPhotos", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse info"]))
        }
      }
    }
  }
}