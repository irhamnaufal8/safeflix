//
//  HomeView.swift
//  SafeFlix
//
//  Created by Irham Naufal on 14/05/24.
//

import SwiftUI

struct HomeView: View {
    
    @State var navigator: AppNavigator
    
    @State var banners = Movie.sample
    @State var bannerSelection = 0
    
    @State var movies = Movie.sample
    @Binding var searchText: String
    
    var body: some View {
        NavigationView {
            GeometryReader { geo in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        bannerSection(geo: geo)
                        popularSection
                        popularSection
                        popularSection
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack(spacing: 0) {
                            Text("Safe")
                            Text("Flix.")
                                .foregroundStyle(.accent)
                        }
                        .font(.title2)
                        .bold()
                        .italic()
                    }
                }
            }
            .toolbarBackground(.black, for: .navigationBar)
        }
        .searchable(text: $searchText)
    }
}

extension HomeView {
    @ViewBuilder
    func bannerSection(geo: GeometryProxy) -> some View {
        VStack {
            TabView(selection: $bannerSelection) {
                ForEach(banners.indices, id: \.self) { index in
                    banners[index].poster
                        .resizable()
                        .scaledToFill()
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: geo.size.width * 9/16)
            
            HStack {
                ForEach(banners.indices, id: \.self) { index in
                    Capsule()
                        .fill(bannerSelection == index ? Color.accentColor : Color.secondary)
                        .frame(width: bannerSelection == index ? 24 : 8, height: 8)
                        .animation(.spring, value: bannerSelection)
                }
            }
        }
    }
    
    @ViewBuilder
    var popularSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(movies) { movie in
                        NavigationLink {
                            Text(movie.title)
                        } label: {
                            movie.poster
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                .padding(.horizontal)
            }
        } header: {
            Text("Popular")
                .font(.headline)
                .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
