//
//  Main.swift
//  Playlist Export
//
//  Created by Georg Kemser on 18.11.21.
//

import Foundation
import SwiftUI

// global variables
public class Objects {
    static let shared = Objects()
    
    public var db: OpaquePointer?
    var playlists: [PlaylistObject] = []
    var topPlaylists: [TopPlaylistObject] = []
    var playlistFolders: [PlaylistFolderObject] = []
    var playlistTracks: [PlaylistTrackObject] = []
    var tracks: [TrackObject] = []
    var playlistTree: PlaylistTree = PlaylistTree(treeId: 0)
    
    var fldToProcess: Double = 0.0
    var plsToProcess: Double = 1.0 // !
    var plsProcessed: Double = 0.0
    
    var copyMusicFiles: Bool = false
}

// intialize objects as public
public let objects = Objects()

// *** main function ***
public func export(deviceSelection: String, deleteExistingFiles: Bool, copyMusicFiles: Bool) {
    let semaphore = DispatchSemaphore(value:0)
    let queue = DispatchQueue(label:"ExportQueue", target: DispatchQueue.global(qos: .userInitiated))
    queue.async {
        // set target device to according selection of picker
        Config.allCases.forEach {
            if ($0.rawValue == deviceSelection) {
                targetDev = $0
            }
        }
        
        isProcessing(state: true)
        objects.copyMusicFiles = copyMusicFiles
        
        clearOutput()
        clearProgressBar()
        
        appendOutput(text: "Export der Swinsian Playlist-Struktur gestartet...\n")
        appendOutput(text: "Zielplattform: \(targetDev.devLabel)\n")
        
        // check, of target playlist directory exists / is available
        let trgtFolder = (targetDev.plsSubfolder != "") ? targetDev.plsUrl.appendingPathComponent(targetDev.plsSubfolder) : targetDev.plsUrl
        if (!fileExists(trgtFolder)) {
            appendError(errormsg: "Zielordner\n            '\(trgtFolder)'\n            existiert nicht oder ist nicht eingebunden!")
            isProcessing(state: false)
            return
        }
        
        if (deleteExistingFiles) {
            deleteExistingFilesAndFolders { data in
                appendOutput(text: "gelöscht!\n")
                semaphore.signal()
            }
            semaphore.wait()
            clearProgressBar()
        }
        
        // https://stackoverflow.com/questions/24102775/accessing-an-sqlite-database-in-swift
        // *** open database
        objects.db = openDB()
        
        // *** read data from database
        // playlist-data
        objects.playlists = readPlaylists()
        // playlist-data
        objects.topPlaylists = readTopPlaylists()
        // playlistFolder-data
        objects.playlistFolders = readPlaylistFolders()
        // playlistTrack-data
        objects.playlistTracks = readPlaylistTracks()
        // track-data
        objects.tracks = readTracks()
        
        // build playlist-tree
        objects.playlistTree = PlaylistTree(treeId: objects.playlists[0].id)
        initTree()
        
        // update progress-bar on ContentView()
        folderToProcess(newVal: objects.fldToProcess)
        fileToProcess(newVal: objects.plsToProcess)
        
        // process playlist-tree and create/write files and folders
        createFiles { data in
            appendOutput(text: "\n...erfolgreich beendet!\n")
            semaphore.signal()
        }
        semaphore.wait()
        
        // *** close database
        closeDB(objects.db!)
        
        isProcessing(state: false)
    }
}
