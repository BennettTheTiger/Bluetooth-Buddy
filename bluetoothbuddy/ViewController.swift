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
                    print("Sending data")
                    //peripheral.writeValue(Data.init(bytes: [01]), for: char, type: .withoutResponse)
                    CBATTRequest

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
        locked = !locked
        updateState()
    }
    
    func updateState(){
        statusText.text = "Status \(locked ? "Locked":"UnLocked")"
        toggleButton.setTitle(locked ? "Locked":"UnLocked", for: .normal)
    }
}
