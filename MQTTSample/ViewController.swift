//
//  ViewController.swift
//  MQTTSample
//
//  Created by 정영민 on 2024/08/13.
//

import UIKit
import CocoaMQTT

class ViewController: UIViewController {

    var mqttClient: CocoaMQTT?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMQTT()
    }

    
    func setupMQTT() {
        // MQTT 클라이언트 설정
        let clientID = "iOSClient-\(UUID().uuidString)"
        mqttClient = CocoaMQTT(clientID: clientID, host: "test.mosquitto.org", port: 1883)
        mqttClient?.delegate = self
        mqttClient?.connect()
    }
    
    @IBAction func publishMessage(_ sender: UIButton) {
        mqttClient?.publish("home/livingroom/temperature", withString: "Hello, MQTT!")
    }

    @IBAction func subscribeTopic(_ sender: UIButton) {
        mqttClient?.subscribe("home/livingroom/temperature")
    }

    @IBAction func actionBluetooth(_ sender: UIButton) {
        
    }
}

extension ViewController: CocoaMQTTDelegate {
    ///
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
       // print("Connected to \(host) on port \(port)")
        print("didConnectAck")
    }
    
    ///
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("didPublishMessage: \(message.string)")
    }
    
    ///
    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("didPublishAck")
    }
    
    ///
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("didReceiveMessage: \(message.string)")
    }
    
    ///
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
        print("didSubscribeTopics")
    }
    
    ///
    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("didUnsubscribeTopics")
    }
    
    ///
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("mqttDidPing")
    }
    
    ///
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("mqttDidReceivePong")
    }
    
    ///
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("mqttDidDisconnect")
    }
        
}

