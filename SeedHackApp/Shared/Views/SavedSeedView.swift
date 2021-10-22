//
//  SavedSeedView.swift
//  SeedHackApp
//
//  Created by devonly on 2021/10/22.
//

import SwiftUI
import RealmSwift

struct SavedSeedView: View {
    @ObservedResults(RealmSeed.self, filter: NSPredicate(format: "mTitle!=nil")) var results
    
    var body: some View {
        List {
            ForEach(results) { result in
                NavigationLink(destination: DetailView(mGameSeed: UInt32(result.mGameSeed, radix: 16)!), label: {
                    Text(result.mTitle!)
                })
            }
//            .onMove(perform: $results.move)
            .onDelete(perform: $results.remove)
        }
        .toolbar(content: {
            EditButton()
        })
        .navigationTitle("Saved")
    }
}

struct SavedSeedView_Previews: PreviewProvider {
    static var previews: some View {
        SavedSeedView()
    }
}
