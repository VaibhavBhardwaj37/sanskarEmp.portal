//
//  AllStatusVc.swift
//  SanskarEP
//
//  Created by Surya on 01/03/24.
//

import UIKit
import iOSDropDown

class AllStatusVc: UIViewController {
    
@IBOutlet weak var LabelView: UIView!
@IBOutlet weak var selectText: DropDown!
@IBOutlet weak var headerLbl: UILabel!
@IBOutlet weak var tableview: UITableView!
@IBOutlet weak var upimage: UIImageView!
@IBOutlet weak var Selected: UISegmentedControl!
@IBOutlet weak var myreportview: UIView!
@IBOutlet weak var Allreportview: UIView!
@IBOutlet weak var searchbar: UISearchBar!
@IBOutlet weak var myreportv: NSLayoutConstraint!
    
    
    
    var list: [[String: Any]] = []
    var PLlist: [[String: Any]] = []
    var DetailData = [[String:Any]]()
    var reqNo = ""
    var type  = ""
    var selectedOption: String = ""
    var filteredDetailData: [[String: Any]] = []

    
    let options = ["Full Day Leave Status", "Half Day Leave Status", "Off Day Request Status","Tour Request Status","PL Summary"]
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDetails()
        EmployeeDetailAPi()
        
        selectText.layer.cornerRadius = 8
        selectText.clipsToBounds = true
        selectText.layer.borderWidth = 1
        
        adjust()
  
        
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: "TourStCell", bundle: nil), forCellReuseIdentifier: "TourStCell")
        tableview.register(UINib(nibName: "statusTableViewCell", bundle: nil), forCellReuseIdentifier: "statusTableViewCell")
        tableview.register(UINib(nibName: "PLCell", bundle: nil), forCellReuseIdentifier: "PLCell")
        tableview.register(UINib(nibName: "bdayviewcell", bundle: nil), forCellReuseIdentifier: "bdayviewcell")
        searchbar.delegate = self
        filteredDetailData = DetailData
        
        setupDropDown()
        myreportview.isHidden =  false
        Allreportview.isHidden =  true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func adjust(){
        if currentUser.EmpCode == "SANS-00079" {
            Selected.isHidden = false
        } else {
            Selected.isHidden = true
            myreportv.constant = -35
        }
    }
    
    @IBAction func backbtn(_ sender: UIButton) {
        dismiss(animated: true,completion: nil)
    }
    
    func setupDropDown() {
        selectText.optionArray = options
        selectText.isSearchEnable = true
        selectText.listHeight = 170
        selectText.didSelect { [weak self] selectedText, _, _ in
            guard let self = self else { return }
            self.selectedOption = selectedText
            
            switch selectedText {
            case "Full Day Leave Status":
                self.type = "full"
            case "Half Day Leave Status":
                self.type = "half"
            case "Off Day Request Status":
                self.type = "off"
            case "Tour Request Status":
                self.type = "tour"
            default:
                self.type = ""
            }
            
            self.getDetails()
            self.PlgetDetails()
        }
    }


    func check(status: String ) -> String {
        
        switch status {
        case "A":
            return " Approved"
        case "R":
            return " Pending"
        case "XA":
            return " Declined"
        case "X":
            return " Cancel"
        default:
            return ""
        }
    }
    
    func sColor(status: String ) -> UIColor {
        
        switch status {
        case "A":
            return .green
        case "R":
            return .blue
        case "XA":
            return .red
        case "X":
            return .purple
        default:
            return .black
        }
    }
    
    @objc func checkboxTapped(_ sender: UIButton) {
        cancelApi()
       }
    
    @IBAction func Selected(_ sender: UISegmentedControl) {
        if Selected.selectedSegmentIndex == 0 {
            myreportview.isHidden =  false
            Allreportview.isHidden =  true
        } else if Selected.selectedSegmentIndex == 1 {
            Allreportview.isHidden =  false
            myreportview.isHidden =  true
        }
            
        tableview.reloadData()
       
    }
    
        
        func EmployeeDetailAPi() {
            var dict = Dictionary<String, Any>()
            DispatchQueue.main.async(execute: {Loader.showLoader()})
            APIManager.apiCall(postData: dict as NSDictionary, url: EmployeeListApi) { result, response, error, data in
                DispatchQueue.main.async(execute: {Loader.hideLoader()})
                if  let responseData = response, responseData["status"] as? Bool == true {
                    if let JSON = responseData["data"] as? [[String: Any]] {
                        self.DetailData = JSON
                        self.filteredDetailData = JSON
                     
                        DispatchQueue.main.async {
                          
                        }
                        self.tableview.reloadData()
                    }
                } else {
                    AlertController.alert(message: (response?.validatedValue("message"))!)
                    print(response?["error"] as Any)
                }
                
            }
        }
        
    func cancelApi() {
        var dict = Dictionary<String,Any>()
        dict["EmpCode"] = currentUser.EmpCode
        dict["RequestId"] = reqNo
        dict["leave_type"] = "full"
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: kLeaveCancel) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let _ = data,(response?["status"] as? Bool == true), response != nil {
                AlertController.alert(message: (response?.validatedValue("message"))!)
                self.getDetails()
            }else{
                print(response?["error"] as Any)
            }
            self.tableview.reloadData()
        }
    }
    
    func getDetails() {
        var dict = Dictionary<String,Any>()
        dict["EmpCode"] = currentUser.EmpCode
        dict["leave_type"] = type
        list.removeAll()
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: status) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let JSON = response as? NSDictionary,
               let status = JSON.value(forKey: "status") as? Bool,
               status == true {
                
                if let jsonData = response?["data"] as? [[[String: Any]]] {
                    self.list = jsonData.flatMap { $0.flatMap { $0 } }
                    print(self.list)
                    self.tableview.reloadData()
                }
            } else {
                print(response?["error"] as Any)
            }
        }
    }
    
    func PlgetDetails() {
        var dict = Dictionary<String,Any>()
        dict["EmpCode"] = currentUser.EmpCode
        list.removeAll()
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: kplPlanel) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let _ = data,(response?["status"] as? Bool == true), response != nil {
                let json = response?["data"] as? [[String:Any]] ?? [[:]]
                for i in json {
                    self.PLlist.append(i)
                }
            }else{
                print(response?["error"] as Any)
            }
            self.tableview.reloadData()
        }
    }
}

