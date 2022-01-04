//
//  Track.swift
//  playlistExport
//
//  Created by Georg Kemser on 16.11.21.
//

import Foundation

struct TrackObject: Decodable, Hashable {
    
    var id: Int!
    var title: String?
    var artist: String?
    var album: String?
    var length: Int?
    var path: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TrackObject, rhs: TrackObject) -> Bool {
        return lhs.id == rhs.id
    }
    
}
