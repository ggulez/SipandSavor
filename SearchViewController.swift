import UIKit

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    

    var drinks = [Drink] ()

    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        fetchDrinks(for: "a")
    }

    // MARK: - Search Bar Delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            drinks.removeAll()
            tableView.reloadData()
        } else {
            fetchDrinks(for: searchText.lowercased())
        }
    }


    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    // MARK: - Table View Data Source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drinks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DrinkCell") ?? UITableViewCell(style: .default, reuseIdentifier: "DrinkCell")
        let drink = drinks[indexPath.row]
        cell.textLabel?.text = drink.strDrink

        return cell
    }
    
    

    // MARK: - Table View Delegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDrink = drinks[indexPath.row]
        performSegue(withIdentifier: "showDrinkDetails", sender: selectedDrink)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDrinkDetails", let destinationVC = segue.destination as? DetailViewController, let selectedDrink = sender as? Drink {
            destinationVC.selectedDrink = selectedDrink
        }
    }

    // MARK: - Helper Methods

    func fetchDrinks(for query: String) {
        let apiKey = "a6a04ace0bmsh714ce427a472e7ep167fefjsn37fd4c61f3bb"
        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/search.php?s=\(query)"

        guard let url = URL(string: urlString) else { return }

        var urlRequest = URLRequest(url: url)

        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")

        URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CocktailDBResponse.self, from: data)

                self?.drinks = response.drinks.prefix(25).map { $0 }

                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }

}
