import UIKit
import Alamofire
import SCLAlertView
import EZLoadingActivity

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
    
    var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
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
            loadWebData()
        }
    }
    
    func loadWebData() {
        EZLoadingActivity.show("Loading...", disableUI: true)
        downloadData { [unowned self] (data) in
            if let pasData = data {
                self.data = pasData
                self.tableView.reloadData()
            } else {
                let alert = SCLAlertView()
                alert.showError("Error", subTitle: "Unable to load data.")
            }
            
            EZLoadingActivity.hide()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.searchBar.text != "" && searchController.searchBar.text != nil {
            return filteredPorts.count
        } else {
            return ports.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        if searchController.searchBar.text != "" && searchController.searchBar.text != nil {
            cell.textLabel?.text = filteredPorts[indexPath.row].name
        } else {
            cell.textLabel?.text = ports[indexPath.row].name
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchText != "" {
            performSegue(withIdentifier: "showSurveyors", sender: filteredPorts[indexPath.row])
        } else {
            performSegue(withIdentifier: "showSurveyors", sender: ports[indexPath.row])
        }
        searchController.isActive = false
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SurveyorListController,
            let port = sender as? Port,
            let surveyorIndices = (sender as? Port)?.surveyors {
            vc.port = port
            vc.surveyors = surveyorIndices.compactMap { data.surveyorsDictionary[$0] }
        }
    }
    
    @IBAction func refresh() {
        loadWebData()
    }
}

extension PortsListViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text ?? ""
        if searchController.searchBar.text != "" && searchController.searchBar.text != nil {
            filteredPorts = ports.filter { $0.name.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        tableView.reloadData()
    }
}

extension PortsListViewController : UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchText
    }
}
