//
//  ProfileVc.swift
//  SanskarEP
//
//  Created by Warln on 11/01/22.
//

import UIKit
import Alamofire

@available(iOS 13.0, *)
class ProfileVc: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var empName: UILabel!
    @IBOutlet weak var empCode: UILabel!
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var plLbl: UILabel!
    @IBOutlet weak var joinDate: UILabel!
    @IBOutlet weak var desgnLbl: UILabel!
    @IBOutlet weak var departLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var reportLbl: UILabel!
    @IBOutlet weak var panLbl: UILabel!
    @IBOutlet weak var aadharLbl: UILabel!
    @IBOutlet weak var bloodLbl: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var notifyLbl: UILabel!
    @IBOutlet weak var cameraimage: UIImageView!
    @IBOutlet weak var editbtn: UIButton!
    @IBOutlet weak var savebtn: UIButton!
    @IBOutlet weak var imagebtn: UIButton!
    
    
    
    var edit = false
    var imageurl1 = "https://sap.sanskargroup.in/uploads/employee/"
    var imaged = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        updateUI()
        cameraimage.isHidden = true
        savebtn.isHidden = true
        
        let img = currentUser.PImg.replacingOccurrences(of: " ", with: "%20")
        if #available(iOS 13.0, *) {
            profile.sd_setImage(with: URL(string:img), placeholderImage: UIImage(systemName: "person.circle.fill"), options: .refreshCached, completed: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let noteCount = UserDefaults.standard.value(forKey: "noteCount") as? Int ?? 0
        if noteCount > 0 {
            notifyLbl.isHidden = false
        }else{
            notifyLbl.isHidden = true
        }
    }
    //MARK: - Update UI
    func updateUI() {
        //Mark:- Profile Pic
        profile.circleImg(2.0, UIColor.gray)
        let img = currentUser.PImg.replacingOccurrences(of: " ", with: "%20")
        print(img)
        profile.sd_setImage(with: URL(string: imageurl1+img))
        //Mark:- Emp Details
        baseView.layer.cornerRadius = 2
        baseView.clipsToBounds = true
        notifyLbl.circleLbl()
        let noteNo = UserDefaults.standard.value(forKey: "noteCount")
        if let noteNo = noteNo as? Int{
            notifyLbl.text = "\(noteNo)"
        }
        empCode.text = currentUser.EmpCode
        empName.text = currentUser.Name
        plLbl.text = currentUser.pl_balance
        joinDate.text = currentUser.JDate
        desgnLbl.text = currentUser.Designation
        departLbl.text = currentUser.Dept
        addressLbl.text = currentUser.address
        reportLbl.text = currentUser.ReportTo
        panLbl.text = currentUser.PanNo
        aadharLbl.text = currentUser.AadharNo
        bloodLbl.text = currentUser.BloodGroup
        logoutBtn.layer.cornerRadius = 10.0
        logoutBtn.clipsToBounds = true
        
    }
    
    
    //MARK: - Logout Button Pressed
    
    @IBAction func logoutBtnPressed(_ sender: UIButton) {
        
        
        currentUser.removeData()
        if #available(iOS 13.0, *) {
            SceneDelegate.shared?.AppFlow()
        }else{
            AppDelegate.shared?.AppFlow()
        }
    }

    func newDetailApi(){
        var dict = Dictionary<String,Any>()
        
        dict["EmpCode"] = currentUser.EmpCode
        dict["image"] = profile.image?.resizeToWidth2(250)
      
        let url =  BASEURL + "/" + ProUpdate
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
    
    @IBAction func buttonaction(_ sender: UIButton) {
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
    
    @IBAction func editbtn(_ sender: UIButton) {
//        cameraimage.isHidden = false
////        if edit == 0 {
//            editbtn.setTitle("Save", for: .normal)
//       // }
//        savebtn.isHidden = true
        
       
            if edit {
                // Save button pressed
                cameraimage.isHidden = true
                newDetailApi()
                editbtn.isHidden = false
                editbtn.setTitle("Edit", for: .normal)
                savebtn.isHidden = true
                edit = false
            } else {
                // Edit button pressed
                cameraimage.isHidden = false
                editbtn.isHidden = true
                savebtn.isHidden = false
                edit = true
            }
        }

    
    
    @IBAction func saveBtn(_ sender: UIButton) {
//        cameraimage.isHidden = true
//        newDetailApi()
//        editbtn.isHidden = true
//        newDetailApi()
            cameraimage.isHidden = true
            editbtn.setTitle("Edit", for: .normal)
            savebtn.isHidden = true
            edit = false
      
    }
    
    
    @IBAction func imagebtn(_ sender: UIButton) {
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
            profile.image = selectedImage
        } else {
            print("Image not found")
        }
        picker.dismiss(animated: true,completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true,completion: nil)
    }

    @IBAction func noteBtnPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        vc.titleTxt = "Notification"
        present(vc, animated: true)
      //  self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func backbutton(_ sender: Any) {
        
        dismiss(animated: true,completion: nil)
    }
  
        func PhotoFormCamera()  {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                let controller = UIImagePickerController()
                controller.sourceType = .camera
                controller.allowsEditing = true
                controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera) ?? [String]()
                controller.delegate = self
                if Float(UIDevice.current.systemVersion) ?? 0.0 >= 8.0 {
                    OperationQueue.main.addOperation({() -> Void in
                        self.present(controller, animated: true)
                    })
                }else {
                    present(controller, animated: true)
                }
            }
        }
        
        //MARK:- Picking image Form PhotoLibrary.
        func PhotoFromPhotoAlbum()  {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                let controller = UIImagePickerController()
                controller.sourceType = .savedPhotosAlbum
                controller.allowsEditing = true
                controller.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? [String]()
                controller.delegate = self
                if Float(UIDevice.current.systemVersion) ?? 0.0 >= 8.0 {
                    OperationQueue.main.addOperation({() -> Void in
                        self.present(controller, animated: true)
                    })
                }else {
                    present(controller, animated: true)
                }
            }
        }
}
extension UIImage {
        func resizeToWidth2(_ width:CGFloat)-> UIImage {
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
