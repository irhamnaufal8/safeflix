//
//  DetailMovieView.swift
//  SafeFlix
//
//  Created by Irham Naufal on 15/05/24.
//

import SwiftUI

struct DetailMovieView: View {
    
    @StateObject var navigator: AppNavigator
    let movie: Movie
    
    @State private var showCamera = false
    @State private var image: UIImage?
    @StateObject private var predictor = AgePredictor()
    
    @State var showAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 6, pinnedViews: .sectionHeaders) {
                    movie.poster
                        .resizable()
                        .scaledToFill()
                        .frame(height: geo.size.width)
                        .clipped()
                        .ignoresSafeArea()
                    
                    
                    (
                        Text(movie.title)
                            .bold()
                        +
                        Text(" (\(movie.year))")
                    )
                    .font(.title)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.black)
                    
                    Text("\(movie.rating.rawValue)+")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(6)
                        .padding(.horizontal, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary)
                        )
                        .padding(.bottom, 8)
                        .padding(.horizontal)
                    
                    Button {
                        watchAction()
                    } label: {
                        Text("\(Image(systemName: "play.fill"))   Watch Now")
                            .bold()
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accentColor)
                            .cornerRadius(4)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        ForEach(0...5, id: \.self) { _ in
                            Text(movie.synopsis)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
            .ignoresSafeArea()
            .alert("Uhm Sorry..", isPresented: $showAlert) {
                
            } message: {
                Text(alertMessage)
            }
        }
        .onAppear {
            AppDelegate.orientationLock = .portrait
        }
        .overlay(alignment: .topLeading) {
            Button {
                navigator.back()
            } label: {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 30, height: 30)
                    
                    Image(systemName: "chevron.left.circle.fill")
                    
                        .foregroundStyle(.ultraThinMaterial)
                        .padding(.horizontal)
                }
                .font(.largeTitle)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onChange(of: image, { _, newValue in
            predictImage(newValue)
        })
        .fullScreenCover(isPresented: $showCamera) { cameraView }
    }
}

extension DetailMovieView {
    @ViewBuilder
    var cameraView: some View {
        CameraView(image: $image) {
            showCamera = false
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showCamera = false
            } label: {
                Image(systemName: "xmark")
                    .font(.headline)
                    .padding(8)
            }
            .buttonStyle(.bordered)
            .tint(.primary)
            .clipShape(Circle())
            .padding()
        }
        .onDisappear { givePrediction() }
    }
}

extension DetailMovieView {
    func watchAction() {
        if movie.rating == .all {
            navigator.navigateTo(.videoPlayer(navigator: navigator, movie: movie))
        } else {
            showCamera = true
        }
    }
    
    func predictImage(_ image: UIImage?) {
        predictor.predictedAge = nil
        guard let image = image else { return }
        predictor.predictAge(image)
    }
    
    func givePrediction () {
        guard let age = predictor.predictedAge else { return }
        if age >= movie.rating.rawValue {
            navigator.navigateTo(.videoPlayer(navigator: navigator, movie: movie))
        } else {
            alertMessage = "You are still under age. Please watch another movie :) (Detected Age: \(age))"
            showAlert = true
        }
    }
}

#Preview {
    DetailMovieView(navigator: .init(), movie: .sample[0])
        .preferredColorScheme(.dark)
}
