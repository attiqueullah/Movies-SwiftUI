//
//  MoviesAPI.swift
//  ModernMVVM
//
//  Created by Vadym Bulavin on 2/20/20.
//  Copyright © 2020 Vadym Bulavin. All rights reserved.
//

import Foundation
import Combine
import Alamofire

enum MoviesAPI {
    static let imageBase = URL(string: "https://image.tmdb.org/t/p/original/")!
    
    private static let base = URL(string: "https://api.themoviedb.org/3")!
    private static let apiKey = "efb6cac7ab6a05e4522f6b4d1ad0fa43"
    private static let agent = Agent()
    
    static func trending()-> AnyPublisher<PageDTO<MovieDTO>, AFError> {
        let request = URLComponents(url: base.appendingPathComponent("trending/movie/week"), resolvingAgainstBaseURL: true)?
            .addApiKey(apiKey)
        return agent.run(request!)
    }
    
    static func moviesDetails(_ id: Int)-> AnyPublisher<MovieDetailDTO,AFError> {
        let request = URLComponents(url: base.appendingPathComponent("movie/\(id)"), resolvingAgainstBaseURL: true)?
            .addApiKey(apiKey)
        return agent.run(request!)
    }
}

private extension URLComponents {
    func addApiKey(_ apiKey: String)-> URLComponents {
        var url = self
        url.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        return url
    }
}

// MARK: - DTOs

struct MovieDTO: Codable {
    let id: Int
    let title: String
    let poster_path: String?
    
    var poster: URL? { poster_path.map { MoviesAPI.imageBase.appendingPathComponent($0) } }
}

struct MovieDetailDTO: Codable {
    let id: Int
    let title: String
    let overview: String?
    let poster_path: String?
    let vote_average: Double?
    let genres: [GenreDTO]
    let release_date: String?
    let runtime: Int?
    let spoken_languages: [LanguageDTO]
    
    var poster: URL? { poster_path.map { MoviesAPI.imageBase.appendingPathComponent($0) } }
    
    struct GenreDTO: Codable {
        let id: Int
        let name: String
    }
    
    struct LanguageDTO: Codable {
        let name: String
    }
}

struct PageDTO<T: Codable>: Codable {
    let page: Int?
    let total_results: Int?
    let total_pages: Int?
    let results: [T]
}


