//
//  ServerManager.swift
//  HHYTVServer
//
//  Created by 华惠友 on 2020/3/23.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit
var serverport = 8080

class ServerManager: NSObject {
    var serverSocket:TCPServer=TCPServer(addr: "192.168.1.101", port: serverport)
    
    fileprivate var isServerRunning : Bool = false
    fileprivate lazy var clientMrgs : [ClientManager] = [ClientManager]()

    func startRunning() {
        // 1.开启监听
        _ = serverSocket.listen()
        isServerRunning = true
        
        // 2.开始接受客户端
        DispatchQueue.global().async {
            while self.isServerRunning {
                if let client = self.serverSocket.accept() {
                    DispatchQueue.global().async {
                        print("有客户端连上了")
                        self.handlerClient(client)
                    }
                }
            }
        }
    }
    
    func stopRunning() {
        isServerRunning = false
    }
    
}

extension ServerManager {
    fileprivate func handlerClient(_ client : TCPClient) {
        // 1.用一个ClientManager管理TCPClient
        let mgr = ClientManager(tcpClient: client)
        mgr.delegate = self
        
        // 2.保存客户端
        clientMrgs.append(mgr)
        
        // 3.用client开始接受消息
        mgr.startReadMsg()
    }
}

extension ServerManager : ClientManagerDelegate {
    func sendMsgToClient(_ data: Data) {
        for mgr in clientMrgs {
            _ = mgr.tcpClient.send(data: data)
        }
    }
    
    func closeClient(_ clientManager: ClientManager) {
        guard let index = clientMrgs.firstIndex(of: clientManager) else { return }
        clientMrgs.remove(at: index)
    }
}
