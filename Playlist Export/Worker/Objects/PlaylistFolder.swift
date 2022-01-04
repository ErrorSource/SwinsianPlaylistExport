//
//  PlaylistFolder.swift
//  playlistExport
//
//  Created by Georg Kemser on 15.11.21.
//

import Foundation

struct PlaylistFolderObject: Decodable, Hashable {
    
    var id: Int!
    var folderId: Int!
    var playlistId: Int!
    var pindex: Int!
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlaylistFolderObject, rhs: PlaylistFolderObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func sortByPindex (lhs: PlaylistFolderObject, rhs: PlaylistFolderObject) -> Bool {
        return lhs.pindex == rhs.pindex
    }
    
}
