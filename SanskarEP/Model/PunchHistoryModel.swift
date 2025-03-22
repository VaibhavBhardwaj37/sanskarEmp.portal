//
//  PunchHistoryModel.swift
//  SanskarEP
//
//  Created by Vaibhav on 22/03/25.
//

import Foundation

struct AttendanceResponse: Codable {
    let status: Bool
    let message: String
    let data: [Attendance]
}

struct Attendance: Codable {
    let date: String
    let inTime: String
    let outTime: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case inTime = "InTime"
        case outTime = "OutTime"
        case location = "Location"
    }
}
