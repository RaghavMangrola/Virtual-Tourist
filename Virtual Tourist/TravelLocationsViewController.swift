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
import XCGLogger

class TravelLocationsViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var labelStackView: UIStackView!
  
  
  @IBAction func editButtonPressed(sender: AnyObject) {
    editMap(editMode)
  }
  let className = "TravelLocationsViewController"
  var editMode = false
  let stack = CoreDataStack.sharedInstance
  var centerCoordinate: CLLocationCoordinate2D?
  var centerCoordinateLongitude: CLLocationDegrees?
  var centerCoordinateLatitude: CLLocationDegrees?
  var altitude: CLLocationDistance?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    labelStackView.hidden = true
    
    mapView.delegate = self
    let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(TravelLocationsViewController.addPinToMap(_:)))
    lpgr.delegate = self
    self.mapView.addGestureRecognizer(lpgr)
    
    loadMapDefaults()
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
    mapView.addAnnotations(pins)
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "pinTapped" {
      let photosVC = segue.destinationViewController as! PhotosViewController
      let annotation = sender as! Pin
      photosVC.pin = annotation
      
    }
  }
  
  func loadMapDefaults() {
    guard let centerCoordinateLatitude = NSUserDefaults.standardUserDefaults().valueForKey("centerCoordinateLatitude") as? CLLocationDegrees else {
      log.warning("centerCoordinate not found in NSUserDefaults")
      return
    }
    
    guard let centerCoordinateLongitude = NSUserDefaults.standardUserDefaults().valueForKey("centerCoordinateLongitude") as? CLLocationDegrees else {
      log.warning("centerCoordinate not found in NSUserDefaults")
      return
    }
    
    guard let altitude = NSUserDefaults.standardUserDefaults().valueForKey("altitude") as? CLLocationDistance else {
      log.warning("altitude not found in NSUserDefaults")
      return
    }
    
    mapView.centerCoordinate = CLLocationCoordinate2DMake(centerCoordinateLatitude, centerCoordinateLongitude)
    mapView.camera.altitude = altitude
  }
}

// MARK: MKMapViewDelegate

extension TravelLocationsViewController: MKMapViewDelegate  {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    pinView?.animatesDrop = true
    
    return pinView
  }
  
  func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
    let annotation = view.annotation as! Pin
    if editMode {
      mapView.removeAnnotation(annotation)
      stack.context.deleteObject(annotation)
      stack.save()
    } else {
      mapView.deselectAnnotation(annotation, animated: false)
      performSegueWithIdentifier("pinTapped", sender: annotation)
    }
  }
  
  func mapView(mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    centerCoordinateLatitude = mapView.centerCoordinate.latitude
    centerCoordinateLongitude = mapView.centerCoordinate.longitude
    altitude = mapView.camera.altitude
    
    log.debug("Center Coordinate Latitude: \(centerCoordinateLatitude!)")
    log.debug("Center Coordinate Longitude: \(centerCoordinateLongitude!)")
    log.debug("Altitude: \(altitude!)")
  }
  
  func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    centerCoordinateLatitude = mapView.centerCoordinate.latitude
    centerCoordinateLongitude = mapView.centerCoordinate.longitude
    altitude = mapView.camera.altitude
    
    log.debug("Center Coordinate Latitude: \(centerCoordinateLatitude!)")
    log.debug("Center Coordinate Longitude: \(centerCoordinateLongitude!)")
    log.debug("Altitude: \(altitude!)")
    
    NSUserDefaults.standardUserDefaults().setValue(centerCoordinateLatitude, forKey: "centerCoordinateLatitude")
    NSUserDefaults.standardUserDefaults().setValue(centerCoordinateLongitude, forKey: "centerCoordinateLongitude")
    NSUserDefaults.standardUserDefaults().setValue(altitude, forKey: "altitude")
  }
  
}

