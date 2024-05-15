//
//  ContentView.swift
//  SafeFlix
//
//  Created by Irham Naufal on 13/03/24.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var navigator = AppNavigator()
    
    @State var searchText = ""
    
    var body: some View {
        NavigationStack(path: $navigator.routes) {
            TabView {
                HomeView(navigator: navigator, searchText: $searchText)
                    .toolbarBackground(.black, for: .tabBar)
                    .tabItem {
                        Text("Home")
                        Image(systemName: "house")
                    }
                
                Text("Profile")
                    .tabItem {
                        Text("Profile")
                        Image(systemName: "person")
                    }
            }
            .navigationDestination(for: Route.self) { $0 }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
