//
//  Genre.swift
//  Movie App
//
//  Created by Việt Trần on 10/29/16.
//  Copyright © 2016 IDE Academy. All rights reserved.
//

import Foundation

struct Genre {
    var id: Int
    var name:String = ""
    
    init?(jsonData: JSONData) {
        guard let id = jsonData["id"] as? Int else {return nil}
        self.id = id
        
        if let name = jsonData["name"] as? String {
            self.name = name
        }
    }
}
