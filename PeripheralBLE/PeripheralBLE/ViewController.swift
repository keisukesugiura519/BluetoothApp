//
//  ViewController.swift
//  PeripheralBLE
//
//  Created by 杉浦圭相 on 2018/07/04.
//  Copyright © 2018 杉浦圭相. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet var advertiseBtn: UIButton!
    private var peripheralManager: CBPeripheralManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // peripheralManager initialzation
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // =========================================================================
    // MARK: Private
    
    private func publishservice () {
        // Create service
        let serviceUUID = CBUUID(string: "E371F980-C783-4BE7-84B6-65A71748F31A")
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // Create characteristic
        let characteristicUUID = CBUUID(string: "AA2C6674-A021-42CF-A8F2-6EBBC7EC93D6")
        let characteristic = CBMutableCharacteristic(type: characteristicUUID,
            properties: .read,
            value: nil,
            permissions: .readable)
        
        // set a characteristic
        service.characteristics = [characteristic]
        
        // add a service
        peripheralManager.add(service)
    }
    
    private func startAdvertise() {
        // アドバタイズメントデータを作成する
        let advertisementData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        
        // アドバタイズ開始
        peripheralManager.startAdvertising(advertisementData)
        
        advertiseBtn.setTitle("STOP ADVERTISING", for: UIControl.State.normal)
    }
    
    private func stopAdvertise () {
        // アドバタイズ停止
        self.peripheralManager.stopAdvertising()
        
        self.advertiseBtn.setTitle("START ADVERTISING", for: UIControl.State.normal)
    }
    
    // ペリフェラルマネージャの状態が変化すると呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
        
        switch peripheral.state {
        case .poweredOn:
            // サービス登録開始
            publishservice()
        default:
            break
        }
    }
    
    // サービス追加処理が完了すると呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            print("Faild service addition error: \(error)")
            return
        }
        print("Successful service addition")
        
        // アドバタイズ開始
        startAdvertise()
    }
    
    // アドバタイズ開始処理が完了すると呼ばれる
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            print("Start Advertise Failed！ error: \(error)")
            return
        }
        print("Sucssessful advertise start!")
    }
    
    @IBAction func advertiseBtnTapped(sender: UIButton) {
        if !peripheralManager.isAdvertising {
            startAdvertise()
        } else {
            stopAdvertise()
        }
    }
}
