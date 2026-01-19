//
//  RowElement.swift
//  CoffeeShop
//
//  Created by Matej Šalka on 18/01/2026.
//

import SwiftUI

struct RowElement: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
}