extension AllStatusVc: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
  
    }
    
    
    func configurefulldaystatus(_ cell: TourStCell, indexPath: IndexPath) {
        let rowData = list[indexPath.row]
        cell.reqid.text = rowData["Emp_Req_No"] as? String ?? ""
        cell.fdate.text = rowData["Leave_From"] as? String ?? ""
        cell.todate.text = rowData["Leave_to"] as? String ?? ""
        cell.duration.text = rowData["Lduration"] as? String ?? ""
        
        if let hodApprovalStatus = rowData["HOD_Approval"] as? String {
            cell.hodA.text = check(status: hodApprovalStatus)
            cell.hodA.textColor = sColor(status: hodApprovalStatus)
            if ["A", "XA", "X"].contains(hodApprovalStatus){
                cell.canclebtn.isHidden = true
            } else {
                cell.canclebtn.isHidden = false
            }
        } else {
            cell.hodA.text = ""
            cell.hodA.textColor = .black
            cell.canclebtn.isHidden = false
        }
        cell.canclebtn.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
    }

    func configurehalfdayStatus(_ cell: statusTableViewCell, indexPath: IndexPath) {
        let rowData = list[indexPath.row]
        cell.reqId.text = rowData["ID"] as? String ?? ""
        cell.fromdate.text = rowData["RDate"] as? String ?? ""
        
        if let hodApprovalStatus = rowData["Status"] as? String {
            cell.status.text = check(status: hodApprovalStatus)
            cell.status.textColor = sColor(status: hodApprovalStatus)
            
            if ["A", "XA", "X"].contains(hodApprovalStatus) {
                cell.cancelbtn.isHidden = true
            } else {
                cell.cancelbtn.isHidden = false
            }
        } else {
            cell.status.text = ""
            cell.status.textColor = .black
        }
        
        cell.todate.isHidden = true
        cell.to.isHidden = true
        cell.cancelbtn.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
    }

    
    func configureoffdayStatus(_ cell: statusTableViewCell, indexPath: IndexPath) {
        let rowData = list[indexPath.row]
               cell.reqId.text = rowData["Emp_Req_No"] as? String ?? ""
               cell.fromdate.text = rowData["Leave_From"] as? String ?? ""
        if let hodApprovalStatus = rowData["Status"] as? String {
               cell.status.text = check(status: hodApprovalStatus)
               cell.status.textColor = sColor(status: hodApprovalStatus)
            
            if ["A", "XA", "X"].contains(hodApprovalStatus) {
                cell.cancelbtn.isHidden = true
            } else {
                cell.cancelbtn.isHidden = false
            }
           } else {
               cell.status.text = ""
               cell.status.textColor = .black
           }
        cell.todate.isHidden = true
        cell.to.isHidden = true
        cell.cancelbtn.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
    }
    
    func configuretourdayStatus(_ cell: statusTableViewCell, indexPath: IndexPath) {
        let rowData = list[indexPath.row]
        cell.reqId.text = rowData["Location"] as? String ?? ""
        cell.fromdate.text = rowData["from_date"] as? String ?? ""
        cell.todate.text = rowData["to_date"] as? String ?? ""
        if let hodApprovalStatus = rowData["Status"] as? String {
            
               cell.status.text = check(status: hodApprovalStatus)
               cell.status.textColor = sColor(status: hodApprovalStatus)
            if ["A", "XA", "X"].contains(hodApprovalStatus){
                cell.cancelbtn.isHidden = true
            } else {
                cell.cancelbtn.isHidden = false
            }
           } else {
               cell.status.text = ""
               cell.status.textColor = .black
           }
        cell.cancelbtn.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
    }
    
    func configurePlStatus(_ cell: PLCell, indexPath: IndexPath) {
        let index = indexPath.row
           cell.dateLbl.text = PLlist[index]["Date"] as? String ?? ""
        let Added = PLlist[index]["Credit"] as? String ?? ""
        let Deduct = PLlist[index]["Debit"] as? String ?? ""
        
        if Added.isEmpty || Added == ".00" {
                cell.creditLbl.isHidden = true
                cell.addedlbl.isHidden = true
                cell.debitLbl.isHidden = false
                cell.deducted.isHidden = false
                cell.debitLbl.text = Deduct
            } else {
                cell.creditLbl.isHidden = false
                cell.addedlbl.isHidden = false
                cell.creditLbl.text = Added
                cell.debitLbl.isHidden = true
                cell.deducted.isHidden = true
            }
        cell.balanceLbl.text = PLlist[index]["Balance"] as? String ?? ""
        cell.refrencelbl.text = PLlist[index]["Reference"] as? String ?? ""

    }
}


