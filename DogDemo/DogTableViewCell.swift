//
//  DogTableViewCell.swift
//  DogDemo
//
//  Created by Nathan Wallace on 3/23/18.
//  Copyright © 2018 Nathan Wallace. All rights reserved.
//

import UIKit
import AlamofireImage

class DogTableViewCell: UITableViewCell {

    @IBOutlet weak var dogImageView: UIImageView!
    @IBOutlet weak var dogTitle: UILabel!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    
    var imageURL: URL? {
        // When the URL is set, download the image.
        didSet {
            updateImageView()
        }
    }
    
    /* This function is called when the imageURL is updated. It pulls
       the image from the server through AlamofireImage. */
    private func updateImageView() {
        imageLoadingIndicator.startAnimating()
        
        guard let url = imageURL else { return }
        
        let filter = AspectScaledToFillSizeFilter(size: dogImageView.frame.size)
        dogImageView.af_setImage(
            withURL: url,
            placeholderImage: UIImage(named: "Placeholder Image"),
            filter: filter,
            imageTransition: .crossDissolve(0.2),
            runImageTransitionIfCached: false
        ) { (_) in
            self.imageLoadingIndicator.stopAnimating()
        }
    }

}
