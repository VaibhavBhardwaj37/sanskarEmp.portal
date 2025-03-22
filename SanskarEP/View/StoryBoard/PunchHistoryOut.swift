//
//  PunchHistoryOut.swift
//  SanskarEP
//
//  Created by Vaibhav on 21/03/25.
//

import UIKit

class PunchHistoryOut: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var frombtn: UIButton!
    @IBOutlet weak var tobtn: UIButton!
    @IBOutlet weak var sendbtn: UIButton!
    @IBOutlet weak var collectionDate: UICollectionView!
    @IBOutlet weak var Headrview: UIView!
    
    
    let headers = ["Date", "In Time", "Out Time", "Location"]
 //   let image = #imageLiteral(resourceName: "location (2)")
  
    var PunchHistoryModel = [Attendance]()
    
    var Days = ["7 Days","15 Days","1 Month","3 Months","6 Months"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        getDetails()
        reset()
//        collectionDate.register(UINib(nibName: "PunchHistoryDaysS" , bundle: nil), forCellWithReuseIdentifier: "Cell")
        
       
    }
    func reset() {
        
        frombtn.layer.cornerRadius = 10
        frombtn.clipsToBounds = true
        frombtn.layer.borderWidth = 1.0
        frombtn.layer.borderColor = UIColor.darkGray.cgColor
        
        Headrview.layer.cornerRadius = 8
        Headrview.clipsToBounds = true
        Headrview.layer.borderWidth = 1.0
        Headrview.layer.borderColor = UIColor.darkGray.cgColor
        
        
        tobtn.layer.cornerRadius = 10
        tobtn.clipsToBounds = true
        tobtn.layer.borderWidth = 1.0
        tobtn.layer.borderColor = UIColor.darkGray.cgColor
    }
    func getDetails() {
        var dict = Dictionary<String, Any>()
        dict["EmpCode"] = currentUser.EmpCode


        let currentDate = Date()
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: currentDate)
        let currentYear = calendar.component(.year, from: currentDate)

       
        dict["month"] = String(format: "%02d", currentMonth)
        dict["year"] = "\(currentYear)"

        DispatchQueue.main.async { Loader.showLoader() }
        APIManager.apiCall(postData: dict as NSDictionary, url: monthwisedetailapi) { result, response, error, data in
            DispatchQueue.main.async { Loader.hideLoader() }
            guard let data = data, error == nil else {
                AlertController.alert(message: error?.localizedDescription ?? "Unknown error")
                return
            }
            do {
                let json = try JSONDecoder().decode(SanskarEP.PunchHistoryModel.self, from: data)
                self.PunchHistoryModel.removeAll()
                self.PunchHistoryModel.append(contentsOf: json.data ?? [])
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("Decoding Error: \(error.localizedDescription)")
            }
        }
    }
    @objc func onClickedMapButton(_ sender: UIButton) {
        
    }

    @IBAction func fromdateonclick(_ sender: UIButton) {
        IosDatePicker().showDate(animation: .zoomIn, pickerMode: .date) { date in
               let selectedDate = Utils.dateString(date: date, format: "yyyy-MM-dd")
               self.frombtn.setTitle(selectedDate, for: .normal)
           }
    }
    
    @IBAction func todateclick(_ sender: Any) {
        IosDatePicker().showDate(animation: .zoomIn, pickerMode: .date) { date in
                let selectedDate = Utils.dateString(date: date, format: "yyyy-MM-dd")
                self.tobtn.setTitle(selectedDate, for: .normal)
            }
    }
    
    @IBAction func sendOnclck(_ sender: UIButton) {
        
    }
    
}
// MARK: - UITableViewDataSource
extension PunchHistoryOut: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PunchHistoryModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PunchCell", for: indexPath) as! PunchHistoryTableViewCell
        let rowData = PunchHistoryModel[indexPath.row]

        cell.dateLabel.text = "\(rowData.date1 ?? "")"
        cell.inTimeLabel.text = rowData.inTime?.isEmpty == false ? rowData.inTime : "-"
        cell.outTimeLabel.text = rowData.outTime?.isEmpty == false ? rowData.outTime : "-"

       
        let locationIn = rowData.locationIn ?? "-"
        let locationOut = rowData.locationOut ?? "-"
        
        cell.locationLabel.text = "\(locationIn),\(locationOut)"

        return cell
    }

}

// MARK: - UITableViewDelegate
extension PunchHistoryOut: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
        headerView.backgroundColor = UIColor.darkGray

        let stackView = UIStackView(frame: headerView.bounds)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        
        let headers = ["Date", "In Time", "Out Time", "Location"]
        
        for title in headers {
            let label = UILabel()
            label.text = title
            label.textColor = UIColor.white
            label.textAlignment = .center
            label.font = UIFont.boldSystemFont(ofSize: 16)
            stackView.addArrangedSubview(label)
        }
        
        headerView.addSubview(stackView)
        return headerView
    }

    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension PunchHistoryOut : UICollectionViewDataSource,UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? PunchHistoryDaysS else {
            return UICollectionViewCell()
        }
        cell.namelabel.text = Days[indexPath.row]
  

        return cell
    }
    
    

    
}
extension PunchHistoryOut: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * spacing
        
        let width = (collectionView.frame.width - totalSpacing) / itemsPerRow
        let height: CGFloat = 45
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}


