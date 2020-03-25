//
//  ViewController.swift
//  HHYTVClient
//
//  Created by 华惠友 on 2020/3/23.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    fileprivate lazy var socket: HHYSocket = HHYSocket(addr: "192.168.1.101", port: 8080)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if socket.connectServer() {
            print("连接上了服务器")
            socket.startReadMsg()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        print("发送消息")
    }

    @IBAction func joinRoom(_ sender: UIButton) {
        socket.sendJoinRoom()
    }
    
    @IBAction func leaveRoom(_ sender: UIButton) {
        socket.sendLeaveRoom()
    }
    
    @IBAction func sendTextMsg(_ sender: UIButton) {
        socket.sendTextMsg(message: "大家好,我来啦")
    }
    
    @IBAction func sendGiftMsg(_ sender: UIButton) {
        socket.sendGiftMsg(giftName: "游轮", giftURL: "http://youlun", giftCount: 10)
    }
    
}
