//
//  CourseCritique.swift
//  GT
//
//  Created by Maksim Tochilkin on 02.08.2020.
//  Copyright © 2020 Maksim Tochilkin. All rights reserved.
//

import Foundation
import SwiftSoup
import Alamofire

enum CourseCritiqueAPI {
    static func fetch(course: Course, completion: @escaping (Double?) -> ()) {
        let url = "https://critique.gatech.edu/course.php?id=\(course.school)%20\(course.number)"
        AF.request(url).responseString { response in
            switch response.result {
            case .success(let string):
                completion(parse(string: string))
            case .failure(let error):
                break
            }
        }
    }
    
    static func parse(string: String) -> Double? {
        do {
            let doc: Document = try SwiftSoup.parse(string)
            let table = try doc.select("tbody").first()
            guard let entries = try table?.select("td") else { return nil }
            
            for child in entries.array() {
                if let text = try? child.text(), let double = Double(text) {
                    return double
                }
            }
            
            return nil
        } catch {
            print(error)
        }
        return nil
    }
}
