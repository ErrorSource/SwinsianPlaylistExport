//
//  PlaylistTrack.swift
//  playlistExport
//
//  Created by Georg Kemser on 16.11.21.
//

import Foundation

struct PlaylistTrackObject: Decodable, Hashable {
    
    var id: Int!
    var playlistId: Int!
    var trackId: Int!
    var tindex: Int!
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlaylistTrackObject, rhs: PlaylistTrackObject) -> Bool {
        return lhs.id == rhs.id
    }
    
    func sortByTindex (lhs: PlaylistTrackObject, rhs: PlaylistTrackObject) -> Bool {
        return lhs.tindex == rhs.tindex
    }
    
}
