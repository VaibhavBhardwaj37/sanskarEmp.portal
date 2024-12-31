//
//  VistorHistoryVC.swift
//  SanskarEP
//
//  Created by Warln on 23/04/22.
//

import UIKit

class VistorHistoryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerTxt: UILabel!
    @IBOutlet weak var searchUIBar: UISearchBar!
    @IBOutlet weak var searchHolder: UIView!
    @IBOutlet weak var detailview: UIView!
    @IBOutlet weak var namelbl: UILabel!
    @IBOutlet weak var reqdate: UITextField!
    @IBOutlet weak var meetinglbl: UILabel!
    @IBOutlet weak var addresslbl: UILabel!
    @IBOutlet weak var intimelbl: UILabel!
    @IBOutlet weak var outtimelbl: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var guestbtn: UIButton!
    @IBOutlet weak var hidebtn: UIButton!
    @IBOutlet weak var submit: UIButton!
    @IBOutlet weak var editstarttime: UITextField!
    @IBOutlet weak var editendtime: UITextField!
    
    
    var titleText: String?
    var vistorList: [VistorList] = []
    var newList: [VistorList] = []
    var fromDate: String?
    var toDate: String?
    var isSearch: Bool = false
    var searchTap: Bool = false
    var selectedIndexPath: IndexPath?
    fileprivate let edittimePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "VistorCell", bundle: nil), forCellReuseIdentifier: "VistorCell")
        tableView.dataSource = self
        tableView.delegate = self
        searchUIBar.delegate = self
   //     headerTxt.text = "Vistor History"
        vistorApiHit()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            self.searchHolder.isHidden = true
        }, completion: nil)
        detailview.isHidden = true
        submit.layer.cornerRadius = 8
        edittimePickerSetup()
    }
    
    func edittimePickerSetup() {
        let edittoolBar = UIToolbar()
        let edittoolBar2 = UIToolbar()
        edittoolBar.sizeToFit()
        edittoolBar2.sizeToFit()
        let doneBtn1 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editdoneBtnClicK))
        let doneBtn2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editdoneBtnClicK1))
        edittoolBar.items = [doneBtn1]
        edittoolBar2.items = [doneBtn2]
        editstarttime.inputAccessoryView = edittoolBar
        editstarttime.inputView = edittimePicker
        editendtime.inputAccessoryView = edittoolBar2
        editendtime.inputView = edittimePicker
        edittimePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            edittimePicker.preferredDatePickerStyle = .wheels
        } else {
        }
    }
    @objc
    func editdoneBtnClicK() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm a"
        editstarttime.text = "\(formatter.string(from: edittimePicker.date))"
        self.view.endEditing(true)
    }
    @objc
    func editdoneBtnClicK1() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm a"
        editendtime.text = "\(formatter.string(from: edittimePicker.date))"
        self.view.endEditing(true)
    }
    
    
    @IBAction func BackBtn(_ sender: UIButton) {
        dismiss(animated: true,completion: nil)
    }
    
    
    @IBAction func datebtn(_ sender: UIButton) {
        IosDatePicker().showDate(animation: .zoomIn, pickerMode: .date) { date in
            self.reqdate.text = Utils.dateString(date: date, format: "yyyy-MM-dd")
        }
    }
    
    @IBAction func hideviewbtn(_ sender: UIButton) {
        detailview.isHidden = true
    }
    
   
    @IBAction func submitbtn(_ sender: UIButton) {
        againvistorApiHit()
    }
    
    @IBAction func GuestBtnCLiclk(_ sender: UIButton) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GuestVc") as! GuestVc
        if #available(iOS 15.0, *) {
        if let sheet = vc.sheetPresentationController {
        var customDetent: UISheetPresentationController.Detent?
            if #available(iOS 16.0, *) {
            customDetent = UISheetPresentationController.Detent.custom { context in
                return 520
                
            }
            sheet.detents = [customDetent!]
            sheet.largestUndimmedDetentIdentifier = customDetent!.identifier
                }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
                            }
                        }
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func searchBtnPressed(_ sender: UIButton ) {
        switch sender.tag{
        case 98:
            searchHolder.isHidden = false
        case 99:
            searchHolder.isHidden = true
        default:
            break
        }
    }
    
    @IBAction func hidebtn(_ sender: UIButton) {
        searchHolder.isHidden = true
    }
    
    
    
    func configure1(with model: VistorList ) {
        guard let url = URL(string: model.image) else {return}
        image.sd_setImage(
            with: url,
            placeholderImage: UIImage(systemName: "person.fill"),
            options: .refreshCached, completed: nil
        )
        namelbl.text = model.name
        reqdate.text = model.guest_date
        meetinglbl.text = model.to_whome
        addresslbl.text = model.address
        editstarttime.text = model.in_time
        editendtime.text = model.out_time
        outtimelbl.text = model.mobile
    }
    @available(iOS 15.0, *)
    @IBAction func filterBtnPressed(_ sender: UIButton ) {
        let vc = FilterVC()
        vc.modalPresentationStyle = UIModalPresentationStyle.pageSheet
        vc.delegate = self
        guard let sheetController = vc.presentationController as? UISheetPresentationController else {
            return
        }
        sheetController.detents = [.medium()]
        sheetController.prefersGrabberVisible = true
        present(vc, animated: true)
        
    }
    
    @objc
    func AcceptOnClick(_ sender: UIButton) {
        let index = sender.tag // Get the index of the selected row from the button tag
        let selectedModel: VistorList

        if isSearch {
            selectedModel = newList[index]
        } else {
            selectedModel = vistorList[index]
        }
        
        configure1(with: selectedModel) // Set the data for the labels
        detailview.isHidden = !detailview.isHidden // Toggle the visibility of detailview
    }

