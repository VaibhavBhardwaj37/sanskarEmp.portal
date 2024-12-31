//
//  ReportAllVc.swift
//  SanskarEP
//
//  Created by Surya on 25/12/24.
//

import UIKit

class ReportAllVc: UIViewController {

    @IBOutlet weak var collectionview: UICollectionView!
//  
    var staticItems = [
        ["month": "month", "Full": "Full", "Half": "Half", "Tour": "Tour", "WFH": "WFH"]]
    let itemKeys = ["month", "Full", "Half", "Tour", "WFH"]
    var empCode: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        detailApi()
    }

    func detailApi() {
        var dict = Dictionary<String, Any>()
        dict["EmpCode"] = empCode
        DispatchQueue.main.async { Loader.showLoader() }
        APIManager.apiCall(postData: dict as NSDictionary, url: EmployeeDetailApi) { result, response, error, data in
            DispatchQueue.main.async { Loader.hideLoader() }
            if let responseData = response, let dataArray = responseData["data"] as? [[String: Any]] {
                for item in dataArray {
                    if let month = item["month"] as? String {
                        let full = "\(item["F"] ?? "")"
                        let half = "\(item["H"] ?? "")"
                        let wfh = "\(item["WFH"] ?? "")"
                        let tour = "\(item["Tour"] ?? "")"
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
                self.collectionview.reloadData()
            } else {
                print(response?["error"] as Any)
            }
        }
    }
}

extension ReportAllVc: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return staticItems.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemKeys.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ReportCollectionView else {
            return UICollectionViewCell()
        }
        let row = staticItems[indexPath.section]
        let key = itemKeys[indexPath.item]
        if let value = row[key] {
            cell.label.text = " \(value)"
        }
        let width = collectionview.frame.width / CGFloat(itemKeys.count) - 0.5
        let height = 40
        cell.setCellSize(width: width, height: CGFloat(height))
        return cell
    }
}

