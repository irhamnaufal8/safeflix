//
//  Optional+orEmpty.swift
//  SafeFlix
//
//  Created by Irham Naufal on 14/05/24.
//

import Foundation

extension Optional where Wrapped == URL {
    func orEmpty() -> URL {
        return self ?? NSURL() as URL
    }
}
