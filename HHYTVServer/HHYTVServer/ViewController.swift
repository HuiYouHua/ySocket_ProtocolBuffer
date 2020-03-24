//
//  ViewController.swift
//  HHYTVServer
//
//  Created by 华惠友 on 2020/3/23.
//  Copyright © 2020 com.development. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var statusLabel: UILabel!
    fileprivate lazy var serverMgr : ServerManager = ServerManager()

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func startRunning(_ sender: UIButton) {
        serverMgr.startRunning()
        statusLabel.text = "服务器已开启"
    }
    
    @IBAction func stopRunning(_ sender: UIButton) {
        serverMgr.stopRunning()
        statusLabel.text = "服务器已关闭"
    }
}

