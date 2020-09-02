//
//  ServerManager.swift
//  GT
//
//  Created by Maksim Tochilkin on 23.03.2020.
//  Copyright © 2020 MT. All rights reserved.
//

import Foundation
import Alamofire
import Combine

enum API {
    
    public static func getCourses(completion: @escaping (Data) -> ()) {
//        AF.request(AppConstants.AppURL.url(at: .courses))
        AF.request(AppConstants.AppURL.url(at: .courses)).responseData { response in
            switch response.result {
            case .success(let data):
                print(data)
                completion(data)
            case .failure(let error):
                print("[API] Error in \(#function) -> \(error.localizedDescription)")
            }
        }
    }
    
    public static func getTestCourses(size: Int, completion: @escaping (Data) -> ()) {
        AF.request(AppConstants.AppURL.testCourses(size: size)).responseData { response in
            switch response.result {
            case .success(let data):
                print(data)
                completion(data)
            case .failure(let error):
                print("[API] Error in \(#function) -> \(error.localizedDescription)")
            }
        }
    }

    public static func listen(to section: Section, completion: @escaping (MTResponse) -> Void) {
        guard let request = self.request(to: section, endpoint: .listenSection) else { return }
        
        request.responseJSON { encodedResponse in
            switch encodedResponse.result {
            case .success(let json):
                break
               
            case .failure(let error):
                print(error)
            }
        }
    }
    
    public static func unsubscribe(from section: Section, completion: @escaping ([String: Any]) -> Void) {
        guard let request = self.request(to: section, endpoint: .unsubscribe) else { return }
        
        request.responseJSON { response in
            
        }
    }
    
    public static func seats(to section: Section, completion: @escaping ([String: Any]) -> Void) {
        guard let request = self.request(to: section, endpoint: .listenSection) else { return }
        
        request.responseJSON { encodedResponse in
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
    
    private static func request(to section: Section, endpoint: AppConstants.AppURL.EndPoints, method: HTTPMethod = .post) -> DataRequest? {
        guard let userId = AppConstants.userId,
              let encodedSection = try? JSONEncoder().encode(section)
        else { return nil }
        
        let data = ["section": encodedSection, "user_id": userId] as [String : Any]
        return AF.request(AppConstants.AppURL.url(at: endpoint), method: method, parameters: data)
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
