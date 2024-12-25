//
//  CalenderOnClick.swift
//  SanskarEP
//
//  Created by Surya on 21/08/24.
//

import UIKit

class CalenderOnClick: UIViewController {

    @IBOutlet weak var requestTypeView: UIView!
    @IBOutlet weak var requestTableview: UITableView!
    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var leaveContainerview: UIView!
    @IBOutlet weak var BookingContainerview: UIView!
    @IBOutlet weak var TourContainerview: UIView!
    @IBOutlet weak var PayslipContainerview: UIView!
    @IBOutlet weak var AdvanceContainerview: UIView!
    @IBOutlet weak var StationaryContainerview: UIView!
    @IBOutlet weak var HealthContainerview: UIView!
    @IBOutlet weak var GuestContainerview: UIView!
    @IBOutlet weak var ReportContainerview: UIView!
    @IBOutlet weak var OtherContainerview: UIView!
    @IBOutlet weak var ApprovalContainerview: UIView!
    @IBOutlet weak var RequestContainerview: UIView!
    @IBOutlet weak var InventoryContainerview: UIView!
    @IBOutlet weak var PrivacyPolicyContanierview: UIView!
    @IBOutlet weak var TerminateContanierview: UIView!
    
    
    var leavecontainerviewdata = CalendersheetVC.self
    var aprove: Bool = false
    var ReqType  = [[String:Any]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTypeView.isHidden = true
        requestTableview.isHidden = true
        requestTypeView.layer.cornerRadius = 10
        requestTableview.dataSource = self
        requestTableview.delegate = self
        hideAllContainerViews()
        SideBarApi()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self.view)
            if !requestTypeView.frame.contains(location) {
                requestTypeView.isHidden = true
                requestTableview.isHidden = true
            }
        }
    }
    
    @IBAction func backbtn(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func SideBarApi() {
            var dict = Dictionary<String, Any>()
            dict["EmpCode"] = currentUser.EmpCode
            DispatchQueue.main.async { Loader.showLoader() }
            APIManager.apiCall(postData: dict as NSDictionary, url: sidebarapi) { result, response, error, data in
                DispatchQueue.main.async { Loader.hideLoader() }
                if let JSON = response as? NSDictionary, let status = JSON["status"] as? Bool, status == true,
                   let data = JSON["data"] as? [[String: Any]] {
                    self.ReqType = data
                    DispatchQueue.main.async {
                        self.requestTableview.reloadData()
                        self.showApprovalIfNeeded()
                    }
                } else {
                    AlertController.alert(message: (response?.validatedValue("message"))!)
                }
            }
        }
    func showApprovalIfNeeded() {
           if ReqType.contains(where: { $0["name"] as? String == "Approval" }) {
               aprove = true
               typeLbl.text = "Approval"
               ApprovalContainerview.isHidden = false
           }
       }
    
    func showContainerView(for name: String) {
           hideAllContainerViews()
           let viewMapping: [String: UIView] = [
               "Approval": ApprovalContainerview,
               "Leave": leaveContainerview,
               "Booking": BookingContainerview,
               "Inventory": InventoryContainerview,
               "Request": RequestContainerview,
               "Tour": TourContainerview,
               "Reports": ReportContainerview,
               "Guest": GuestContainerview,
               "Advance": AdvanceContainerview,
               "Stationary": StationaryContainerview,
               "Health": HealthContainerview,
               "Pay Slip": PayslipContainerview,
               "Other": OtherContainerview,
               "Privacy Policy": PrivacyPolicyContanierview,
               "Delete Account": TerminateContanierview
               
           ]
           if let selectedView = viewMapping[name] {
               selectedView.isHidden = false  
           }
       }
    func hideAllContainerViews() {
           let allContainers = [
               leaveContainerview, BookingContainerview, TourContainerview,
               PayslipContainerview, AdvanceContainerview, StationaryContainerview,
               HealthContainerview, GuestContainerview, ReportContainerview,
               OtherContainerview, ApprovalContainerview, RequestContainerview,
               InventoryContainerview,PrivacyPolicyContanierview,TerminateContanierview
           ]
           allContainers.forEach { $0?.isHidden = true }
       }
    @IBAction func RequestBtnclick(_ sender: UIButton) {
        hideAllContainerViews()
        requestTypeView.isHidden = false
        requestTableview.isHidden = false
    }
}

extension CalenderOnClick: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReqType.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = requestTableview.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell1.textLabel?.text = ReqType[indexPath.row]["name"] as? String ?? ""
        cell1.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        return cell1
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSearchResult = ReqType[indexPath.row]["name"] as? String ?? ""
        typeLbl.text = selectedSearchResult
        showContainerView(for: selectedSearchResult)
        requestTypeView.isHidden = true
        requestTableview.isHidden = true
    }
}
