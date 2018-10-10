import UIKit
import Alamofire
import SCLAlertView

class PortsListViewController: UITableViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.dimsBackgroundDuringPresentation = false
        
        if #available(iOS 11.0, *) {
            self.navigationItem.searchController = searchController
            searchController.searchBar.barStyle = .black
            searchController.searchBar.tintColor = UIColor.white
        } else {
            searchController.searchBar.barTintColor = UIColor(red: 156 / 0xff, green: 223 / 0xff, blue: 154 / 0xff, alpha: 1.0)
            searchController.searchBar.tintColor = UIColor.black
            definesPresentationContext = true
            self.tableView.tableHeaderView = searchController.searchBar
        }
        
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

extension PortsListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text != "" && searchController.searchBar.text != nil {
            filteredPorts = ports.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        tableView.reloadData()
    }
}
