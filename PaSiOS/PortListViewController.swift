import UIKit
import Alamofire
import SCLAlertView

class PortsListViewController: UITableViewController {

    
    var data: PortsAndSurveyorsData! {
        didSet {
            data.ports.sort(by: { $0.name < $1.name })
        }
    }
    var ports: [Port] {
        return data?.ports ?? []
    }
    
}
