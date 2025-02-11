
//  SecondnewApprovalVc.swift
//  SanskarEP
//
//  Created by Surya on 05/02/25.
//

import UIKit

class SecondnewApprovalVc: UIViewController {
    

    @IBOutlet weak var collectionview: UICollectionView!
    
 //   let staticItems = ["Leave", "Booking", "Tour", "Re"]
    
    var task = [
        TaskManagement(taskName: "Leave ", taskImg: "Request (1)"),
        TaskManagement(taskName: "Booking", taskImg: "Reports"),
        TaskManagement(taskName: "Tour", taskImg: "Guest"),
        TaskManagement(taskName: "Tour Bill", taskImg: "Guest"),
        TaskManagement(taskName: "Re", taskImg: ""),
        
     //   TaskManagement(taskName: "Tour Management", taskImg: "world-map"),
    ]
    override func viewDidLoad() {
        super.viewDidLoad()

        
        collectionview.register(UINib(nibName: "ApprvlCollCell" , bundle: nil), forCellWithReuseIdentifier: "Cell")
        collectionview.delegate = self
        collectionview.dataSource = self
    }
    
    @objc func onClickedMapButton(_ sender: UIButton) {
        print(sender.tag)
        let index = sender.tag
        switch sender.tag {
        case 0 :
            let vc = storyboard?.instantiateViewController(withIdentifier: "LeaveTypeVc") as! LeaveTypeVc
        //  let   vc = storyboard?.instantiateViewController(withIdentifier: "BookforReceptionVc") as! BookforReceptionVc
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
          //  present(vc, animated: true, completion: nil)
            self.present(vc,animated: true,completion: nil)
        default:
            break
        }
    }
}
extension SecondnewApprovalVc: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return task.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ApprvlCollCell else {
            return UICollectionViewCell()
        }
        let image = task[indexPath.row].taskImg
        cell.imageview.image = UIImage(named: image)
        cell.namelabel.text = task[indexPath.row].taskName
    
      //  cell.imageview =
        cell.actionbtn.tag = indexPath.row
        cell.actionbtn.addTarget(self, action: #selector(SecondnewApprovalVc.onClickedMapButton(_:)), for: .touchUpInside)
       
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = 2
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        return CGSize(width: 120, height: 130)
    }
}
