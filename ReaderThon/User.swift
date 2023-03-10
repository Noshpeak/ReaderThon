//
//  User.swift
//  ReaderThon
//
//  Created by Lingeswaran Kandasamy on 3/10/23.
//

import SwiftUI
import FirebaseFirestoreSwift

struct User: Identifiable,Codable {
    @DocumentID var id: String?
    var userRole: String
    var userUID: String
    var userEmail: String
    var userProfileURL: URL
    
    enum CodingKeys: CodingKey {
        case id
        case userRole
        case userUID
        case userEmail
        case userProfileURL
    }
}
