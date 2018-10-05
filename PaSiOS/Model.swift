import Foundation

struct Port: Codable {
    var name: String
    var latitude, longitude: Double
    var surveyors: [Int]
}
