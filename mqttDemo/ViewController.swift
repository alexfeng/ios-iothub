//
//  ViewController.swift
//  mqttDemo
//
//  Created by 冯向博 on 2018/2/24.
//  Copyright © 2018年 Alex.feng. All rights reserved.
//

import UIKit
import SwiftMQTT
import Toast_Swift

let endPointName = "yourendpointname"
let deviceName = "yourdevicename"
let userName = "\(endPointName)/\(deviceName)"
let userCode = "yourcode"
let defualtPayload = ["hey" : "iot"]
let defaltTopic = "yourtopic"

class ViewController: UIViewController {
    @IBOutlet weak var tipLabel: UILabel!
    
    var mqttSession: MQTTSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let clientID = "iOS-" + String(ProcessInfo().processIdentifier)
        
        mqttSession = MQTTSession(host: "\(endPointName).mqtt.iot.gz.baidubce.com", port: 1883, clientID: clientID, cleanSession: true, keepAlive: 60, useSSL: false)
        mqttSession.username = userName
        mqttSession.password = userCode
        mqttSession.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: button actions
    
    @IBAction func onConnect(_ sender: UIButton) {
        mqttSession.disconnect()
        mqttSession.connect { (succeeded, error) -> Void in
            if succeeded {
                print("Connected!")
                self.tipLabel.text = "Connected"
            }
            else {
                print("error = \(error.localizedDescription)")
                self.tipLabel.text = error.localizedDescription
            }
        }
    }
    
    @IBAction func onSubscribe(_ sender: UIButton) {
        mqttSession.subscribe(to: defaltTopic, delivering: .atLeastOnce) { (succeeded, error) -> Void in
            if succeeded {
                print("Subscribed!")
                self.tipLabel.text = "Subscribed"
            }
        }
    }
    
    @IBAction func onPublish(_ sender: UIButton) {
        
        let jsonDict = defualtPayload
        
        let data = try! JSONSerialization.data(withJSONObject: jsonDict, options: .prettyPrinted)
        mqttSession.publish(data, in: defaltTopic, delivering: .atLeastOnce, retain: false) { (succeeded, error) -> Void in
            if succeeded {
                print("Published!")
                 self.tipLabel.text = "Published"
            }
        }
    }
}

extension ViewController: MQTTSessionDelegate {
    func mqttDidReceive(message data: Data, in topic: String, from session: MQTTSession) {
        let receiveStr = String(data: data, encoding: .utf8)
        print("mqttDidReceive message = \(receiveStr ?? "") topic = \(topic)")
        // create a new style
        var style = ToastStyle()
        
        // this is just one of many style options
        style.messageColor = .white
        
        // present the toast with the new style
        self.view.makeToast("message:\(receiveStr ?? "")", duration: 2.0, position: .top, title: "topic:\(topic)", image: nil,style: style)
    }
    
    func mqttDidDisconnect(session: MQTTSession) {
        print("mqttDidDisconnect")
    }
    
    func mqttSocketErrorOccurred(session: MQTTSession) {
        print("mqttSocketErrorOccurred")
    }
}

