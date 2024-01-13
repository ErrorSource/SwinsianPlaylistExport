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
        let actTreeNode = treeNode.children
        if (actTreeNode.first != nil && actTreeNode.count > 0) {
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
        if (!FileManager.default.fileExists(atPath: plsFolderName.absoluteString.nrmlzd())) {
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
        let plsFileName = (targetDev.devLabel == "Fenix") ? plsTrgtFolder.appendingPathComponent(nodePls.name!.fenixzd() + ".m3u") : plsTrgtFolder.appendingPathComponent(nodePls.name! + ".m3u")
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
            var trackPath = ""
            if (targetDev.devLabel == "Fenix") {
                trackPath   = (plTrack.path   != nil) ? String("\(nodePlayist.name!)/\(trackArtist) - \(URL(fileURLWithPath: plTrack.path!).lastPathComponent)").nrmlzd() : ""
				
				plContent = plContent + "#EXTINF:\(trackLength), \(trackArtist.fenixzd()) - \(trackTitle.fenixzd())\n"
				plContent = plContent + "\(trackPath.fenixzd())\n"
            } else {
                trackPath   = (plTrack.path   != nil) ? String(describing: plTrack.path!).replacingOccurrences(of: Config.musicPathLocal, with: targetDev.paths.musicPathOnServer).nrmlzd() : ""
				
				plContent = plContent + "#EXTINF:\(trackLength), \(trackArtist) - \(trackTitle)\n"
				plContent = plContent + "\(trackPath)\n"
            }
            
            // copy music file to according subfolder, if switch activated
            if (objects.copyMusicFiles) {
                // case Fenix: target subfolder is equal to playlist name
                let mfSrcFile = (plTrack.path != nil) ? String(describing: plTrack.path!).nrmlzd() : ""
                let mfTrgtFolder = (targetDev.devLabel == "Fenix") ? String("\(targetDev.paths.plsPath)/\(nodePlayist.name!)").fenixzd() : nodePlayist.name!
                
                if (mfSrcFile != "") {
                    do {
						let mfTrgtFile = (targetDev.devLabel == "Fenix") ? mfSrcFile.fenixzd() : mfSrcFile
						try copyMusicFiles(srcPath: mfSrcFile, trgtPath: mfTrgtFile, trgtFolder: mfTrgtFolder, fileNamePrefix: "\(trackArtist) - ")
                    } catch {
                        appendError(errormsg: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    return plContent
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
    
    func fenixzd() -> String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890-._/'")
		return self
			.replacingOccurrences(of: "´", with: "'", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "`", with: "'", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ä", with: "ae", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ö", with: "oe", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ü", with: "ue", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ä", with: "Ae", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ö", with: "Oe", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ü", with: "Ue", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ß", with: "ss", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ẞ", with: "Ss", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "à", with: "a", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "á", with: "a", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "â", with: "a", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "æ", with: "a", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ã", with: "a", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "å", with: "a", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ā", with: "a", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "À", with: "A", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Á", with: "A", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Â", with: "A", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Æ", with: "A", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ã", with: "A", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Å", with: "A", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ā", with: "A", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "é", with: "e", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "è", with: "e", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ê", with: "e", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ë", with: "e", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ė", with: "e", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "É", with: "E", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "È", with: "E", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ê", with: "E", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ë", with: "E", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ė", with: "E", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "î", with: "i", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ï", with: "i", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "í", with: "i", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ī", with: "i", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ì", with: "i", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Î", with: "I", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ï", with: "I", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Í", with: "I", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ī", with: "I", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ì", with: "I", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ô", with: "o", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ò", with: "o", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ó", with: "o", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "õ", with: "o", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "œ", with: "o", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ø", with: "o", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ō", with: "o", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ô", with: "O", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ò", with: "O", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ó", with: "O", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Õ", with: "O", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Œ", with: "O", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ø", with: "O", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ō", with: "O", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "û", with: "u", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ù", with: "u", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ú", with: "u", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ū", with: "u", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Û", with: "U", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ù", with: "U", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ú", with: "U", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ū", with: "U", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ś", with: "s", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "š", with: "s", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ś", with: "S", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Š", with: "S", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ÿ", with: "y", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ÿ", with: "Y", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ç", with: "c", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ć", with: "c", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "č", with: "c", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ç", with: "C", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ć", with: "C", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Č", with: "C", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ñ", with: "n", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "ń", with: "n", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ñ", with: "N", options: NSString.CompareOptions.literal, range: nil)
			.replacingOccurrences(of: "Ń", with: "N", options: NSString.CompareOptions.literal, range: nil)
			.filter { okayChars.contains($0) }
    }
    
    mutating func sanitize() -> Void {
        self = self.sanitized()
    }
    
    mutating func nrmlzd() -> Void {
        self = self.nrmlzd()
    }
    
    mutating func fenixzd() -> Void {
        self = self.fenixzd()
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
