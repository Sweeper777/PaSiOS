import UIKit
import GoogleMaps

class SinglePortMapController : UIViewController {
    var mapView: GMSMapView!
    var port: Port!
    
    override func viewDidLoad() {
        mapView = GMSMapView()
        self.view = mapView
        mapView.moveCamera(GMSCameraUpdate.setTarget(port.coordinate))
        mapView.moveCamera(GMSCameraUpdate.zoom(to: 7))
        
        let marker = GMSMarker(position: port.coordinate)
        marker.map = mapView
    }
}
