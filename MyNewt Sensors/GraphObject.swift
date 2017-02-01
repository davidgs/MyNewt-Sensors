//
//  GraphObject.swift
//  MyNewt
//
//  Created by David G. Simmons on 1/27/17.
//  Copyright © 2017 Dragonfly IoT. All rights reserved.
//

import UIKit

class GraphObject: NSObject {
    let name : String!
    var vals : [Int] = []
    
    init(name: String) {
        self.name = name
    }
    
    func addValue(value: Int){
        if(vals.count > 20){
            self.vals.remove(at: 0)
            self.vals.append(value)
        } else {
            self.vals.append(value)
        }
    }

}
