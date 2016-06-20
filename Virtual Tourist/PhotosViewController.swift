//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/16/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  var annotation: Pin!
  var fetchedResultsController: NSFetchedResultsController!
  let flickrClientInstance = FlickrClient.sharedInstance
  let stack = CoreDataStack.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
    searchPhotos()
  }
  
  func setupMapView() {
    mapView.addAnnotation(annotation)
    mapView.camera.centerCoordinate = CLLocationCoordinate2DMake(annotation.latitude, annotation.longitude)
    mapView.camera.altitude = 10000
  }
  
  func searchPhotos() {
    flickrClientInstance.searchPhotos("\(annotation.latitude)", longitude: "\(annotation.longitude)") { photoURLS, error in
      guard let photoURLS = photoURLS else {
        return
      }
      
      self.savePhotos(photoURLS)
    }
  }
  
  func savePhotos(photoURLS: [String]) {
    for photoURL in photoURLS {
      let photo = Photo(imageURL: photoURL, context: stack.context)
      photo.pin = self.annotation
    }
    self.stack.save()
  }
}

extension PhotosViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    
    return pinView
  }
}
