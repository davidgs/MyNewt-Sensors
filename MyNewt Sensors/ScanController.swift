//
//  ScanController.swift
//  MyNewt
//
//  Created by David G. Simmons on 12/19/16.
//  Copyright © 2016 Dragonfly IoT. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScanController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var scanActivity: UIActivityIndicatorView!
    @IBOutlet weak var scanView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    
   
    var conPeriph : String!
    var connService : String!
    
    // Table View
    var deviceTableView : UITableView!
    var foundDevices : [String] = []
    var foundUUIDs : [String] = []
    var foundPeripherals : [CBPeripheral] = []
    var savePrefs = true

    var deviceManager : CBCentralManager!
    var peripheral : CBPeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusLabel.text = "Scanning for Bluetooth Devices..."
        self.deviceManager = CBCentralManager(delegate: self, queue: nil)
        self.setupDeviceTableView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(savePrefs){
            if(deviceManager.isScanning) {
                deviceManager.stopScan()
            }
            myNewt.setDeviceName(name: conPeriph)
            myNewt.setServiceUUID(uuid: connService)
            deviceManager.cancelPeripheralConnection(self.peripheral)
            myNewt.setSubAll(subscribe: true)
            myNewt.setExactMatch(match: true)
            myNewt.savePrefs()
        }
        self.tearDownSensorTagTableView()
    }
    
    @IBAction func closeScan(_ sender: Any) {
        self.savePrefs = false
        self.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    /******* CBCentralManagerDelegate *******/
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripherals(withServices: nil, options: nil)
            self.scanActivity.startAnimating()
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            self.showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let nameOfDeviceFound = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        print("AD DATA: \(nameOfDeviceFound)")
        if(nameOfDeviceFound != nil){
            
            self.foundDevices.append(nameOfDeviceFound as! String)
            self.foundUUIDs.append("")
            self.deviceTableView?.reloadData()
            self.foundPeripherals.append(peripheral)
            self.statusLabel.text = "Select Bluetooth Device"
        }
    }

    // Discover services of the peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //        peripheral.discoverServices(nil)
        print("did connect")
        if(conPeriph == nil){
            // get/se the name
            conPeriph = peripheral.name
            self.peripheral.delegate = self
            self.peripheral.discoverServices(nil)
            self.statusLabel.text = "Select Service UUID"
            return
        }
        if(connService == nil){
        }
        

    }
    
    
    // If disconnected, start searching again
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        deviceManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    /******* CBCentralPeripheralDelegate *******/
    
    // Check if the service discovered is valid
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.tearDownSensorTagTableView()
        self.setupDeviceTableView()
        self.foundDevices.append("Service UUIDs")
        self.foundUUIDs.append("")
        for service in peripheral.services! {
            let thisService = service as CBService
            foundDevices.append(thisService.uuid.uuidString)
            foundUUIDs.append("")
        }
        self.deviceTableView?.reloadData()

    }
    
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered Characteristics")
    }
    
    
    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        peripheral.readRSSI()
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        let rssi = abs((peripheral.rssi?.intValue)! )
        print("Scan RSSI: \(peripheral.rssi?.intValue)")
    }
    
    /******* Helper *******/
    
    // Show alert
    func showAlertWithText (header : String = "Warning", message : String) {
        let alert = UIAlertController(title: header, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        alert.view.tintColor = UIColor.red
        self.present(alert, animated: true, completion: nil)
    }
    
// Set up Table View
func setupDeviceTableView () {
    
    self.deviceTableView = UITableView()
    self.deviceTableView.delegate = self
    self.deviceTableView.dataSource = self
    
    
    self.deviceTableView.frame = CGRect(x: self.scanView.bounds.origin.x, y: self.scanView.bounds.origin.y, width: self.scanView.bounds.width , height: self.scanView.bounds.height)
    self.deviceTableView.register(DeviceCell.self, forCellReuseIdentifier: "device")
    
    self.deviceTableView.tableFooterView = UIView() // to hide empty lines after cells
    self.scanView.addSubview(self.deviceTableView)
}

// Tear down tableView
func tearDownSensorTagTableView(){
    self.deviceTableView.removeFromSuperview()
    self.deviceTableView = nil
    self.foundDevices = []
    self.foundUUIDs = []
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return foundDevices.count
}

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inp = indexPath.row
        print("Selected \(foundDevices[indexPath.row])")
        if(conPeriph == nil){
            self.peripheral = foundPeripherals[indexPath.row]
            self.deviceManager.stopScan()
        
            self.deviceManager.connect(peripheral, options: nil)
        } else if(connService == nil){
            connService = foundDevices[indexPath.row]
            self.dismiss(animated: true, completion: nil)
        }
    }

/******* UITableViewDelegate *******/

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let thisCell = tableView.dequeueReusableCell(withIdentifier: "device", for: indexPath as IndexPath) as! DeviceCell
    print("Setting Label for row: \(indexPath.row) to: \(foundDevices[indexPath.row])")
    thisCell.deviceNameLabel.text  = foundDevices[indexPath.row]
    thisCell.deviceValueLabel.text = foundUUIDs[indexPath.row]
    
    return thisCell
}

}
