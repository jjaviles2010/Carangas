//
//  CarAPI.swift
//  Carangas
//
//  Created by Jose Javier on 17/10/19.
//  Copyright © 2019 Eric Brito. All rights reserved.
//

import Foundation

enum APIError: Error {
    case badURL
    case taskError
    case badResponse
    case badData
    case invalidStatusCode(Int)
}

class CarAPI {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type":"application/json"]
        configuration.timeoutIntervalForRequest = 30
        configuration.allowsCellularAccess = false
        configuration.httpMaximumConnectionsPerHost = 3
        return configuration
    }()
    
    //Sessao preconfigurada do IOS, simples padrao
//    private static let session = URLSession.shared
    
    private static let session = URLSession(configuration: configuration)
    
    static func loadCars(onComplete: @escaping (Result<[Car], APIError>) -> Void) {
        guard let url = URL(string: basePath) else {
            onComplete(.failure(.badURL))
            return
        }
        
        let task = session.dataTask(with: url) { (data, response, error) in
            
            if let error = error {
                onComplete(.failure(.taskError))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                onComplete(.failure(.badResponse))
                return
            }
            
            if response.statusCode != 200 {
                onComplete(.failure(.invalidStatusCode(response.statusCode)))
                return
            }
            
            guard let data = data else {
                onComplete(.failure(.badData))
                return
            }
            
            do{
                let cars = try JSONDecoder().decode([Car].self, from: data)
                
                onComplete(.success(cars))
                
                print("Total de carros:", cars.count)
            } catch {
                print(error)
            }
        }
        
        //Esse codigo é o que de fato faz a chamada
        task.resume()
        
    }
    
    class func deleteCar(_ car: Car, onComplete: @escaping (Result<Bool, APIError>) -> Void) {
        request(.delete, car: car, onComplete: onComplete)
    }
    
    class func updateCar(_ car: Car, onComplete: @escaping (Result<Bool, APIError>) -> Void) {
        request(.update, car: car, onComplete: onComplete)
    }
    
    class func createCar(_ car: Car, onComplete: @escaping (Result<Bool, APIError>) -> Void) {
        request(.create, car: car, onComplete: onComplete)
    }
    
    class func request(_ operation: RESTOperation, car: Car, onComplete: @escaping (Result<Bool, APIError>) -> Void) {
        
        let urlString = basePath + "/" + (car._id ?? "")
        let url = URL(string: urlString)!
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = operation.rawValue
        urlRequest.httpBody = try? JSONEncoder().encode(car)
        
        let task = session.dataTask(with: urlRequest) {(data, _, _) in
            if data != nil {
                //sucesso
                onComplete(.success(true))
            } else {
                onComplete(.failure(.taskError))
            }
        }
        task.resume()
    }

    
}

enum RESTOperation: String {
    case delete = "DELETE"
    case update = "PUT"
    case create = "POST"
}
