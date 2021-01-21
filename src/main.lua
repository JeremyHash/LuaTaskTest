-- LuaTaskTest
-- Author:LuatTest
-- CreateDate:20200716
-- UpdateDate:20201112

PROJECT = "LuaTaskTest"
VERSION = "1.0.0"
PRODUCT_KEY = "LMe0gb26NhPbBZ7t3mSk3dxA8f4ZZmM1"

require "log"
LOG_LEVEL = log.LOGLEVEL_INFO

-- lib依赖管理
require "sys"
require "led"
require "net"
require "common"
require "utils"
require "misc"
require "ntp"
require "http"
require "socket"
require "mqtt"
require "audio"
require "pins"
require "record"
require "cc"
require "sms"
require "uiWin"
require "scanCode"
require "lbsLoc"
require "wifiScan"
require "pm"
require "nvm"
require "aLiYun"
require "pb"
-- require "wdt"
require "wifiScan"

-- 测试配置 设置为true代表开启此项测试
LuaTaskTestConfig = {
    modType = "8910",
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
        asyncTcpTest = false,
        asyncUdpTest = false,
        errorIPTest  = false
    },
    mqttTest = false,
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
    },
    bluetoothTest = {
        masterTest    = false,
        slaveTest     = false,
        btWifiTdmTest = false
    }
}

-- require "console"
-- console.setup(1, 115200)

-- 保持唤醒
-- pm.wake("LuaTaskTest")

-- sys.taskInit(
--     function()
--         ril.regUrc("RING", function ()
--             ril.request("ATA")
--         end)
--     end
-- )

require "netLed"

if LuaTaskTestConfig.modType == "8910" then
    -- 8910
    pmd.ldoset(2, pmd.LDO_VLCD)
    netLed.setup(true, pio.P0_1, pio.P0_4)
elseif LuaTaskTestConfig.modType == "1802" or LuaTaskTestConfig.modType == "1802S" then
    -- 1802/1802S
    netLed.setup(true, 64, 65)
end

-- netLed.updateBlinkTime("GPRS", 500, 500)

-- require "errDump"
-- errDump.request("udp://ota.airm2m.com:9072")

if LuaTaskTestConfig.updateTest then
    sys.taskInit(
        function()
            sys.waitUntil("IP_READY_IND")
            log.info("UpdateTest","成功访问网络, FOTA升级测试开始，当前版本 : " .. rtos.get_version() .. " VERSION : " .. VERSION)
            require "update"
            -- update.request()
            update.request(nil, "http://wiki.airm2m.com:48000/fota.bin")
        end
    )
end

for k, v in pairs(LuaTaskTestConfig.aliyunTest) do
    if v then
        require "AliyunTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.httpTest) do
    if v then
        require "HttpTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.socketTest) do
    if v then
        require "SocketTest"
        break
    end
end

if LuaTaskTestConfig.mqttTest then
    require "MqttTest"
end

for k, v in pairs(LuaTaskTestConfig.baseTest) do
    if v then
        require "BaseTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.audioTest) do
    if v then
        require "AudioTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.gpioTest) do
    if v then
        require "GpioTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.fsTest) do
    if v then
        require "FsTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.keyPadCallSmsTest) do
    if v then
        require "KeyPadCallSmsTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.dispTest) do
    if v then
        require "DispTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.lbsLocTest) do
    if v then
        require "LbsLocTest"
        break
    end
end

if LuaTaskTestConfig.uartTransferTest then
    require "UartTransferTest"
end

for k, v in pairs(LuaTaskTestConfig.cryptoTest) do
    if v then
        require "CryptoTest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.i2cAndSpiTest) do
    if v then
        require "I2CAndSPITest"
        break
    end
end

for k, v in pairs(LuaTaskTestConfig.bluetoothTest) do
    if v then
        require "BluetoothTest"
        break
    end
end

sys.taskInit(
            function()
                while true do
                    log.info("VERSION", rtos.get_version(), VERSION)
				    log.info("FSFREESIZE", rtos.get_fs_free_size() .. " Bytes")
                    log.info("RAMUSEAGE", collectgarbage("count") .. " KB")
                    local timeTable = misc.getClock()
                    log.info("TIME", string.format("%d-%d-%d %d:%d:%d", timeTable.year, timeTable.month, timeTable.day, timeTable.hour, timeTable.min, timeTable.sec))
                    sys.wait(30000)
                end
            end
)

-- 自动校准时间
ntp.timeSync(
            1, 
            function()
                log.info("ntp.timeSync", "AutoTimeSync is Done !")
            end
)

-- 死机断言
ril.request("AT*EXASSERT=1")

-- 开启APTRACE
ril.request("AT^TRACECTRL=0,1,1")

--启动系统框架
sys.init(0, 0)
sys.run()
