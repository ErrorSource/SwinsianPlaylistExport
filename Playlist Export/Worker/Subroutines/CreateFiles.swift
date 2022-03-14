//
//  CreateFiles.swift
//  playlistExport
//
//  Created by Georg Kemser on 18.11.21.
//

import Foundation

func createFiles(completion: @escaping(Data?) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async() {
        if (targetDev.plsFolderStartId == 0) {
            iterateTree(treeNode: objects.playlistTree, depth: 0, trgtPath: "")
        } else {
            // get desired topNode
            if (objects.playlistTree.children.count > 0) {
                for (node) in objects.playlistTree.children {
                    if (node.treeId == targetDev.plsFolderStartId) {
                        iterateTree(treeNode: node, depth: 0, trgtPath: "")
                    }
                }
            }
        }
        
        completion(Data())
    }
}

func iterateTree(treeNode: PlaylistTree, depth: Int, trgtPath: String) {
    let nodeDepth = depth + 1
    
    if (treeNode.children.count > 0 && nodeDepth < 99) { // little safety
        for (node) in treeNode.children {
            if (node.children.count > 0) {
                // current node is a FOLDER/DIRECTORY
                appendOutput(text: "📁 \(String(repeating: " ", count: 4 * nodeDepth)) \(objects.playlists.filter({ $0.id == node.treeId }).first!.name!)")
                
                // set directory-name/-depth
                let dirName = objects.playlists.filter({ $0.id == node.treeId }).first!.name
                let nodePath = (trgtPath != "") ? trgtPath + "/" + dirName! : dirName!
                
                // create subfolder, of not exists
                createSubFolder(subDir: nodePath)
                
                // recursion
                iterateTree(treeNode: node, depth: nodeDepth, trgtPath: nodePath)
            } else {
                // current node is a FILE
                appendOutput(text: "🎶 \(String(repeating: " ", count: 4 * nodeDepth)) \(objects.playlists.filter({ $0.id == node.treeId }).first!.name!)")
                
                writePlsFile(treeNode: node, subDir: trgtPath)
                
                // update progress-bar on ContentView()
                objects.plsProcessed += 1
                filesProcessed(newVal: objects.plsProcessed)
            }
        }
        // additional write folder playlist file (necessary for ownTone to find playlists in subfolders)
        let actTreeNode = treeNode.children.first
//        if (actTreeNode != nil && actTreeNode!.children.count > 0) {
        if (actTreeNode != nil && treeNode.children.count > 0) {
            writeFolderPlsFile(treeNode: treeNode, actDir: trgtPath)
        }
    }
}

func createSubFolder(subDir: String) {
    if (subDir != "") {
        // define target path
        let plsRootFolder = (targetDev.plsSubfolder != "") ? targetDev.plsUrl.appendingPathComponent(targetDev.plsSubfolder) : targetDev.plsUrl
        let plsFolderName = plsRootFolder.appendingPathComponent(subDir)
        
        // create directory, if not exists
        if !FileManager.default.fileExists(atPath: plsFolderName.absoluteString.nrmlzd()) {
            do {
                try FileManager.default.createDirectory(atPath: plsFolderName.path.nrmlzd(), withIntermediateDirectories: true, attributes: nil)
            } catch {
                appendError(errormsg: error.localizedDescription)
            }
        }
    }
}

func writePlsFile(treeNode: PlaylistTree, subDir: String) {
    // get according playlist
    let nodePls = objects.playlists.filter({ $0.id == treeNode.treeId }).first!
    
    // create file-content
    let plContent = createPlaylistContent(nodePlayist: nodePls)
    
    // write to playlist-file
    do {
        // open path
        let plsRootFolder = (targetDev.plsSubfolder != "") ? targetDev.plsUrl.appendingPathComponent(targetDev.plsSubfolder) : targetDev.plsUrl
        let plsTrgtFolder = (subDir != "") ? plsRootFolder.appendingPathComponent(subDir) : plsRootFolder
        let plsFileName = plsTrgtFolder.appendingPathComponent(nodePls.name! + ".m3u")
        try plContent.write(to: plsFileName.nrmlzd(), atomically: true, encoding: String.Encoding.utf8)
    } catch {
        appendError(errormsg: error.localizedDescription)
    }
}

func writeFolderPlsFile(treeNode: PlaylistTree, actDir: String) {
    var plFolderContent = "#EXTM3U\n" // header
    if (treeNode.children.count > 0) {
        for (node) in treeNode.children {
            if (node.children.count > 0) {
                let actTreeNode = node.children
                // get according playlist
                let nodePls = objects.playlists.filter({ $0.id == node.treeId }).first!
                if (actTreeNode.count > 0) {
                    for (subNode) in actTreeNode {
                        let subNodePls = objects.playlists.filter({ $0.id == subNode.treeId }).first!
                        let plsRootFolder = (targetDev.plsSubfolder != "") ? URL(fileURLWithPath: targetDev.paths.plsPathOnServer).appendingPathComponent(targetDev.plsSubfolder) : URL(fileURLWithPath: targetDev.paths.plsPathOnServer)
                        let plsTrgtFolder = (actDir != "") ? plsRootFolder.appendingPathComponent(actDir) : plsRootFolder
                        let plsFolderFilePlaylists = plsTrgtFolder.appendingPathComponent(nodePls.name!).appendingPathComponent(subNodePls.name! + ".m3u")
                        plFolderContent = plFolderContent + "\(plsFolderFilePlaylists.path.nrmlzd())\n"
                    }
                    
                    if (plFolderContent != "#EXTM3U\n") {
                        // write to playlist-folder-file
                        do {
                            // open path
                            let plsRootFolder = (targetDev.plsSubfolder != "") ? targetDev.plsUrl.appendingPathComponent(targetDev.plsSubfolder) : targetDev.plsUrl
                            let plsTrgtFolder = (actDir != "") ? plsRootFolder.appendingPathComponent(actDir) : plsRootFolder
                            let plsFileName = plsTrgtFolder.appendingPathComponent(nodePls.name! + ".m3u")
                            try plFolderContent.write(to: plsFileName.nrmlzd(), atomically: true, encoding: String.Encoding.utf8)
                        } catch {
                            appendError(errormsg: error.localizedDescription)
                        }
                        
                        // reset folderfile-content
                        plFolderContent = "#EXTM3U\n" // header
                    }
                }
            }
        }
    }
}

