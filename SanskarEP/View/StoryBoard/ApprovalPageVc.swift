//
//  ApprovalPageVc.swift
//  SanskarEP
//
//  Created by Surya on 21/01/25.
//

import UIKit

class ApprovalPageVc: UIViewController {

@IBOutlet weak var tableview: UITableView!
@IBOutlet weak var selectdate: UILabel!
@IBOutlet weak var intime: UILabel!
@IBOutlet weak var outtime: UILabel!
@IBOutlet weak var leavetype: UILabel!
    
    
    var daTalist = [[String: Any]]()
    var imageData = String()
    var imageurl = "https://ep.sanskargroup.in/uploads/"
    var EmpData = String()
    var NameLbl = String()
    var EmpCode = String()
    
    var data = String()
    var selectedDateFormatted = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: "NewEventListCell" , bundle: nil), forCellReuseIdentifier: "NewEventListCell")
        tableview.register(UINib(nibName: "bdayviewcell" , bundle: nil), forCellReuseIdentifier: "bdayviewcell")
       
        EventApi()
        AttendanceApi()
        
    }
    func AttendanceApi() {
        var dict = [String: Any]()
        dict["EmpCode"] = currentUser.EmpCode

        DispatchQueue.main.async {
            Loader.showLoader()
        }
        APIManager.apiCall(postData: dict as NSDictionary, url: attendanceApi) { result, response, error, data in
            DispatchQueue.main.async {
                Loader.hideLoader()
            }
            if let JSON = response as? NSDictionary, JSON.value(forKey: "status") as? Bool == true,
                let dataArray = JSON["data"] as? [[String: Any]] {
                if let firstEntry = dataArray.first, let inTime = firstEntry["InTime"] as? String, inTime != "0" {
                    self.intime.text = inTime
                } else {
                    self.intime.text = "Absent"
                }
            } else {
                self.intime.text = "Absent"
            }
        }
    }
    
    func EventApi() {
        var dict = [String: Any]()
        dict["EmpCode"] = currentUser.EmpCode

        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
    //    let reqDate = dateFormatter.string(from: currentDate)
        dict["req_date"] = selectedDateFormatted
        DispatchQueue.main.async {
            Loader.showLoader()
        }
        
        APIManager.apiCall(postData: dict as NSDictionary, url: eventApi) { result, response, error, data in
            DispatchQueue.main.async {
                Loader.hideLoader()
            }
            if let JSON = response as? NSDictionary {
                if JSON.value(forKey: "status") as? Bool == true {
                    let data = JSON["data"] as? [[String: Any]] ?? [[:]]
                    self.daTalist = data

                    
                    DispatchQueue.main.async {
             //           self.Label1.isHidden = true
                        self.tableview.reloadData()
                    }
                } else {
                    print(response?["error"] as Any)
                    DispatchQueue.main.async {
              //          self.Label1.text = response?.validatedValue("message")
                        self.tableview.isHidden = true
                    }
                }
            }
        }
    }
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MMM-yyyy"
        if let date = inputFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd-MMM"
            return outputFormatter.string(from: date)
        }
        return dateString
    }
    func calculateDayDifference(fromDate: String, toDate: String) -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        if let startDate = formatter.date(from: fromDate), let endDate = formatter.date(from: toDate) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            return (components.day ?? 0) + 1
        }
        return 1
    }
}
extension ApprovalPageVc: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       
        return daTalist.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionData = daTalist[section]
        if let list = sectionData["list"] as? [[String: Any]] {
            
            return list.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionData = daTalist[indexPath.section]
        let list = sectionData["list"] as? [[String: Any]]
        let cellData = list?[indexPath.row] ?? [:]

        let type = sectionData["type"] as? String ?? ""

        if type == "leave" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewEventListCell", for: indexPath) as! NewEventListCell
       //     cell.eventbtn.addTarget(self, action: #selector(messageOnClick(_:)), for: .touchUpInside)
    //        cell.eventbtn.tag = indexPath.row
            
            cell.viewbtn.isHidden = true
            cell.imageview.isHidden = true
            
            cell.NameLbl.text = cellData["Name"] as? String ?? ""
  //        cell.fromdate.text = cellData["from_date"] as? String ?? ""
 //        cell.todate.text = cellData["to_date"] as? String ?? ""
//         cell.locationlabel.text = cellData["Dept"] as? String ?? ""
            
//          cell.reasonlbl.text = cellData["Reason"] as? String ?? ""
            cell.TypeLbl.text = cellData["leave_type"] as? String ?? ""
            EmpCode =  cellData["Emp_Code"] as? String ?? ""
            
            if let leaveType = cellData["leave_type"] as? String, leaveType.lowercased() == "half" {
                if let fromDate = cellData["from_date"] as? String {
                    let formattedFromDate = formatDate(fromDate)
                    cell.Datelbl.text = "\(formattedFromDate) (1)"
                } else {
                    cell.Datelbl.text = ""
                }
            } else {
                if let fromDate = cellData["from_date"] as? String, let toDate = cellData["to_date"] as? String {
                    let formattedFromDate = formatDate(fromDate)
                    let formattedToDate = formatDate(toDate)
                    let dayCount = calculateDayDifference(fromDate: fromDate, toDate: toDate)
                    cell.Datelbl.text = "\(formattedFromDate) to \(formattedToDate) (\(dayCount))"
                } else {
                    cell.Datelbl.text = ""
                }
            }
            
    //        cell.Datelbl.text =
            
//            if let leaveType = cellData["leave_type"] as? String, leaveType.lowercased() == "half" {
//                cell.todate.isHidden = true
//                cell.to.isHidden = true
//            } else {
//                cell.todate.isHidden = false
//                cell.to.isHidden = false
//                cell.todate.text = cellData["to_date"] as? String ?? ""
//            }
//
            if currentUser.Code == "H" {
                cell.eventbtn.isHidden = false
                cell.imageview.isHidden = false
            } else {
       //         cell.NameLbl.text = cellData["ID"] as? String ?? ""
                NameLbl = cellData["leave_type"] as? String ?? ""
                
                cell.NameLbl.text = "Leave Request" + " " +  "(" + NameLbl + ")"
                
                let rowdata = cellData["status"] as? String ?? ""
                if rowdata == "R" {
                    cell.TypeLbl.text = "Pending"
                    cell.TypeLbl.textColor = UIColor.red
                }
  //              cell.eventbtn.isHidden = true
//                cell.type.isHidden = true
//                cell.typelbl.isHidden = true
                cell.imageview.isHidden = true
                cell.Datelbl.isHidden = true
           }
            
            return cell
            
        } else if type == "birthday" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bdayviewcell", for: indexPath) as! bdayviewcell
       //     cell.msgbtn.addTarget(self, action: #selector(MessageOnClick(_:)), for: .touchUpInside)
            cell.msgbtn.tag = indexPath.row
            
            cell.MyLbl2.text = cellData["BDay"] as? String ?? ""
            cell.MyLbl.text = cellData["Name"] as? String ?? ""
            cell.mylbl3.isHidden = true
            cell.terminatedbtn.isHidden = true
            
            EmpData = cellData["EmpCode"] as? String ?? ""
            if let imageUrl = cellData["PImg"] as? String {
                imageData = imageUrl.trimmingCharacters(in: .whitespaces)
                if imageData.isEmpty {
                    cell.MyImage.image = UIImage(named: "download")
                } else {
                    let formattedImageUrl = imageData.replacingOccurrences(of: "", with: "%20")
                    if let url = URL(string: formattedImageUrl) {
                        cell.MyImage.sd_setImage(with: url)
                    }
                }
            }
            
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let sectionData = daTalist[indexPath.section]
        let list = sectionData["list"] as? [[String: Any]]
        let cellData = list?[indexPath.row] ?? [:]

        let type = sectionData["type"] as? String ?? ""

        switch type {
        case "leave":
            return 70
        case "birthday":
            return 130
        default:
            return 150
        }
    }

}
