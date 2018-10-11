import UIKit
import GoogleMaps
import SCLAlertView

class MapViewController: UIViewController {
    var mapView: GMSMapView!
    var data: PortsAndSurveyorsData! {
        didSet {
            data.ports.sort(by: { $0.name < $1.name })
        }
    }
    
    var ports: [Port] {
        return data?.ports ?? []
    }
    var markers: [GMSMarker] = []
}
