//
//  DataService.swift
//  SmartHome
//
//  Created by Aysun Molla on 30.06.2021.
//

import Foundation

class DataService {
    
    let baseURL = "http://127.0.0.1:5000/predict?cmd="
    
    func getHomeData(for sentence: String) -> String {
        let command = sentence.replacingOccurrences(of: " ", with: "%20")
        var returnData = ""
        let urlString = "\(baseURL)\(command)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    //self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let parseData = self.parseJSON(safeData) {
                        returnData = parseData
                    }
                }
            }
            task.resume()
        }
        return returnData
    }
    
    func parseJSON(_ data: Data) -> String? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(HomeData.self, from: data)
            
            var returnMessage = ""
            returnMessage += "Action: \(decodedData.action)\n"
            returnMessage += "Action Need: \(decodedData.action_needed)\n"
            returnMessage += "Category: \(decodedData.category)\n"
            returnMessage += "Question: \(decodedData.question)\n"
            returnMessage += "Subcategory: \(decodedData.sub_category)\n"
            returnMessage += "Time: \(decodedData.time)"
            print(returnMessage)
            return returnMessage
        } catch {
            //delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
