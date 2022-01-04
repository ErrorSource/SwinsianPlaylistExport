//
//  Playlist.swift
//  playlistExport
//
//  Created by Georg Kemser on 15.11.21.
//

import Foundation

struct PlaylistObject: Decodable, Hashable {
    
    var id: Int!
    var name: String?
    var pindex: Int!
    var smart: Bool?
    var smartpredicate: String?
    var sortkey: String?
    var ascending: Bool?
    var folder: Bool?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlaylistObject, rhs: PlaylistObject) -> Bool {
        return lhs.id == rhs.id
    }
    
}
