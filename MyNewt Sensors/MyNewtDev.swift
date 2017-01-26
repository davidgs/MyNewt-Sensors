//
//  MyNewtPeripheral.swift
//  MyNewt BLE
//
//  Created by David G. Simmons on 12/7/16.
//  Copyright © 2016 Dragonfly IoT. All rights reserved.
//

import Foundation
import CoreBluetooth


class MyNewtDev {
    private var deviceName = "nimble"
// Service UUIDs
    private var  serviceUUID = CBUUID(string: "E761D2AF-1C15-4FA7-AF80-B5729020B340")
    private var exactMatch : Bool = false
    private var subscribeAll : Bool = false

// config UUIDs start with 0xDE
// Data UUIDs start with 0xBE

    private var configPrefix = "DE"
    private var dataPrefix = "BE"

    private var deviceString = ""
    private var rssiUpdate : Int = 1
    
    init(){
        loadPrefs()
    }
    
    init(reset: Bool){
        
    }
 // Check name of device from advertisement data
    func MyNewtDevFound (advertisementData: [NSObject : AnyObject]!) -> Bool {
        let nameOfDeviceFound = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        if nameOfDeviceFound == nil {
            return false
        }
        switch exactMatch {
        case true:
            if(nameOfDeviceFound! as String == self.deviceName){
                self.deviceString = nameOfDeviceFound as! String
                return true
            } else {
                return false
            }
        case false:
            if(nameOfDeviceFound!.lowercased.range(of: self.deviceName) != nil){
                self.deviceString = nameOfDeviceFound as! String
                return true
            } else {
                return false
            }
        }
        
    }
    
    
    // Check if the service has a valid UUID
    func validService (service : CBService) -> Bool {
        print(service.uuid.uuidString)
        if service.uuid == self.serviceUUID  {
            return true
        }
        else {
            return false
        }
    }
    
    func isNotifyCharacteristic(characteristic: CBCharacteristic) -> Bool {
        if(characteristic.properties.contains(CBCharacteristicProperties.notify)) {
            print("Notify Characteristic!")
            return true
        } else {
            return false
        }
    }
    
