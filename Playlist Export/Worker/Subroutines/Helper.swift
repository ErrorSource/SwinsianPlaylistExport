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

func sortTracksByKey(tracks: [TrackObject], sortKey: String, ascending: Bool) -> [TrackObject] {
	switch sortKey {
	case sortBy.artist:
		return tracks.sorted(by: {
			guard let sortKey0_1 = $0.artist, let sortKey1_1 = $1.artist, let sortKey0_2 = $0.disc, let sortKey1_2 = $1.disc, let sortKey0_3 = $0.trackNumber, let sortKey1_3 = $1.trackNumber else { return false }
			if (sortKey0_1 != sortKey1_1) {
				if (ascending) {
					return sortKey0_1.localizedCaseInsensitiveContains(sortKey1_1)
				} else {
					return sortKey1_1.localizedCaseInsensitiveContains(sortKey0_1)
				}
			} else {
				if (sortKey0_2 != sortKey1_2) {
					return sortKey0_2 < sortKey1_2
				} else {
					return sortKey0_3 < sortKey1_3
				}
			}
		})
	case sortBy.album:
		return tracks.sorted(by: {
			guard let sortKey0_1 = $0.album, let sortKey1_1 = $1.album, let sortKey0_2 = $0.disc, let sortKey1_2 = $1.disc, let sortKey0_3 = $0.trackNumber, let sortKey1_3 = $1.trackNumber else { return false }
			if (sortKey0_1 != sortKey1_1) {
				if (ascending) {
					return sortKey0_1.localizedCaseInsensitiveContains(sortKey1_1)
				} else {
					return sortKey1_1.localizedCaseInsensitiveContains(sortKey0_1)
				}
			} else {
				if (sortKey0_2 != sortKey1_2) {
					return sortKey0_2 < sortKey1_2
				} else {
					return sortKey0_3 < sortKey1_3
				}
			}
		})
	case sortBy.title:
		return tracks.sorted(by: {
			guard let sortKey0 = $0.title, let sortKey1 = $1.title else { return false }
			if (ascending) {
				return sortKey0.localizedCaseInsensitiveContains(sortKey1)
			} else {
				return sortKey1.localizedCaseInsensitiveContains(sortKey0)
			}
		})
	case sortBy.trackNumber:
		return tracks.sorted(by: {
			guard let sortKey0 = $0.trackNumber, let sortKey1 = $1.trackNumber else { return false }
			return (ascending) ? sortKey0 < sortKey1 : sortKey0 > sortKey1
		})
	case sortBy.disc:
		return tracks.sorted(by: {
			guard let sortKey0_1 = $0.disc, let sortKey1_1 = $1.disc, let sortKey0_2 = $0.trackNumber, let sortKey1_2 = $1.trackNumber else { return false }
			if (sortKey0_1 != sortKey1_1) {
				return (ascending) ? sortKey0_1 < sortKey1_1 : sortKey0_1 > sortKey1_1
			} else {
				return sortKey0_2 < sortKey1_2
			}
		})
	case sortBy.dateAdded:
		return tracks.sorted(by: {
			guard let sortKey0 = $0.dateAdded, let sortKey1 = $1.dateAdded else { return false }
			return (ascending) ? sortKey0 < sortKey1 : sortKey0 > sortKey1
		})
	case sortBy.dateModified:
		return tracks.sorted(by: {
			guard let sortKey0 = $0.dateModified, let sortKey1 = $1.dateModified else { return false }
			return (ascending) ? sortKey0 < sortKey1 : sortKey0 > sortKey1
		})
	default:
		return tracks
	}
}
