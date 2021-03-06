import UIKit
import GoogleMaps
import SCLAlertView
import EZLoadingActivity

class MapViewController: UIViewController, GMSMapViewDelegate {
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
    
    var searchText = ""
    
    override func viewDidLoad() {
        mapView = GMSMapView()
        mapView.setMinZoom(kGMSMinZoomLevel, maxZoom: 9)
        view = mapView
        mapView.delegate = self
        
        searchController.searchBar.delegate = self
        
        if let data = loadCache() {
            self.data = data
            reloadMarkers()
        } else {
            loadWebData()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print(searchController.searchBar.text)
    }
    
    func loadWebData() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        downloadData { [unowned self] (data) in
            if let pasData = data {
                self.data = pasData
                self.reloadMarkers()
            } else {
                let alert = SCLAlertView()
                alert.showError("Error", subTitle: "Unable to load data.")
            }
            EZLoadingActivity.hide()
        }
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
        
        if let loc = searchLocation {
            let searchLocationMarker = GMSMarker()
            searchLocationMarker.position = loc
            searchLocationMarker.title = "Searched Location"
            searchLocationMarker.icon = GMSMarker.markerImage(with: .green)
            searchLocationMarker.map = self.mapView
            markers.append(searchLocationMarker)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard marker.title != "Searched Location" else { return }
        if let index = markers.firstIndex(of: marker) {
            searchController.isActive = false
            if searchText != "" {
                performSegue(withIdentifier: "showSurveyors", sender: filteredPorts[index])
            } else {
                performSegue(withIdentifier: "showSurveyors", sender: ports[index])
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SurveyorListController,
            let port = sender as? Port {
            vc.port = port
            vc.surveyors = port.surveyors.compactMap { data.surveyorsDictionary[$0] }
            vc.showMapButton = false
        }
    }
    
    @IBAction func refresh() {
        loadWebData()
    }
}


extension MapViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        var searchLocation: CLLocationCoordinate2D? = nil
        if searchController.searchBar.text != nil && searchController.searchBar.text != "" {
//            filteredPorts = ports.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
            let searchResult = searchPorts(allPorts: ports, keywords: searchController.searchBar.text!)
            filteredPorts = searchResult.ports
            searchLocation = searchResult.cooridnate
            if let firstPort = filteredPorts.first {
                let cameraPosition = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: firstPort.latitude, longitude: firstPort.longitude), zoom: mapView.camera.zoom, bearing: mapView.camera.bearing, viewingAngle: mapView.camera.viewingAngle)
                mapView.animate(to: cameraPosition)
            }
        } else {
            filteredPorts = []
        }
        reloadMarkers(searchLocation: searchLocation)
    }
}

extension MapViewController : UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchText
    }
}
