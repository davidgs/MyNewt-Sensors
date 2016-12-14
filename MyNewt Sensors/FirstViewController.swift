//
//  FirstViewController.swift
//  MyNewt Sensors
//
//  Created by David G. Simmons on 12/13/16.
//  Copyright © 2016 Dragonfly IoT. All rights reserved.
//

import UIKit
import CoreBluetooth

let myDev : MyNewtDev = MyNewtDev()

class FirstViewController: UIViewController , CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var scanActivity: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var signalStrength: UIImageView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var myNewtView: UIView!
    
    // BLE
    var centralManager : CBCentralManager!
    var myNewtPeripheral : CBPeripheral!
    
    // Table View
    var myNewtTableView : UITableView!
    
    // Sensor Values
    var myNewtSensors : [MyNewtSensor] = []
    
    var objectTemperature : Double!
    
    var  isScanning : Bool = false
    var isConnected  : Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager(delegate: self, queue: nil)
               
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if(myNewtPeripheral.state == CBPeripheralState.connected){
            centralManager.cancelPeripheralConnection(myNewtPeripheral)
            self.signalStrength.image = UIImage(named: "NoSignal-sm")
            self.connectButton.setTitle("Scan For MyNewt", for: UIControlState.normal)
            self.isConnected = false
            self.isScanning = false
            self.deviceNameLabel.text = "None"
            self.myNewtSensors = []
            self.tearDownSensorTagTableView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSensorTagTableView()
        self.scanActivity.startAnimating()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connectButtonPressed(_ sender: Any) {
        if(myNewtPeripheral.state == CBPeripheralState.connected){
            centralManager.cancelPeripheralConnection(myNewtPeripheral)
            self.signalStrength.image = UIImage(named: "NoSignal-sm")
            self.connectButton.setTitle("Scan For MyNewt", for: UIControlState.normal)
            self.isConnected = false
            self.isScanning = false
            self.deviceNameLabel.text = "None"
            self.myNewtSensors = []
            self.tearDownSensorTagTableView()
        } else if(self.isScanning){
            centralManager.stopScan()
            self.scanActivity.stopAnimating()
            self.signalStrength.image = UIImage(named: "NoSignal-sm")
            self.connectButton.setTitle("Scan For MyNewt", for: UIControlState.normal)
            self.isConnected = false
            self.isScanning = false
        }else {
            // start scanning
            self.setupSensorTagTableView()
            self.scanActivity.startAnimating()
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
            self.connectButton.setTitle("Stop Scan", for: UIControlState.normal)
            self.isScanning = true
            
        }

    }

    
    /******* CBCentralManagerDelegate *******/
    
    // Check status of BLE hardware
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripherals(withServices: nil, options: nil)
            self.statusLabel.text = "Scanning ..."
        }
        else {
            // Can have different conditions for all states if needed - show generic alert for now
            self.showAlertWithText(header: "Error", message: "Bluetooth switched off or not initialized")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if myDev.MyNewtDevFound(advertisementData: advertisementData as [NSObject : AnyObject]!) == true {
            // Update Status Label
            self.statusLabel.text = "Mynewt Device Found"
            self.scanActivity.stopAnimating()
            // Stop scanning, set as the peripheral to use and establish connection
            self.centralManager.stopScan()
            self.isScanning = false
            self.myNewtPeripheral = peripheral
            self.myNewtPeripheral.delegate = self
            self.centralManager.connect(peripheral, options: nil)
        }
        else {
            //self.statusLabel.text = "Mynewt Device NOT Found"
            //showAlertWithText(header: "Warning", message: "SensorTag Not Found")
        }

    }
    // Check out the discovered peripherals to find a MyNewt Device
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if myDev.MyNewtDevFound(advertisementData: advertisementData as [NSObject : AnyObject]!) == true {
            // Update Status Label
            self.statusLabel.text = "Mynewt Device Found"
            self.scanActivity.stopAnimating()
            // Stop scanning, set as the peripheral to use and establish connection
            self.centralManager.stopScan()
            self.isScanning = false
            self.myNewtPeripheral = peripheral
            self.myNewtPeripheral.delegate = self
            self.centralManager.connect(peripheral, options: nil)
        }
        else {
            //self.statusLabel.text = "Mynewt Device NOT Found"
            //showAlertWithText(header: "Warning", message: "SensorTag Not Found")
        }
    }
    
    // Discover services of the peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.statusLabel.text = "Discovering services"
        peripheral.discoverServices(nil)
    }
    
    
    // If disconnected, start searching again
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.statusLabel.text = "Disconnected"
        self.isConnected = false
        
    }
    
    /******* CBCentralPeripheralDelegate *******/
    
    // Check if the service discovered is valid
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services! {
            let thisService = service as CBService
            if myDev.validService(service: thisService) {
                // Discover characteristics of all valid services
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
        }
    }
    
    
    // Enable notification and sensor for each characteristic of valid service
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        self.statusLabel.text = "Enabling sensors"
        
        for charateristic in service.characteristics! {
            let thisCharacteristic = charateristic as CBCharacteristic
            if(myDev.getSubAll()){
                if(myDev.isNotifyCharacteristic(characteristic: thisCharacteristic)){
                    self.myNewtPeripheral.setNotifyValue(true, for: thisCharacteristic)
                }
            } else {
                if myDev.validDataCharacteristic(characteristic: thisCharacteristic) {
                    self.myNewtPeripheral.setNotifyValue(true, for: thisCharacteristic)
                }
                if myDev.validConfigCharacteristic(characteristic: thisCharacteristic) {
                    peripheral.readValue(for: thisCharacteristic)
                }
            }
        }
        self.scanActivity.stopAnimating()
        self.isConnected = true
        isScanning = false
        self.connectButton.setTitle("Disconnect MyNewt", for: UIControlState.normal)
        
    }
    
    
    
    // Get data values when they are updated
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        self.statusLabel.text = "Connected"
        self.deviceNameLabel.text = myDev.getDeviceString()
        
        peripheral.readRSSI()
        let charType = characteristic.uuid.uuidString.substring(to: characteristic.uuid.uuidString.index(characteristic.uuid.uuidString.startIndex, offsetBy: 2))
        
        let charVal = characteristic.uuid.uuidString.substring(from: characteristic.uuid.uuidString.index(characteristic.uuid.uuidString.startIndex, offsetBy: 2))
        let uuid = characteristic.uuid.uuidString
        var seen : Bool = false
        // self.readRSSI()
        for i in 0..<myNewtSensors.count {
            if(myNewtSensors[i].containsValue(value: uuid)) {
                seen = true
                myNewtSensors[i].updateValue(key: uuid, value: characteristic.value! as NSData)
                myNewtSensors[i].setValue(MyNewtDev.getDoubleValue(value: characteristic.value! as NSData), forKey: "sensorValue")
            }
        }
        if(!seen){
            // never seen this before
            if(myDev.getSubAll()){
                let newSensor = MyNewtSensor(sensorName: "Sensor Data UUID: 0x\(characteristic.uuid.uuidString)", nUUID : characteristic.uuid.uuidString, dUUID : characteristic.uuid.uuidString, sensorValue : 0.00)
                myNewtSensors.append(newSensor)
            } else {
                switch charType {
                case "DE":
                    let newSensor = MyNewtSensor(sensorName: String(data: characteristic.value!, encoding: String.Encoding.utf8)!, nUUID : characteristic.uuid.uuidString, dUUID : "BE" + charVal, sensorValue : 0.00)
                    myNewtSensors.append(newSensor)
                    print(myNewtSensors[myNewtSensors.count-1])
                default:
                    break
                }
            }
            
        }
        
        self.myNewtTableView?.reloadData()
    }
    
    func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        let rssi = abs((peripheral.rssi?.intValue)! )
        print("RSSI: \(peripheral.rssi?.intValue)")
        if(rssi < 70){
            self.signalStrength.image = UIImage(named: "FourBars-sm")!
        } else if (rssi < 80) {
            self.signalStrength.image = UIImage(named: "ThreeBars-sm")!
        } else if (rssi < 90) {
            self.signalStrength.image = UIImage(named: "TwoBars-sm")!
        } else if(rssi < 100) {
            self.signalStrength.image = UIImage(named: "OneBar-sm")!
        } else {
            self.signalStrength.image = UIImage(named: "NoSignal-sm")!
        }
        
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
    func setupSensorTagTableView () {
        
        self.myNewtTableView = UITableView()
        self.myNewtTableView.delegate = self
        self.myNewtTableView.dataSource = self
        
        
        self.myNewtTableView.frame = CGRect(x: self.myNewtView.bounds.origin.x, y: self.myNewtView.bounds.origin.y, width: self.myNewtView.bounds.width , height: self.myNewtView.bounds.height)
        self.myNewtTableView.register(myNewtCell.self, forCellReuseIdentifier: "myNewtSensor")
        
        self.myNewtTableView.tableFooterView = UIView() // to hide empty lines after cells
        self.myNewtView.addSubview(self.myNewtTableView)
    }
    
    // Tear down tableView
    func tearDownSensorTagTableView(){
        self.myNewtTableView.removeFromSuperview()
        self.myNewtTableView = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myNewtSensors.count
    }
    
    
    /******* UITableViewDelegate *******/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let thisCell = tableView.dequeueReusableCell(withIdentifier: "myNewtSensor", for: indexPath as IndexPath) as! myNewtCell
        print("Setting Label for row: \(indexPath.row) to: \(myNewtSensors[indexPath.row].sensorLabel)")
        thisCell.sensorNameLabel.text  = myNewtSensors[indexPath.row].sensorLabel
        thisCell.sensorValueLabel.text = String(format: "%.2f", myNewtSensors[indexPath.row].sensorValue)
        
        return thisCell
    }
    
}

