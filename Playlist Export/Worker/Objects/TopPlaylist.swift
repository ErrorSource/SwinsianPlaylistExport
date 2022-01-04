//
//  TopPlaylist.swift
//  playlistExport
//
//  Created by Georg Kemser on 16.11.21.
//

import Foundation

struct TopPlaylistObject: Decodable, Hashable {
    
    var id: Int!
    var pindex: Int!
    var playlistId: Int!
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TopPlaylistObject, rhs: TopPlaylistObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func  < (lhs: TopPlaylistObject, rhs: TopPlaylistObject) -> Bool {
        return lhs.pindex == rhs.pindex
    }
    
}
