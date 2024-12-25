//
//  ReportAllVc.swift
//  SanskarEP
//
//  Created by Surya on 25/12/24.
//

import UIKit

class ReportAllVc: UIViewController {
    
    @IBOutlet weak var collectionview: UICollectionView!
    
    let staticItems = [
       
           ["month": "Oct", "PL": 1, "Tour": 5, "WFH": 1, "Bal": 8],
           ["month": "Nov", "PL": 2, "Tour": 2, "WFH": 3, "Bal": 2],
           ["month": "Dec", "PL": 3, "Tour": 3, "WFH": 3, "Bal": 1],
           ["month": "Jan", "PL": 5, "Tour": 4, "WFH": 4, "Bal": 4]
       ]
    let itemKeys = ["month", "PL", "Tour", "WFH", "Bal"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionview.delegate = self
        collectionview.dataSource = self
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
        let width = collectionview.frame.width / CGFloat(itemKeys.count) - 10
        let height = collectionview.frame.width / CGFloat(itemKeys.count) - 10
        cell.setCellSize(width: width, height: height)
        
        return cell
    }
    
}
