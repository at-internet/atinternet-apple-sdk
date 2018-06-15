//
//  File.swift
//  Tracker iOS
//
//  Created by Théo Damaville on 15/06/2018.
//

import Foundation

func pathFor(asset: String) -> String? {
    let bundlePath = Bundle(for: Tracker.self).path(forResource: "TrackerBundle", ofType: "bundle")
    if let bp = bundlePath {
        let bundle = Bundle(path: bp)
        return bundle?.path(forResource: asset, ofType: "png")
    } else {
        return nil
    }
}
