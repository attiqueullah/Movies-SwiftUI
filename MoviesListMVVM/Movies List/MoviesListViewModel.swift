//
//  MoviesListViewModel.swift
//  MoviesListMVVM
//
//  Created by Attique Ullah on 16/06/2021.
//

import Foundation
import SwiftUI
import Combine

class MoviesListViewModel : ObservableObject {
    
    @Published var state : State = .idle
   
    private var bag = Set<AnyCancellable>()
    private let input = PassthroughSubject<Event, Never>()
    
    init() {
        Publishers.system(initial: state, reduce: MoviesListViewModel.reduce, scheduler: RunLoop.main,
                          feedbacks: [MoviesListViewModel.whenLoading(),MoviesListViewModel.userInput(input: input.eraseToAnyPublisher())])
            .assign(to: \.state, on: self)
            .store(in: &bag)
    }
    
    deinit {
        bag.removeAll()
    }
    
    func send(event: Event) {
        input.send(event)
    }
}

// MARK: - Inner Types

extension MoviesListViewModel {
    enum State {
        case idle
        case loading
        case loaded([ListItem])
        case loadMovieDetail(Int)
        case error(Error)
    }
    
    enum Event {
        case onAppear
        case onSelectMovie(Int)
        case onMoviesLoaded([ListItem])
        case onFailedToLoadMovies(Error)
    }
    
    struct ListItem: Identifiable {
        let id: Int
        let title: String
        let poster: URL?
        
        init(movie: MovieDTO) {
            id = movie.id
            title = movie.title
            poster = movie.poster
        }
    }
}

// MARK: - Inner Types

extension MoviesListViewModel {
    
    static func reduce(_ state: State, _ event: Event) -> State {
        switch state {
        case .idle:
            switch event {
            case .onAppear:
                return .loading
            default:
                return state
            }
        case .loading:
            switch event {
            case .onMoviesLoaded(let movies):
                return .loaded(movies)
            case .onFailedToLoadMovies(let error):
                return .error(error)
            default:
                return state
            }
        case .loaded:
            switch event {
            case .onSelectMovie(let movieId):
                return .loadMovieDetail(movieId)
            default:
                return state
            }
        case .loadMovieDetail(_):
            return state
        case .error: return state
        
        }
    }
    static func whenLoading() -> Feedback<State,Event>{
        Feedback { (state: State) -> AnyPublisher<Event,Never> in
            guard case .loading = state else {
                return Empty().eraseToAnyPublisher()
            }
            
            return MoviesAPI.trending()
                    .map { $0.results.map(ListItem.init) }
                    .map(Event.onMoviesLoaded)
                    .catch { Just(Event.onFailedToLoadMovies($0)) }
                    .eraseToAnyPublisher()
        }
    }
    
    static func userInput(input: AnyPublisher<Event, Never>) -> Feedback<State, Event> {
        Feedback (run: { _ in input })
    }
}

extension MoviesListViewModel {
    func movieDetailView(withMovieId ID: Int) -> some View {
        return MovieBuilder.makeMovieDetailView(withMovieId: ID)
    }
}

enum MovieBuilder {
  static func makeMovieDetailView(withMovieId ID: Int) -> some View {
    let viewModel = MoviesDetailViewModel(movieID: ID)
    return MoviesDetailView(viewModel: viewModel)
  }
}
