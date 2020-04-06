//
//  ServerManager.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import Alamofire
import Groot
import ObjectMapper
import Combine

struct ServerManager {
    static let shared = ServerManager()
    
    private init() { }
    
    public func getCourses(completion: @escaping ([[String: Any]]) -> ()) {
        AF.request(AppConstants.shared.coursesUrl).responseJSON { response in
            switch response.result {
            case .success(let json):
                if let courses = json as? [[String: Any]] {
                    completion(courses)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
//    public func getCourses(completion: @escaping ([Course]) -> ()) {
//        AF.request(AppConstants.shared.coursesUrl).responseJSON { response in
//            switch response.result {
//            case .success(let json):
//                if let courses = Mapper<Course>().mapArray(JSONObject: json) {
//                    completion(courses)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
    
//    public func listen(to course: Course, completion: @escaping ([MTResponse]) -> Void) {
//        let encodedCourse = Mapper<Course>().toJSON(course)
//        AF.request(AppConstants.shared.listenUrl, method: .post, parameters: encodedCourse).responseJSON { response in
//            switch response.result {
//            case .success(let json):
//                if let responses = Mapper<MTResponse>().mapArray(JSONObject: json) {
//                    completion(responses)
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//
    public func listen(to section: Section, completion: @escaping (MTResponse) -> Void) {
        guard let userId = AppConstants.shared.userId else { return }
        let encodedSection = json(fromObject: section)
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
    
    
    public func seats(to section: Section, completion: @escaping ([String: Any]) -> Void) {
        guard let userId = AppConstants.shared.userId else { return }
        let encodedSection = json(fromObject: section)
        let data = ["section": encodedSection, "user_id": userId] as [String : Any]
        AF.request(AppConstants.shared.listenSectionUrl, method: .post, parameters: data).responseJSON { encodedResponse in
            switch encodedResponse.result {
            case .success(let json):
                if let dict = json as? [String: Any] {
                    completion(dict)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public func request(to section: Section) -> DataRequest {
          let userId = AppConstants.shared.userId!
          let encodedSection = json(fromObject: section)
          let data = ["section": encodedSection, "user_id": userId] as [String : Any]
          return AF.request(AppConstants.shared.listenSectionUrl, method: .post, parameters: data)
      }
    
//    public func listen(to section: Section) -> AnyPublisher<MTResponse, URLError>? {
//        guard let userId = AppConstants.shared.userId else { return nil }
//        let encodedSection = json(fromObject: section)
//        let data = ["section": encodedSection, "user_id": userId] as [String: Any]
//        let url = URL(string: AppConstants.shared.listenSectionUrl)
//        let headers = [
//            HTTPHeader(name: "Content-Type", value: "application/json")
//        ]
//        do {
//            var request = try URLRequest(url: url!, method: .post, headers: .init(headers))
//            request.httpBody = try JSONSerialization.data(withJSONObject: data)
//            return URLSession.shared.dataTaskPublisher(for: request)
//            .compactMap{ (result, response) -> MTResponse? in
//                return Mapper<MTResponse>().map(JSONObject: result)
//            }
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//        } catch {
//            print(error)
//            return nil
//        }
//    }
}
