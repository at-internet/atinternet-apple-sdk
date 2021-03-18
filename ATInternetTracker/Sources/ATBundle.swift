//
//  File.swift
//  Tracker iOS
//
//  Created by Théo Damaville on 15/06/2018.
//

import Foundation

func pathFor(asset: String) -> String? {
    let bundlePath = Bundle.tracker.path(forResource: "TrackerBundle", ofType: "bundle")
    if let bp = bundlePath {
        let bundle = Bundle(path: bp)
        return bundle?.path(forResource: asset, ofType: "png")
    } else {
        return nil
    }
}

extension Bundle {

    static var tracker: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: Tracker.self)
        #endif
    }

}
