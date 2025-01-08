//
//  NewHomeVC.swift
//  SanskarEP
//
//  Created by Surya on 12/08/23.
//

import UIKit
import SDWebImage
import Charts
import FSCalendar
import MarqueeLabel

class NewHomeVC: UIViewController  {
    
    @IBOutlet weak var profileview: UIView!
    @IBOutlet weak var empnamelbl: UILabel!
    @IBOutlet weak var empcodelbl: UILabel!
    @IBOutlet weak var emptimelbl: UILabel!
    @IBOutlet weak var empimage: UIImageView!
    @IBOutlet weak var notificationlbl: UILabel!
    @IBOutlet weak var datacoll: UICollectionView!
    @IBOutlet weak var collectionview: UIView!
    @IBOutlet weak var maincalview: UIView!
    @IBOutlet weak var calcollectionview: UICollectionView!
    @IBOutlet weak var MonthLabel: UILabel!
    @IBOutlet weak var backbtnview: UIView!
    @IBOutlet weak var fowardbtnview: UIView!
    @IBOutlet weak var dateview: UIView!
    @IBOutlet weak var dotbtn: UIButton!
    @IBOutlet weak var eventview: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var detailview: UIView!
    @IBOutlet weak var empname: UILabel!
    @IBOutlet weak var empcode: UILabel!
    @IBOutlet weak var depart: UILabel!
    @IBOutlet weak var requestid: UILabel!
    @IBOutlet weak var reason: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var fromdate: UILabel!
    @IBOutlet weak var approvalbtn: UIButton!
    @IBOutlet weak var rejectbtn: UIButton!
    @IBOutlet weak var employeeImage: UIImageView!
    @IBOutlet weak var bookingview: UIView!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var detailcollection: UICollectionView!
    
    
    
    var selectedDate = Date()
    var totalSquares = [String]()
    
    var staticItems = [
        ["month": "month", "Full": "Full", "Half": "Half", "Tour": "Tour", "WFH": "WFH"]]
    let itemKeys = ["month", "Full", "Half", "Tour", "WFH"]
    
    //var dataList   = [[String:Any]]()
   //var DataList   = [[String:Any]]()
    var EventList = [[String:Any]]()
    var daTalist = [[String: Any]]()
    var calenderlist = [[String: Any]]()
    
    var EmpCode = String()
    var empData: EmpLData?
    var EmpData = String()
    var imageData = String()
    var imageurl = "https://ep.sanskargroup.in/uploads/"
    
    var status: Int?
    var totalCount: Int = 0
    var noteLbl: Bool = false
    var aprove: Bool = false
    var book: Bool = false
        

    //var datalist = [[String:Any]]()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(UINib(nibName: "NewEventListCell" , bundle: nil), forCellReuseIdentifier: "NewEventListCell")
        tableview.register(UINib(nibName: "bdayviewcell" , bundle: nil), forCellReuseIdentifier: "bdayviewcell")
        tableview.register(UINib(nibName: "EventbookingCell" , bundle: nil), forCellReuseIdentifier: "EventbookingCell")
        
        collectionview.layer.cornerRadius = 8
        collectionview.clipsToBounds = true
        
        backbtnview.circleWithBorder2()
        fowardbtnview.circleWithBorder2()
        maincalview.clipsToBounds = true
     
        maincalview.layer.cornerRadius = 8
        maincalview.layer.borderWidth = 1
        maincalview.layer.borderColor = UIColor.lightGray.cgColor
        
        detailview.layer.cornerRadius = 8
    
        detailview.layer.borderWidth = 2
        detailview.layer.borderColor = UIColor.lightGray.cgColor
        
        dateview.layer.borderColor = UIColor.black.cgColor
        
        maincalview.layer.cornerRadius = 8
        self.notificationlbl.layer.cornerRadius = notificationlbl.frame.height / 2
        self.notificationlbl.clipsToBounds = true
        
        setCellView()
        setMonthView()
        EventApi()
        
       
        
        
        empimage.layer.cornerRadius = 7
        dateview.layer.cornerRadius = 10

        approvalpending()
        AttendanceApi()
    
        
        empnamelbl.text = currentUser.Name
        empcodelbl.text = currentUser.EmpCode
        
