//
//  AppConstants.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import UIKit

struct AppConstants {
    
    static let shared = AppConstants()
    
    var userId: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    private init() { }
    
    let baseUrl =  "https://oscarapp.appspot.com" //"https://oscar-gt.herokuapp.com"
    
    var coursesUrl: String {
        return baseUrl + EndPoints.courses.rawValue
    }
    
    var listenUrl: String {
        return baseUrl + EndPoints.listen.rawValue
    }
    
    var listenSectionUrl: String {
        return baseUrl + EndPoints.listenSection.rawValue
    }
    
    var unsubscribe: String {
        return baseUrl + EndPoints.unsubscribe.rawValue
    }
    
    
    enum EndPoints: String {
        case courses = "/courses"
        case listen = "/listen"
        case listenSection = "/listen/section"
        case unsubscribe = "/unsubscribe"
    }
}
