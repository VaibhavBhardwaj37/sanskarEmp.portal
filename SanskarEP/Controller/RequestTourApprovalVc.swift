//
//  RequestTourApprovalVc.swift
//  SanskarEP
//
//  Created by Sanskar IOS Dev on 20/06/23.
//

import UIKit
import Alamofire
import MobileCoreServices

class RequestTourApprovalVc: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()
    
        @IBOutlet var imageview: UIImageView!
        @IBOutlet var amount: UITextField!
        @IBOutlet var tourid: UITextField!
        @IBOutlet var MyTableView: UITableView!
        @IBOutlet var BtnLbl: UIButton!
    
        @IBOutlet var dropbtn: UIButton!
    //
       var TourId = [String]()
        fileprivate let pickerView = ToolbarPickerView()
        override func viewDidLoad() {
            super.viewDidLoad()
            print(TourId)
    
    
            MyTableView.isHidden = true
    
            MyTableView.delegate = self
            MyTableView.dataSource = self
           
        }
    
    
        @IBAction func backbutton(_ sender: Any) {
            dismiss(animated: true,completion: nil)
            self.navigationController?.popViewController(animated: true)
    
        }
    
        @IBAction func ArrowButton(_ sender: Any) {
            if MyTableView.isHidden {
                animate(toggle: true)
            } else {
                animate(toggle: false)
    
              //  self.MyTableView.isHidden = !self.MyTableView.isHidden
            }
        }
        func animate(toggle:Bool) {
            if toggle {
                UIView.animate(withDuration: 0.3) {
                    self.MyTableView.isHidden = false
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.MyTableView.isHidden = true
                }
            }
        }
    
    
    @IBAction func AddImage(_ sender: Any) {
        let ac = UIAlertController(title: "Select Image", message: "Select Image from", preferredStyle: .actionSheet)
       //             let cameraBtn = UIAlertAction(title: "Camera", style: .default) {[weak self] (_) in self?.showImagePicker(selectedSource: .camera)
        func openCamera() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
                imagePicker.sourceType = .camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                present(imagePicker, animated: true, completion: nil)
                    } else {
                print("Camera not available.")
            }
        }
        func openGallery() {
          
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            present(imagePicker, animated: true, completion: nil)
        }
        //        }
        //        let GalleryBtn = UIAlertAction(title: "Gallery", style: .default) {[weak self] (_) in self?.showImagePicker(selectedSource: .photoLibrary)
        //        }
        //        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        //        ac.addAction(cameraBtn)
        //        ac.addAction(GalleryBtn)
        //        ac.addAction(cancelBtn)
        //        self.present(ac,animated: true, completion: nil)
        //    }
        //
            func showImagePicker(selectedSource: UIImagePickerController.SourceType) {
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
                if let pickedImage = info[.originalImage] as? UIImage {
                    imageview.image = pickedImage
                }
               picker.dismiss(animated: true,completion: nil)
            }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true,completion: nil)
        }
        
    }
        @IBAction func SubmitBtn(_ sender: Any) {
            var dict = Dictionary<String,Any>()
            dict["EmpCode"] = currentUser.EmpCode
           print(dict)
            dict["Amount"] = "500"
           // amount.text!
           // print(amount)
            dict["Tour_id"] =  "TR/2023/IT/8090"
         //   tourid.text!
            dict["Date1"] = "2023-06-19"
            dict["image"] = imageview.image?.resizeToWidth(250)
            let url =  BASEURL + "/" + ptourApi
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
                    upload.responseJSON(completionHandler: { (response) in
                        debugPrint(response)
                        switch response.result {
                        case .success(_):
    //                        DispatchQueue.main.async(execute: {loader.shareInstance.hideLoading()})
                            if let JSON = response.result.value as? NSDictionary {
                                if JSON.value(forKey: "status") as! Bool == true {
                                  print(JSON)
    
                                } else {
    
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
    //        APIManager.apiCall(postData: dict as NSDictionary, url: ptourApi) { result, response, error, data in
    //            if let JSON = response as? NSDictionary {
    //                if JSON.value(forKey: "status") as? Bool == true {
    //                    print(JSON)
    //                    let data = (JSON["data"] as? [[String:Any]] ?? [[:]])
    //                    print(data)
    //                    AlertController.alert(message: (response?.validatedValue("message"))!)
    //                }
    //
    //            }
    //
    //        }
        }
    }
    extension RequestTourApprovalVc: UITableViewDelegate,UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return TourId.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = MyTableView.dequeueReusableCell(withIdentifier: "droptourTableViewCell", for: indexPath) as! droptourTableViewCell
            cell.lbl?.text = TourId[indexPath.row]
            print(cell.lbl.text)
            return cell
    
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let cell = tableView.cellForRow(at: indexPath)
            dropbtn.setTitle("\(TourId[indexPath.row])",for:.normal)
            animate(toggle: false)
        }
    
    }
//    extension UIImage {
//        func resizeToWidth(_ width:CGFloat)-> UIImage {
//            let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
//            imageView.contentMode = UIView.ContentMode.scaleAspectFit
//            imageView.image = self
//            UIGraphicsBeginImageContext(imageView.bounds.size)
//            imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
//            let result = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//            return result!
//        }
//    }