        dotbtn.isHidden = false
     
  
        detailview.isHidden = true
        bookingview.isHidden = true
        eventview.layer.cornerRadius = 8
        eventview.layer.borderWidth = 1
        eventview.layer.borderColor = UIColor.lightGray.cgColor
        
        if currentUser.PImg.isEmpty {
            empimage.image = UIImage(named: "")
        } else {
            let img = currentUser.PImg.replacingOccurrences(of: " ", with: "%20")
            if #available(iOS 15.0, *) {
                empimage.sd_setImage(with: URL(string: img), placeholderImage: UIImage(systemName: "person.circle.fill"), options: .refreshCached, completed: nil)
            }
        }

//        let noteNo = UserDefaults.standard.value(forKey: "noteCount")
//        if let noteNo = noteNo as? Int {
//            notificationlbl.text = "\(noteNo)"
//        }
//        if noteLbl{
//            notificationlbl.isHidden = true
//        }else{
//            notificationlbl.isHidden = false
//        }
     //   barchartview.delegate = self
        
        profileview.layer.cornerRadius = 5
       //     profileview.layer.bounds.width / 19
      //     updateUI()
     //    if currentUser.Code == "H"{
    //   let data = TaskManagement(taskName: "Approval", taskImg: "Approval12")
   //       dotbtn.isHidden = false
  //     task.insert(data, at: 1)
         //   approvLbl.isHidden = false
   //         countlbl.isHidden = false
    //        aprove = true
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideDetailView))
//            self.view.addGestureRecognizer(tapGesture)
        
        getListData()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
           calcollectionview.addGestureRecognizer(longPressGesture)
        
        
    }
    
