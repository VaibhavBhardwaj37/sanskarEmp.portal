//
//  LeaveNotificationAlert.swift
//  SanskarEP
//
//  Created by Vaibhav on 18/02/25.
//

import UIKit


protocol LeaveRequestDelegate {
    func FetchRequest(_ status: Bool, _ noteId: String)
}

class LeaveNotificationAlert: UIViewController {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var Namelbl: UILabel!
    @IBOutlet weak var typelbl: UILabel!
    @IBOutlet weak var Acceptbtn: UIButton!
    @IBOutlet weak var Rejectbtn: UIButton!
    @IBOutlet weak var Remarkstext: UITextView!
    @IBOutlet weak var Headerview: UIView!
    @IBOutlet weak var viewtop: NSLayoutConstraint!
    
    
    var imgName: String?
    var nameTxt: String?
    var delegate: LeaveRequestDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Headerview.layer.cornerRadius = 5
        Headerview.clipsToBounds = true
        Remarkstext.isHidden = true
        Remarkstext.delegate = self
        
        Remarkstext.layer.cornerRadius = 10
        Acceptbtn.layer.cornerRadius = 10
        Rejectbtn.layer.cornerRadius = 10
        
        Remarkstext.clipsToBounds = true
        Remarkstext.layer.borderWidth = 1.0
        Remarkstext.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    
    func setup() {
        guard let url = URL(string: "https://sap.sanskargroup.in//uploads/visitor/\(imgName ?? "")") else {return}
        imageview.sd_setImage(
            with: url,
            placeholderImage: UIImage(systemName: "person.fill"),
            options: .refreshCached,
            completed: nil
        )
        Namelbl.text = nameTxt
    }
    
    @IBAction func canclebtn(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func Acceptonclick(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func RejectOnclick(_ sender: UIButton) {
        if Remarkstext.isHidden {
            Remarkstext.isHidden = false
            viewtop.constant = 60
            sender.setTitle("Send", for: .normal)
            sender.backgroundColor = UIColor.blue
        } else {
            Remarkstext.isHidden = true
            viewtop.constant = 5
            sender.setTitle("Reject", for: .normal)
            sender.backgroundColor = UIColor(red: 187/255, green: 45/255, blue: 59/255, alpha: 1.0)
           
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
extension LeaveNotificationAlert : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (Remarkstext.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 200
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if Remarkstext.textColor == UIColor.lightGray {
            Remarkstext.text = ""
            Remarkstext.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if Remarkstext.text == "" {

            Remarkstext.text = "Remark ..."
            Remarkstext.textColor = UIColor.lightGray
        }
    }
}
