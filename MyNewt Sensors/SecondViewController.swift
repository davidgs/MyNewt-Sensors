//
//  SecondViewController.swift
//  MyNewt Sensors
//
//  Created by David G. Simmons on 12/13/16.
//  Copyright © 2016 Dragonfly IoT. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    
    
    @IBOutlet weak var deviceNameField: UITextField!
    @IBOutlet weak var sserviceUUIDField: UITextField!
    @IBOutlet weak var configUUIDPrefixField: UITextField!
    @IBOutlet weak var dataUUIDPrefix: UITextField!
    @IBOutlet weak var nameExactMatch: UISwitch!
    @IBOutlet weak var subAll: UISwitch!
    
    @IBAction func setExactMatch(_ sender: Any) {
        myDev.setExactMatch(match: self.nameExactMatch.isOn)
    }
    
    @IBAction func subAllOnOff(_ sender: Any) {
        myDev.setSubAll(subscribe: self.subAll.isOn)
    }
   
    
    @IBAction func saveConfig(_ sender: Any) {
        let newName = self.deviceNameField.text
        if(self.deviceNameField.text != "" && self.deviceNameField.text != myDev.getDeviceName()){
            myDev.setDeviceName(name: newName!)
        }
        if(self.sserviceUUIDField.text != "" && self.sserviceUUIDField.text != myDev.getServiceUUID()){
            myDev.setServiceUUID(uuid: self.sserviceUUIDField.text!)
        }
        if(self.configUUIDPrefixField.text != "" && self.configUUIDPrefixField.text != myDev.getConfigPrefix()){
            myDev.setConfigPrefix(prefix: self.configUUIDPrefixField.text!)
        }
        if(self.dataUUIDPrefix.text != "" && self.dataUUIDPrefix.text != myDev.getDataPrefix()){
            myDev.setDataPrefix(prefix: self.dataUUIDPrefix.text!)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        
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