//    @objc func hideDetailView() {
//      
//        detailview.isHidden = true
//    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
   
        let noteCount = UserDefaults.standard.value(forKey: "noteCount") as? Int ?? 0
        if noteCount > 0 {
            noteLbl = false
            DispatchQueue.main.async {
                self.datacoll.reloadData()
            }
        }else{
            noteLbl = true
            DispatchQueue.main.async {
                self.datacoll.reloadData()
            }
        }

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
             EventApi()
    }
    @IBAction func ButtonTapped(_ sender: Any) {
        let profile = storyboard?.instantiateViewController(withIdentifier: "ProfileVc") as! ProfileVc
        self.present(profile,animated: true,completion: nil)
        
    }
    
    
    @IBAction func backbutton(_ sender: UIButton) {
        detailview.isHidden = true
    }
    
    
    @IBAction func attendancegraphbtn(_ sender: UIButton) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "ReportAllVc") as! ReportAllVc
        self.present(vc, animated: true)
    }
    
    @IBAction func dotsbtn(_ sender: UIButton) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "CalenderOnClick") as! CalenderOnClick
        
        if #available(iOS 15.0, *) {
        if let sheet = vc.sheetPresentationController {
        var customDetent: UISheetPresentationController.Detent?
            if #available(iOS 16.0, *) {
            customDetent = UISheetPresentationController.Detent.custom { context in
                return 540
            }
            sheet.detents = [customDetent!]
            sheet.largestUndimmedDetentIdentifier = customDetent!.identifier
                }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
                            }
                        }
        self.present(vc, animated: true)
        
    }
    

    @IBAction func aprvlbtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ApprovalLitNewVc") as! ApprovalLitNewVc
        if #available(iOS 15.0, *) {
        if let sheet = vc.sheetPresentationController {
        var customDetent: UISheetPresentationController.Detent?
        if #available(iOS 16.0, *) {
        customDetent = UISheetPresentationController.Detent.custom { context in
        return 540
        
        }
       sheet.detents = [customDetent!]
       sheet.largestUndimmedDetentIdentifier = customDetent!.identifier
    }
       sheet.prefersScrollingExpandsWhenScrolledToEdge = false
       sheet.prefersGrabberVisible = true
       sheet.preferredCornerRadius = 12
    }
   }
    present(vc, animated: true)
    }
    
    @IBAction func inventorybtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "inventoryhome") as! inventoryhome
        if #available(iOS 15.0, *) {
        if let sheet = vc.sheetPresentationController {
        var customDetent: UISheetPresentationController.Detent?
        if #available(iOS 16.0, *) {
        customDetent = UISheetPresentationController.Detent.custom { context in
        return 580
        
        }
       sheet.detents = [customDetent!]
       sheet.largestUndimmedDetentIdentifier = customDetent!.identifier
    }
       sheet.prefersScrollingExpandsWhenScrolledToEdge = false
       sheet.prefersGrabberVisible = true
       sheet.preferredCornerRadius = 12
    }
   }
    present(vc, animated: true)
    }
   
    func setCellView() {
        let width  = (calcollectionview.frame.size.width - 2) / 8
        let height = (calcollectionview.frame.size.height - 2) / 8
        if let flowLayout = calcollectionview.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = CGSize(width: width, height: height)
        }
    }

    
    func setMonthView() {
        totalSquares.removeAll()
        let daysInMonth = calenderHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = calenderHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = calenderHelper().weekDay(date: firstDayOfMonth)
        
        
        var count: Int = 2
        while(count <= 42)
        {
           if(count <= startingSpaces || count - startingSpaces > daysInMonth)
            {
               totalSquares.append("")
           }
            else
            {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        MonthLabel.text = calenderHelper().monthString(date: selectedDate) + " " + calenderHelper().YearString(date: selectedDate)
        calcollectionview.reloadData()
    }

    
    @IBAction func SearchBarBtn(_ sender: UIButton) {
 //      let vc = self.storyboard?.instantiateViewController(withIdentifier: "PieChartVC") as! PieChartVC
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearcHvC") as! SearcHvC
        if #available(iOS 15.0, *) {
        if let sheet = vc.sheetPresentationController {
        var customDetent: UISheetPresentationController.Detent?
            if #available(iOS 16.0, *) {
            customDetent = UISheetPresentationController.Detent.custom { context in
                return 550
            }
            sheet.detents = [customDetent!]
            sheet.largestUndimmedDetentIdentifier = customDetent!.identifier
                }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 12
                            }
                        }
        present(vc, animated: true)
    }
    
    @IBAction func upcomingbdaybtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "BdayViewController") as! BdayViewController
        present(vc, animated: true)
    }
    
    
    @IBAction func previousTapped(_ sender: UIButton) {
        selectedDate = calenderHelper().minusmonth(date: selectedDate)
        setMonthView()
    }
    
    @IBAction func nextTapped(_ sender: UIButton) {
        selectedDate = calenderHelper().plusmonth(date: selectedDate)
        setMonthView()
    }
    override open var shouldAutorotate: Bool {
        return false
    }
  
    
    @IBAction func notificationbtn(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        vc.titleTxt = "Notification"
        present(vc, animated: true)
    }
    
 
    func approvalpending() {
        var dict = [String: Any]()
        dict["EmpCode"] = currentUser.EmpCode
        print(dict["EmpCode"])
        DispatchQueue.main.async {
            Loader.showLoader()
        }
        APIManager.apiCall(postData: dict as NSDictionary, url: CountApi) { result, response, error, data in
            DispatchQueue.main.async {
                Loader.hideLoader()
            }
            if let JSON = response as? NSDictionary {
                if JSON.value(forKey: "status") as? Bool == true {
                    print(JSON)
                    let data = JSON["data"] as? [String: Any] ?? [:]
                    print(data)
                    let total = data["total"] as! Int
              //      self.countlbl.text = "(" + "\(total)" + ")" // Convert Int to String and assign to UILabel text property
                } else {
                    print(response?["error"] as Any)
                    DispatchQueue.main.async {
                        // Handle error case if needed
                    }
                }
            }
        }
    }
    
