//
//  ViewController.swift
//  bluetoothbuddy
//
//  Created by Bennett Schoonerman on 4/16/19.
//  Copyright © 2019 BennettSchoonerman. All rights reserved.
//

import UIKit
import CoreBluetooth
let myArduino = CBUUID.init(string: "")

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn{
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.name ?? "Unknown")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected \(String(describing: iotDevice?.name))")
        peripheral.discoverServices(nil)
        peripheral.delegate = self
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let chars = service.characteristics{
            for char in chars {
                print(char.uuid.uuidString)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services{
            for svc in services{
                print(svc.uuid.uuidString)
            }
        }
    }
    
    
    
    //if you loose a device search for one
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    
    
    var centralManager : CBCentralManager!
    var iotDevice : CBPeripheral?
    
    
    var locked = true
    
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var userInput: UITextField!
    @IBOutlet weak var toggleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

