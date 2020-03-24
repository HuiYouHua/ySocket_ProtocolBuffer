//
//  ClientManager.swift
//  HHYTVServer
//
//  Created by 华惠友 on 2020/3/23.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

protocol ClientManagerDelegate: class {
    func sendMsgToClient(_ data: Data)
    func closeClient(_ clientManager: ClientManager)
}

class ClientManager: NSObject {
    var tcpClient: TCPClient
    
    weak var delegate: ClientManagerDelegate?
    
    fileprivate var isClientConnected: Bool = false
    
    fileprivate var heartTimeCount: Int = 0
    fileprivate var timer: Timer!
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
    
    deinit {
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
}

extension ClientManager {
    func startReadMsg() {
        
        isClientConnected = true
        timer = Timer(fireAt: Date(), interval: 1, target: self, selector: #selector(checkHeaterBeat), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
        timer.fire()
        
        while isClientConnected {
            if let lmsg = tcpClient.read(4) {
                // 1.读取长度的data
                let lmsgData = Data(bytes: lmsg, count: 4)
                var length: Int = 0
                (lmsgData as NSData).getBytes(&length, length: 4)
                
                // 2.读取类型
                guard let typeMsg = tcpClient.read(2) else { return }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                print("收到的消息类型" + "\(type)")
                
                // 3.根据长度,读取真实消息
                guard let msg = tcpClient.read(length) else { return }
                let msgData = Data(bytes: msg, count: length)
                
                if type == 1 {
                    print("离开房间,客户端主动断开连接")
                    self.removeClient()
                } else if type == 100 {    // 收到心跳
                    heartTimeCount = 0
                    let heatMsg = String(data: msgData, encoding: .utf8)!
                    print("收到心跳:" + heatMsg)
                    continue
                }
                
                let totalData = lmsgData + typeData + msgData
                delegate?.sendMsgToClient(totalData)
                
            } else {
                print("客户端断开了连接")
                self.removeClient()
            }
        }
    }
    
    // 心跳处理
    @objc fileprivate func checkHeaterBeat() {
        heartTimeCount += 1
        if heartTimeCount >= 10 {
            print("心跳断开,客户端断开了连接")
            removeClient()
        }
    }
    
    private func removeClient() {
        delegate?.closeClient(self)
        _ = tcpClient.close()
        if timer != nil {
            timer.invalidate()
            timer = nil
        }
    }
}
