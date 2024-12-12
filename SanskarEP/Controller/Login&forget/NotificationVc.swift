//
//  NotificationVc.swift
//  SanskarEP
//
//  Created by Warln on 04/04/22.
//

import UIKit
import SDWebImage
import iOSDropDown

class NotificationVc: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var grantView: UIView!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var locationTxt: DropDown!
    @IBOutlet weak var tabview: UIView!
    @IBOutlet weak var notLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    var titleTxt: String?
    var notifyData = [Notify]()
    var locDetails = ["Ground Floor","Reception","Conference Room","Second Floor"]
    var selectNo: Int = 0
    var datalist = [[String:Any]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerLbl.text = titleTxt
        tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
        tableView.dataSource = self
        tableView.delegate = self
        fetchData()
        grantView.isHidden = true
        NotificationCenter.default.addObserver(forName: NSNotification.Name("NtCount"), object: nil, queue: nil) { [weak self] _ in
            self?.fetchData()
            
        }
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        dismiss(animated: true,completion: nil)
    }
    
    @IBAction func clearBtnPressed(_ sender: UIButton) {
        removeNotify()
    }
    
    
    func fetchData() {
            var dict = Dictionary<String, Any>()
            dict["EmpCode"] = currentUser.EmpCode
            DispatchQueue.main.async { Loader.showLoader() }
            APIManager.apiCall(postData: dict as NSDictionary, url: notifyList) { result, response, error, data in
                DispatchQueue.main.async { Loader.hideLoader() }

                if let JSON = response as? NSDictionary {
                    if JSON.value(forKey: "status") as? Bool == true {
                        print(JSON)
                        let data = (JSON["data"] as? [[String: Any]] ?? [[:]])
                        print(data)

                        self.datalist = data
                        print(self.datalist)
                    } else {
                        print(response?["error"] as Any)
                    }

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.updateNoNotificationLabel()
                        self.updateClearButtonVisibility()// Update label based on data availability
                    }
                }
            }
        }

        // Add this method to update the label based on data availability
        private func updateNoNotificationLabel() {
            if datalist.isEmpty {
                notLabel.text = "No Notifications Available"
            } else {
                notLabel.text = "" // Clear the label if there are notifications
            }
        }
    private func updateClearButtonVisibility() {
            let shouldShowClearButton = !datalist.isEmpty
            clearButton.isHidden = !shouldShowClearButton
        }

        // ... (other methods)
    

    func getGrant(_ id: String, _ reply: String, _ noteId: String) {
        var dict = Dictionary<String,Any>()
        dict["req_id"] = id
        dict["reply"] = reply
        dict["push_id"] = noteId
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: kgrant) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let _ = data,(response?["status"] as? Bool == true), response != nil {
                AlertController.alert(message: (response?.validatedValue("message"))!)
            }else{
                print(response?["error"] as Any)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    
    func visitorGrant( id: String,loc: String,rply: String ) {
        var dict = Dictionary<String,Any>()
        dict["id"] = id
        dict["reply"] = rply
        dict["location"] = loc
        dict["EmpCode"] = currentUser.EmpCode
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: vistorAccept) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let _ = data,(response?["status"] as? Bool == true), response != nil {
                AlertController.alert(message: (response?.validatedValue("message"))!)
                self.grantView.isHidden = true
            }else{
                print(response?["error"] as Any)
            }
            self.tableView.reloadData()
        }
    }
    
    func removeNotify() {
        var dict = Dictionary<String,Any>()
        dict["EmpCode"] = currentUser.EmpCode
        DispatchQueue.main.async(execute: {Loader.showLoader()})
        APIManager.apiCall(postData: dict as NSDictionary, url: removeNote) { result, response, error, data in
            DispatchQueue.main.async(execute: {Loader.hideLoader()})
            if let _ = data, (response?["status"] as? Bool == true), response != nil {
                DispatchQueue.main.async(execute: {Loader.hideLoader()})
                AlertController.alert(message: (response?.validatedValue("message"))!)
                self.fetchData()
            }else{
                print(response?["error"] as Any)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    @IBAction func buttonActionDone(_ sender: UIButton) {
        switch sender.tag {
        case 90:
            let index = datalist[selectNo]
            guard let location = locationTxt.text else { return }
            visitorGrant(id: index["id"] as? String ?? "", loc: location, rply: "grant")
            datalist.remove(at: selectNo)
        case 91:
            grantView.isHidden = true
        default:
            break
        }
    }
}
    extension NotificationVc: GuestRequestDelegate {
        func fetchRequest(_ status: Bool, _ location: String) {
            let index = datalist[selectNo]
            if status {
                visitorGrant(id: index["id"] as? String ?? "", loc: location, rply: "grant")
                datalist.remove(at: selectNo)
            } else {
                visitorGrant(id: index["id"] as? String ?? "", loc: "", rply: "declined")
                datalist.remove(at: selectNo)
            }
        }
    }

//        switch sender.tag {
//        case 90:
//            let index = notifyData[selectNo]
//            guard let loaction = locationTxt.text else {return}
//            visitorGrant(id: index.id, loc: loaction, rply: "grant")
//            notifyData.remove(at: selectNo)
//        case 91:
//            grantView.isHidden = true
//        default:
//            break
//        }
//    }
//}
//extension NotificationVc: GuestRequestDelegate {
//    func fetchRequest(_ status: Bool, _ location: String) {
//        let index = notifyData[selectNo]
//        if status == true {
//            visitorGrant(id: index.id, loc: location, rply: "grant")
//            notifyData.remove(at: selectNo)
//        }else {
//            visitorGrant(id: index.id, loc: "", rply: "declined")
//            notifyData.remove(at: selectNo)
//        }
//    }
//
//
//}

extension NotificationVc: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            print(datalist)
        return datalist.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        //        let data = notifyData[indexPath.row]
        //        if data.status == "true" {
        //            cell.titleLbl.text = data.notification_title
        //            cell.subTitleLbl.text = data.notification_content
        //        }else{
        //
        //        }
        let amountdata = datalist[indexPath.row]["notification_title"] as? String ?? ""
        print(amountdata)
        cell.titleLbl.text = amountdata
        let amountdata1 = datalist[indexPath.row]["notification_content"] as? String ?? ""
        print(amountdata1)
        cell.subTitleLbl.text = amountdata1
        return cell
    }
}

