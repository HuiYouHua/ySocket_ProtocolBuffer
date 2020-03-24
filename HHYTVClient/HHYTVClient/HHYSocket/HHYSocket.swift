//
//  HHYSocket.swift
//  HHYTVClient
//
//  Created by 华惠友 on 2020/3/23.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

protocol HHYSocketDelegate: class {
    func socket(_ socket: HHYSocket, joinRoom user: UserInfo)
    func socket(_ socket: HHYSocket, leaveRoom user: UserInfo)
    func socket(_ socket: HHYSocket, chatMessage: ChatMessage)
    func socket(_ socket: HHYSocket, giftMessage: GiftMessage)
}

class HHYSocket {
    weak var delegate: HHYSocketDelegate?
    
    fileprivate var timer: Timer!

    fileprivate var tcpClient: TCPClient
    fileprivate var userInfo: UserInfo.Builder = {
       let userInfo = UserInfo.Builder()
        userInfo.name = "huayoyu\(arc4random_uniform(10))"
        userInfo.level = 20
        userInfo.iconUrl = "icon\(arc4random_uniform(10))"
        return userInfo
    }()
    
    init(addr: String, port: Int) {
        tcpClient = TCPClient(addr: addr, port: port)
    }
    
    deinit {
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
    }
    
}

extension HHYSocket {
    func connectServer() -> Bool {
        let (status, _) = tcpClient.connect(timeout: 5)
        if status {
            // 心跳定时器
            timer = Timer(fireAt: Date(), interval: 9, target: self, selector: #selector(sendHeatBeat), userInfo: nil, repeats: true)
            RunLoop.main.add(timer, forMode: .common)
        }
        return status
    }
    
    func startReadMsg() {
        DispatchQueue.global().async {
            while true {
                guard let lmsg = self.tcpClient.read(4) else { continue }
                
                // 1.读取长度的data
                let lmsgData = Data(bytes: lmsg, count: 4)
                var length: Int = 0
                (lmsgData as NSData).getBytes(&length, length: 4)
                
                // 2.读取类型
                guard let typeMsg = self.tcpClient.read(2) else {
                    return
                }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                
                // 3.根据长度,读取真实消息
                guard let msg = self.tcpClient.read(length) else {
                    return
                }
                let msgData = Data(bytes: msg, count: length)
                
                // 4.处理消息
                DispatchQueue.main.async {
                    self.handleMsg(type: type, msgData: msgData)
                }
            }
        }
    }
    
    fileprivate func handleMsg(type: Int, msgData: Data) {
        switch type {
        case 0:
            let msg = try! UserInfo.parseFrom(data: msgData)
            delegate?.socket(self, joinRoom: msg)
            print("收到了加入房间消息:" + msg.name + "__" + String(msg.level) + "__" + msg.iconUrl)
        case 1:
            let msg = try! UserInfo.parseFrom(data: msgData)
            delegate?.socket(self, leaveRoom: msg)
            print("收到了离开房间消息:" + msg.name + "__" + String(msg.level) + "__" + msg.iconUrl)
        case 2:
            let msg = try! ChatMessage.parseFrom(data:
                msgData)
            delegate?.socket(self, chatMessage: msg)
            print("收到了文本消息:" + msg.user.name + "__" + msg.text)
        case 3:
            let msg = try! GiftMessage.parseFrom(data: msgData)
            delegate?.socket(self, giftMessage: msg)
            print("收到了礼物消息:" + msg.user.name + "__" + msg.giftname + "__" + msg.giftUrl + "__" + String(msg.giftcount))
        default:
            print("未知类型")
        }
    }
}

extension HHYSocket {
    func sendJoinRoom() {
        // 1.获取消息的长度
        let msgData = (try! userInfo.build()).data()
        
        // 2.发送消息
        sendMsg(data: msgData, type: 0)
    }
    
    func sendLeaveRoom() {
        // 1.获取消息的长度
        let msgData = (try! userInfo.build()).data()
        
        // 2.发送消息
        sendMsg(data: msgData, type: 1)
    }
    
    func sendTextMsg(message: String) {
        // 1.创建TextMessag类型
        let chatMsg = ChatMessage.Builder()
        chatMsg.text = message
        chatMsg.user = try! userInfo.build()
        
        // 2.获取对应的data
        let chatData = (try! chatMsg.build()).data()
        
        // 3.发送消息
        sendMsg(data: chatData, type: 2)
    }
    
    func sendGiftMsg(giftName: String, giftURL: String, giftCount: Int) {
        // 1.创建TextMessag类型
        let giftMsg = GiftMessage.Builder()
        giftMsg.giftname = giftName
        giftMsg.giftUrl = giftURL
        giftMsg.giftcount = Int32(giftCount)
        giftMsg.user = try! userInfo.build()
        
        // 2.获取对应的data
        let giftData = (try! giftMsg.build()).data()
        
        // 4.发送消息
        sendMsg(data: giftData, type: 3)
    }
    
    
    fileprivate func sendMsg(data: Data, type: Int) {
        // 1.获取消息的长度
        var length = data.count
        
        // 2.将消息长度,写入到data
        let headerData = Data(bytes: &length, count: 4)
        
        // 3.消息的类型
        var tmpType = type
        let typeData = Data(bytes: &tmpType, count: 2)
        
        // 4.发送消息
        let totalData = headerData + typeData + data
        let _ = tcpClient.send(data: totalData)
    }
    

}

extension HHYSocket {
    // 发送ping心跳
    @objc fileprivate func sendHeatBeat() {
        let heatString = "#"
        let heatData = heatString.data(using: .utf8)!
        print("发送心跳:" + heatString)
        sendMsg(data: heatData, type: 100)
    }
}
