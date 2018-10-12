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
        
        searchController.searchBar.barStyle = .black
        searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
        } else {
            self.navigationItem.titleView = searchController.searchBar
            searchController.hidesNavigationBarDuringPresentation = false
        }
        searchController.searchBar.tintColor = .white
        
        searchController.searchResultsUpdater = self
    }
    
    func reloadMarkers(searchLocation: CLLocationCoordinate2D? = nil) {
        markers.forEach { $0.map = nil }
        let dataSource = searchController.searchBar.text != nil && searchController.searchBar.text != "" ? filteredPorts : ports

        markers = dataSource.map {
            port in
            let marker = GMSMarker()
            marker.title = port.name
            marker.position = CLLocationCoordinate2D(latitude: port.latitude, longitude: port.longitude)
            marker.map = self.mapView
            return marker
        }
        
    }
}


extension MapViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
