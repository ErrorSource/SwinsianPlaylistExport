//
//  Helper.swift
//  Playlist Export
//
//  Created by Georg Kemser on 19.11.21.
//

import Foundation

func fileExists(_ url: URL) -> Bool {
    var isDir = ObjCBool(false)
    let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
    
    return exists
}