//    func detailApi() {
//        self.staticItems.removeAll()
//        
//        var dict = Dictionary<String, Any>()
//        dict["EmpCode"] = EmpCode
//        DispatchQueue.main.async { Loader.showLoader() }
//        APIManager.apiCall(postData: dict as NSDictionary, url: EmployeeDetailApi) { result, response, error, data in
//            DispatchQueue.main.async { Loader.hideLoader() }
//         
//            if let responseData = response, let dataArray = responseData["data"] as? [[String: Any]] {
//                for item in dataArray {
//                    if let monthFull = item["month"] as? String {
//                        let monthComponents = monthFull.split(separator: " ")
//                        let month = String(monthComponents.first ?? "")
//                        let full = "\(item["F"] ?? "0")"
//                        let half = "\(item["H"] ?? "0")"
//                        let wfh = "\(item["WFH"] ?? "0")"
//                        let tour = "\(item["Tour"] ?? "0")"
//                        let row: [String: String] = [
//                            "month": month,
//                            "Full": full,
//                            "Half": half,
//                            "Tour": tour,
//                            "WFH": wfh
//                        ]
//                        self.staticItems.append(row)
//                    }
//                }
//                self.detailcollection.reloadData()
//            } else {
//                print(response?["error"] as Any)
//            }
//        }
//    }
    
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
                    self.emptimelbl.text = inTime
                } else {
                    self.emptimelbl.text = "Absent"
                }
            } else {
                self.emptimelbl.text = "Absent"
            }
        }
    }
   
    @objc
    func didNotify () {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        vc.titleTxt = "Notification"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getListData() {
        let dict = Dictionary<String,Any>()
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: exList) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let json = data,(response?["status"] as? Bool == true), response != nil {
                let decode = JSONDecoder()
                do{
                    self.empData = try decode.decode(EmpLData.self, from: json)
                    self.matchList()
                }catch{
                    print(error.localizedDescription)
                }
            }
        }
        
    }

    func matchList() {
        
        guard let lists = empData?.data else {return}
        if lists.count > 0 {
            for list in lists {
                switch currentUser.EmpCode {
                case list.empCode:
                    //  let data = TaskManagement(taskName: "Booking", taskImg: "flight")
                    status = list.status
                    book = true
                    //  task.insert(data, at: 5)
                    
                    if note == true {
                        didNotify()
                    }
                default:
                    break
                }
            }
            DispatchQueue.main.async {
                self.datacoll.reloadData()
                self.fetchData()
            }
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let location = gestureRecognizer.location(in: calcollectionview)
            if let indexPath = calcollectionview.indexPathForItem(at: location) {
             
                let vc = storyboard!.instantiateViewController(withIdentifier: "CalenderOnClick") as! CalenderOnClick
                
                if #available(iOS 15.0, *) {
                    if let sheet = vc.sheetPresentationController {
                        var customDetent: UISheetPresentationController.Detent?
                        if #available(iOS 16.0, *) {
                            customDetent = UISheetPresentationController.Detent.custom { context in
                                return 540
                            }
                            sheet.detents = [customDetent!]
                            sheet.largestUndimmedDetentIdentifier = customDetent!.identifier
                        }
                        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                        sheet.prefersGrabberVisible = true
                        sheet.preferredCornerRadius = 12
                    }
                }
                self.present(vc, animated: true)
            }
        }
    }
    
    func EventApi() {
        var dict = [String: Any]()
        dict["EmpCode"] = currentUser.EmpCode

        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let reqDate = dateFormatter.string(from: currentDate)
        dict["req_date"] = reqDate
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
                        self.Label1.isHidden = true
                        self.tableview.reloadData()
                    }
                } else {
                    print(response?["error"] as Any)
                    DispatchQueue.main.async {
                        self.Label1.text = response?.validatedValue("message")
                        self.tableview.isHidden = true
                    }
                }
            }
        }
    }
    
    func calenderAPi() {
        var dict = [String: Any]()
        dict["EmpCode"] = currentUser.EmpCode
        dict["from_date"] = "2024-09-01"
        dict["to_date"] = "2024-09-31"
        
        DispatchQueue.main.async {
            Loader.showLoader()
        }
        APIManager.apiCall(postData: dict as NSDictionary, url: calenderapi) { result, response, error, data in
            DispatchQueue.main.async {
                Loader.hideLoader()
            }
            if let JSON = response as? NSDictionary {
                if JSON.value(forKey: "status") as? Bool == true {
                    let data = JSON["data"] as? [[String: Any]] ?? [[:]]
                    self.calenderlist = data
              //      self.setdata()

                    
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                    }
                } else {
                    print(response?["error"] as Any)
                }
            }
        }
    }


    func fetchData() {
        var dict = Dictionary<String, Any>()
        dict["EmpCode"] = currentUser.EmpCode
        DispatchQueue.main.async {
            Loader.showLoader()
        }

        APIManager.apiCall(postData: dict as NSDictionary, url: notifyList) { result, response, error, data in
            DispatchQueue.main.async {
                Loader.hideLoader()
                if let JSON = response as? NSDictionary {
                    if let status = JSON.value(forKey: "status") as? Bool, status == true {
                        print(JSON)
                        if let dataDictionary = JSON["data"] as? [[String: Any]] {
                            let count = dataDictionary.count
                            DispatchQueue.main.async {
                                if count == 0 {
                                    self.notificationlbl.isHidden = true
                                } else {
                                    self.notificationlbl.isHidden = false
                                    self.notificationlbl.text = "\(count)"
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.notificationlbl.isHidden = true
                            }
                        }
                    } else {
                        if let errorMessage = response?["error"] as? String {
                            print(errorMessage)
                        }
                        DispatchQueue.main.async {
                            self.notificationlbl.isHidden = true
                        }
                    }
                }
            }
        }
    }


    @IBAction func approvebtn(_ sender: UIButton) {
        if let reqId = requestid.text, !reqId.isEmpty {
               getGrant(reqId, "granted")
           } else {
               print("Request ID is missing")
           }
        detailview.isHidden = true
    }
    
    @IBAction func rejectbtn(_ sender: UIButton) {
        if let reqId = requestid.text, !reqId.isEmpty {
               getGrant(reqId, "declined")
           } else {
               print("Request ID is missing")
           }
        detailview.isHidden = true
    }
    func getGrant(_ id: String, _ reply: String) {
        var dict = Dictionary<String, Any>()
        dict["req_id"] = id
        print(dict["req_id"])
        dict["reply"] = reply
        print(dict["reply"])
       
        DispatchQueue.main.async(execute: { Loader.showLoader() })
        APIManager.apiCall(postData: dict as NSDictionary, url: kgrant) { result, response, error, data in
            DispatchQueue.main.async(execute: { Loader.hideLoader() })
            if let _ = data, (response?["status"] as? Bool == true), response != nil {
             
                AlertController.alert(message: (response?.validatedValue("message"))!)
//                DispatchQueue.main.async {
//                    self.dismiss(animated: true)
//                }
            } else {
                print(response?["error"] as Any)
            }
        }
    }
    
    @objc func messageOnClick(_ sender: UIButton) {
        self.staticItems.removeAll()
        self.staticItems.append(["month": "Month", "Full": "Full", "Half": "Half", "Tour": "Tour", "WFH": "WFH"])
        self.detailcollection.reloadData()

        let indexPath = IndexPath(row: sender.tag, section: sender.superview?.superview?.tag ?? 0)
        let sectionData = daTalist[indexPath.section]
        let list = sectionData["list"] as? [[String: Any]]
        let selectedData = list?[indexPath.row] ?? [:]

        DispatchQueue.main.async {
            self.empname.text = selectedData["Name"] as? String ?? ""
            self.empcode.text = selectedData["Emp_Code"] as? String ?? ""
            self.depart.text = selectedData["Dept"] as? String ?? ""
            self.reason.text = selectedData["Reason"] as? String ?? ""
            self.type.text = selectedData["leave_type"] as? String ?? ""

            if let leaveType = selectedData["leave_type"] as? String, leaveType.lowercased() == "half" {
                self.fromdate.text = selectedData["from_date"] as? String ?? ""
            } else {
                self.fromdate.text = "\(selectedData["from_date"] as? String ?? "") to \(selectedData["to_date"] as? String ?? "")"
            }

            if let image = selectedData["PImg"] as? String {
                let img = image.replacingOccurrences(of: " ", with: "%20")
                self.employeeImage.sd_setImage(with: URL(string: img))
            } else {
                self.employeeImage.image = UIImage(named: "download")
            }

            self.approvalbtn.layer.cornerRadius = 8
            self.rejectbtn.layer.cornerRadius = 8
            self.detailview.isHidden = false
        }
        if let empCode = selectedData["Emp_Code"] as? String {
               self.detailApi(empCode: empCode)
           }
    }

    func detailApi(empCode: String) {
        self.staticItems.removeAll()
        self.staticItems.append(["month": "Month", "Full": "Full", "Half": "Half", "Tour": "Tour", "WFH": "WFH"]) // Add default headers

        var dict = Dictionary<String, Any>()
        dict["EmpCode"] = empCode
        DispatchQueue.main.async { Loader.showLoader() }
        APIManager.apiCall(postData: dict as NSDictionary, url: EmployeeDetailApi) { result, response, error, data in
            DispatchQueue.main.async { Loader.hideLoader() }

            if let responseData = response, let dataArray = responseData["data"] as? [[String: Any]] {
                for item in dataArray {
                    if let monthFull = item["month"] as? String {
                        let monthComponents = monthFull.split(separator: " ")
                        let month = String(monthComponents.first ?? "")
                        let full = "\(item["F"] ?? "0")"
                        let half = "\(item["H"] ?? "0")"
                        let wfh = "\(item["WFH"] ?? "0")"
                        let tour = "\(item["Tour"] ?? "0")"
                        let row: [String: String] = [
                            "month": month,
                            "Full": full,
                            "Half": half,
                            "Tour": tour,
                            "WFH": wfh
                        ]
                        self.staticItems.append(row)
                    }
                }
                self.detailcollection.reloadData()
            } else {
                print(response?["error"] as Any)
            }
        }
    }




    @objc func Messageonclick(_ sender: UIButton) {
      //  self.bookingview.isHidden = !self.bookingview.isHidden
    }

    
    @objc func MessageOnClick(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableview)
        if let indexPath = tableview.indexPathForRow(at: point) {
       
            let sectionData = daTalist[indexPath.section]
            let list = sectionData["list"] as? [[String: Any]]
            let cellData = list?[indexPath.row] ?? [:]
            let type = sectionData["type"] as? String ?? ""
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "BirthPViewController") as! BirthPViewController
            if type == "birthday" {
                if let imgUrl = cellData["PImg"] as? String {
                    vc.imaged = imgUrl.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                } else {
                    vc.imaged = ""
                }
            }
            if #available(iOS 15.0, *) {
                if let sheet = vc.sheetPresentationController {
                    var customDetent: UISheetPresentationController.Detent?
                    if #available(iOS 16.0, *) {
                        customDetent = UISheetPresentationController.Detent.custom { context in
                            return 590
                        }
                        sheet.detents = [customDetent!]
                        sheet.largestUndimmedDetentIdentifier = customDetent!.identifier
                    }
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersGrabberVisible = true
                    sheet.preferredCornerRadius = 12
                }
            }
            self.present(vc, animated: true)
        } else {
            print("Error: Could not find indexPath for sender.")
        }
    }

    
}


