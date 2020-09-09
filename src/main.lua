-- LuaTaskTest
-- Author:LuatTest
-- CreateDate:20200716
-- UpdateDate:20200908

PROJECT = "LuaTaskTest"
VERSION = "1.0.0"
PRODUCT_KEY = "LMe0gb26NhPbBZ7t3mSk3dxA8f4ZZmM1"

require "log"
LOG_LEVEL = log.LOGLEVEL_TRACE

-- require "console"
-- console.setup(2, 115200)

require "netLed"
pmd.ldoset(2,pmd.LDO_VLCD)
netLed.setup(true,pio.P0_1,pio.P0_4)

require "errDump"
errDump.request("udp://ota.airm2m.com:9072")

-- require "update"
-- update.request()
-- update.request(nil,"http://118.25.149.191:8000/ota.bin")

-- 屏幕驱动文件管理
-- require "color_lcd_spi_ILI9341"
-- require "color_lcd_spi_gc9106l"
-- require "color_lcd_spi_st7735"

-- lib依赖管理
require "sys"
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
require "uiWin"
require "scanCode"
require "lbsLoc"
require "pm"

-- 保持唤醒
pm.wake("LuaTaskTest")


--加载Http功能测试模块
-- require "HttpTest"

--加载Socket功能测试模块
-- require "SocketTest"

--加载Mqtt功能测试模块
-- require "MqttTest"

--加载Audio功能测试模块
-- require "AudioTest"

--加载Gpio功能测试模块
-- require "GpioTest"

--加载文件功能测试模块
-- require "FsTest"

--加载Call功能测试模块
-- require "CallTest"

--加载Disp功能测试模块
-- require "DispTest"

--加载KeyPad功能测试模块
-- require "KeyPadTest"

--加载LbsLoc功能测试模块
-- require "LbsLocTest"

--加载Ril功能测试模块
require "RilTest"

sys.taskInit(function()
    while true do
        log.info("VERSION", rtos.get_version(), _G.VERSION)
        sys.wait(10000)
    end
end)

-- 自动校准时间
ntp.timeSync(1,function()log.info("----------------> AutoTimeSync is Done ! <----------------")end)

-- 死机断言
ril.request("AT*EXASSERT=1")

--启动系统框架
sys.init(0, 0)
sys.run()
