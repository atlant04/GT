//
//  AppConstants.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation


struct AppConstants {
    
    static let shared = AppConstants()
    
    private init() { }
    
    let baseUrl = "https://oscarapp.appspot.com"
    
    var coursesUrl: String {
        return baseUrl + EndPoints.courses.rawValue
    }
    
    var listenUrl: String {
        return baseUrl + EndPoints.listen.rawValue
    }
    
    
    enum EndPoints: String {
        case courses = "/courses"
        case listen = "/listen"
    }
}
