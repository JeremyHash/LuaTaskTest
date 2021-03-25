# LuaTaskTest

#### 介绍
合宙LuaTask 自动化测试工具
#### 软件架构
 + Lua V5.1
 + LuaTask V2.3.8
#### 功能模块
 + consoleTest
 + aliyunTest       
 + httpTest         
 + socketTest       
 + mqttTest   
 + updateTest      
 + baseTest         
 + audioTest        
 + gpioTest         
 + fsTest           
 + keyPadCallSmsTest
 + dispTest         
 + lbsLocTest       
 + uartTransferTest 
 + RS485Test
 + cryptoTest       
 + i2cAndSpiTest    
 + bluetoothTest
#### 使用说明
 + 测试单元的开关控制查看src/main.lua
```
-- 测试配置 设置为true代表开启此项测试
LuaTaskTestConfig = {
    modType     = "8910",
    netLed      = true,
    consoleTest = false,
    aliyunTest = {
        aliyunMqttTest = false,
        aliyunOtaTest  = false
    },
    httpTest = {
        getTest                        = false,
        getWaitTest                    = false,
        get301Test                     = false,
        get302Test                     = false,
        getTestWithCA                  = false,
        getTestWithCAAndKey            = false,
        getTestAndSaveToBigFile        = false,
        getTestAndSaveToSmallFile      = false,
        postTest                       = false,
        postJsonTest                   = false,
        postTestWithUserHead           = false,
        postTestWithOctetStream        = false,
        postTestWithMultipartFormData  = false,
        postTestWithXwwwformurlencoded = false,
        headTest                       = false,
        putTest                        = false,
        deleteTest                     = false
    },
    socketTest = {
        syncTcpTest  = false,
        syncUdpTest  = false,
        asyncTest    = false,
    },
    mqttTest   = false,
    updateTest = false,
    baseTest = {
        -- netTest，sysTest 要单独测试
        netTest      = false,
        sysTest      = false,
        adcTest      = false,
        bitTest      = false,
        packTest     = false,
        stringTest   = false,
        commonTest   = false,
        miscTest     = false,
        ntpTest      = false,
        nvmTest      = false,
        tableTest    = false,
        pmTest       = false,
        powerKeyTest = false,
        rilTest      = false,
        simTest      = false,
        jsonTest     = false,
        rtosTest     = false,
        mathTest     = false,
        pbTest       = false
    },
    audioTest = {
        audioPlayTest     = false,
        audioStreamTest   = false,
        recordTest        = false
    },
    usbAudioTest = false,
    gpioTest = {
        gpioIntTest = false,
        gpioInTest  = false,
        gpioOutTest = false,
        ledTest     = false
    },
    fsTest = {
        sdCardTest      = false,
	    insideFlashTest = false
    },
    keyPadCallSmsTest = {
        keypadTest = false,
        callTest   = false,
        smsTest    = false
    },
    dispTest = {
        logoTest        = false,
        scanTest        = false,
        photoTest       = false,
        photoSendTest   = false,
        qrcodeTest      = false,
        uiWinTest       = false
    },
    lbsLocTest = {
        cellLocTest = false,
        wifiLocTest = false,
        gpsLocTest  = false
    },
    uartTransferTest  = false,
    RS485Test         = false,
    cryptoTest = {
        base64Test     = false,
        hmacMd5Test    = false,
        xxteaTest      = false,
        flowMd5Test    = false,
        md5Test        = false,
        hmacSha1Test   = false,
        sha1Test       = false,
        sha256Test     = false,
        hmacSha256Test = false,
        crcTest        = false,
        aesTest        = false,
        rsaTest        = false
    },
    i2cAndSpiTest = {
        I2CTest = false,
        SPITest = false
    },
    bluetoothTest = {
        masterTest = false,
        slaveTest  = false,
        beaconTest = false,
        scanTest   = false
    }
}
```
 + 参考合宙官方教程烧录脚本进行测试