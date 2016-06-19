//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/18/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
  var session = NSURLSession.sharedSession()
  static let sharedInstance = FlickrClient()
  
  func taskForGetMethod(parameters parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionTask {
    
    var parameters = parameters
    
    parameters[ParameterKeys.Extras] = ParameterValues.MediumURL
    parameters[ParameterKeys.APIKey] = APIKeys.flickr
    parameters[ParameterKeys.Format] = ParameterValues.ResponseFormat
    
    let request = NSMutableURLRequest(URL: flickrURLFromParameters(parameters))
    print(request)
    
    let task = session.dataTaskWithRequest(request) { data, response, error in
      
      func sendError(error: String) {
        let userInfo = [NSLocalizedDescriptionKey: error]
        completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
      }
      
      guard (error == nil) else {
        sendError("There was an error with your request: \(error)")
        return
      }
      
      guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
        sendError("Your request returned a status code other than 2xx!")
        return
      }
      
      guard let data = data else {
        sendError("No data was returned by the request!")
        return
      }

      self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
    }
    
    task.resume()
    return task
  }
  
  
  private func flickrURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
    let components = NSURLComponents()
    components.scheme = FlickrClient.Constants.ApiScheme
    components.host = FlickrClient.Constants.ApiHost
    components.path = FlickrClient.Constants.ApiPath + (withPathExtension ?? "")
    components.queryItems = [NSURLQueryItem]()
    
    for (key, value) in parameters {
      let queryItem = NSURLQueryItem(name: key, value: "\(value)")
      components.queryItems!.append(queryItem)
    }
    
    return components.URL!
  }
  
  private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
    
    var parsedResult: AnyObject!
    do {
      parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
    } catch {
      let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
      completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }
    completionHandlerForConvertData(result: parsedResult, error: nil)
  }
}
