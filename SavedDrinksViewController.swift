import UIKit
import FirebaseCore
import FirebaseDatabase

class SavedDrinksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var savedDrinks = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Fetch the data from Firebase database
        let drinksRef = Database.database().reference().child("drinks")
        drinksRef.observe(.value) { snapshot in
            self.savedDrinks.removeAll()

            // Iterate through the child nodes of drinks node
            for child in snapshot.children {
                if let snapshot = child as? DataSnapshot,
                   let dict = snapshot.value as? [String: Any],
                   let name = dict["name"] as? String {
                    self.savedDrinks.append(name)
                }
            }

            // Reload tableview data on the main thread
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedDrinks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedDrinkCell", for: indexPath)
        cell.textLabel?.text = savedDrinks[indexPath.row]
        return cell
    }
}

