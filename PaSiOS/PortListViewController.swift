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
    
    var filteredPorts: [Port] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = loadCache() {
            self.data = data
        } else {
            downloadData { [unowned self] (data) in
                if let pasData = data {
                    self.data = pasData
                    self.tableView.reloadData()
                } else {
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "Unable to load data.")
                }
            }
        }
    }
}
