//
//  GuestVc.swift
//  SanskarEP
//
//  Created by Warln on 13/01/22.
//

import UIKit
import Alamofire

class GuestVc: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //MARK: - IBOutlet
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var dateTxtField: UITextField!
    @IBOutlet weak var nametextField: UITextField!
    @IBOutlet weak var whomTxtField: UITextField!
    @IBOutlet weak var reasonTxtView: UITextView!
    @IBOutlet weak var Uimage: UIImageView!
    
    //Mark:- Variable
    var titleTxt: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateTxtField.textColor == UIColor.lightGray
        nametextField.textColor == UIColor.lightGray
        whomTxtField.textColor == UIColor.lightGray
        setup()
        reasonTxtView.delegate = self
//        if #available(iOS 15.0, *) {
//            sheetPresentationController?.prefersGrabberVisible = true
//        } else {
//            // Fallback on earlier versions
//        }
//        if #available(iOS 15.0, *) {
//            sheetPresentationController?.detents = [.large()]
//        } else {
//            // Fallback on earlier versions
//        }

        
    }
    
    @IBAction func Backbtn(_ sender: UIButton) {
        dismiss(animated: true,completion: nil)
    }
    
    
    @IBAction func uploadimage(_ sender: UIButton) {
        let ac = UIAlertController(title: "Select Image", message: "Select Image from", preferredStyle: .actionSheet)
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) {[weak self] (_) in self?.showImagePicker(selectedSource: .camera)
            
        }
        let GalleryBtn = UIAlertAction(title: "Gallery", style: .default) {[weak self] (_) in self?.showImagePicker(selectedSource: .photoLibrary)
        }
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cameraBtn)
        ac.addAction(GalleryBtn)
        ac.addAction(cancelBtn)
        self.present(ac,animated: true, completion: nil)
    }
    
    func setup() {
        reasonTxtView.text = "Reason For Meeting..."
        reasonTxtView.textColor = .lightGray
        headerLbl.text = titleTxt
        reasonTxtView.layer.cornerRadius = 10
        reasonTxtView.layer.borderWidth = 0.5
        reasonTxtView.layer.borderColor = UIColor.lightGray.cgColor
        reasonTxtView.clipsToBounds = true
        datepicker()
    }
    
    func datepicker () {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {

        }
        datePicker.addTarget(self, action: #selector(datePickerValue(_:)), for: .valueChanged)
        datePicker.frame.size = CGSize(width: 0, height: 250)
        dateTxtField.inputView = datePicker
    }
    
    @objc
    func datePickerValue(_ sender: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateTxtField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
    
         //   dismiss(animated: true,completion: nil)
        
        switch sender.tag {
        case 17:
            self.navigationController?.popViewController(animated: true)
        case 18:
            let vc = storyboard?.instantiateViewController(withIdentifier: "VistorHistoryVC") as! VistorHistoryVC
           // navigationController?.pushViewController(vc, animated: true)
            self.present(vc,animated: true,completion: nil)
        case 19:
            let vc = storyboard?.instantiateViewController(withIdentifier: "GuestHistoryVc") as! GuestHistoryVc
          //  navigationController?.pushViewController(vc, animated: true)
            self.present(vc,animated: true,completion: nil)
        default:
            break
        }
        
    }
    
    
    @IBAction func searchBtnPressed(_ sender: UIButton ) {
        let vc = GuestHistoryVc()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
//        if (dateTxtField.text! == "") && (nametextField.text! == "") && (whomTxtField.text! == "")  {
//            AlertController.alert(message: "Please Enter the details")
//        }else{
//            guestRequest()
//        }
     
        if dateTxtField.text?.isEmpty ?? true {
               AlertController.alert(message: "Please enter the Date and Time")
               return
           }
           if nametextField.text?.isEmpty ?? true {
               AlertController.alert(message: "Please enter the Name")
               return
           }
           if whomTxtField.text?.isEmpty ?? true {
               AlertController.alert(message: "Please enter Whom to Meet")
               return
           }
           // Check for both empty and placeholder text for the reason field
           if reasonTxtView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || reasonTxtView.text == "Reason For Meeting..." {
               AlertController.alert(message: "Please enter the Reason")
               return
           }
        
           guestRequest()
       }
    func showImagePicker(selectedSource: UIImagePickerController.SourceType){
        guard UIImagePickerController.isSourceTypeAvailable(selectedSource) else {
            print("Selected Source not available")
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = selectedSource
        imagePickerController.allowsEditing = false
        self.present(imagePickerController,animated: true,completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            Uimage.image = selectedImage
        } else {
            print("Image not found")
        }
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }

}

//MARK: - Send Request to server

extension GuestVc {
    
    func guestRequest() {
        var dict = Dictionary<String,Any>()
        dict["EmpCode"] = currentUser.EmpCode
        dict["Reason"] = reasonTxtView.text
        dict["WhomtoMeet"] = whomTxtField.text!
        dict["Guest_Name"] = nametextField.text!
        dict["Date1"] = dateTxtField.text!
        dict["image"] = Uimage.image?.resizeToWidth3(250)
//        DispatchQueue.main.async(execute: {Loader.showLoader()})
//        APIManager.apiCall(postData: dict as NSDictionary, url: kGuestApi) { result, response, error, data in
//            DispatchQueue.main.async(execute: {Loader.hideLoader()})
//            if let _ = data,(response?["status"] as? Bool == true), response != nil {
//                AlertController.alert(message: (response?.validatedValue("message"))!)
//                self.removeData()
//            }else{
//                print(response?["error"] as Any)
//            }
//        }
        let url =  BASEURL + "/" + kGuestApi
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (key, value) in dict {
                if key == "image"{
                    let milliseconds = Int64(Date().timeIntervalSince1970 * 1000.0)
                    let milisIsStirng = "\(milliseconds)"
                    let filename = "\(milisIsStirng).png"
                    let imageData = (value as! UIImage).pngData() as NSData?
                    multipartFormData.append((imageData! as Data) as Data, withName: key , fileName: filename as String, mimeType: "image/png")
                } else {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key )
                }
            }
        }, usingThreshold: UInt64(), to: url, method: .post , headers: nil, encodingCompletion: { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                upload.responseJSON(completionHandler: { [self] (response) in
                    debugPrint(response)
                    switch response.result {
                    case .success(_):
                        DispatchQueue.main.async(execute: {Loader.hideLoader()})
                        if let JSON = response.result.value as? NSDictionary {
                            if JSON.value(forKey: "status") as! Bool == true {
                                print(JSON)
                                let data = (JSON["data"] as? [[String:Any]] ?? [[:]])
                                print(data)
                                AlertController.alert(message: JSON.value(forKey: "message") as! String)
                                self.navigationController?.popViewController(animated: true)
                                
                            } else {
                                AlertController.alert(message: JSON.value(forKey: "message") as! String)
                            }
                        }
                        
                        break
                    case .failure(let encodingError):
                        if let err = encodingError as? URLError, err.code == .notConnectedToInternet || err.code == .timedOut {
                            
                        } else {
                            
                        }
                    }
                })
            case .failure(let encodingError):
                if let err = encodingError as? URLError, err.code == .notConnectedToInternet || err.code == .timedOut {
                    
                } else {
                    
                }
                
            }
        })
        
    }
    
    func removeData() {
        whomTxtField.text?.removeAll()
        nametextField.text?.removeAll()
        dateTxtField.text?.removeAll()
        reasonTxtView.text.removeAll()
    
    }
}

//MARK: - UITextView Delegate

extension GuestVc: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (reasonTxtView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars < 200
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {

        if reasonTxtView.textColor == UIColor.lightGray {
            reasonTxtView.text = ""
            reasonTxtView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {

        if reasonTxtView.text == "" {

            reasonTxtView.text = "Reason For Meeting..."
            reasonTxtView.textColor = UIColor.lightGray
        }
    }
}
extension UIImage {
        func resizeToWidth3(_ width:CGFloat)-> UIImage {
            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
            imageView.contentMode = UIView.ContentMode.scaleAspectFit
            imageView.image = self
            UIGraphicsBeginImageContext(imageView.bounds.size)
            imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let result = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return result!
        }
    }
