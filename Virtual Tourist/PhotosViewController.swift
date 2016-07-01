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
  @IBOutlet weak var noImagesFoundLabel: UILabel!
  @IBOutlet weak var toolbar: UIToolbar!
  @IBOutlet weak var toolbarButton: UIBarButtonItem!
  
  @IBAction func toolbarButtonPressed(sender: AnyObject) {
    if selectedPhotos.isEmpty {
      deletePhotos()
      searchPhotos()
    } else {
      deleteSelectedPhotos()
    }
  }
  
  let flickrClientInstance = FlickrClient.sharedInstance
  let stack = CoreDataStack.sharedInstance
  
  var insertedIndexCache: [NSIndexPath]!
  var deletedIndexCache: [NSIndexPath]!
  
  var selectedPhotos = [NSIndexPath]() {
    didSet {
      toolbarButton.title = selectedPhotos.isEmpty ? "New Collection" : "Remove Selected Pictures"
    }
  }
  
  var pin: Pin!
  var fetchedResultsController: NSFetchedResultsController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupMapView()
    configureFlowLayout(view.frame.size.width)
    
    if fetchPhotos().isEmpty {
      searchPhotos()
    } else {
      toolbar.hidden = false
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
    
    let fetchRequest = NSFetchRequest(entityName: "Photo")
    fetchRequest.sortDescriptors = []
    fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
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
        self.toolbar.hidden = false
      }
      self.stack.save()
    }
  }
  
  func deleteSelectedPhotos() {
    var photosToDelete = [Photo]()
    
    for indexPath in selectedPhotos {
      photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
    }
    
    for photo in photosToDelete {
      stack.context.deleteObject(photo)
    }
    stack.save()
    
    selectedPhotos = []
  }
  
  func deletePhotos() {
    for photo in fetchedResultsController.fetchedObjects as! [Photo] {
      stack.context.deleteObject(photo)
    }
    stack.save()
  }
}

// MARK: MKMapViewDelegate

extension PhotosViewController: MKMapViewDelegate {
  func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    let reuseId = "pin"
    
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
    pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    
    return pinView
  }
}

extension PhotosViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoViewCell
    
    if let index = selectedPhotos.indexOf(indexPath) {
      selectedPhotos.removeAtIndex(index)
    } else {
      selectedPhotos.append(indexPath)
    }
    
    configureCellSection(cell, indexPath: indexPath)
    
  }

  func configureCellSection(cell: PhotoViewCell, indexPath: NSIndexPath) {
    if let _ = selectedPhotos.indexOf(indexPath){
      cell.alpha = 0.5
    } else {
      cell.alpha = 1.0
    }
  }
}

// MARK: UICollectionViewDataSource

extension PhotosViewController: UICollectionViewDataSource {
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchedResultsController.sections![section].numberOfObjects
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photoCell", forIndexPath: indexPath) as! PhotoViewCell
    let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
    
    let image = UIImage(named: "placeholder")
    cell.activityIndicator.startAnimating()
    
    flickrClientInstance.downloadPhotofromURL(photo.imageURL!) { imageData, error in
      
      guard let imageData = imageData, downloadedImage = UIImage(data: imageData) else {
        return
      }
      
      dispatch_async(dispatch_get_main_queue()) {
        photo.imageData = imageData
        self.stack.save()
        
        if let updateCell = self.collectionView.cellForItemAtIndexPath(indexPath) as? PhotoViewCell {
          updateCell.imageView.image = downloadedImage
          updateCell.activityIndicator.stopAnimating()
          updateCell.activityIndicator.hidden = true
        }
      }
    }
    
    cell.imageView.image = image
    configureCellSection(cell, indexPath: indexPath)
    
    return cell
  }
}

// MARK: NSFetchedResultsControllerDelegate

extension PhotosViewController: NSFetchedResultsControllerDelegate {
  
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    insertedIndexCache = [NSIndexPath]()
    deletedIndexCache = [NSIndexPath]()
    
  }
  
  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {

    switch type {
    case .Insert:
      insertedIndexCache.append(newIndexPath!)
    case .Delete:
      deletedIndexCache.append(indexPath!)
    default:
      break
    }
  }
  
  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    collectionView.performBatchUpdates({
      self.collectionView.insertItemsAtIndexPaths(self.insertedIndexCache)
      self.collectionView.deleteItemsAtIndexPaths(self.deletedIndexCache)

    }, completion: nil)
  }
}