func createPlaylistContent(nodePlayist: PlaylistObject) -> String {
    var plContent = "#EXTM3U\n" // header
    
    // get tracks to playlist
    let nodeTracks = objects.playlistTracks.filter({ $0.playlistId == nodePlayist.id })
    if (nodeTracks.first != nil) {
        var sortedTracks: [TrackObject] = []
        // first push all according tracks into array to sort them later (tindex == default sorting)
        for (plTrack) in nodeTracks.sorted(by: \.tindex) {
            // get track-object
            let track = objects.tracks.filter({ $0.id == plTrack.trackId }).first!
            sortedTracks.append(track)
        }
        
        // sort array, if sortkey given
        if let sortKey = nodePlayist.sortkey {
            if (sortKey != sortBy.tindex) {
                sortedTracks = sortTracksByKey(tracks: sortedTracks, sortKey: sortKey, ascending: nodePlayist.ascending!)
            }
        }
        
        for (plTrack) in sortedTracks {
            let trackLength = (plTrack.length != nil) ? String(describing: Int(plTrack.length!)) : "0"
            let trackArtist = (plTrack.artist != nil) ? String(describing: plTrack.artist!) : ""
            let trackTitle  = (plTrack.title  != nil) ? String(describing: plTrack.title!) : ""
            // precomposedStringWithCompatibilityMapping: convert UTF-8-MAC encoding to UTF-8 (standard) (UTF-8 NFD to UTF-8 NFC)
            // (see https://stackoverflow.com/questions/68173237/normalizing-composing-and-decomposing-utf8-strings-in-swift)
            // sanitized: some characters in filenames are not "optimal" → replace them
            let trackPath   = (plTrack.path   != nil) ? String(describing: plTrack.path!).replacingOccurrences(of: Config.musicPathLocal, with: targetDev.paths.musicPathOnServer).nrmlzd() : ""
            plContent = plContent + "#EXTINF:\(trackLength), \(trackArtist) - \(trackTitle)\n"
            plContent = plContent + "\(trackPath)\n"
        }
    }
    
    return plContent
}

func sortTracksByKey(tracks: [TrackObject], sortKey: String, ascending: Bool) -> [TrackObject] {
    switch sortKey {
    case sortBy.artist:
        return tracks.sorted(by: {
            guard let sortKey0_1 = $0.artist, let sortKey1_1 = $1.artist, let sortKey0_2 = $0.disc, let sortKey1_2 = $1.disc, let sortKey0_3 = $0.trackNumber, let sortKey1_3 = $1.trackNumber else { return false }
            if (sortKey0_1 != sortKey1_1) {
                return (ascending) ? sortKey0_1 < sortKey1_1 : sortKey0_1 > sortKey1_1
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
                return (ascending) ? sortKey0_1 < sortKey1_1 : sortKey0_1 > sortKey1_1
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
            return (ascending) ? sortKey0 < sortKey1 : sortKey0 > sortKey1
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

extension String {
    // replace special characters, which are bad for filenames
    func sanitized() -> String {
        return self
            .replacingOccurrences(of: "?",  with: "", options: NSString.CompareOptions.literal, range: nil) // questionmark in pathname is not good ;o)
            .replacingOccurrences(of: ":",  with: "", options: NSString.CompareOptions.literal, range: nil)
            .replacingOccurrences(of: " ́",  with: "´",  options: NSString.CompareOptions.literal, range: nil) // these accents are not the same!
            .replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
    }
    
    func nrmlzd() -> String {
        return self.precomposedStringWithCompatibilityMapping.sanitized()
    }
    
    mutating func sanitize() -> Void {
        self = self.sanitized()
    }
    
    mutating func nrmlzd() -> Void {
        self = self.nrmlzd()
    }
}

extension URL {
    func nrmlzd() -> URL {
//        let urlString = self.absoluteString.precomposedStringWithCompatibilityMapping
//        // seperate url-string by "file://" and the rest (avoid replacing char ":" with sanitized()
//        let urlParts = urlString.components(separatedBy: ":///")
//        let newUrl = "\(urlParts[0]):///\(urlParts[1].sanitized())" // <- not working
//        print("gk76: newUrl", newUrl)
//        print("gk76: URL", URL(string: newUrl))
        
        // gk76: sanitized not neccessary here?
        return URL(string: self.absoluteString.precomposedStringWithCompatibilityMapping)!
    }
}