extension AllStatusVc: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Selected.selectedSegmentIndex == 1 {
            return filteredDetailData.count
           } else {
               switch selectedOption {
               case "PL Summary":
                   return PLlist.count
               default:
                   return list.count
               }
           }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Selected.selectedSegmentIndex == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "bdayviewcell", for: indexPath) as? bdayviewcell else {
                return UITableViewCell()
            }
            let index = filteredDetailData[indexPath.row]
            cell.MyLbl.text = "\(index["name"] as? String ?? "")"
            cell.MyLbl2.text = "\(index["EmpCode"] as? String ?? "")"
            cell.mylbl3.text = "\(index["Dept"] as? String ?? "")"
            let imageData = index["EmpImage"] as? String ?? ""
            let imgURL = imageData.replacingOccurrences(of: " ", with: "%20")
            cell.MyImage.image = nil
            cell.MyImage.sd_setImage(with: URL(string: imgURL), placeholderImage: UIImage(named: "placeholder"))
            cell.message.isHidden = true
            cell.msgbtn.isHidden = true
            return cell
        }

           var cellIdentifier: String
           switch selectedOption {
           case "Full Day Leave Status":
               cellIdentifier = "TourStCell"
           case "Half Day Leave Status":
               cellIdentifier = "statusTableViewCell"
           case "Off Day Request Status":
               cellIdentifier = "statusTableViewCell"
           case "Tour Request Status":
               cellIdentifier = "statusTableViewCell"
           case "PL Summary":
               cellIdentifier = "PLCell"
           default:
               cellIdentifier = "TourStCell"
           }
           
           let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
           
           switch selectedOption {
           case "Full Day Leave Status":
               if let tourCell = cell as? TourStCell {
                   configurefulldaystatus(tourCell, indexPath: indexPath)
               }
           case "Half Day Leave Status":
               if let halfdaystatusCell = cell as? statusTableViewCell {
                   configurehalfdayStatus(halfdaystatusCell, indexPath: indexPath)
               }
           case "Off Day Request Status":
               if let offdaystatusCell = cell as? statusTableViewCell {
                   configureoffdayStatus(offdaystatusCell, indexPath: indexPath)
               }
           case "Tour Request Status":
               if let tourdaystatusCell = cell as? statusTableViewCell {
                   configuretourdayStatus(tourdaystatusCell, indexPath: indexPath)
               }
           case "PL Summary":
               if let PLSUMMARYCell = cell as? PLCell {
                   configurePlStatus(PLSUMMARYCell, indexPath: indexPath)
               }
           default:
               break
           }
           
           return cell
       }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if Selected.selectedSegmentIndex == 1 {
                let vc = storyboard!.instantiateViewController(withIdentifier: "EmployeeDetailNewVc") as! EmployeeDetailNewVc
            vc.Datalist = filteredDetailData[indexPath.row]
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
            

        } else {
            if selectedOption != "PL Summary" {
                      reqNo = list[indexPath.row]["Emp_Req_No"] as? String ?? ""
                  }
        }
        
        }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Selected.selectedSegmentIndex == 1 {
            return 120
        } else {
            switch selectedOption {
            case "Full Day Leave Status":
                return 140
            case "Half Day Leave Status":
                return 100
            case "Off Day Request Status":
                return 100
            case "Tour Request Status":
                return 100
            case "PL Summary":
                return 180
                
            default:
                return 60
            }
        }
    }

}
extension AllStatusVc: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           if searchText.isEmpty {
               filteredDetailData = DetailData
           } else {
               filteredDetailData = DetailData.filter { data in
                   let empCode = (data["EmpCode"] as? String ?? "").lowercased()
                   let name = (data["name"] as? String ?? "").lowercased()
                   return empCode.contains(searchText.lowercased()) || name.contains(searchText.lowercased())
               }
           }
           tableview.reloadData()
       }
}
