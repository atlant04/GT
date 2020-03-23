//
//  ServerManager.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

struct ServerManager {
    static let shared = ServerManager()
    
    private init() { }
    
    public func getCourses(completion: @escaping ([Course]) -> ()) {
        AF.request(AppConstants.shared.coursesUrl).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let courses = Mapper<Course>().mapArray(JSONObject: json) {
                    completion(courses)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func listen(to course: Course, completion: @escaping ([Response]) -> Void) {
        let encodedCourse = Mapper<Course>().toJSON(course)
        AF.request(AppConstants.shared.listenUrl, method: .post, parameters: encodedCourse).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let responses = Mapper<Response>().mapArray(JSONObject: json) {
                    completion(responses)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
