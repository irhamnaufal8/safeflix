//
//  AppNavigator.swift
//  SafeFlix
//
//  Created by Irham Naufal on 14/05/24.
//

import SwiftUI

final class AppNavigator: ObservableObject {

    @Published var routes: [Route] = .init()

    func navigateTo(_ view: Route) {
        routes.append(view)
    }

    func back() {
        _ = routes.popLast()
    }

    func backToRoot() {
        routes = []
    }
}

enum Route {
    
}

extension Route: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.hashValue)
    }

    static func == (lhs: Route, rhs: Route) -> Bool {
        return true
    }
}

extension Route: View {
    var body: some View {
        switch self {
        default:
            return EmptyView()
        }
    }
}