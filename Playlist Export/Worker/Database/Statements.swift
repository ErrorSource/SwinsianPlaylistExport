//
//  Statements.swift
//  playlistExport
//
//  Created by Georg Kemser on 15.11.21.
//

import Foundation
import SQLite3

func openDB() -> OpaquePointer? {
    var db: OpaquePointer?
    
    if (fileExists(Config.dbUrl)) {
        guard sqlite3_open(Config.dbUrl.path, &db) == SQLITE_OK else {
            appendError(errormsg: "Kann Swinsian-Datenbank nicht öffnen!")
            sqlite3_close(db)
            db = nil
            return nil
        }
    } else {
        appendError(errormsg: "Datenbank-Datei '\(Config.dbUrl.path)' existiert nicht!")
    }
    
    return db!
}

func closeDB(_: OpaquePointer) {
    if sqlite3_close(objects.db) != SQLITE_OK {
        appendError(errormsg: "Kann Swinsian-Datenbank nicht schließen!")
    }
    
    objects.db = nil
}

func readPlaylists() -> [PlaylistObject] {
    var playlistObjects: [PlaylistObject] = []
    var statement: OpaquePointer? = nil
    
    let sqlStatement = "SELECT playlist_id, name, pindex, smart, smartpredicate, sortkey, ascending, folder FROM playlist"
    
    if sqlite3_prepare_v2(objects.db, sqlStatement, -1, &statement, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error preparing select: \(errmsg)")
    }
    
    while sqlite3_step(statement) == SQLITE_ROW {
        // *** id
        var playlist = PlaylistObject(id: Int(sqlite3_column_int64(statement, 0)))
        
        // *** name
        if let cString = sqlite3_column_text(statement, 1) {
            let plStr = String(cString: cString)
            playlist.name = plStr
        }
        // *** pindex
        playlist.pindex = Int(exactly: sqlite3_column_int(statement, 2))
        // *** smart
        playlist.smart = (Int(exactly: sqlite3_column_int(statement, 3)) != 0) ? true : false
        // *** smartpredicate
        //playlist.smartpredicate = Raw(sqlite3_column_blob(statement, 4))
        // *** sortkey
        if let cString = sqlite3_column_text(statement, 5) {
            let plStr = String(cString: cString)
            playlist.sortkey = plStr
        }
        // *** ascending
        playlist.ascending = (Int(exactly: sqlite3_column_int(statement, 6)) != 0) ? true : false
        // *** folder
        playlist.folder = (Int(exactly: sqlite3_column_int(statement, 7)) != 0) ? true : false
        
        playlistObjects.append(playlist)
    }
    
    if sqlite3_finalize(statement) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error finalizing prepared statement: \(errmsg)")
    }
    
    statement = nil
    
    return playlistObjects
}

func readTopPlaylists() -> [TopPlaylistObject] {
    var topPlaylistObjects: [TopPlaylistObject] = []
    var statement: OpaquePointer? = nil
    
    let sqlStatement = "SELECT topplaylist_id, pindex, playlist_id FROM topplaylist"
    
    if sqlite3_prepare_v2(objects.db, sqlStatement, -1, &statement, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error preparing select: \(errmsg)")
    }
    
    while sqlite3_step(statement) == SQLITE_ROW {
        // *** id
        var topPlaylist = TopPlaylistObject(id: Int(sqlite3_column_int64(statement, 0)))
        
        // *** pindex
        topPlaylist.pindex = Int(exactly: sqlite3_column_int(statement, 1))
        // *** playlistId
        topPlaylist.playlistId = Int(exactly: sqlite3_column_int(statement, 2))
        
        
        topPlaylistObjects.append(topPlaylist)
    }
    
    if sqlite3_finalize(statement) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error finalizing prepared statement: \(errmsg)")
    }
    
    statement = nil
    
    return topPlaylistObjects
}

