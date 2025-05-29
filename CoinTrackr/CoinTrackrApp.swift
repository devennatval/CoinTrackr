//
//  CoinTrackrApp.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 27/05/25.
//

import SwiftUI
import SwiftData

@main
struct CoinTrackrApp: App {
    var body: some Scene {
        WindowGroup {
            EntryPointView()
        }
        .modelContainer(PersistenceController.shared.container)
    }
}