extension NotificationVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let appAction = UIContextualAction(style: .destructive, title: "Approve") {  (contextualAction, view, boolValue) in
            self.editData(at: indexPath)
        }
        appAction.backgroundColor = .green
        appAction.image = UIImage(named: "check-mark")
        let swipeActions = UISwipeActionsConfiguration(actions: [appAction])

        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
         let deleteAction = UIContextualAction(style: .destructive, title: "Reject") {  (contextualAction, view, boolValue) in
             self.deleteData(at: indexPath)
         }

        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage(named: "remove")
         let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])

         return swipeActions
     }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        let index = notifyData[indexPath.row]
//        if index.note_type == "visitor"{
//            selectNo = indexPath.row
////            guard let url = URL(string: "https://sap.sanskargroup.in//uploads/visitor/\(index.notification_thumbnail)") else {return}
////            profileImg.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.fill"), options: .refreshCached, completed: nil)
////            nameLbl.text = index.from_EmpCode
////            grantView.isHidden = false
//            let vc = CustomAlert(nibName: "CustomAlert", bundle: nil)
//            vc.imgName = index.notification_thumbnail
//            vc.nameTxt = index.from_EmpCode
//            vc.delegate = self
//            vc.modalPresentationStyle = .overCurrentContext
//            vc.modalTransitionStyle = .flipHorizontal
//            present(vc, animated: true)
//        }else{
//            let vc = storyboard?.instantiateViewController(withIdentifier: idenity.kAPPList) as! AppListVc
//            vc.type = index.note_type
//            navigationController?.pushViewController(vc, animated: true)
//        }
//
//    }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let index = datalist[indexPath.row] // Use datalist instead of notifyData
            if index["note_type"] as? String == "visitor" {
                selectNo = indexPath.row
                let vc = CustomAlert(nibName: "CustomAlert", bundle: nil)
                vc.imgName = index["notification_thumbnail"] as? String ?? ""
                vc.nameTxt = index["from_EmpCode"] as? String ?? ""
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .flipHorizontal
                present(vc, animated: true)
            } else {
                let vc = storyboard?.instantiateViewController(withIdentifier: "EventDetailVc") as! EventDetailVc
           //     vc.type = index["note_type"] as? String ?? ""
             //   navigationController?.pushViewController(vc, animated: true)
                present(vc, animated: true, completion: nil)
            }
        }
    
//    func deleteData(at indexPath: IndexPath) {
//        let index = notifyData[indexPath.row]
//        if index.note_type == "visitor"{
//            visitorGrant(id: index.id, loc: "", rply: "declined")
//            notifyData.remove(at: indexPath.row)
//        }else{
//            getGrant(index.req_id, "declined", index.id)
//            notifyData.remove(at: indexPath.row)
//        }
//
//    }
    func deleteData(at indexPath: IndexPath) {
            let index = datalist[indexPath.row]
            if index["note_type"] as? String == "visitor" {
                visitorGrant(id: index["id"] as? String ?? "", loc: "", rply: "declined")
                datalist.remove(at: indexPath.row)
            } else {
                getGrant(index["req_id"] as? String ?? "", "declined", index["id"] as? String ?? "")
                datalist.remove(at: indexPath.row)
            }
            
            tableView.reloadData()
        }
//    func editData(at indexPath: IndexPath) {
//        let index = notifyData[indexPath.row]
//        if index.note_type == "visitor" {
//            selectNo = indexPath.row
//            grantView.isHidden = false
//        }else{
//            getGrant(index.req_id, "grant", index.id)
//            notifyData.remove(at: indexPath.row)
//        }
//
//    }
    func editData(at indexPath: IndexPath) {
            let index = datalist[indexPath.row]
            if index["note_type"] as? String == "visitor" {
                selectNo = indexPath.row
                grantView.isHidden = false
            } else {
                getGrant(index["req_id"] as? String ?? "", "grant", index["id"] as? String ?? "")
                datalist.remove(at: indexPath.row)
                tableView.reloadData()
            }
        }
}
