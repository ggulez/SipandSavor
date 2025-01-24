import UIKit
import FirebaseCore

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var cocktailImageView: UIImageView!
    @IBOutlet weak var cocktailNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var recipeTextView: UITextView!
    
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let selectedDrink = selectedDrink else { return }
        let drinkRef = Database.database().reference().child("drinks").childByAutoId()
        drinkRef.child("name").setValue(selectedDrink.strDrink)
        drinkRef.child("recipe").setValue(selectedDrink.strInstructions)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    var selectedDrink: Drink?
    var savedDrinks = [String]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let selectedDrink = selectedDrink,
           let imageUrlString = selectedDrink.strDrinkThumb,
           let imageUrl = URL(string: imageUrlString),
           let drinkName = selectedDrink.strDrink,
           let instructions = selectedDrink.strInstructions {
            
            cocktailNameLabel.text = drinkName
            recipeTextView.text = instructions
                        
            let task = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                guard let self = self, let imageData = data else { return }
                DispatchQueue.main.async {
                    self.cocktailImageView.image = UIImage(data: imageData)
                }
            }
            task.resume()
            
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()

        }
    }
    
    
    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDrink?.ingredients.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath)
        guard let ingredient = selectedDrink?.ingredients[indexPath.row] else {
            return cell
        }
        cell.textLabel?.text = "\(ingredient.measure) : \(ingredient.name)"
        return cell
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? SavedDrinksViewController {
            destinationViewController.savedDrinks = savedDrinks
            print(savedDrinks)
        }
    }
}