//    func guestRequest() {
//        var dict = Dictionary<String,Any>()
//        dict["EmpCode"] = currentUser.EmpCode   
//        dict["Reason"] = reasonTxtView.text
//        dict["WhomtoMeet"] = whomTxtField.text!
//        dict["Guest_Name"] = nametextField.text!
//        dict["Date1"] = dateTxtField.text!
//        dict["image"] = Uimage.image?.resizeToWidth3(250)
////        DispatchQueue.main.async(execute: {Loader.showLoader()})
////        APIManager.apiCall(postData: dict as NSDictionary, url: kGuestApi) { result, response, error, data in
////            DispatchQueue.main.async(execute: {Loader.hideLoader()})
////            if let _ = data,(response?["status"] as? Bool == true), response != nil {
////                AlertController.alert(message: (response?.validatedValue("message"))!)
////                self.removeData()
////            }else{
////                print(response?["error"] as Any)
////            }
////        }
//        let url =  BASEURL + "/" + kGuestApi
//        DispatchQueue.main.async(execute: {Loader.showLoader()})
//        Alamofire.upload(multipartFormData: { (multipartFormData) in
//            for (key, value) in dict {
//                if key == "image"{
//                    let milliseconds = Int64(Date().timeIntervalSince1970 * 1000.0)
//                    let milisIsStirng = "\(milliseconds)"
//                    let filename = "\(milisIsStirng).png"
//                    let imageData = (value as! UIImage).pngData() as NSData?
//                    multipartFormData.append((imageData! as Data) as Data, withName: key , fileName: filename as String, mimeType: "image/png")
//                } else {
//                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key )
//                }
//            }
//        }, usingThreshold: UInt64(), to: url, method: .post , headers: nil, encodingCompletion: { (encodingResult) in
//            switch encodingResult {
//            case .success(let upload, _, _):
//                upload.uploadProgress(closure: { (Progress) in
//                    print("Upload Progress: \(Progress.fractionCompleted)")
//                })
//                upload.responseJSON(completionHandler: { [self] (response) in
//                    debugPrint(response)
//                    switch response.result {
//                    case .success(_):
//                        DispatchQueue.main.async(execute: {Loader.hideLoader()})
//                        if let JSON = response.result.value as? NSDictionary {
//                            if JSON.value(forKey: "status") as! Bool == true {
//                                print(JSON)
//                                let data = (JSON["data"] as? [[String:Any]] ?? [[:]])
//                                print(data)
//                                AlertController.alert(message: JSON.value(forKey: "message") as! String)
//                                self.navigationController?.popViewController(animated: true)
//                                
//                            } else {
//                                AlertController.alert(message: JSON.value(forKey: "message") as! String)
//                            }
//                        }
//                        
//                        break
//                    case .failure(let encodingError):
//                        if let err = encodingError as? URLError, err.code == .notConnectedToInternet || err.code == .timedOut {
//                            
//                        } else {
//                            
//                        }
//                    }
//                })
//            case .failure(let encodingError):
//                if let err = encodingError as? URLError, err.code == .notConnectedToInternet || err.code == .timedOut {
//                    
//                } else {
//                    
//                }
//                
//            }
//        })
//        
//    }
    
    func vistorApiHit() {
        var dict = Dictionary<String,Any>()
        dict["EmpCode"] = currentUser.EmpCode
        dict["fromDate"] = fromDate ?? ""
        dict["toDate"] = toDate ?? ""
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        vistorList.removeAll()
        newList.removeAll()
        APIManager.apiCall(postData: dict as NSDictionary, url: vistorHistory) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            guard let data = data, error == nil else {
                AlertController.alert(message: error?.localizedDescription as? String ?? "")
                return
            }
            do{
                let json = try JSONDecoder().decode(VistorResponse.self, from: data)
                self.vistorList.append(contentsOf: json.data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    func againvistorApiHit() {
        var dict = Dictionary<String,Any>()
        dict["EmpCode"] = currentUser.EmpCode
        dict["MOBILE"] = outtimelbl.text
        dict["TO_WHOME"] = namelbl.text
        dict["IN_TIME"] = editstarttime.text
        dict["ADDRESS"] = addresslbl.text
        dict["AROGYA_SETU_STATUS"] = "yes"
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        vistorList.removeAll()
        newList.removeAll()
        APIManager.apiCall(postData: dict as NSDictionary, url: visitorregistration) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            guard let data = data, error == nil else {
                AlertController.alert(message: error?.localizedDescription as? String ?? "")
                return
            }
            do{
                let json = try JSONDecoder().decode(VistorResponse.self, from: data)
                self.vistorList.append(contentsOf: json.data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
    
            }catch{
                print(error.localizedDescription)
            }
        }
    }

}

extension VistorHistoryVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearch{
            return newList.count
        }else{
            return vistorList.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VistorCell", for: indexPath) as? VistorCell else {
            return UITableViewCell()
        }
        if isSearch {
            cell.configure(with: newList[indexPath.row])
        } else {
            cell.configure(with: vistorList[indexPath.row])
        }
  
        cell.penbtn.tag = indexPath.row
        cell.penbtn.addTarget(self, action: #selector(AcceptOnClick(_:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }



    }



extension VistorHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175
    }
}

extension VistorHistoryVC: FilterVCDelegate {
    func didGetDate(with start: String, with end: String) {
        DispatchQueue.main.async {
            self.fromDate = start
            self.toDate = end
            self.vistorApiHit()
        }
    }
    
}

extension VistorHistoryVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
           isSearch = false
    }
       
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           searchBar.resignFirstResponder()
           isSearch = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            isSearch = false
            self.tableView.reloadData()
        }else{
            newList = vistorList.filter({ text in
                let temp: NSString = text.name as NSString
                let range = temp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
                return range.location != NSNotFound
            })
            if newList.count == 0 {
                isSearch = false
            }else{
                isSearch = true
            }
            self.tableView.reloadData()
        }
    }
}
