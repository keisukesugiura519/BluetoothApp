//
//  ViewController.swift
//  CentralBLE
//
//  Created by 杉浦圭相 on 2018/07/04.
//  Copyright © 2018 杉浦圭相. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate
{
    private var isScanning = false
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    
    @IBOutlet weak var scnlabel: UILabel!
    @IBOutlet weak var Button:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セントラルマネージャ初期化
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("初期化した〜！")
        Button.setTitle("Scan Start", for: .normal)
    }
    
    override func didReceiveMemoryWarning() {

        super.didReceiveMemoryWarning()
    }
    
    // =========================================================================
    // MARK: CBCentralManagerDelegate
    
    // セントラルマネージャの状態が変化すると呼ばれる
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state: \(central.state)")
    }
    
    // 周辺にあるデバイスを発見すると呼ばれる
    private func centralManager(central: CBCentralManager,
                        didDiscoverPeripheral peripheral: CBPeripheral,
                        advertisementData: [String : AnyObject],
                        RSSI: NSNumber)
    {
        print("発見したBLEデバイス: \(peripheral)")
        
        if let name = peripheral.name, name.hasPrefix("iPad (2)") {
            self.peripheral = peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(central: CBCentralManager,
                        didConnectPeripheral peripheral: CBPeripheral)
    {
        print("接続成功！")
        
        scnlabel.text = "iPad(2) connected"
        
        // サービス探索結果を受け取るためにデリゲートをセット
        peripheral.delegate = self
        
        // サービス探索開始
        peripheral.discoverServices(nil)
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    private func centralManager(central: CBCentralManager,
                        didFailToConnectPeripheral peripheral: CBPeripheral,
                        error: NSError?)
    {
        print("接続失敗・・・")
    }
    
    // =========================================================================
    // MARK:CBPeripheralDelegate
    
    // サービス発見時に呼ばれる
    private func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let error = error {
            print("エラー: \(error)")
            return
        }
        
        guard let services = peripheral.services, services.count > 0 else {
            print("no services")
            return
        }
        print("\(services.count) 個のサービスを発見！ \(services)")
        
        for service in services {
            // キャラクタリスティック探索開始
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // キャラクタリスティック発見時に呼ばれる
    private func peripheral(peripheral: CBPeripheral,didDiscoverCharacteristicsForService service: CBService,error: NSError?) {
        if let error = error {
            print("エラー: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        print("\(String(describing: characteristics?.count)) 個のキャラクタリスティックを発見！ \(String(describing: characteristics))")
    }
    
    // =========================================================================
    // MARK: Actions
    
    @IBAction func scanBtnTapped(sender: UIButton) {
        if !isScanning {
            isScanning = true
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            sender.setTitle("STOP SCAN", for: UIControl.State.normal)
        } else {
            centralManager.stopScan()
            sender.setTitle("START SCAN", for: UIControl.State.normal)
            isScanning = false
        }
    }
}
