//
//  SecondViewController.swift
//  MyNewt Sensors
//
//  Created by David G. Simmons on 12/13/16.
//  Copyright © 2016 Dragonfly IoT. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var rssiLabel: UILabel!
    let rssiLabelString = "RSSI Update Interval: "
    @IBOutlet weak var rssiStepper: UIStepper!
    
    @IBOutlet weak var deviceNameField: UITextField!
    @IBOutlet weak var sserviceUUIDField: UITextField!
    @IBOutlet weak var configUUIDPrefixField: UITextField!
    @IBOutlet weak var dataUUIDPrefix: UITextField!
    @IBOutlet weak var nameExactMatch: UISwitch!
    @IBOutlet weak var subAll: UISwitch!
    
    @IBAction func setExactMatch(_ sender: Any) {
        myNewt.setExactMatch(match: self.nameExactMatch.isOn)
        myNewt.savePrefs()
    }
    
    @IBAction func subAllOnOff(_ sender: Any) {
        myNewt.setSubAll(subscribe: self.subAll.isOn)
        myNewt.savePrefs()
    }
   
    @IBAction func rssiStepperChanged(_ sender: Any) {
        let val = rssiStepper.value
        let intVal = Int(val)
        print(intVal)
        self.rssiLabel.text = rssiLabelString + String(intVal)
        myNewt.setRSSI(val: intVal)
        myNewt.savePrefs()
        
    }
    
    
    @IBAction func resetAction(_ sender: Any) {
        myNewt = MyNewtDev(reset: true)
        myNewt.savePrefs()
        myNewt.loadPrefs()
        self.configUUIDPrefixField.text = ""
        self.dataUUIDPrefix.text = ""
        self.deviceNameField.text = ""
        self.sserviceUUIDField.text = ""
        self.nameExactMatch.setOn(false, animated: true)
        self.subAll.setOn(false, animated: true)
        self.rssiLabel.text = self.rssiLabelString + String(1)
    }
        
    @IBAction func saveConfig(_ sender: Any) {
        let newName = self.deviceNameField.text
        if(self.deviceNameField.text != "" && self.deviceNameField.text != myNewt.getDeviceName()){
            myNewt.setDeviceName(name: newName!)
        }
        if(self.sserviceUUIDField.text != "" && self.sserviceUUIDField.text != myNewt.getServiceUUID()){
            myNewt.setServiceUUID(uuid: self.sserviceUUIDField.text!)
        }
        if(self.configUUIDPrefixField.text != "" && self.configUUIDPrefixField.text != myNewt.getConfigPrefix()){
            myNewt.setConfigPrefix(prefix: self.configUUIDPrefixField.text!)
        }
        if(self.dataUUIDPrefix.text != "" && self.dataUUIDPrefix.text != myNewt.getDataPrefix()){
            myNewt.setDataPrefix(prefix: self.dataUUIDPrefix.text!)
        }
        myNewt.savePrefs()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.rssiLabel.text = self.rssiLabelString + String(myNewt.getRSSIInterval())
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myNewt.loadPrefs()
        loadFields()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        myNewt.savePrefs()
    }
    
    
    func loadFields(){
        let prefs = UserDefaults.standard
        if let lastDev = prefs.string(forKey: "deviceName"){
            print("The user has a defined Device Name: " + lastDev)
            if(lastDev != "nimble") {
                self.deviceNameField.text = lastDev
            }
        }
        if let dataPrefix = prefs.string(forKey: "dataPrefix"){
            print("Data Prefix: \(dataPrefix)")
            if(dataPrefix != "BE") {
                self.dataUUIDPrefix.text = dataPrefix
            }
        }
        if let configPrefix = prefs.string(forKey: "configPrefix"){
            print("Config Prefix: \(configPrefix)")
            if(configPrefix != "DE"){
                self.configUUIDPrefixField.text = configPrefix
            }
        }
        if let serviceUUID = prefs.string(forKey: "serviceUUID"){
            print("Service UUID: \(serviceUUID)")
            if(serviceUUID != "E761D2AF-1C15-4FA7-AF80-B5729020B340") {
                self.sserviceUUIDField.text = serviceUUID
            }
        }
        print("Subscribe all: \(prefs.bool(forKey: "subscribeAll"))")
        self.subAll.setOn(prefs.bool(forKey: "subscribeAll"), animated: true)
        self.nameExactMatch.setOn(prefs.bool(forKey: "exactMatch"), animated: true)
        print("exact match: \(prefs.bool(forKey: "exactMatch"))")
        
    }

}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
