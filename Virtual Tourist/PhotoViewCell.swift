//
//  PhotoViewCell.swift
//  Virtual Tourist
//
//  Created by Raghav Mangrola on 6/20/16.
//  Copyright © 2016 Raghav Mangrola. All rights reserved.
//

import Foundation
import UIKit

class PhotoViewCell: UICollectionViewCell {
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  var taskToCancelIfCellIsReused: NSURLSessionTask? {
    didSet {
      if let taskToCancel = oldValue {
        taskToCancel.cancel()
      }
    }
  }
}