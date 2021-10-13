//
//  ContentView.swift
//  Shared
//
//  Created by devonly on 2021/10/13.
//

import SwiftUI
import SeedHack

struct ContentView: View {
    var body: some View {
        TabView {
            AnalyzeSeedView()
                .tabItem({
                    Image(.analyze)
                    Text("Analyze")
                }).tag(0)
            SearchSeedView()
                .tabItem({
                    Image(.search)
                    Text("Search")
                }).tag(0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
