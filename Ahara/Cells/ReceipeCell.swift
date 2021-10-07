//
//  ReceipeCell.swift
//  Ahara
//
//  Created by Miroslav Kostic on 5/18/21.
//
import UIKit

class ReceipeCell : UICollectionViewCell {
    
    @IBOutlet weak var imgLiked: UIImageView!
    @IBOutlet weak var lblCheifName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblRecipeName: UILabel!
    @IBOutlet weak var imgReceipe: UIImageView!
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ReceipeTableCell : UITableViewCell {
    
    @IBOutlet weak var imgLiked: UIImageView!
    @IBOutlet weak var lblCheifName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblMarkCount: UILabel!
    @IBOutlet weak var lblRecipeName: UILabel!
    @IBOutlet weak var vwHalf: UIView!
    @IBOutlet weak var imgChief: imgProfileView!
    @IBOutlet weak var imgReceipe: UIImageView!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.bringSubviewToFront(imgChief)
        self.contentView.layer.cornerRadius = 12
        vwHalf.rotate(angle: -11)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:20, left:0, bottom:0, right:0))
    }
}
