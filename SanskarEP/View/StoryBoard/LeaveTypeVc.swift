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
    
    
    var selectedOption: String = ""
    var filteredDetailData: [[String: Any]] = []
    var filterList = ["Last 7 Days","Last 15 Days","Last 30 Days","Last 3 months ","Last 6 months"]
    var approveM = [[String:Any]]()
    var selectedRows: Set<Int> = []
    override func viewDidLoad() {
        super.viewDidLoad()
        selectbtn.isHidden = true
        filterbtn.isHidden = true
        filterview.isHidden = true
        oneview.isHidden = true
        getDetails()
        tabletop.constant = -45
        
  //      tableview.register(UINib(nibName: "apptourCell", bundle: nil), forCellReuseIdentifier: "apptourCell")
        tableview.register(UINib(nibName: "newapproCell", bundle: nil), forCellReuseIdentifier: "newapproCell")
        filtertable.register(UINib(nibName: "AssignListCell", bundle: nil), forCellReuseIdentifier: "AssignListCell")
        approveall.layer.cornerRadius = 8
        rejectall.layer.cornerRadius = 8
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
        } else if selected.selectedSegmentIndex == 1 {
            selectbtn.isHidden = false
            filterbtn.isHidden = true
            searchview.isHidden = false
            tabletop.constant = -50
        } else if selected.selectedSegmentIndex == 2 {
            selectbtn.isHidden = true
            filterbtn.isHidden = false
            searchview.isHidden = true
            tabletop.constant = -100
        }
        tableview.reloadData()
    }
    
    @IBAction func approveallbtn(_ sender: UIButton) {
        
    }
    
    @IBAction func rejectalllbtn(_ sender: UIButton) {
        
    }
    
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
        
        if filterview.isHidden == true {
            tabletop.constant = -100
        } else if filterview.isHidden == false {
            tabletop.constant = 28
        } else {
            
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
    func getGrant(_ id: [String], _ reply: String) {
        var dict = Dictionary<String,Any>()
        dict["req_id"] = id
        print(dict["req_id"])
        dict["reply"] = reply
        print(dict["reply"])
   
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: kgrant) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let _ = data,(response?["status"] as? Bool == true), response != nil {
                AlertController.alert(message: (response?.validatedValue("message"))!)
                DispatchQueue.main.async {
                    self.getDetails()
                }
            }else{
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

        // If all rows are selected, update button title
        if selectedRows.count == approveM.count {
            selectbtn.setTitle("Deselect", for: .normal)
        //    Deselectview.isHidden = false
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
        
        print(sender.tag)
        let index = approveM[sender.tag]
    //    getGrant(index["ID"] as? String ?? "", "declined")
        if let id = index["ID"] as? String {
            getGrant([id], "declined")
        }
        approveM.remove(at: sender.tag)
        tableview.reloadData()
      
    }
//    func updateApproveAllButtonTitle() {
//        if selectedRows.count == approveM.count {
//            AllApprovebtn.setTitle("Approve All", for: .normal)
//            RejectAllbtn.setTitle("Reject All", for: .normal)
//        } else {
//            AllApprovebtn.setTitle("Approve", for: .normal)
//            RejectAllbtn.setTitle("Reject", for: .normal)
//        }
//    }
}
extension LeaveTypeVc: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == tableview {
            if selected.selectedSegmentIndex == 0 {
                return 10
            } else if selected.selectedSegmentIndex == 1 {
                return approveM.count
            } else if selected.selectedSegmentIndex == 2 {
                return 10
            }
           
        } else if tableView == filtertable {
           return filterList.count
        } else {
            
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tableview {
            
            if selected.selectedSegmentIndex == 0 {
                //            guard let cell = tableView.dequeueReusableCell(withIdentifier: "newapproCell", for: indexPath) as? newapproCell else {
                //                return UITableViewCell()
                //            }
                //            return cell
            } else if selected.selectedSegmentIndex == 1 {

                let item = approveM[indexPath.row]
                let leaveType = item["leave_type"] as? String ?? ""
                if leaveType == "full" || leaveType == "half" || leaveType == "tour" || leaveType == "WFH" {
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: "newapproCell", for: indexPath) as? newapproCell else {
                        return UITableViewCell()
                    }
                    cell.name.text = item["Name"] as? String ?? ""
                    cell.dept.text = item["Dept"] as? String ?? ""
                    cell.reason.text = item["Reason"] as? String ?? ""
                    cell.type.text = item["leave_type"] as? String ?? ""
                    
                    if  leaveType == "half" {
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
                    cell.okbtn.tag = indexPath.row
                    cell.okbtn.addTarget(self, action: #selector(LeaverejectOnClick(_:)), for: .touchUpInside)
                    cell.selectionStyle = .none
                    //           updateApproveAllButtonTitle()
                    return cell
                }
            } else if selected.selectedSegmentIndex == 2 {
                
            }
        } else if tableView == filtertable {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AssignListCell", for: indexPath) as? AssignListCell else {
            
            return UITableViewCell()
        }
            cell.AssignLbl.text = filterList[indexPath.row]
            return cell
        } else {
            
        }
        

        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == tableview {
            if selected.selectedSegmentIndex == 1 {
                let item = approveM[indexPath.row]
                let leaveType = item["leave_type"] as? String ?? ""
                if leaveType == "full" || leaveType == "half" || leaveType == "tour" || leaveType == "WFH"{
                    return 240
                } else {
                    return 100
                }
            } else if selected.selectedSegmentIndex == 0 {
                return 200
            } else if selected.selectedSegmentIndex == 2 {
                return 150
            }
        } else if tableView == filtertable {
            return 60
        } else {
            
        }

        return 200
    }
}
