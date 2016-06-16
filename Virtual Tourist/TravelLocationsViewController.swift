//
//  TravelLocationsViewController.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/4/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var deleteLabel: UILabel!
  @IBOutlet weak var labelStackView: UIStackView!
  
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    editMap(editMode)
  }
  
  var editMode = false
  let stack = CoreDataStack.sharedInstance
  
  override func viewDidLoad() {
    super.viewDidLoad()
    labelStackView.hidden = true
    
    mapView.delegate = self
    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.addPinToMap(_:)))
    lpgr.delegate = self
    self.mapView.addGestureRecognizer(lpgr)
    
    loadPinsFromDatabase()
  }
  
  func addPinToMap(gestureRecognizer: UILongPressGestureRecognizer) {
    if gestureRecognizer.state == UIGestureRecognizerState.Began && !editMode {
      let point = gestureRecognizer.locationInView(mapView)
      let coordinate = mapView.convertPoint(point, toCoordinateFromView: mapView)
      let latitude = coordinate.latitude
      let longitude = coordinate.longitude
      
      let annotation = Pin(latitude: latitude, longitude: longitude, context: stack.context)
      mapView.addAnnotation(annotation)
      stack.save()
    }
  }
  
  func editMap(status: Bool) {
    editButton.title = status ? "Edit" : "Done"
    editMode = !status
    UIView.animateWithDuration(0.3) {
      self.labelStackView.hidden = status
    }
  }
  
  func loadPinsFromDatabase() {
    var pins = [Pin]()
    let fetchRequest = NSFetchRequest(entityName: "Pin")
    
    do {
      let results = try stack.context.executeFetchRequest(fetchRequest)
      if let results = results as? [Pin] {
        pins = results
      }
    } catch {
      print("Couldn't find any Pins")
    }
    print(pins)
    mapView.addAnnotations(pins)
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

