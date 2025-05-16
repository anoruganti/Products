//
//  ContentView.swift
//  ProductList
//
//  Created by Anil Oruganti on 11/05/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            
            Image(systemName: "cloud.heavyrain")
            .font(.system(size: 100))
            .foregroundColor(.blue)
            .shadow(color: .gray, radius: 10, x: 0, y: 10)
            .clipShape(Circle())
            .padding(60)

            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