extension NewHomeVC: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == calcollectionview {
            return totalSquares.count
        } else if collectionView == detailcollection {
            return staticItems.count
        }
        return 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == calcollectionview {
            return 1
        } else if collectionView == detailcollection {
            return itemKeys.count
        }
        return 0
    }

    // Cell for item at index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == calcollectionview {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalCell", for: indexPath) as? calenderCell else {
                return UICollectionViewCell()
            }

            let dateText = totalSquares[indexPath.item]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d"
            let currentDateString = dateFormatter.string(from: Date())

            if dateText.isEmpty {
                cell.isHidden = true
            } else {
                cell.isHidden = false
                cell.dayofmonth.text = dateText

                let calendar = Calendar.current
                let currentDay = calendar.component(.day, from: Date())
                let currentMonth = calendar.component(.month, from: Date())
                let currentYear = calendar.component(.year, from: Date())
                let selectedMonth = calendar.component(.month, from: selectedDate)
                let selectedYear = calendar.component(.year, from: selectedDate)

                if selectedYear < currentYear || (selectedYear == currentYear && selectedMonth < currentMonth) {
                    cell.dayofmonth.textColor = .gray
                } else if selectedYear > currentYear || (selectedYear == currentYear && selectedMonth > currentMonth) {
                    cell.dayofmonth.textColor = .black
                } else {
                    if let day = Int(dateText) {
                        if day < currentDay {
                            cell.dayofmonth.textColor = .gray
                        } else if day == currentDay {
                            cell.dayofmonth.textColor = .systemGreen
                        } else {
                            cell.dayofmonth.textColor = .black
                        }
                    }
                }

                if indexPath.item % 7 == 0 {
                    cell.dayofmonth.textColor = .red
                }
            }

            cell.layer.cornerRadius = 8
            return cell
        } else if collectionView == detailcollection {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? EmployeedetailsCell else {
                return UICollectionViewCell()
            }

            let sectionKey = itemKeys[indexPath.section]
            let rowData = staticItems[indexPath.item]

            if let value = rowData[sectionKey] {
                cell.detaillabel.text = " \(value)"
            }

            let width = collectionView.frame.width / CGFloat(itemKeys.count + 1) - 0.8
            let height = 40
            cell.setCellSize(width: width, height: CGFloat(height))
            return cell
        }
        return UICollectionViewCell()
    }
}

