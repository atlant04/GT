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
    
    public func listen(to course: Course, completion: @escaping ([MTResponse]) -> Void) {
        let encodedCourse = Mapper<Course>().toJSON(course)
        AF.request(AppConstants.shared.listenUrl, method: .post, parameters: encodedCourse).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let responses = Mapper<MTResponse>().mapArray(JSONObject: json) {
                    completion(responses)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func listen(to course: Section, completion: @escaping (MTResponse) -> Void) {
        guard let userId = AppConstants.shared.userId else { return }
        let encodedSection = Mapper<Section>().toJSON(course)
        let data = ["section": encodedSection, "user_id": userId] as [String : Any]
        AF.request(AppConstants.shared.listenSectionUrl, method: .post, parameters: data).responseJSON { encodedResponse in
            switch encodedResponse.result {
            case .success(let json):
                if let response = Mapper<MTResponse>().map(JSONObject: json) {
                    completion(response)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
