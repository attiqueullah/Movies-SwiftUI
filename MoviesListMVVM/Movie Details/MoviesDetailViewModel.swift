//
//  MoviesDetailViewModel.swift
//  MoviesListMVVM
//
//  Created by Attique Ullah on 19/06/2021.
//

import Foundation
import Combine
import Kingfisher

class MoviesDetailViewModel : ObservableObject {
    @Published private(set) var state: State
    
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init(movieID: Int) {
        self.state = .idle(movieID)
        
        Publishers.system(initial: .idle(movieID), reduce: MoviesDetailViewModel.reduce, scheduler: RunLoop.main, feedbacks: [MoviesDetailViewModel.whenLoading(),MoviesDetailViewModel.userInput(input: self.input.eraseToAnyPublisher())])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }
    
    func send(event: Event) {
        input.send(event)
    }
}
private extension MoviesDetailViewModel {
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle(let id):
            switch event {
            case .onAppear:
                return .loading(id)
            default:
                return state
            }
        case .loading:
            switch event {
            case .onFailedToLoad(let error):
                return .error(error)
            case .onLoaded(let movie):
                return .loaded(movie)
            default:
                return state
            }
        case .loaded:
            return state
        case .error:
            return state
            
        }
    }
    
    static func whenLoading() -> Feedback<State,Event>{
        Feedback (effects: { state -> AnyPublisher<Event,Never> in
            guard case .loading(let id) = state else  { return Empty().eraseToAnyPublisher() }
            
            return MoviesAPI.moviesDetails(id)
                .map(MovieDetail.init)
                .map(Event.onLoaded)
                .catch { Just(Event.onFailedToLoad($0)) }
                .eraseToAnyPublisher()
        })
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback(run:{ _ in input})
    }
}
// MARK: - Inner Types

extension MoviesDetailViewModel {
    enum State {
        case idle(Int)
        case loading(Int)
        case loaded(MovieDetail)
        case error(Error)
    }
    
    enum Event {
        case onAppear
        case onLoaded(MovieDetail)
        case onFailedToLoad(Error)
    }
    
    struct MovieDetail {
        let id: Int
        let title: String
        let overview: String?
        let poster: URL?
        let rating: Double?
        let duration: String
        let genres: [String]
        let releasedAt: String
        let language: String
        
        init(movie: MovieDetailDTO) {
            id = movie.id
            title = movie.title
            overview = movie.overview
            poster = movie.poster
            rating = movie.vote_average
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = [.minute, .hour]
            duration = movie.runtime.flatMap { formatter.string(from: TimeInterval($0 * 60)) } ?? "N/A"
            
            genres = movie.genres.map(\.name)
            
            releasedAt = movie.release_date ?? "N/A"
            
            language = movie.spoken_languages.first?.name ?? "N/A"
        }
    }
}
