//
//  NotifyResponse.swift
//  SanskarEP
//
//  Created by Warln on 04/04/22.
//

import Foundation

struct NotifyResponse: Decodable {
    let data: [Notify]
}

struct Notify: Decodable {
    let id: String
    let notification_title: String
    let notification_content: String
    let notification_thumbnail: String
    let from_EmpCode: String
    let req_id: String
    let note_type: String
    let status: String
}
