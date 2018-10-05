import Foundation

struct Port: Codable {
    var name: String
    var latitude, longitude: Double
    var surveyors: [Int]
}

struct Surveyor: Codable {
    var id: Int
    var name: String
    var contacts, prices: [String]
}
