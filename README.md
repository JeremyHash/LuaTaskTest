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
LuaTaskTestConfig = {
    modType = "8910",
    aliyunTest = {
        aliyunMqttTest = false,
        aliyunOtaTest  = false
    },
    httpTest = {
        getTest                        = false,
        getTestWithCA                  = false,
        getTestWithCAAndKey            = false,
        getTestAndSaveToBigFile        = false,
        getTestAndSaveToSmallFile      = false,
        postTest                       = false,
        postTestWithUserHead           = false,
        postTestWithOctetStream        = false,
        postTestWithMultipartFormData  = false,
        postTestWithXwwwformurlencoded = false
    },
    socketTest = false,
    mqttTest = false,
    baseTest = {
        adcTest      = false,
        bitTest      = false,
        packTest     = false,
        stringTest   = false,
        commonTest   = false,
        miscTest     = false,
        netTest      = false,
        ntpTest      = false,
        nvmTest      = false,
        tableTest    = false,
        pmTest       = false,
        powerKeyTest = false,
        rilTest      = false,
        simTest      = false,
        sysTest      = false,
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
    gpioTest = {
        gpioIntTest = false,
        gpioOutTest = false,
        ledTest     = false
    },
    fsTest = {
        sdCardTest      = false,
	    insideFlashTest = false
    },
    keyPadCallSmsTest = {
        callTest = false,
        smsTest  = false
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
    }
}
```
 + 参考合宙官方教程烧录脚本进行测试