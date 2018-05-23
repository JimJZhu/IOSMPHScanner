//
//  AuthHelper.swift
//  Scanner
//
//  Created by Jim on 2018-05-23.
//  Copyright © 2018 Jim. All rights reserved.
//

import Foundation
import os.log
import FirebaseAuth

class AuthHelper {
    static func isAdmin(user: User?) -> Bool{
        guard let user = user else{
            os_log("Empty user sent!", log: OSLog.default, type: .debug)
            return false
        }
        switch user.uid {
        case "JXgaZSSqdyZ5AY0we3e4DplkNVh1":
            return true
        default:
            return false
        }
    }
}
