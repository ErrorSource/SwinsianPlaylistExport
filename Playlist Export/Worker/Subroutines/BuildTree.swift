//
//  BuildTree.swift
//  playlistExport
//
//  Created by Georg Kemser on 17.11.21.
//

import Foundation

func initTree() {
    for (rootPlaylist) in objects.topPlaylists.sorted(by: \.pindex) {
        let filterId = (targetDev.plsFolderStartId != 0) ? targetDev.plsFolderStartId : rootPlaylist.playlistId
        let topNode = objects.playlists.filter({ $0.id == filterId }).first
        
        // first, add every root playlist
        let treeNode = PlaylistTree(treeId: (topNode?.id)!)
        objects.playlistTree.add(child: treeNode)
        
        // create recursive structure
        buildTree(node: topNode!, depth: 0, treeNode: treeNode)
        
        // exit loop, if only one top-node to process
        if (targetDev.plsFolderStartId != 0) {
            objects.plsToProcess -= 1
            break
        }
    }
}

func buildTree(node: PlaylistObject, depth: Int, treeNode: PlaylistTree) {
    let nodeDepth = depth + 1
    
    // get according playlist-object of current node
    let nodeObj = objects.playlists.filter({ $0.id == node.id }).first
    
    if (nodeObj?.folder == true && nodeDepth < 99) { // little safety
        // loop through playlist-folders
        for (plFolder) in objects.playlistFolders.sorted(by: \.pindex) {
            if (node.id == plFolder.folderId && node.folder == true) {
                // get playlist-object of each folder-subnodes of current node
                let nodeFolderObj = objects.playlists.filter({ $0.id == plFolder.playlistId }).first
                
                // create treeNode-object
                let newTreeNode = PlaylistTree(treeId: (nodeFolderObj!.id)!)
                
                if (nodeFolderObj?.folder == true) {
                    // folder - add to tree
                    treeNode.add(child: newTreeNode)
                    objects.fldToProcess += 1
                    
                    // recursion again!
                    buildTree(node: nodeFolderObj!, depth: nodeDepth, treeNode: newTreeNode)
                } else {
                    // file - add to tree
                    treeNode.add(child: newTreeNode)
                    objects.plsToProcess += 1
                }
            }
        }
    } else {
        // just add top-playlist-file to overall-counter
        objects.plsToProcess += 1
    }
}

func deleteExistingFilesAndFolders(completion: @escaping(Data?) -> Void) {
    // define target path
    let plsRootFolder = (targetDev.plsSubfolder != "") ? targetDev.plsUrl.appendingPathComponent(targetDev.plsSubfolder) : targetDev.plsUrl
    
    if (!fileExists(plsRootFolder)) {
        appendError(errormsg: "Playlist-Ordner\n            '\(plsRootFolder)'\n            existiert nicht oder ist nicht eingebunden!")
        isProcessing(state: false)
        return
    }
    
    appendOutput(text: "Existierende Playlist-Ordner und -Dateien werden gelöscht...")
    
    do {
        let fileURLs = try FileManager.default.contentsOfDirectory(at: plsRootFolder,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: .skipsHiddenFiles)
        if (fileURLs.count > 0) {
            objects.plsToProcess = Double(fileURLs.count)
            fileToProcess(newVal: objects.plsToProcess)
            
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
                
                // update progress-bar on ContentView()
                objects.plsProcessed += 1
                filesProcessed(newVal: objects.plsProcessed)
            }
        }
    } catch {
        print(error)
        appendError(errormsg: error.localizedDescription)
    }
    
    completion(Data())
}
