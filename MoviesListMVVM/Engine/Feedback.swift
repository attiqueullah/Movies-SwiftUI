//
//  Feedback.swift
//  MoviesListMVVM
//
//  Created by Attique Ullah on 16/06/2021.
//

import Foundation
import Combine

struct Feedback<State , Event> {
    let run : (AnyPublisher<State, Never>) -> AnyPublisher<Event, Never>
}

extension Feedback {
    init<Effect: Publisher>(effects: @escaping (State) -> Effect ) where Effect.Output == Event, Effect.Failure == Never {
        self.run = { state -> AnyPublisher<Event, Never> in
            state
                .map { state -> Effect in
                    return effects(state)
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
    }
}
