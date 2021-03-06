//
//  APIClient.swift
//  CompositionalLayout-Combine
//
//  Created by Doğan Sayan on 2.04.2022.
//

import Foundation
import Combine

struct PhotoResultsWrapper: Decodable {
  let hits: [Photo]
}

struct Photo: Decodable, Hashable {
  let id: Int
  let webformatURL: String
}

class APIClient{
    
    public func searchPhotos(for query:String) -> AnyPublisher<[Photo],Error>{
        let perPage = 200
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "paris"
        let endpoint = "https://pixabay.com/api/?key=\(Config.apikey)&q=\(query)&per_page=\(perPage)&safesearch=true"
        let url = URL(string: endpoint)!
        
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PhotoResultsWrapper.self, decoder: JSONDecoder())
            .map { $0.hits }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}
