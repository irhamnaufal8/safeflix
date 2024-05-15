//
//  VideoPlayerView.swift
//  SafeFlix
//
//  Created by Irham Naufal on 15/05/24.
//

import SwiftUI
import WebKit

struct VideoPlayer: UIViewRepresentable {
    
    var url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        AppDelegate.orientationLock = .landscape
        uiView.scrollView.isScrollEnabled = false
        uiView.load(URLRequest(url: url))
    }
}

struct VideoPlayerView: View {
    
    @StateObject var navigator: AppNavigator
    let movie: Movie
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VideoPlayer(url: movie.videoURL)
                .ignoresSafeArea()
            
            Button {
                navigator.back()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                    
                    Text(movie.title)
                        .lineLimit(1)
                }
                .font(.title)
                .bold()
                .shadow(color: .black.opacity(0.05), radius: 10)
                .padding(.top, 6)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            AppDelegate.orientationLock = .landscape
        }
    }
}

#Preview {
    VideoPlayerView(navigator: .init(), movie: Movie.sample[0])
        .preferredColorScheme(.dark)
}
