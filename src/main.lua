-- LuaTaskTest
-- Author:LuatTest
-- CreateDate:20200716
-- UpdateDate:20201112

PROJECT = "LuaTaskTest"
VERSION = "1.0.0"
PRODUCT_KEY = "LMe0gb26NhPbBZ7t3mSk3dxA8f4ZZmM1"

-- 测试配置 设置为true代表开启此项测试
LuaTaskTestConfig = {
    modType = "1802S",
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
        adcTest      = true,
        bitTest      = true,
        packTest     = true,
        stringTest   = true,
        commonTest   = true,
        miscTest     = true,
        netTest      = false,
        ntpTest      = true,
        nvmTest      = true,
        tableTest    = true,
        pmTest       = true,
        powerKeyTest = true,
        rilTest      = true,
        simTest      = true,
        sysTest      = false,
        jsonTest     = true,
        rtosTest     = true,
        mathTest     = true,
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
        base64Test    = false,
        macMd5Test    = false,
        xteaTest      = false,
        lowMd5Test    = false,
        d5Test        = false,
        macSha1Test   = false,
        ha1Test       = false,
        ha256Test     = false,
        macSha256Test = false,
        rcTest        = false,
        esTest        = false,
        saTest        = false
    },
    i2cAndSpiTest = {
        I2CTest = false,
        SPITest = false
    }
}

require "log"
LOG_LEVEL = log.LOGLEVEL_TRACE

-- require "console"
-- console.setup(2, 115200)

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

-- require "update"
-- update.request(nil, "http://117.51.140.119:8000/jeremy.bin")
-- update.request()


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
-- require "audio"
require "pins"
-- require "record"
require "cc"
require "sms"
-- require "uiWin"
-- require "scanCode"
require "lbsLoc"
-- require "wifiScan"
require "pm"
require "nvm"
require "powerKey"
require "aLiYun"
require "pb"
-- require "wdt"

-- 屏幕驱动文件管理
-- require "color_lcd_spi_ILI9341"
-- require "color_lcd_spi_gc9106l"
-- require "color_lcd_spi_st7735"
-- require "color_lcd_spi_st7735S"

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

if LuaTaskTestConfig.socketTest then
    require "SocketTest"
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

-- require "AudioTest"

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

-- require "DispTest"

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

-- 保持唤醒
pm.wake("LuaTaskTest")

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

--启动系统框架
sys.init(0, 0)
sys.run()
