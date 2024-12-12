//
//  PieChartVC.swift
//  SanskarEP
//
//  Created by Surya on 28/09/24.
//

import UIKit

class PieChartVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let pieChartView = PieChartView(frame: CGRect(x: 20, y: 80, width: 170, height: 170))
           view.addSubview(pieChartView)
        let LeavePieChartView = LeavePieChartView(frame: CGRect(x: 20, y: 300, width: 170, height: 170))
           view.addSubview(LeavePieChartView)
        
    }
    

 

}