//MARK: - UICollectionViewDelegate

extension NewHomeVC: UICollectionViewDelegate {

}

extension NewHomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
          if collectionView == self.datacoll {
              return CGSize(width: 85, height: 85)
          } else if collectionView == self.calcollectionview {
              let width = collectionView.frame.width / 8
              let height: CGFloat = 30
              return CGSize(width: width, height: height)
          } else if collectionView == self.detailcollection {
              let totalSpacing: CGFloat = 0.5 * CGFloat(itemKeys.count - 1)
              let width = (collectionView.frame.width - totalSpacing) / CGFloat(itemKeys.count)
              let height: CGFloat = 40
              return CGSize(width: width, height: height)
          }

      
          return CGSize(width: collectionView.frame.width / 2 - 10, height: 30)
      }

     
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
          return 0.5
      }
      func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
          return 0.5
      }
}

//MARK: - Extra funcationality

extension NewHomeVC {
    
    @objc func searchBtnPresed(_ sender: UIButton) {
        print(sender.tag)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVc") as! NotificationVc
        vc.titleTxt = "Notification"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

extension NewHomeVC: UITableViewDelegate, UITableViewDataSource {
    
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
            cell.eventbtn.addTarget(self, action: #selector(messageOnClick(_:)), for: .touchUpInside)
            cell.eventbtn.tag = indexPath.row
            cell.viewbtn . isHidden = true
            cell.NameLbl.text = cellData["Name"] as? String ?? ""
  //        cell.fromdate.text = cellData["from_date"] as? String ?? ""
 //        cell.todate.text = cellData["to_date"] as? String ?? ""
//         cell.locationlabel.text = cellData["Dept"] as? String ?? ""
            
//          cell.reasonlbl.text = cellData["Reason"] as? String ?? ""
            cell.TypeLbl.text = cellData["leave_type"] as? String ?? ""
            EmpCode =  cellData["Emp_Code"] as? String ?? ""
            
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
                cell.NameLbl.text = cellData["Name"] as? String ?? ""
                let rowdata = cellData["status"] as? String ?? ""
                if rowdata == "R" {
                    cell.TypeLbl.text = "Pending"
                    cell.TypeLbl.textColor = UIColor.red
                }
                cell.eventbtn.isHidden = true
//                cell.type.isHidden = true
//                cell.typelbl.isHidden = true
                cell.imageview.isHidden = true
           }
            
            return cell
            
        } else if type == "booking" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EventbookingCell", for: indexPath) as! EventbookingCell
            cell.bookingbtn.addTarget(self, action: #selector(Messageonclick(_:)), for: .touchUpInside)
            cell.bookingbtn.tag = indexPath.row
            
            cell.santname.text = cellData["Name"] as? String ?? ""
            
            // ChannelID mapping
            if let channelID = cellData["ChannelID"] as? String {
                switch channelID {
                case "1":
                    cell.Channel.text = "Sanskar"
                case "2":
                    cell.Channel.text = "Satsang"
                case "3":
                    cell.Channel.text = "Subh"
                default:
                    cell.Channel.text = "Unknown Channel"
                }
            } else {
                cell.Channel.text = "Unknown Channel"
            }
            
            cell.Date.text = "\(cellData["Katha_from_Date"] as? String ?? "") to \(cellData["katha_date"] as? String ?? "")"
            cell.Location.text = cellData["Venue"] as? String ?? ""
            cell.time.text = cellData["KathaTiming"] as? String ?? ""
            
            return cell
        } else if type == "birthday" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bdayviewcell", for: indexPath) as! bdayviewcell
            cell.msgbtn.addTarget(self, action: #selector(MessageOnClick(_:)), for: .touchUpInside)
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
            return 60
        case "booking":
            return 150
        case "birthday":
            return 130
        default:
            return 150
        }
    }

}
