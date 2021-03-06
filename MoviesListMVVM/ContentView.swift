//
//  ContentView.swift
//  MoviesListMVVM
//
//  Created by Attique Ullah on 15/06/2021.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        MoviesListView(viewModel: MoviesListViewModel())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
