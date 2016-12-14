//
//  MyNewtSensor.swift
//  MyNewt
//
//  Created by David G. Simmons on 12/13/16.
//  Copyright © 2016 David G. Simmons. All rights reserved.
//

import Foundation

class MyNewtSensor : NSObject{
    var sensorLabel : String
    var nUUID : String
    var dUUID : String
    var sensorValue : Double
    
    override init() {
        sensorLabel = "Sensor"
        nUUID = "DEEE"
        dUUID = "BEEE"
        sensorValue = 0.00
        super.init()
    }
    
    init(sensorName : String, nUUID : String, dUUID : String, sensorValue : Double) {
        self.sensorLabel = sensorName
        self.nUUID = nUUID
        self.dUUID = dUUID
        self.sensorValue = sensorValue
        super.init()
    }
    
    func containsValue(value: String) -> Bool {
        return self.sensorLabel == value || self.nUUID == value || self.dUUID == value
    }
    
    func updateValue(key: String, value: NSData){
        
        switch key {
        case "dUUID" :
            self.sensorValue = MyNewtDev.getDoubleValue(value: value as NSData)
        case "nUUID" :
            self.sensorLabel = String(data: value as Data, encoding: String.Encoding.utf8)!

        default:
            return
        }
        
    }
    
}
