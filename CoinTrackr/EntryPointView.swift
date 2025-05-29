//
//  EntryPointView.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 29/05/25.
//

import SwiftUI

struct EntryPointView: View {
    @Environment(\.modelContext) private var context

    var body: some View {
        PortfolioView(viewModel: .init(context: context))
    }
}
