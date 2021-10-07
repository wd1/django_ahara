//
//  MyBoxCell.swift
//  Ahara
//
//  Created by Miroslav Kostic on 5/18/21.
//

import UIKit

class MyBoxCell : UICollectionViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgMyBox: UIImageView!
    open override func awakeFromNib() {
        super.awakeFromNib()
        imgMyBox.setGradientBackground(colorTop: .clear, colorBottom: UIColor(hex: 0xB0B0B0, alpha: 0.45))
        lblName.layer.shadowColor = UIColor.black.cgColor
        lblName.layer.shadowRadius = 3.0
        lblName.layer.shadowOpacity = 1.0
        lblName.layer.shadowOffset = CGSize(width: 4, height: 4)
        lblName.layer.masksToBounds = false
    }
}

