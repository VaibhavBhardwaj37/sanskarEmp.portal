//
//  homeCollectionCell.swift
//  SanskarEP
//
//  Created by Surya on 12/08/23.
//

import UIKit

class homeCollectionCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var taskLbl: UILabel!
    @IBOutlet weak var taskBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setup() {
        self.layer.cornerRadius = 20
        self.clipsToBounds = true
    }

    
}