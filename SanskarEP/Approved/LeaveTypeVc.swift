//
//  LeaveTypeVc.swift
//  SanskarEP
//
//  Created by Surya on 07/02/25.
//

import UIKit

class LeaveTypeVc: UIViewController {

    @IBOutlet weak var selected: UISegmentedControl!
    @IBOutlet weak var selectbtn: UIButton!
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var oneview: UIView!
    @IBOutlet weak var tabletop: NSLayoutConstraint!
    @IBOutlet weak var approveall: UIButton!
    @IBOutlet weak var rejectall: UIButton!
    @IBOutlet weak var filterbtn: UIButton!
    @IBOutlet weak var filterview: UIView!
    @IBOutlet weak var searchview: UIView!
    @IBOutlet weak var filtertable: UITableView!
    @IBOutlet weak var notlbl: UILabel!
    
    
    
    var selectedOption: String = ""
    var expandedRowIndex: Int? = nil
    var filterList = ["7 Days","15 Days","30 Days","3 months","6 months"]
    var approveM = [[String:Any]]()
    var selectedRows: Set<Int> = []
    var LeaveDetails: [LeaveHistory] = []
    var type: String?
    var filteredLeaveDetails: [LeaveHistory] = []
    var filteredapproveM =  [[String:Any]]()
    var isSearching = false
    var remarksHeight = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        selectbtn.isHidden = true
        filterbtn.isHidden = true
        filterview.isHidden = true
        oneview.isHidden = true
        getDetails()
        ListAPi()
        tabletop.constant = -45
        
        selected.selectedSegmentIndex = 0
        selectedbtn(selected)
    
