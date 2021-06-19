//
//  MoviesListView.swift
//  MoviesListMVVM
//
//  Created by Attique Ullah on 18/06/2021.
//

import SwiftUI
import Kingfisher

struct MoviesListView: View {
    
    @ObservedObject var viewModel: MoviesListViewModel
    @State var movieDetails: Bool = false
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitle("Trending Movies")
        }
        .onAppear { self.viewModel.send(event: .onAppear) }
    }
    
    private var content : some View {
        switch viewModel.state {
        case .idle: return Color.clear.eraseToAnyView()
        case .loading: return Spinner(isAnimating: true, style: .large).eraseToAnyView()
        case .loaded(let movies): return listView(movies: movies).eraseToAnyView()
        case .loadMovieDetail(let movieId): return MoviesDetailView(viewModel: MoviesDetailViewModel(movieID: movieId)).eraseToAnyView()
        case .error(let error) : return Text(error.localizedDescription).eraseToAnyView()
    }
    }
    
    private func listView(movies: [MoviesListViewModel.ListItem]) -> some View {
        return ScrollView {
                VStack {
                    ForEach(movies) { movie in
                        NavigationLink(
                            destination: viewModel.movieDetailView(withMovieId: movie.id),
                            label: {
                                MovieListItemView(movie: movie)
                                    .padding([.leading,.trailing],20)
                                
                            })
                    }
                }
        }
    }
}

struct MoviesListView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesListView(viewModel: MoviesListViewModel())
    }
}

struct MovieListItemView: View {
    let movie: MoviesListViewModel.ListItem
    let processor = DownsamplingImageProcessor(size: CGSize(width: 50, height: 100))
                 |> RoundCornerImageProcessor(cornerRadius: 10)
    
    var body: some View {
        HStack {
            poster
            title
            arrow
            
        }
        .frame(height: 100)
    }
    
    private var title: some View {
        Text(movie.title)
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .frame(idealWidth: .infinity, maxWidth: .infinity, alignment: .leading)
    }
    
    private var poster: some View {
        movie.poster.map { url in
            KFImage(url)
                .placeholder({ spinner })
                .setProcessor(processor)
                .cacheMemoryOnly()
                .fade(duration: 0.25)
            
            //AsyncImage(url: url, placeholder: { Text("Loading ...") }, image: { Image(uiImage: $0).resizable() })
        }
        .aspectRatio(contentMode: .fit)
        .frame(idealHeight: 100)
    }
    
    private var arrow: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 25))
            .foregroundColor(.gray)
            .opacity(0.6)
        
        
    }
    private var spinner: some View {
        VStack {
            Spinner(isAnimating: true, style: .medium)
        }
        .frame(width: 50, height: 100, alignment: .center)
        .background(Color.gray)
        .opacity(0.2)
        .cornerRadius(10)
    }
}

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
