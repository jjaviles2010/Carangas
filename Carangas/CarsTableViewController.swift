//
//  CarsTableViewController.swift
//  Carangas
//
//  Copyright © 2019 Eric Brito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {
    
    var cars: [Car] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.addTarget(self, action: #selector(loadCars), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCars()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let vc = segue.destination as? CarViewController {
            let car = cars[tableView.indexPathForSelectedRow!.row]
            vc.car = car
        }
        
    }
    
    @objc func loadCars() {
        //forma de chamar passando o metodo
//        CarAPI.loadCars(onComplete: updataCars)
        
        //Forma de carregar directo com a clousure
        CarAPI.loadCars { [weak self] (result) in
            guard let self = self else {return}
            
            switch result {
            case .success(let cars):
                self.cars = cars
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            case .failure(let apiError):
                switch apiError {
                case .badResponse:
                    print("Response Erro")
                default:
                    print("Outro erro")
                }
                
            }
        }
    }
    
    //forma criando metodo a ser chamado quando terminar a chamada da API
//    func updataCars(cars: [Car]) {
//        self.cars = cars
//        tableView.reloadData()
//    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let car = cars[indexPath.row]
            CarAPI.deleteCar(car) { (result) in
                switch result {
                case .success: DispatchQueue.main.async {
                    self.cars.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                case .failure:
                    print("Falhou!")
                }
            }
        }
        
    }
}
