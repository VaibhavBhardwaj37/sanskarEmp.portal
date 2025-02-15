//
//  newapproCell.swift
//  SanskarEP
//
//  Created by Surya on 08/02/25.
//

import UIKit

class newapproCell: UITableViewCell {
    
    @IBOutlet weak var btnreject: UIButton!
    @IBOutlet weak var btnAprove: UIButton!
    @IBOutlet weak var okbtn: UIButton!
    @IBOutlet weak var txtRemarkView: UITextView!
    @IBOutlet weak var reamrk: UIView!
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var dept: UILabel!
    @IBOutlet weak var datelbl: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var reason: UILabel!
    @IBOutlet weak var checkbtn: UIButton!
    @IBOutlet weak var imageview1: UIImageView!
    @IBOutlet weak var status: UILabel!
   // Track expanded cell index
    var arrowButtonTapped: ((UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        reamrk.isHidden = true
        btnAprove.layer.cornerRadius = 8
        btnreject.layer.cornerRadius = 8
        okbtn.layer.cornerRadius = 8
        imageview.layer.borderWidth = 0.5
        imageview.clipsToBounds = true
        imageview.layer.cornerRadius = 6
        
        txtRemarkView.delegate = self
        txtRemarkView.layer.cornerRadius = 10
        txtRemarkView.clipsToBounds = true
        txtRemarkView.text = "Remark ..."
        txtRemarkView.textColor = UIColor.lightGray
        txtRemarkView.layer.borderWidth = 1.0
        txtRemarkView.layer.borderColor = UIColor.darkGray.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func Approvebtn(_ sender: UIButton) {
     
        
    }
    
    func setImage(with model: String) {
        var imgUrl = ""
        if model.containsWhitespace {
            imgUrl = model.replacingOccurrences(of: " ", with: "%20")
        }else{
            imgUrl = model
        }
        guard let url = URL(string: imgUrl) else {return}
        imageview1.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.fill"), options: .refreshCached, completed: nil)
    }
    
    @IBAction func rjectbtn(_ sender: UIButton) {
        arrowButtonTapped?(sender)
    }
}
extension newapproCell : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (txtRemarkView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 200
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if txtRemarkView.textColor == UIColor.lightGray {
            txtRemarkView.text = ""
            txtRemarkView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if txtRemarkView.text == "" {

            txtRemarkView.text = "Remark ..."
            txtRemarkView.textColor = UIColor.lightGray
        }
    }
}
