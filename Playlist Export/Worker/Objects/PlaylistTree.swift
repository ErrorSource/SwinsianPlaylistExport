//
//  PlaylistTree.swift
//  playlistExport
//
//  Created by Georg Kemser on 16.11.21.
//

import Foundation

//final class PlaylistTree<Value> {
//
//    let value: Value
//
//    private(set) weak var parent: PlaylistTree?
//    private(set) var children: [PlaylistTree] = []
//
//    init(value: Value) {
//        self.value = value
//    }
//
//    func add(child: PlaylistTree) {
//        children.append(child)
//        child.parent = self
//    }
//
//}

final class PlaylistTree {
    var treeId: Int
    var children: [PlaylistTree] = []
    weak var parent: PlaylistTree?
    
    init(treeId: Int) {
        self.treeId = treeId
    }
    
    func add(child: PlaylistTree) {
        children.append(child)
        child.parent = self
    }
}
