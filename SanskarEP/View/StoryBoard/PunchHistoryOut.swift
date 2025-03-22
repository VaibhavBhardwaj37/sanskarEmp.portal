//
//  PunchHistoryOut.swift
//  SanskarEP
//
//  Created by Vaibhav on 21/03/25.
//

import UIKit

class PunchHistoryOut: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let headers = ["Date", "In Time", "Out Time", "Location"]
 //   let image = #imageLiteral(resourceName: "location (2)")
//    var punchHistory: [Attendance] = []
    
    let punchHistory: [[String]] = [
        ["15-03-25", "10:14", "19:40", "Noida"],
        ["16-03-25", "10:10", "19:35", "Noida"],
        ["17-03-25", "0:0", "", ""],
        ["18-03-25", "11:02", "19:34", "Delhi"],
        ["19-03-25", "10:15", "19:33", "Jaipur"],
        ["20-03-25", "10:04", "19:31", "Punjab"],
        ["22-03-25", "10:11", "20:06", "Nepal"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableViewDataSource
extension PunchHistoryOut: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return punchHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PunchCell", for: indexPath) as! PunchHistoryTableViewCell
        let rowData = punchHistory[indexPath.row]

        cell.dateLabel.text = rowData[0]
        cell.inTimeLabel.text = rowData[1]
        cell.outTimeLabel.text = rowData[2].isEmpty ? "-" : rowData[2]
        cell.locationLabel.text = rowData[3].isEmpty ? "-" : rowData[3]

        // Align separators properly
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero

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
