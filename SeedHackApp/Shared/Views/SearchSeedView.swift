//
//  SearchSeedView.swift
//  SeedHackApp (iOS)
//
//  Created by devonly on 2021/10/13.
//

import SwiftUI
import SwiftUIX
import SeedHack

struct SearchSeedView: View {
    @State var initialSeed: String?
    
    var body: some View {
        NavigationView {
            Form {
                SearchBar("Initial Seed", text: $initialSeed, onEditingChanged: { _ in
                    
                }, onCommit: {
                    
                })
            }
            .navigationTitle("Find Seed")
        }
    }
}

struct SearchSeedView_Previews: PreviewProvider {
    static var previews: some View {
        SearchSeedView()
    }
}
