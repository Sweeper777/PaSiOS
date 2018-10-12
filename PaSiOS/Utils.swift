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

extension CLLocationDegrees {
    func toRadians() -> Double {
        return self * (.pi / 180.0)
    }
}

extension CLLocationCoordinate2D {
    func distance(from point: CLLocationCoordinate2D) -> Double {
        let r = 6371.0
        let dLat = (self.latitude - point.latitude).toRadians()
        let dLng = (self.longitude - point.longitude).toRadians()
        let a = pow(sin(dLat / 2), 2) + cos(self.latitude.toRadians()) * cos(point.latitude.toRadians()) * pow(sin(dLng / 2), 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return r * c
    }
}

extension Port {
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

fileprivate func search(byCoordinate coordinate: CLLocationCoordinate2D, allPorts: [Port]) -> [Port] {
    return Array(allPorts.sorted { $0.coordinate.distance(from: coordinate) < $1.coordinate.distance(from: coordinate) }.prefix(10))
}
