//
//  BluetoothVC.swift
//  MQTTSample
//
//  Created by 정영민 on 2024/08/20.
//

import UIKit
import CoreBluetooth

class BluetoothVC: UIViewController {
    // MARK: - Variables
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    
    var list: [CBPeripheral] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 중앙 관리자 초기화
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

// MARK: - IBActions
extension BluetoothVC {
    
}

// MARK: - Private functions
extension BluetoothVC {
    
}

extension BluetoothVC: CBCentralManagerDelegate, CBPeripheralDelegate {
    // Central Manager 상태 업데이트 시 호출
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            // 블루투스가 켜졌다면, 주변 기기를 검색합니다.
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        case .poweredOff, .resetting, .unauthorized, .unsupported, .unknown:
            // 다른 상태 처리
            print("Bluetooth is not available.")
        @unknown default:
            break
        }
    }
    
    // 주변 기기 발견 시 호출
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        /*
         RSSI (Received Signal Strength Indicator) 값으로, 기기에서 수신된 신호의 강도
         
         0 dBm에 가까울수록 신호가 강합니다.
         -50 dBm 이하라면 매우 강한 신호로 볼 수 있으며, 연결이 안정적일 가능성이 높습니다.
         -70 dBm ~ -50 dBm은 일반적으로 양호한 신호 강도로 간주됩니다.
         -90 dBm 이하라면 신호가 약해 연결에 문제가 있을 수 있습니다.
         */
         
        print("Discovered \(peripheral.name ?? "Unknown") at \(RSSI)")
        
        if RSSI.intValue > -70, !list.contains(where: { $0.identifier == peripheral.identifier }) {
            list.append(peripheral)
        }
        
        /*
        // 원하는 기기를 찾았다면 연결 시작
        if discoveredPeripheral != peripheral {
            discoveredPeripheral = peripheral
            
            // 연결 시도
            centralManager.connect(peripheral, options: nil)
        }
        */
    }
    
    // 주변 기기 연결 성공 시 호출
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(peripheral.name ?? "Unknown")")
        
        // 서비스 검색 시작
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // 연결 실패 시 호출
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral.name ?? "Unknown"): \(error?.localizedDescription ?? "No error information")")
    }
    
    // 주변 기기의 서비스 발견 시 호출
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Error discovering services: \(error.localizedDescription)")
            return
        }
        
        // 각 서비스의 특성(characteristic) 검색
        if let services = peripheral.services {
            for service in services {
                print("Service found: \(service)")
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    // 서비스의 특성 발견 시 호출
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Error discovering characteristics: \(error.localizedDescription)")
            return
        }
        
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                print("Characteristic found: \(characteristic)")
                
                // 데이터 수신을 위해 알림 설정
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    // 특성에서 데이터 업데이트 시 호출
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Error updating value for characteristic: \(error.localizedDescription)")
            return
        }
        
        if let value = characteristic.value {
            print("Received data: \(value)")
            // 데이터를 처리하는 코드 추가
        }
    }
}


extension BluetoothVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BluetoothTableCell", for: indexPath) as! BluetoothTableCell
        let data = list[indexPath.row]
        cell.nameLabel.text = data.name
        return cell
    }
}
