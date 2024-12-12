//
//  calenderCell.swift
//  SanskarEP
//
//  Created by Surya on 19/07/24.
//

import UIKit

class calenderCell: UICollectionViewCell {
    
    @IBOutlet weak var dayofmonth: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dayofmonth.textColor = .black // Set default text color
        self.layer.cornerRadius = 5   // Optional: Rounded corners for the cell
        self.layer.borderWidth = 1    // Optional: Add border
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
