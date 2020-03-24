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
    
    init(tcpClient: TCPClient) {
        self.tcpClient = tcpClient
    }
}

extension ClientManager {
    func startReadMsg() {
        isClientConnected = true
        while isClientConnected {
            if let lmsg = tcpClient.read(4) {
                // 1.读取长度的data
                let lmsgData = Data(bytes: lmsg, count: 4)
                var length: Int = 0
                (lmsgData as NSData).getBytes(&length, length: 4)
                
                // 2.读取类型
                guard let typeMsg = tcpClient.read(2) else {
                    return
                }
                let typeData = Data(bytes: typeMsg, count: 2)
                var type: Int = 0
                (typeData as NSData).getBytes(&type, length: 2)
                
                // 3.根据长度,读取真实消息
                guard let msg = tcpClient.read(length) else {
                    return
                }
                let msgData = Data(bytes: msg, count: length)
                
                /**
                switch type {
                case 0, 1:
                    let user = try! UserInfo.parseFrom(data: msgData)
                    print(user.name + "__" + String(user.level) + user.iconUrl)
                default:
                    print("未知类型")
                }
                 */
                
                
                let totalData = lmsgData + typeData + msgData
                delegate?.sendMsgToClient(totalData)

            } else {
                isClientConnected = false
                _ = tcpClient.close()
                delegate?.closeClient(self)
                print("客户端断开了连接")
            }
        }
    }
}
