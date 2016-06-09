//
//  TravelLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/4/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    mapView.delegate = self
    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.addPinToMap(_:)))
    lpgr.delegate = self
    self.mapView.addGestureRecognizer(lpgr)
  }
  
  func addPinToMap(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == UIGestureRecognizerState.Began {
      let point = gestureRecognizer.locationInView(mapView)
      let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      mapView.addAnnotation(annotation)
    
    }
  }
  
  
  
}

// MARK: MKMapViewDelegate

extension TravelLocationsViewController {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView?.animatesDrop = true
    
    return pinView
  }
}