func readPlaylistFolders() -> [PlaylistFolderObject] {
    var playlistFolderObjects: [PlaylistFolderObject] = []
    var statement: OpaquePointer? = nil
    
    let sqlStatement = "SELECT id, playlistfolder_id, playlist_id, pindex FROM playlistfolderplaylist"
    
    if sqlite3_prepare_v2(objects.db, sqlStatement, -1, &statement, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error preparing select: \(errmsg)")
    }
    
    while sqlite3_step(statement) == SQLITE_ROW {
        // *** id
        var playlistFolder = PlaylistFolderObject(id: Int(sqlite3_column_int64(statement, 0)))
        
        // *** folderId
        playlistFolder.folderId = Int(exactly: sqlite3_column_int(statement, 1))
        // *** playlistId
        playlistFolder.playlistId = Int(exactly: sqlite3_column_int(statement, 2))
        // *** pindex
        playlistFolder.pindex = Int(exactly: sqlite3_column_int(statement, 3))
        
        playlistFolderObjects.append(playlistFolder)
    }
    
    if sqlite3_finalize(statement) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error finalizing prepared statement: \(errmsg)")
    }
    
    statement = nil
    
    return playlistFolderObjects
}

func readPlaylistTracks() -> [PlaylistTrackObject] {
    var playlistTrackObjects: [PlaylistTrackObject] = []
    var statement: OpaquePointer? = nil
    
    let sqlStatement = "SELECT id, playlist_id, track_id, tindex FROM playlisttrack"
    
    if sqlite3_prepare_v2(objects.db, sqlStatement, -1, &statement, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error preparing select: \(errmsg)")
    }
    
    while sqlite3_step(statement) == SQLITE_ROW {
        // *** id
        var playlistTrack = PlaylistTrackObject(id: Int(sqlite3_column_int64(statement, 0)))
        
        // *** playlistId
        playlistTrack.playlistId = Int(exactly: sqlite3_column_int(statement, 1))
        // *** trackId
        playlistTrack.trackId = Int(exactly: sqlite3_column_int(statement, 2))
        // *** tindex
        playlistTrack.tindex = Int(exactly: sqlite3_column_int(statement, 3))
        
        playlistTrackObjects.append(playlistTrack)
    }
    
    if sqlite3_finalize(statement) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error finalizing prepared statement: \(errmsg)")
    }
    
    statement = nil
    
    return playlistTrackObjects
}

func readTracks() -> [TrackObject] {
    var trackObjects: [TrackObject] = []
    var statement: OpaquePointer? = nil
    
    let sqlStatement = "SELECT track_id, title, artist, album, length, path FROM track"
    
    if sqlite3_prepare_v2(objects.db, sqlStatement, -1, &statement, nil) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error preparing select: \(errmsg)")
    }
    
    while sqlite3_step(statement) == SQLITE_ROW {
        // *** id
        var track = TrackObject(id: Int(sqlite3_column_int64(statement, 0)))
        
        // *** title
        if let cString = sqlite3_column_text(statement, 1) {
            let tStr = String(cString: cString)
            track.title = tStr
        }
        // *** artist
        if let cString = sqlite3_column_text(statement, 2) {
            let tStr = String(cString: cString)
            track.artist = tStr
        }
        // *** album
        if let cString = sqlite3_column_text(statement, 3) {
            let tStr = String(cString: cString)
            track.album = tStr
        }
        // *** length
        track.length = Int(exactly: sqlite3_column_int(statement, 4))
        // *** path
        if let cString = sqlite3_column_text(statement, 5) {
            let tStr = String(cString: cString)
            track.path = tStr
        }
        
        trackObjects.append(track)
    }
    
    if sqlite3_finalize(statement) != SQLITE_OK {
        let errmsg = String(cString: sqlite3_errmsg(objects.db)!)
        appendError(errormsg: "error finalizing prepared statement: \(errmsg)")
    }
    
    statement = nil
    
    return trackObjects
}
