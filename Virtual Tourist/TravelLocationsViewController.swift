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
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var deleteLabel: UILabel!
  @IBOutlet weak var labelStackView: UIStackView!
  
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    editMap(editMode)
  }
  
  var editMode = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    labelStackView.hidden = true
    
    mapView.delegate = self
    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.addPinToMap(_:)))
    lpgr.delegate = self
    self.mapView.addGestureRecognizer(lpgr)
  }
  
  func addPinToMap(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == UIGestureRecognizerState.Began && !editMode {
      let point = gestureRecognizer.locationInView(mapView)
      let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
      
      let annotation = MKPointAnnotation()
      annotation.coordinate = coordinate
      mapView.addAnnotation(annotation)
    }
  }
  
  func editMap(status: Bool) {
    editButton.title = status ? "Edit" : "Done"
    editMode = !status
    UIView.animateWithDuration(0.3) {
      self.labelStackView.hidden = status
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
  
  func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    let annotation = view.annotation
    if editMode {
      mapView.removeAnnotation(annotation!)
    }
  }
}

