//
//  InstructionCell.swift
//  Ahara
//
//  Created by Miroslav Kostic on 5/24/21.
//

import UIKit

class InstructionCell : UITableViewCell {
            
    @IBOutlet weak var lblStep: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 12.0
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top:20, left:0, bottom:0, right:0))
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
    }
}
