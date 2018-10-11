import UIKit
import GoogleMaps
import SCLAlertView

class MapViewController: UIViewController {
    var mapView: GMSMapView!
    let searchController = UISearchController(searchResultsController: nil)

    var data: PortsAndSurveyorsData! {
        didSet {
            data.ports.sort(by: { $0.name < $1.name })
        }
    }
    
    var ports: [Port] {
        return data?.ports ?? []
    }
    
    var filteredPorts: [Port] = []
    
    var markers: [GMSMarker] = []
    
    override func viewDidLoad() {
        mapView = GMSMapView()
        mapView.setMinZoom(kGMSMinZoomLevel, maxZoom: 9)
        view = mapView
        
        if let data = loadCache() {
            self.data = data
            reloadMarkers()
        } else {
            downloadData { [unowned self] (data) in
                if let pasData = data {
                    self.data = pasData
                    self.reloadMarkers()
                } else {
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "Unable to load data.")
                }
            }
        }
    }
}


extension MapViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
