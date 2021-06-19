//
//  MoviesDetailView.swift
//  MoviesListMVVM
//
//  Created by Attique Ullah on 19/06/2021.
//

import SwiftUI
import Combine
import  Kingfisher

struct MoviesDetailView: View {
    @ObservedObject var viewModel: MoviesDetailViewModel
    @Environment(\.imageCache) var cache: ImageCache

    var body: some View {
        content
            .onAppear { self.viewModel.send(event: .onAppear) }
    }
    
    private var content: some View {
        switch viewModel.state {
        case .idle:
            return Color.clear.eraseToAnyView()
        case .loading:
            return spinner.eraseToAnyView()
        case .error(let error):
            return Text(error.localizedDescription).eraseToAnyView()
        case .loaded(let movie):
            return self.movie(movie).eraseToAnyView()
        }
    }
    
    private func movie(_ movie: MoviesDetailViewModel.MovieDetail) -> some View {
        ScrollView {
            VStack {
                fillWidth
                
                Text(movie.title)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                             
                Divider()

                HStack {
                    Text(movie.releasedAt)
                    Text(movie.language)
                    Text(movie.duration)
                }
                .font(.subheadline)
                
                poster(of: movie)
                                
                genres(of: movie)
                
                Divider()

                movie.rating.map {
                    Text("⭐️ \(String($0))/10").font(.body)
                }
                
                Divider()

                movie.overview.map {
                    Text($0).font(.body)
                }
            }
        }
    }
    
    private var fillWidth: some View {
        HStack {
            Spacer()
        }
    }
    
    private func poster(of movie: MoviesDetailViewModel.MovieDetail) -> some View {
        
        movie.poster.map { url in
            
            KFImage(url)
                .resizable()
                .placeholder({ spinner })
                .cacheMemoryOnly()
                .fade(duration: 0.25)
                
        }
        .aspectRatio(contentMode: .fit)
    }
    
    private var spinner: Spinner { Spinner(isAnimating: true, style: .large) }
    
    private func genres(of movie: MoviesDetailViewModel.MovieDetail) -> some View {
        HStack {
            ForEach(movie.genres, id: \.self) { genre in
                Text(genre)
                    .padding(5)
                    .border(Color.gray)
            }
        }
    }
}

struct MoviesDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesDetailView(viewModel: MoviesDetailViewModel(movieID: 0))
    }
}
