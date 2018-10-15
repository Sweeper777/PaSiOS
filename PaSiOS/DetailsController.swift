import UIKit

class DetailsController: UITableViewController {
    var surveyor: Surveyor!
    
    @IBOutlet var priceTextView: UITextView!
    @IBOutlet var contactTextView: UITextView!
    
    override func viewDidLoad() {
        priceTextView.text = surveyor.prices.joined(separator: "\n")
        contactTextView.text = surveyor.contacts.joined(separator: "\n")
    }
}
