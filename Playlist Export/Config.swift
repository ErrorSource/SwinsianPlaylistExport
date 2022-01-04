//
//  Config.swift
//  Playlist Export
//
//  Created by Georg Kemser on 18.11.21.
//

import Foundation

let DEBUG = true

let DELETE_EXISTING_FILES_BEFORE_EXPORT = true

// default target device (Mucke or RPiCar)
var targetDev = Config.Mucke

// general config
public enum Config: String, CaseIterable, Identifiable {
    case Mucke
    case RPiCar
    case Local
    
    public var id: Config { self }
    
    public var devLabel: (_: String) {
        switch self {
        case .Mucke:
            return ("Mucke")
        case .RPiCar:
            return ("RPiCar")
        case .Local:
            return ("Lokal/Fenix")
        }
    }
    
    // path to Swinsian SQLite3-DB
    static let dbPath = "/Users/georg/Library/Application Support/Swinsian/Library.sqlite"
    static let dbUrl  = URL(fileURLWithPath: Config.dbPath)
    
    // "local" path to music library on hades; "local" means SMB-path to it (/Volumes/...)
    static let musicPathLocal = "/Volumes/Mucke/Music"
    
    // playlist-folder ID to begin with
    // (set to 0, if ALL folders should be processed)
    // (get ID with *DB Browser for SQLite* → /Users/georg/Library/Application Support/Swinsian/Library.sqlite → playlist → pindex = 0 (= only topplaylist-items supported!))
    var plsFolderStartId: (_: Int) {
        switch self {
        case .Mucke:
            return (1)
        case .RPiCar:
            return (121)
        case .Local:
            return (121)
        }
    }
    
    var paths: (plsPath: String, plsPathOnServer: String, musicPathOnServer: String) {
        switch self {
        case .Mucke:
            return (
                // plsPath (location of playlist-directory)
                "/Volumes/Mucke/Playlists",
                // plsPathOnServer
                "/media/Playlists",
                // musicPathOnServer
                "/media/Music"
            )
            
        case .RPiCar:
            return (
                // plsPath (location of playlist-directory)
                "/Volumes/Mucke/RPiCar/Playlists",
                // plsPathOnServer
                "/media/usbstick/Music/Playlists",
                // musicPathOnServer
                "/media/usbstick/Music"
            )
            
        case .Local:
            return (
                // plsPath (location of playlist-directory)
                "/Users/georg/Music/Playlists",
                // plsPathOnServer
                "/Users/georg/Music/Playlists",
                // musicPathOnServer
                "/Volumes/Mucke/Music"
            )
        }
    }
    
    // plsSubfolder (subfolder off servers playlist-folder, where to put export-files beneath; leave empty for playlists root-folder!)
    var plsSubfolder: (_: String) {
        switch self {
        case .Mucke:
            return ("")
        case .RPiCar:
            return ("")
        case .Local:
            return ("")
        }
    }
    
    var plsPathLocal: (_: String) {
        return (self.paths.plsPath)
    }
    
    var plsUrl: (_: URL) {
        return (URL(fileURLWithPath: self.paths.plsPath))
    }
}
