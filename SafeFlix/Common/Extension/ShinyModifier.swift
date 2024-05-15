//
//  ShinyModifier.swift
//  SafeFlix
//
//  Created by Irham Naufal on 16/05/24.
//

import SwiftUI

public struct ShinyModifier: ViewModifier {
    
    @State private var show: Bool = false

    let speed: Double
    let height: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .overlay {
                Capsule()
                    .fill(LinearGradient(colors: [.clear, .accent, .clear], startPoint: .leading, endPoint: .trailing))
                    .frame(maxWidth: .infinity, maxHeight: 14)
                    .offset(y: show ? height/2 : -(height/2))
            }
            .onAppear {
                withAnimation(.easeInOut(duration: speed).repeatForever(autoreverses: true)) {
                    self.show.toggle()
                }
            }
    }
}

public extension View {
    func shineEffect(speed: Double = 1.5, height: CGFloat) -> some View {
        return modifier(ShinyModifier(speed: speed, height: height))
    }
}

fileprivate struct ShinyPreview: View {
    var body: some View {
        
        ZStack {
            Color.black
                .frame(height: 800)
                .shineEffect(height: 800)
        }
    }
}

#Preview {
    ShinyPreview()
}
