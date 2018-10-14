import UIKit

class SurveyorListController: UITableViewController {
    var portName: String!
    var surveyors: [Surveyor] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "surveyors for port '\(portName!)'"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveyors.count
    }
}
