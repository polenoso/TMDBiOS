//
//  NetworkService.swift
//  theiostmdb
//
//  Created by aitor pagan  on 10/3/17.
//
//

import Foundation
import Alamofire
import AlamofireImage

class NetworkService : NSObject {
    
    let api_key = "71fbe398f71c98f66552653199f9f592"
    let base_url = "https://api.themoviedb.org/3/"
    let images_url = "https://image.tmdb.org/t/p/w300/"
    let discover_url = "discover/movie"
    let search_url = "search/movie"
    var request: Alamofire.Request?
    static let shared : NetworkService = NetworkService()
    
    func discoverMovies(page: Int, completionHandler: @escaping ([Film]) -> Void, errorHandler: @escaping (String) -> Void){
        request = Alamofire.request("\(self.base_url)\(self.discover_url)", method: .get,parameters: self.discoverParams(page: page),encoding: URLEncoding.default, headers:nil).validate(statusCode: 200..<300).responseJSON(completionHandler:{ (response) in
                NSLog("Load discover page: %d", page)
            guard  let object = response.result.value as? [String : Any] else{
               print("Error General / Request Cancel")
                print(response.result)
                return
            }
            if let results = object["results"] as? [[String: Any]]{
                var films = [Film]()
                for i in 0..<results.count{
                    films.append(Film.init(dictionary: results[i] as [String : AnyObject]))
                }
                DispatchQueue.main.async {
                    print("Response thread: \(Thread.current) is main thread: \(Thread.isMainThread)")
                    completionHandler(films)
                }
            }else{
                errorHandler(String(describing: response.result.value));
            }
            
        })
    }
    
    func searchMovies(query: String, page: Int, completionHandler: @escaping ([Film]) -> Void, errorHandler: @escaping (String) -> Void){
        request = Alamofire.request("\(self.base_url)\(self.search_url)", method: .get,parameters: self.searchParams(query: query, page: page),encoding: URLEncoding.default, headers:nil).validate(statusCode: 200..<300).responseJSON(completionHandler:{ (response) in
            NSLog("Load discover page: %d", page)
            guard  let object = response.result.value as? [String : Any] else{
                print("Error General / Request cancelled")
                print(response.result)
                return
            }
            if let results = object["results"] as? [[String: Any]]{
                var films = [Film]()
                for i in 0..<results.count{
                    films.append(Film.init(dictionary: results[i] as [String : AnyObject]))
                }
                DispatchQueue.main.async {
                    print("Response thread: \(Thread.current) is main thread: \(Thread.isMainThread)")
                    completionHandler(films)
                }
            }else{
                errorHandler(String(describing: response.result.value));
            }
            
        })
    }
    
    func requestImage(path: String, completionHandler: @escaping (Image) -> Void){
        request = Alamofire.request("\(self.images_url)\(path)").responseImage(imageScale: 1.5, inflateResponseImage: false, completionHandler: {response in
            guard let image = response.result.value else{
                print(response.result)
                return
            }
            DispatchQueue.main.async {
                completionHandler(image)
            }
        })
    }
    
    
    func discoverParams(page : Int) -> Dictionary<String,AnyObject>{
        let params: Dictionary<String, AnyObject> = [
        "api_key" : self.api_key as AnyObject,
        "language" : "en-US" as AnyObject,
        "sort_by" : "popularity.desc" as AnyObject,
        "include_adult" : "false" as AnyObject,
        "page" : String(page) as AnyObject
            ]
        return params
    }
    
    func searchParams(query: String, page: Int) -> Dictionary<String,AnyObject>{
        let params: Dictionary<String, AnyObject> = [
            "api_key" : self.api_key as AnyObject,
            "language" : "en-US" as AnyObject,
            "sort_by" : "popularity.desc" as AnyObject,
            "include_adult" : "false" as AnyObject,
            "page" : String(page) as AnyObject,
            "query" : query as AnyObject
        ]
        return params
    }
    
    func stopRequests(){
        request!.cancel()
    }
    
}
