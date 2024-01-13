//
//  CopyMusicFiles.swift
//  Playlist Export
//
//  Created by Georg Kemser on 05.08.22.
//

import Foundation

func copyMusicFiles(srcPath: String, trgtPath: String, trgtFolder: String, fileNamePrefix: String) throws {
    if (srcPath.isEmpty || trgtPath.isEmpty || trgtFolder.isEmpty) {
        appendError(errormsg: "copyMusicFiles: Either src or dest is empty!")
        return
    }
    
    // create directory, if not exists
    if (!FileManager.default.fileExists(atPath: trgtFolder)) {
        do {
            try FileManager.default.createDirectory(atPath: trgtFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            appendError(errormsg: error.localizedDescription)
            throw error
        }
    }
    
    let srcURL  = URL(fileURLWithPath: srcPath)
	let trgtURL = URL(fileURLWithPath: trgtPath)
    let dstURL  = URL(fileURLWithPath: "\(trgtFolder)/\(fileNamePrefix)\(trgtURL.lastPathComponent)")
    
    // try to copy music-file
    if (!FileManager.default.fileExists(atPath: dstURL.path)) {
        do {
            try FileManager.default.copyItem(atPath: srcURL.path, toPath: dstURL.path)
        } catch {
            appendError(errormsg: error.localizedDescription)
            throw error
        }
    }
}
