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
  @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
  
  let flickrClientInstance = FlickrClient.sharedInstance
  let stack = CoreDataStack.sharedInstance
  
  var pin: Pin!
  var fetchedResultsController: NSFetchedResultsController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
    configureFlowLayout(view.frame.size.width)

    if fetchPhotos().isEmpty {
      searchPhotos()
    }
  }
  
  func setupMapView() {
    mapView.addAnnotation(pin)
    mapView.camera.centerCoordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
    mapView.camera.altitude = 10000
  }
  
  func configureFlowLayout(width: CGFloat) {
    collectionViewFlowLayout.minimumInteritemSpacing = 1
    collectionViewFlowLayout.minimumLineSpacing = 1
    collectionViewFlowLayout.itemSize = CGSizeMake((view.frame.size.width / 3) - 1, view.frame.size.width / 3)
  }
  
  func fetchPhotos() -> [Photo] {
    var photos = [Photo]()
    
    let fr = NSFetchRequest(entityName: "Photo")
    fr.sortDescriptors = []
    fr.predicate = NSPredicate(format: "pin = %@", pin)
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
    fetchedResultsController.delegate = self
    
    do {
      try fetchedResultsController.performFetch()
      if let results = fetchedResultsController.fetchedObjects as? [Photo] {
        photos = results
      }
    } catch {
      print("Error while trying to fetch photos.")
    }
    return photos
  }
  
  func searchPhotos() {
    flickrClientInstance.searchPhotos("\(pin.latitude)", longitude: "\(pin.longitude)") { photoURLS, error in
      guard let photoURLS = photoURLS else {
        return
      }
      self.savePhotos(photoURLS)
    }
  }
  
  func savePhotos(photoURLS: [String]) {
    dispatch_async(dispatch_get_main_queue()) {
      for photoURL in photoURLS {
        let photo = Photo(imageURL: photoURL, context: self.stack.context)
        photo.pin = self.pin
      }
      self.stack.save()
    }
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

extension PhotosViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.sections![section].numberOfObjects
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoViewCell
    let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
    
    let image = UIImage(named: "placeholder")
    
    flickrClientInstance.downloadPhotofromURL(photo.imageURL!) { imageData, error in
      
      guard let imageData = imageData, downloadedImage = UIImage(data: imageData) else {
        return
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        photo.imageData = imageData
        self.stack.save()
        
        if let updateCell = self.collectionView.cellForItemAtIndexPath(indexPath) as? PhotoViewCell {
          updateCell.imageView.image = downloadedImage
        }
      }
    }
    
    cell.imageView.image = image
    
    return cell
  }
}

extension PhotosViewController: NSFetchedResultsControllerDelegate {
  
}