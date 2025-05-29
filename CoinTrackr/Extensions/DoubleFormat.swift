//
//  DoubleFormat.swift
//  CoinTrackr
//
//  Created by Deven Nathanael on 29/05/25.
//

import Foundation

extension Double {
    var trimDecimal: String {
        let absValue = abs(self)
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0

        let magnitude = absValue >= 1 ? log10(absValue) : 0
        let digits = max(0, 8 - Int(magnitude.rounded(.down)))
        formatter.maximumFractionDigits = min(digits, 8)

        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
