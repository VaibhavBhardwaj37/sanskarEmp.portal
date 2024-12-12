//
//  SearcHvC.swift
//  SanskarEP
//
//  Created by Surya on 01/02/24.
//

import UIKit

class SearcHvC: UIViewController {

    @IBOutlet weak var searchview: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    var searchvalue =  ["Leave Request","Leave Cancellation","Profile","Tour Detail","AllStatusVc","Your Guest List","Your Visitor List","UpComing B'day","B'day Wishes","Advance","Submit Tour","Health Managment","Approved Tour","Stationary Request","Pay-Slip Request"]
    
    var filteredSearchValue = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let searchTextField = searchbar.value(forKey: "searchField") as? UITextField {
               searchTextField.textColor = UIColor.darkText
           }
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "searchCell", bundle: nil), forCellReuseIdentifier: "searchCell")
        searchbar.delegate = self
        filteredSearchValue = searchvalue
        searchbar.layer.cornerRadius = 10
        searchbar.clipsToBounds = true
    }
    

    @IBAction func backbtn(_ sender: UIButton) {
        dismiss(animated: true,completion: nil)
    }
    

}
extension SearcHvC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredSearchValue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell", for: indexPath) as! searchCell
        cell.SLabel.text = filteredSearchValue[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let selectedSearchResult = filteredSearchValue[indexPath.row]
        if let index = searchvalue.firstIndex(of: selectedSearchResult){
            switch index {
            case 0:
                let vc = storyboard?.instantiateViewController(withIdentifier: "NewAllLeaveReqVc") as! NewAllLeaveReqVc
            //    vc.headerTxt = searchvalue[indexPath.row]
                self.present(vc,animated: true,completion: nil)
            case 1:
                let vc = storyboard?.instantiateViewController(withIdentifier: "LeaveCancel") as! LeaveCancel
                vc.titleTxt = searchvalue[indexPath.row]
                self.present(vc,animated: true,completion: nil)
            case 2:
                let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileVc") as! ProfileVc
                self.present(vc,animated: true,completion: nil)
            case 3:
                let vc = storyboard?.instantiateViewController(withIdentifier: "TourVC") as! TourVC
                vc.titleTxt = searchvalue[indexPath.row]
                self.present(vc,animated: true,completion: nil)
            case 4:
                let vc = storyboard?.instantiateViewController(withIdentifier: "AllStatusVc") as! AllStatusVc
                self.present(vc,animated: true,completion: nil)
            case 5:
                let vc = storyboard?.instantiateViewController(withIdentifier: "GuestHistoryVc") as! GuestHistoryVc
                self.present(vc,animated: true,completion: nil)
            case 6:
                let vc = storyboard?.instantiateViewController(withIdentifier: "VistorHistoryVC") as! VistorHistoryVC
                self.present(vc,animated: true,completion: nil)
            case 7:
                let vc = storyboard?.instantiateViewController(withIdentifier: "BdayViewController") as! BdayViewController
                self.present(vc,animated: true,completion: nil)
            case 8:
                let vc = storyboard?.instantiateViewController(withIdentifier: "MyBdayWishVc") as! MyBdayWishVc
                self.present(vc,animated: true,completion: nil)
            case 9:
                let vc = storyboard?.instantiateViewController(withIdentifier: "AdvcanceVC") as! AdvcanceVC
                vc.titleTxt = searchvalue[indexPath.row]
                self.present(vc,animated: true,completion: nil)
            case 10:
                let vc = storyboard?.instantiateViewController(withIdentifier: "AllDetail2VC") as! AllDetail2VC
                self.present(vc,animated: true,completion: nil)
            case 11:
                let vc = storyboard?.instantiateViewController(withIdentifier: "HealthVc") as! HealthVc
                vc.titleTxt = searchvalue[indexPath.row]
                self.present(vc,animated: true,completion: nil)
            case 12:
                let vc = storyboard?.instantiateViewController(withIdentifier: "ApprovedTourVC") as! ApprovedTourVC
                self.present(vc,animated: true,completion: nil)
            case 13:
                let vc = storyboard?.instantiateViewController(withIdentifier: "HealthVc") as! HealthVc
                vc.titleTxt = searchvalue[indexPath.row]
                vc.stat = true
                self.present(vc,animated: true,completion: nil)
            case 14:
                let vc = storyboard?.instantiateViewController(withIdentifier: "PaySlipVc") as! PaySlipVc
                vc.titleTxt = searchvalue[indexPath.row]
                self.present(vc,animated: true,completion: nil)
            default:
                print(index)
            }
        }
    }
}
extension SearcHvC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredSearchValue = searchvalue
        } else {
            filteredSearchValue = searchvalue.filter { $0.lowercased().contains(searchText.lowercased()) }
        }
        
        tableview.reloadData()
    }
}

