//
//  PhotosViewController.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/16/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import UIKit
import MapKit

class PhotosViewController: UIViewController, MKMapViewDelegate {

  @IBOutlet weak var mapView: MKMapView!
  var annotation: Pin!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
  }
  
  func setupMapView() {
    mapView.addAnnotation(annotation)
    mapView.camera.centerCoordinate = CLLocationCoordinate2DMake(annotation.latitude, annotation.longitude)
    mapView.camera.altitude = 10000
  }
}

extension MKMapViewDelegate {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    
    return pinView
  }
}