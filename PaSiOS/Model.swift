import Foundation

class PortsAndSurveyorsData: Codable {
    var surveyors: [Surveyor]!
    var ports: [Port]!
    private var dictionary: [Int: Surveyor]!
    
    var surveyorsDictionary: [Int: Surveyor] {
        if dictionary == nil {
            dictionary = [Int: Surveyor](uniqueKeysWithValues: surveyors.map { ($0.id, $0) })
        }
        return dictionary
    }
    
    enum CodingKeys : String, CodingKey {
        case surveyors
        case ports
    }
}

struct Port: Codable {
    var name: String
    var latitude, longitude: Double
    var surveyors: [Int]
    
    init() {
        name = ""
        latitude = 0
        longitude = 0
        surveyors = []
    }
}

struct Surveyor: Codable {
    var id: Int
    var name: String
    var contacts, prices: [String]
}
