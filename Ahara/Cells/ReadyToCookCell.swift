//
//  ReadyToCookCell.swift
//  Ahara
//
//  Created by Miroslav Kostic on 5/19/21.
//

import UIKit

class ReadyToCookCell : UITableViewCell {
    
    @IBOutlet weak var imgLiked: UIImageView!
    @IBOutlet weak var vwBottom: UIView!
    @IBOutlet weak var imgCook: UIImageView!
    @IBOutlet weak var imgChief: imgProfileView!
    @IBOutlet weak var lblChiefName: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblViews: UILabel!
    @IBOutlet weak var lblCookName: UILabel!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.bringSubviewToFront(vwBottom)
        self.contentView.layer.cornerRadius = 12.0
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:20, left:0, bottom:0, right:0))
    }
}
