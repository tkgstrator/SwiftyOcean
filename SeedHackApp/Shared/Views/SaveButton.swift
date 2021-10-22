//
//  SaveButton.swift
//  SeedHackApp
//
//  Created by devonly on 2021/10/22.
//

import SwiftUI

struct SaveButton: View {
    let mGameSeed: String
    @State var isPresented: Bool = false
    
    var body: some View {
        Button(action: {
            isPresented.toggle()
        }, label: {
            Image(.plus)
                .resizable()
                .aspectRatio(contentMode: .fit)
        })
            .sheet(isPresented: $isPresented, onDismiss: {}, content: {
                SaveView(mGameSeed: mGameSeed)
            })
    }
    
    struct SaveView: View {
        let mGameSeed: String
        @State var mTitle: String = ""
        @Environment(\.dismiss) var dismiss
    
        init(mGameSeed: String) {
            self.mGameSeed = mGameSeed
            if let object = SeedManager.shared.object(RealmSeed.self, forPrimaryKey: mGameSeed), let mTitle = object.mTitle {
                self._mTitle = State(initialValue: mTitle)
            } else {
                self._mTitle = State(initialValue: "")
            }
        }
        
        var body: some View {
            NavigationView {
                List {
                    TextField("Memo", text: $mTitle)
                    Button(action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            dismiss()
                        })
                        let object: RealmSeed? = SeedManager.shared.object(RealmSeed.self, forPrimaryKey: mGameSeed)
                        if let object = object {
                            SeedManager.shared.updateMemo(object, memo: mTitle)
                        } else {
                            let object: RealmSeed = RealmSeed(mGameSeed: mGameSeed, memo: mTitle)
                            SeedManager.shared.save(object)
                        }
                    }, label: {
                        Text("Save")
                    })
                }
                .navigationTitle(String(format: "%08X", UInt32(mGameSeed, radix: 16)!))
            }
        }
    }
}



struct SaveButton_Previews: PreviewProvider {
    static var previews: some View {
        SaveButton(mGameSeed: "12345678")
    }
}
