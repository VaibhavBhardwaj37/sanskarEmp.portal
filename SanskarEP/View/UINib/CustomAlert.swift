//
//  CustomAlert.swift
//  SanskarEP
//
//  Created by Warln on 22/04/22.
//

import UIKit
import SDWebImage
import iOSDropDown

protocol GuestRequestDelegate {
    func fetchRequest(_ status: Bool, _ location: String)
}

class CustomAlert: UIViewController {
    
    @IBOutlet weak var posterImg: UIImageView!
    @IBOutlet weak var nameLbL: UILabel!
    @IBOutlet weak var locateTxt: DropDown!
    @IBOutlet weak var holderView: UIView!
    
    var locDetails = ["Ground Floor","Reception","Conference Room","Second Floor"]
    var imgName: String?
    var nameTxt: String?
    var delegate: GuestRequestDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Bundle.main.loadNibNamed("CustomAlert", owner: self, options: nil)
        holderView.layer.cornerRadius = 5
        holderView.clipsToBounds = true
        setup()
        setDrop()

    }
    
    func setup() {
        guard let url = URL(string: "https://sap.sanskargroup.in//uploads/visitor/\(imgName ?? "")") else {return}
        posterImg.sd_setImage(
            with: url,
            placeholderImage: UIImage(systemName: "person.fill"),
            options: .refreshCached,
            completed: nil
        )
        nameLbL.text = nameTxt
    }
    
    func setDrop() {
        locateTxt.optionArray = locDetails
        locateTxt.isSearchEnable = true
        locateTxt.listHeight = 150
        locateTxt.didSelect { selectedText, index, id in
            self.locateTxt.text = selectedText
        }
    }
    
    @IBAction func rejectBtnPressed(_ sender: UIButton ) {
        delegate?.fetchRequest(false, "")
        self.dismiss(animated: true)
    }
    
    @IBAction func acceptBtnPressed(_ sender: UIButton ) {
        delegate?.fetchRequest(true, locateTxt.text ?? "")
        self.dismiss(animated: true)
    }
    
    @IBAction func dismissBtnPressed(_ sender: UIButton ) {
        self.dismiss(animated: true)
    }
}
