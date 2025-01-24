//
//  ViewController.swift
//  Sip & Savor
//
//  Created by GIO on 4/13/23.
//

import UIKit
//import FirebaseCore


class ViewController: UIViewController {
    
    @IBOutlet weak var cocktailImageView: UIImageView!
    @IBOutlet weak var cocktailNameLabel: UILabel!
    
    var selectedDrink: Drink?
    
    // surprise me button
    @IBAction func refreshButtonTapped(_ sender: UIButton) {
        fetchCocktail()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCocktail()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        cocktailImageView.addGestureRecognizer(tapGesture)

    }
    
    /*
     Using URLSession to make a network request to the API and retrieve the response data.
     
     Then use JSONDecoder to decode the JSON data into a CocktailDBResponse object, which contains
     an array of Drink objects.
     
     Then set the image and name of the first drink in the array to the UIImageView and UILabel in the view controller.
     */
    
    // cocktail fetcher
    func fetchCocktail() {
        let apiKey = "a6a04ace0bmsh714ce427a472e7ep167fefjsn37fd4c61f3bb"
        let urlString = "https://www.thecocktaildb.com/api/json/v1/1/random.php"
        
        guard let url = URL(string: urlString)
            else { return }
        
        var urlRequest = URLRequest(url: url)
        
        urlRequest.addValue(apiKey, forHTTPHeaderField: "X-RapidAPI-Key")
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(CocktailDBResponse.self, from: data)
                
                if let drink = response.drinks.first {
                    DispatchQueue.main.async {
                        self.selectedDrink = drink
                        self.cocktailImageView.image = nil
                        self.cocktailNameLabel.text = nil
                        self.fetchDrinkImage(for: drink)                        
                    }
                }
                else {
                    print("Error: Invalid response data")
                }
            }
            
            catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    //image fetcher
    func fetchDrinkImage(for drink: Drink) {
        guard let imageUrlString = drink.strDrinkThumb,
            let imageUrl = URL(string: imageUrlString)
            else { return }
        
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching drink image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.cocktailImageView.image = UIImage(data: data)
                self.cocktailNameLabel.text = drink.strDrink
            }
        }.resume()
    }
    
    // image tapping
    @objc func imageTapped() {
        performSegue(withIdentifier: "showDrinkDetails", sender: self)
    }
    
    //segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDrinkDetails",
            let destinationVC = segue.destination as? DetailViewController,
            let selectedDrink = self.selectedDrink {
                destinationVC.selectedDrink = selectedDrink
        }
    }
}

struct CocktailDBResponse: Codable {
    let drinks: [Drink]
}

struct Drink: Codable {
    //drink
    let strDrink: String?
    let strDrinkThumb: String?
    
    //instructions
    let strInstructions: String?
    
    //ingredients
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    
    //measures
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    

    var ingredients: [(name: String, measure: String)] {
        var ingredients = [(name: String, measure: String)]()
        if let name = strIngredient1, let measure = strMeasure1 {
            ingredients.append((name, measure))
        }
        if let name = strIngredient2, let measure = strMeasure2 {
            ingredients.append((name, measure))
        }
        if let name = strIngredient3, let measure = strMeasure3 {
            ingredients.append((name, measure))
        }
        
        if let name = strIngredient4, let measure = strMeasure4 {
            ingredients.append((name, measure))
        }
        if let name = strIngredient5, let measure = strMeasure5 {
            ingredients.append((name, measure))
        }
        if let name = strIngredient6, let measure = strMeasure6 {
            ingredients.append((name, measure))
        }

        
        return ingredients
    }
}







