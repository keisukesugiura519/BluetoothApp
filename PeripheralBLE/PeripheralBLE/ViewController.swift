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
        
        // ペリフェラルマネージャ初期化
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        print("ペリフェラルマネージャー初期化したったー")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // =========================================================================
    // MARK: Private
    
    private func publishservice () {
        // サービスを作成
        let serviceUUID = CBUUID(string: "E371F980-C783-4BE7-84B6-65A71748F31A")
        let service = CBMutableService(type: serviceUUID, primary: true)
        
        // キャラクタリスティックを作成
        let characteristicUUID = CBUUID(string: "AA2C6674-A021-42CF-A8F2-6EBBC7EC93D6")
        let characteristic = CBMutableCharacteristic(type: characteristicUUID,
            properties: .read,
            value: nil,
            permissions: .readable)
        
        // キャラクタリスティックをサービスにセット
        service.characteristics = [characteristic]
        
        // サービスを追加
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
    
    // =========================================================================
    // MARK: CBPeripheralManagerDelegate
    
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
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if let error = error {
            print("サービス追加失敗！ error: \(error)")
            return
        }
        print("サービス追加成功！")
        
        // アドバタイズ開始
        startAdvertise()
    }
    
    // アドバタイズ開始処理が完了すると呼ばれる
    private func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if let error = error {
            print("アドバタイズ開始失敗！ error: \(error)")
            return
        }
        print("アドバタイズ開始成功！")
    }
    
    // =========================================================================
    // MARK: Actions
    
    @IBAction func advertiseBtnTapped(sender: UIButton) {
        if !peripheralManager.isAdvertising {
            startAdvertise()
        } else {
            stopAdvertise()
        }
    }
}
