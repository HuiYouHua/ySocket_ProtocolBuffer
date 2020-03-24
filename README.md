# ySocket_ProtocolBuffer
swift下采用ySocket实现通信，ProtocolBuffer实现数据传输解析

HHYTVServer：服务端

HHYTVClient：客户端

发送有四种消息：

- 进入房间消息，type = 0
- 离开房间消息，type = 1
- 发送文本消息，type = 2
- 发送礼物消息，type = 3



###ProtocolBuffer在swift5、Xcode11中集成：

**ProtocolBuffer环境安装**

- ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

- brew install automake

- brew install libtool

- brew install protobuf

- **brew install protobuf-swift**`没有这一步，proto文件转swift会失败`




客户端集成**cocoaPods

```
use_frameworks!
pod 'ProtocolBuffers-Swift'
```



**服务器集成**

因为服务器使用Mac编写,不能直接使用cocoapods集成

因为需要将工程编译为静态库来集成

到Git中下载整个库

执行脚本: ./scripts/build.sh

添加: ./src/ProtocolBuffers/ProtocolBuffers.xcodeproj到项目中

**ProtocolBuffer的使用**
创建.proto文件
.proto文件代码编写完成后, 生成对应语言代码

```
protoc xxx.proto --swift_out="./"
```

