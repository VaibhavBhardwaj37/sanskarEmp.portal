//
//  GuestResponse.swift
//  SanskarEP
//
//  Created by Warln on 23/04/22.
//

import Foundation
struct GuestResponse: Decodable {
    let status: Bool
    let message: String
    let data: [GuestList]
}
struct GuestList: Decodable {
    let Guest_Name: String
    let WhomtoMeet: String
    let Reason: String
    let Date1: GuestDate
    let PImg: String
}
struct GuestDate: Decodable {
    let date: String
}
struct VistorResponse: Decodable {
    let status: Bool
    let message: String
    let data: [VistorList]
}
struct VistorList: Decodable {
    let id: String
    let name: String
    let address: String
    let image: String
    let guest_date: String
    let to_whome: String
    let in_time: String
    let out_time: String
    let mobile: String
}
