//
//  RoomFileBroswerModel.swift
//  DemoApp
//
//  Created by CY zhao on 2023/7/4.
//

import Foundation

class RoomFileBroswerModel: NSObject {
    var title: String
    var path: String
    
    init(title: String = "", path: String) {
        self.title = title
        self.path = path
        super.init()
    }
}
