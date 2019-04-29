//
//  ViewController.swift
//  bluetoothbuddy
//
//  Created by Bennett Schoonerman on 4/16/19.
//  Copyright © 2019 BennettSchoonerman. All rights reserved.
//

import UIKit
import CoreBluetooth
let service = CBUUID(string: "FFE0")
let characteristic = CBUUID(string: "FFE1")

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    //Bluetooth Refs
    var centralManager : CBCentralManager!
    var iotDevice : CBPeripheral?
    var chatChannel : CBCharacteristic?
    
    //App State
    var locked = true
    
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var toggleButton: UIButton!
    
    //Mark CBManager
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn{
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name ?? "Unknown")
        if peripheral.name?.contains("SH-HC-08") == true{
            centralManager.stopScan()
            print("Ad data \(advertisementData)")
            central.connect(peripheral, options: nil)
            iotDevice = peripheral
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected \(String(describing: peripheral.name))")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let chars = service.characteristics{
            for char in chars {
                print("Characteristic ID " + char.uuid.uuidString)
                if(char.uuid == characteristic){
                    chatChannel = char //keep track of this characteristic
                    print("Sending data")
                    let msg = "0"
                    peripheral.writeValue(Data.init(_: Array(msg.utf8)), for: char, type: .withoutResponse)
                    peripheral.setNotifyValue(true, for: char)//listen for data here
                }
            }
        }
    }
    
    //after connections
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services{
            for svc in services{
                print("Found Service of " + svc.uuid.uuidString)
                if(svc.uuid == service){
                    print("Getting characteristics of " + service.uuidString )
                    peripheral.discoverCharacteristics(nil, for: svc)
                }
            }
        }
    }
    
    //fired on serial characteristic changes or 'Arduino Serial.writes()'
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if(error != nil){
            print(error?.localizedDescription as Any)
            return
        }
        //print("Periferals characteristics value changed \(characteristic.description)")
        print(String(bytes: characteristic.value!, encoding: .utf8) as Any)
        
        let data = String(decoding: characteristic.value!, as: UTF8.self).components(separatedBy: ":")
    
        switch data[0]{
        case "200":
            print(data[1])
            statusText.text = data[1]
            toggleButton.setTitle(data[1] == "Locked" ? "Unlock" : "Lock", for: .normal)
        case "250":
            print("User: " + data[1])
            //statusText.text = data[1]
        default:
            print("Unknown Data Code")
        }
        
    }
    
    //if you loose a device search for one
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
        print("Lost Connection")
        locked = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup button
        toggleButton.backgroundColor = .orange
        toggleButton.layer.cornerRadius = 10
        toggleButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
    }
    
    @IBAction func clickedUnlock(_ sender: UIButton) {
        if let target = chatChannel{
            if let inputText = userInput.text{
                iotDevice?.writeValue(Data.init(_: Array(inputText.utf8)), for: target, type: .withoutResponse)
            }
        }
    }
    
    func updateState(){
        statusText.text = "Status \(locked ? "Locked":"UnLocked")"
        toggleButton.setTitle(locked ? "Locked":"UnLocked", for: .normal)
    }
}
