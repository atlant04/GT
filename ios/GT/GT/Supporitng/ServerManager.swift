//
//  ServerManager.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import Alamofire

struct ServerManager {
    static let shared = ServerManager()
    
    private init() { }
    
    fileprivate func getCourses(completion: @escaping ([Course]) -> ()) {
        AF.request(AppConstants.coursesUrl)
    }
}
