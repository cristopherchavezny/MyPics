//
//  PhotoCollectionViewCell.swift
//  MyPics
//
//  Created by Cris C on 12/14/18.
//  Copyright © 2018 Hazlo Tech. All rights reserved.
//

import UIKit

class PickerItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var selectedIndicatorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpCellShape()
        setUpSelectedIndicator()
    }
    
    func setUpCellShape() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.25
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 5.0
    }
    
    func setUpSelectedIndicator() {
        let _ = [
            photoImageView,
            selectedIndicatorView
            ].map{
                $0?.layer.cornerRadius = 4.0
                $0?.layer.masksToBounds = true
        }
        
        selectedIndicatorView.alpha = 0.0
        selectedIndicatorView.layer.borderWidth = 2.0
        selectedIndicatorView.layer.borderColor = UIColor.gray.cgColor
    }
    
    func indicateSelected() {
        self.selectedIndicatorView.alpha = 0.5
    }

    func indicateDeselected() {
        self.selectedIndicatorView.alpha = 0.0
    }
    
}
