import UIKit
import Alamofire
import CoreLocation
import Regex

func downloadData(completion: @escaping (PortsAndSurveyorsData?) -> Void) {
    Alamofire.request(pastebinLink).responseData { (response) in
        if let _ = response.error {
            completion(nil)
            return
        }
        guard let data = response.data else { completion(nil); return }
        let decoder = JSONDecoder()
        let pasData = try? decoder.decode(PortsAndSurveyorsData.self, from: data)
        UserDefaults.standard.set(data, forKey: "cache")
        completion(pasData)
    }
}

func loadCache() -> PortsAndSurveyorsData? {
    guard let data = UserDefaults.standard.data(forKey: "cache") else {
        return nil
    }
    let decoder = JSONDecoder()
    return try? decoder.decode(PortsAndSurveyorsData.self, from: data)
}
