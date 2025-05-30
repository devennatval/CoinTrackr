//
//  StringExtension.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 30/05/25.
//

import Foundation

extension String {
    var localizedDouble: Double? {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .decimal
        return formatter.number(from: self)?.doubleValue
    }
}