        tableview.register(UINib(nibName: "newapproCell", bundle: nil), forCellReuseIdentifier: "newapproCell")
        filtertable.register(UINib(nibName: "AssignListCell", bundle: nil), forCellReuseIdentifier: "AssignListCell")
        approveall.layer.cornerRadius = 8
        rejectall.layer.cornerRadius = 8
        search.delegate =  self
      
       
    }
    
    @IBAction func backbtn(_ sender: UIButton) {
     dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectedbtn(_ sender: UISegmentedControl) {
        if selected.selectedSegmentIndex == 0 {
            selectbtn.isHidden = true
            filterbtn.isHidden = true
            searchview.isHidden = false
            oneview.isHidden = true
            tabletop.constant = -50
            type = "1"
            ListAPi()
            tableview.reloadData()
//            if LeaveDetails.isEmpty  {
//                notlbl.text = "No Data Available"
 //           }
        } else if selected.selectedSegmentIndex == 1 {
            selectbtn.isHidden = false
            filterbtn.isHidden = true
            searchview.isHidden = false
            tabletop.constant = -50
            tableview.reloadData()
//            if approveM.isEmpty  {
//                notlbl.text = "No Data Available"
    //        }
        } else if selected.selectedSegmentIndex == 2 {
            selectbtn.isHidden = true
            filterbtn.isHidden = false
            searchview.isHidden = true
            tabletop.constant = -100
            type = "2"
            ListAPi()
            tableview.reloadData()
//            if LeaveDetails.isEmpty  {
//                notlbl.text = "No Data Available"
   //         }
        }
       // updateNoNotificationLabel()
    }
    
    @IBAction func approveallbtn(_ sender: UIButton) {
        var ids: [String] = []
        for index in selectedRows {
            if let id = approveM[index]["ID"] as? String {
                ids.append(id)
            }
        }
        if !ids.isEmpty {
            getGrant(ids, "granted")
        }
        approveM = approveM.enumerated().filter { !selectedRows.contains($0.offset) }.map { $0.element }
        selectedRows.removeAll()
        tableview.reloadData()
    }
    
    @IBAction func rejectalllbtn(_ sender: UIButton) {
        if selectedRows.isEmpty {
               AlertController.alert(message: "Please select at least one request to reject.")
               return
           }
           let alert = UIAlertController(title: "Reject Requests", message: "Enter rejection reason", preferredStyle: .alert)
           alert.addTextField { textField in
               textField.placeholder = "Enter reason"
           }
           let rejectAction = UIAlertAction(title: "Reject", style: .destructive) { _ in
               guard let reason = alert.textFields?.first?.text, !reason.isEmpty else {
                   AlertController.alert(message: "Rejection reason cannot be empty.")
                   return
               }
               var ids: [String] = []
               for index in self.selectedRows {
                   if let id = self.approveM[index]["ID"] as? String {
                       ids.append(id)
                   }
               }
               if !ids.isEmpty {
                   self.getGrant(ids, "declined", reason)
               }
               self.approveM = self.approveM.enumerated().filter { !self.selectedRows.contains($0.offset) }.map { $0.element }
               self.selectedRows.removeAll()
               self.tableview.reloadData()
           }
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
           alert.addAction(rejectAction)
           alert.addAction(cancelAction)
           present(alert, animated: true, completion: nil)
       
    }
    
    func updateApproveAllButtonTitle() {
        if selectedRows.count == approveM.count {
            approveall.setTitle("Approve All", for: .normal)
            rejectall.setTitle("Reject All", for: .normal)
        } else {
            approveall.setTitle("Approve", for: .normal)
            rejectall.setTitle("Reject", for: .normal)
        }
    }
    
//     func updateNoNotificationLabel() {
//        else if  LeaveDetails.isEmpty{
//            notlbl.isHidden = true
//            notlbl.text = "No Data Available"
//            
//        }else {
//            notlbl.isHidden = false
//            notlbl.text = ""
//        }
//    }
    
    
    @IBAction func allselectbtn(_ sender: UIButton) {
        self.oneview.isHidden = !self.oneview.isHidden
        if selectedRows.count == approveM.count {
               selectedRows.removeAll()
            sender.setImage(UIImage(named: "Uncheck"), for: .normal)
               oneview.isHidden = true
            tabletop.constant = -50
            
           } else {
               selectedRows = Set(0..<approveM.count)
               sender.setImage(UIImage(named: "check"), for: .normal)
               oneview.isHidden = false
              tabletop.constant = 8
           }
           tableview.reloadData()
    }
    
    
    @IBAction func filteronclick(_ sender: UIButton) {
       self.filterview.isHidden = !self.filterview.isHidden
//        tabletop.constant = 28
        
//        if filterview.isHidden == true {
//            tabletop.constant = -100
//        } else if filterview.isHidden == false {
//            tabletop.constant = 28
//        } else {
//            
//        }
    }
    
    func ListAPi() {
        var dict = [String: Any]()
        dict["type"] = type
        dict["EmpCode"] = currentUser.EmpCode
        DispatchQueue.main.async {Loader.showLoader()}
        APIManager.apiCall(postData: dict as NSDictionary, url: AHistoryapi) { result, response, error, data in
            DispatchQueue.main.async {
                Loader.hideLoader()
            }
            guard let responseData = data else {
                print("Error: No data received")
                return
            }
            do {
                let decoder = JSONDecoder()
                let monthWiseDetail = try decoder.decode(LeaveHistoryModel.self, from: responseData)
                
                if monthWiseDetail.status == true, let details = monthWiseDetail.data {
                    DispatchQueue.main.async {
                        self.LeaveDetails = details
                        
                        self.tableview.reloadData()
                      
                    }
                } else {
                    print("Error: \(monthWiseDetail.message ?? "Unknown error")")
                }
            } catch {
                print("Decoding Error:", error.localizedDescription)
            }
        }
    }
    
    func getDetails() {
        var dict = [String: Any]()
        dict["EmpCode"] = currentUser.EmpCode
        dict["leave_type"] = "All"
        dict["fromDate"] =  ""
        dict["toDate"] =  ""

        DispatchQueue.main.async {
            Loader.showLoader()
        }

        APIManager.apiCall(postData: dict as NSDictionary, url: kAprrove) { result, response, error, data in
            DispatchQueue.main.async {
                Loader.hideLoader()
            }
            self.approveM.removeAll()

            if let data = data, response?["status"] as? Bool == true {
                if let json = response?["data"] as? [[String: Any]] {
                    self.approveM.append(contentsOf: json)
                }
            } else {
                print(response?["error"] as Any)
            }

            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    func getGrant(_ id: [String], _ reply: String, _ reason: String? = nil) {
        var dict = Dictionary<String, Any>()
        dict["req_id"] = id
        dict["reply"] = reply
        
        if reply == "declined", let rejectionReason = reason {
            dict["reason"] = rejectionReason
        }

        DispatchQueue.main.async(execute: { Loader.showLoader() })
        APIManager.apiCall(postData: dict as NSDictionary, url: kgrant) { result, response, error, data in
            DispatchQueue.main.async(execute: { Loader.hideLoader() })
            if let _ = data, (response?["status"] as? Bool == true), response != nil {
                AlertController.alert(message: (response?.validatedValue("message"))!)
                DispatchQueue.main.async {
                    self.getDetails()
                }
            } else {
                print(response?["error"] as Any)
            }
            self.tableview.reloadData()
        }
    }
    @objc func checkboxTapped(_ sender: UIButton) {
        let rowIndex = sender.tag
        if selectedRows.contains(rowIndex) {
            selectedRows.remove(rowIndex)
        } else {
            selectedRows.insert(rowIndex)
        }
        if selectedRows.count == approveM.count {
            selectbtn.setTitle("Deselect", for: .normal)
        } else {
            selectbtn.setTitle("Select", for: .normal)
        }
        tableview.reloadData()
    }
    @objc
    func LeaveAcceptOnClick(_ sender: UIButton) {
        print(sender.tag)
        let index = approveM[sender.tag]
        if let id = index["ID"] as? String {
            getGrant([id], "granted")
        }
        approveM.remove(at: sender.tag)
        tableview.reloadData()
    }

    
    @objc
    func LeaverejectOnClick(_ sender: UIButton ) {
        remarksHeight =  (remarksHeight == 45) ? 0 : 45
    }
    
    @objc
    func finalrejectOnClick(_ sender: UIButton) {
        let index = approveM[sender.tag]
        if let id = index["ID"] as? String,
           let cell = tableview.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? newapproCell {
            let reason = cell.txtRemarkView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if reason.isEmpty || reason == "Remark ..."  {
                let alert = UIAlertController(title: "Error", message: "Please enter a rejection reason.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
                return
            }
            self.getGrant([id], "declined", reason)
            self.approveM.remove(at: sender.tag)
            self.tableview.reloadData()
        }
    }
    
}
extension LeaveTypeVc: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tableview {
            switch selected.selectedSegmentIndex {
            case 0, 2:
                return isSearching ? filteredLeaveDetails.count : LeaveDetails.count
            case 1:
                return isSearching ? filteredapproveM.count : approveM.count
            default:
                return 0
            }
        } else if tableView == filtertable {
            return filterList.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableview {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "newapproCell", for: indexPath) as? newapproCell else {
                return UITableViewCell()
            }
            switch selected.selectedSegmentIndex {
            case 0, 2:
                let item = isSearching ? filteredLeaveDetails[indexPath.row] : LeaveDetails[indexPath.row]
                cell.name.text = item.name
                cell.reason.text = item.lReason
                cell.type.text = item.type
                cell.dept.text = item.department
                cell.imageview1.sd_setImage(with: URL(string: item.imageURL ?? ""), placeholderImage: UIImage(named: "placeholder"))

                if item.type == "Half Day" {
                    cell.datelbl.text = item.leave_From
                } else {
                    cell.datelbl.text = "\(item.leave_From ?? "") to \(item.leave_to ?? "")"
                }
                if let leaveStatus = item.status, !leaveStatus.isEmpty {
                    cell.status.text = " " + " Status: \(leaveStatus)"
                } else {
                    cell.status.text = ""
                }
                cell.checkbtn.isHidden = true
                cell.btnAprove.isHidden = true
                cell.txtRemarkView.isHidden = true
                cell.okbtn.isHidden = true
                cell.btnreject.isHidden = true

            case 1:
                
                let item = isSearching ? filteredapproveM[indexPath.row] : approveM[indexPath.row]
          
                cell.name.text = item["Name"] as? String ?? ""
                cell.dept.text = item["Dept"] as? String ?? ""
                cell.reason.text = item["Reason"] as? String ?? ""
                cell.type.text = item["leave_type"] as? String ?? ""

                let leaveType = item["leave_type"] as? String ?? ""
            

                if leaveType == "half" {
                    cell.datelbl.text = item["from_date"] as? String ?? ""
                } else {
                    cell.datelbl.text = "\(item["from_date"] as? String ?? "") to \(item["to_date"] as? String ?? "")"
                }
                cell.setImage(with: item["image"] as? String ?? "")

                if selectedRows.contains(indexPath.row) {
                    cell.checkbtn.setImage(UIImage(named: "check"), for: .normal)
                } else {
                    cell.checkbtn.setImage(UIImage(named: "Uncheck"), for: .normal)
                }
                cell.checkbtn.tag = indexPath.row
                cell.checkbtn.addTarget(self, action: #selector(checkboxTapped(_:)), for: .touchUpInside)
                cell.btnAprove.tag = indexPath.row
                cell.btnAprove.addTarget(self, action: #selector(LeaveAcceptOnClick(_:)), for: .touchUpInside)
                cell.reamrk.isHidden = (indexPath.row != expandedRowIndex)
                cell.okbtn.tag = indexPath.row
                cell.okbtn.addTarget(self, action: #selector(finalrejectOnClick(_:)), for: .touchUpInside)
                updateApproveAllButtonTitle()
                
                cell.status.isHidden = true
                cell.checkbtn.isHidden = false
                cell.btnAprove.isHidden = false
                cell.txtRemarkView.isHidden = false
                cell.okbtn.isHidden = false
                cell.btnreject.isHidden = false
                cell.arrowButtonTapped = { button in
                    if self.expandedRowIndex == indexPath.row {
                        self.expandedRowIndex = nil
                    } else {
                        self.expandedRowIndex = indexPath.row
                    }
                    self.tableview.beginUpdates()
                    self.tableview.reloadRows(at: [indexPath], with: .automatic)
                    self.tableview.endUpdates()
                }

            default:
                break
            }
            
            return cell
        } else if tableView == filtertable {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignListCell", for: indexPath) as? AssignListCell else {
                return UITableViewCell()
            }
            cell.AssignLbl.text = filterList[indexPath.row]
            return cell
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tableview {
            if selected.selectedSegmentIndex == 1 {
                return (indexPath.row == expandedRowIndex) ? 235 : 180  // Adjust height when expanded
            } else {
                return 145
            }
        } else if tableView == filtertable {
            return 60
        }
        return 200
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == filtertable {
            
        } else {
            
        }
    }
    
}
extension LeaveTypeVc: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredLeaveDetails = LeaveDetails
            filteredapproveM = approveM
        } else {
            isSearching = true
            filteredLeaveDetails = LeaveDetails.filter { data in
                return (data.name?.lowercased() ?? "").contains(searchText.lowercased()) ||
                       (data.lReason?.lowercased() ?? "").contains(searchText.lowercased())
            }
            
            filteredapproveM = approveM.filter { data in
                let empCode = (data["EmpCode"] as? String ?? "").lowercased()
                let name = (data["Name"] as? String ?? "").lowercased()
                return empCode.contains(searchText.lowercased()) || name.contains(searchText.lowercased())
            }
        }
        tableview.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchBar.text = ""
        filteredLeaveDetails = LeaveDetails
        filteredapproveM = approveM
        tableview.reloadData()
        searchBar.resignFirstResponder()
    }
}
