# LuaTaskTest

#### 介绍
合宙LuaTask 自动化测试工具
#### 软件架构
 + Lua V5.1
 + LuaTask V2.3.5
#### 功能模块
 + aliyunTest       
 + httpTest         
 + socketTest       
 + mqttTest         
 + baseTest         
 + audioTest        
 + gpioTest         
 + fsTest           
 + keyPadCallSmsTest
 + dispTest         
 + lbsLocTest       
 + uartTransferTest 
 + cryptoTest       
 + i2cAndSpiTest    
#### 使用说明
 + 测试单元的开关控制查看src/main.lua
```
-- 测试配置 设置为true代表开启此项测试
local LuatTaskTestConfig = {
    aliyunTest        = false,
    httpTest          = false,
    socketTest        = false,
    mqttTest          = true,
    baseTest          = false,
    audioTest         = false,
    gpioTest          = false,
    fsTest            = false,
    keyPadCallSmsTest = false,
    dispTest          = false,
    lbsLocTest        = false,
    uartTransferTest  = false,
    cryptoTest        = false,
    i2cAndSpiTest     = false
}
```
 + 参考合宙官方教程烧录脚本进行测试