    // Check if the characteristic has a valid data UUID prefix
    func validDataCharacteristic (characteristic : CBCharacteristic) -> Bool {
        print(characteristic.uuid.uuidString)
        _ = isNotifyCharacteristic(characteristic: characteristic)
        if (characteristic.uuid.uuidString.range(of: dataPrefix) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    
    // Check if the characteristic has a valid config UUID
    func validConfigCharacteristic (characteristic : CBCharacteristic) -> Bool {
        if (characteristic.uuid.uuidString.range(of: self.configPrefix) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    func setRSSI(val: Int){
        self.rssiUpdate = val
    }
    
    func getRSSIInterval() -> Int {
        return self.rssiUpdate
    }
    
    func getDeviceName () -> String {
        return self.deviceName
    }
    
    func setDeviceName(name: String){
        self.deviceName = name
    }
    
    func getServiceUUID() -> String {
        return self.serviceUUID.uuidString
    }
    
    func setServiceUUID(uuid: String){
        self.serviceUUID = CBUUID(string: uuid)
    }
    
    func getExactMatch() -> Bool {
        return self.exactMatch
    }
    
    func setExactMatch(match: Bool){
        self.exactMatch = match
    }
    
    func getConfigPrefix() -> String {
        return self.configPrefix
    }
    
    func setConfigPrefix(prefix: String) {
        self.configPrefix = prefix
    }
    
    func getDataPrefix() -> String {
        return self.dataPrefix
    }
    
    func setDataPrefix(prefix: String) {
        self.dataPrefix = prefix
    }
    
    func getDeviceString() -> String {
        return self.deviceString
    }
    
    func getSubAll() -> Bool {
        return self.subscribeAll
    }
    
    func setSubAll(subscribe: Bool) {
        self.subscribeAll = subscribe
    }
    
    func savePrefs(){
        let prefs = UserDefaults.standard
        prefs.set(getSubAll(), forKey: "subscribeAll")
        prefs.set(getExactMatch(), forKey: "exactMatch")
        prefs.set(getServiceUUID(), forKey: "serviceUUID")
        prefs.set(getConfigPrefix(), forKey: "configPrefix")
        prefs.set(getDataPrefix(), forKey: "dataPrefix")
        prefs.set(getDeviceName(), forKey: "deviceName")
        prefs.set(rssiUpdate, forKey: "rssiUpdate")

    }
    
    func loadPrefs(){
        //application.keyWindow?.rootViewController?.childViewControllers[1] as! SecondViewController
        let prefs = UserDefaults.standard
        if let lastDev = prefs.string(forKey: "deviceName"){
            print("The user has a defined Device Name: " + lastDev)
            setDeviceName(name: lastDev)
            
        }
        if let dataPrefix = prefs.string(forKey: "dataPrefix"){
            setDataPrefix(prefix: dataPrefix)
            print("Data Prefix: \(dataPrefix)")
            
        }
        if let configPrefix = prefs.string(forKey: "configPrefix"){
            setConfigPrefix(prefix: configPrefix)
            print("Config Prefix: \(configPrefix)")
            
        }
        if let serviceUUID = prefs.string(forKey: "serviceUUID"){
            setServiceUUID(uuid: serviceUUID)
            print("Service UUID: \(serviceUUID)")
            
        }
        let b = prefs.bool(forKey: "subscribeAll")
        setSubAll(subscribe: b)
        print("Subscribe all: \(b)")
        let c = prefs.bool(forKey: "exactMatch")
        setExactMatch(match: c)
        print("exact match: \(c)")
        let r = prefs.integer(forKey: "rssiUpdate")
        if(r != nil) {
            self.rssiUpdate = r
        }
        
    }
    // Process the values from sensor
    
    
    // Convert NSData to array of bytes
    class func dataToSignedBytes16(value : NSData) -> [Int16] {
        let count = value.length
        var array = [Int16](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<Int16>.size)
        return array
    }
    
    class func dataToUnsignedBytes16(value : NSData) -> [UInt16] {
        let count = value.length
        var array = [UInt16](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<UInt16>.size)
        return array
    }
    
    class func dataToSignedBytes8(value : NSData) -> [Int8] {
        let count = value.length
        var array = [Int8](repeating: 0, count: count)
        value.getBytes(&array, length:count * MemoryLayout<Int8>.size)
        return array
    }
    
    // Get Double Value
    class func getDoubleValue(value : NSData) -> Double {
        let dataFromSensor = dataToSignedBytes16(value: value)
        //    print("Value: \(value.u16)\n")
        return Double(dataFromSensor[0])
    }
    
    // Get object temperature value
    class func getObjectTemperature(value : NSData, ambientTemperature : Double) -> Double {
        let dataFromSensor = dataToSignedBytes16(value: value)
        let Vobj2 = Double(dataFromSensor[0]) * 0.00000015625
        
        let Tdie2 = ambientTemperature + 273.15
        let Tref  = 298.15
        
        let S0 = 6.4e-14
        let a1 = 1.75E-3
        let a2 = -1.678E-5
        let b0 = -2.94E-5
        let b1 = -5.7E-7
        let b2 = 4.63E-9
        let c2 = 13.4
        
        let S = S0*(1+a1*(Tdie2 - Tref)+a2*pow((Tdie2 - Tref),2))
        let Vos = b0 + b1*(Tdie2 - Tref) + b2*pow((Tdie2 - Tref),2)
        let fObj = (Vobj2 - Vos) + c2*pow((Vobj2 - Vos),2)
        let tObj = pow(pow(Tdie2,4) + (fObj/S),0.25)
        
        let objectTemperature = (tObj - 273.15)
        
        return objectTemperature
    }
    
    // Get Accelerometer values
    class func getAccelerometerData(value: NSData) -> [Double] {
        let dataFromSensor = dataToSignedBytes8(value: value)
        let xVal = Double(dataFromSensor[0]) / 64
        let yVal = Double(dataFromSensor[1]) / 64
        let zVal = Double(dataFromSensor[2]) / 64 * -1
        return [xVal, yVal, zVal]
    }
    
    // Get Relative Humidity
    class func getRelativeHumidity(value: NSData) -> Double {
        let dataFromSensor = dataToUnsignedBytes16(value: value)
        let humidity = -6 + 125/65536 * Double(dataFromSensor[1])
        return humidity
    }
    
    // Get magnetometer values
    class func getMagnetometerData(value: NSData) -> [Double] {
        let dataFromSensor = dataToSignedBytes16(value: value)
        let xVal = Double(dataFromSensor[0]) * 2000 / 65536 * -1
        let yVal = Double(dataFromSensor[1]) * 2000 / 65536 * -1
        let zVal = Double(dataFromSensor[2]) * 2000 / 65536
        return [xVal, yVal, zVal]
    }
    
    // Get gyroscope values
    class func getGyroscopeData(value: NSData) -> [Double] {
        let dataFromSensor = dataToSignedBytes16(value: value)
        let yVal = Double(dataFromSensor[0]) * 500 / 65536 * -1
        let xVal = Double(dataFromSensor[1]) * 500 / 65536
        let zVal = Double(dataFromSensor[2]) * 500 / 65536
        return [xVal, yVal, zVal]
    }
}
