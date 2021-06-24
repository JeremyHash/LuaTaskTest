-- DispTest
-- Author:LuatTest
-- CreateDate:20200719
-- UpdateDate:20201025
module(..., package.seeall)

local waitTime1 = 2000
local waitTime2 = 5000

-- 屏幕驱动文件管理
-- require "color_lcd_spi_ILI9341"
-- require "color_lcd_spi_gc9106l"
-- require "color_lcd_spi_st7735"
-- require "color_lcd_spi_st7735S"

local gc0310_sdr = {
    zbar_scan = 1,
    i2c_addr = 0x21,
    sensor_width = 320,
    sensor_height = 240,
    id_reg = 0xf1,
    id_value = 0x10,
    spi_mode = disp.CAMERA_SPI_MODE_LINE2,
    spi_speed = disp.CAMERA_SPEED_SDR,
    spi_yuv_out = disp.CAMERA_SPI_OUT_Y1_V0_Y0_U0,

    init_cmd = {

        0xfe, 0xf0, 0xfe, 0xf0, 0xfe, 0x00, 0xfc, 0x16, -- 4e 
        0xfc, 0x16, -- 4e -- [0]apwd [6]regf_clk_gate 
        0xf2, 0x07, -- sync output
        0xf3, 0x83, -- ff--1f--01 data output
        0xf5, 0x07, -- sck_dely
        0xf7, 0x88, -- f8/   88
        0xf8, 0x00, -- 00
        0xf9, 0x4f, -- 0f--01   4d
        0xfa, 0x32, -- 32
        0xfc, 0xce, 0xfd, 0x00,
        ------------------------------------------------/
        ----------------/   CISCTL reg  ----------------/
        ------------------------------------------------/
        0x00, 0x2f, 0x01, 0x0f, 0x02, 0x04, 0x03, 0x02, 0x04, 0x12, 0x09, 0x00,
        0x0a, 0x00, 0x0b, 0x00, 0x0c, 0x02, -- 04 
        0x0d, 0x01, 0x0e, 0xec, -- e8 
        0x0f, 0x02, 0x10, 0x88, 0x16, 0x00, 0x17, 0x14, 0x18, 0x6a, -- 1a 
        0x19, 0x14, 0x1b, 0x48, 0x1c, 0x1c, 0x1e, 0x6b, 0x1f, 0x28, 0x20, 0x8b, -- 0x89 travis20140801
        0x21, 0x49, 0x22, 0xb0, 0x23, 0x04, 0x24, 0xff, 0x34, 0x20,

        ------------------------------------------------/
        --------------------   BLK   --------------------
        ------------------------------------------------/
        0x26, 0x23, 0x28, 0xff, 0x29, 0x00, 0x32, 0x00, 0x33, 0x10, 0x37, 0x20,
        0x38, 0x10, 0x47, 0x80, 0x4e, 0x0f, -- 66
        0xa8, 0x02, 0xa9, 0x80,

        ------------------------------------------------/
        ------------------   ISP reg  ------------------/
        ------------------------------------------------/
        0x40, 0xff, 0x41, 0x21, 0x42, 0xcf, 0x44, 0x02, 0x45, 0xa8, 0x46, 0x02, -- sync
        0x4a, 0x11, 0x4b, 0x01, 0x4c, 0x20, 0x4d, 0x05, 0x4f, 0x01, 0x50, 0x01,
        0x55, 0x00, 0x56, 0xf0, 0x57, 0x01, 0x58, 0x40,
        ------------------------------------------------/
        ------------------/   GAIN   --------------------
        ------------------------------------------------/
        0x70, 0x70, 0x5a, 0x84, 0x5b, 0xc9, 0x5c, 0xed, 0x77, 0x74, 0x78, 0x40,
        0x79, 0x5f, ------------------------------------------------/ 
        ------------------/   DNDD  --------------------/
        ------------------------------------------------/ 
        0x82, 0x08, -- 0x14 
        0x83, 0x0b, 0x89, 0xf0,
        ------------------------------------------------/ 
        ------------------   EEINTP  --------------------
        ------------------------------------------------/ 
        0x8f, 0xaa, 0x90, 0x8c, 0x91, 0x90, 0x92, 0x03, 0x93, 0x03, 0x94, 0x05,
        0x95, 0x43, -- 0x65
        0x96, 0xf0, ------------------------------------------------/ 
        --------------------/  ASDE  --------------------
        ------------------------------------------------/ 
        0xfe, 0x00, 0x9a, 0x20, 0x9b, 0x80, 0x9c, 0x40, 0x9d, 0x80, 0xa1, 0x30,
        0xa2, 0x32, 0xa4, 0x30, 0xa5, 0x30, 0xaa, 0x10, 0xac, 0x22,

        ------------------------------------------------/
        ------------------/   GAMMA   ------------------/
        ------------------------------------------------/
        0xfe, 0x00, 0xbf, 0x08, 0xc0, 0x1d, 0xc1, 0x34, 0xc2, 0x4b, 0xc3, 0x60,
        0xc4, 0x73, 0xc5, 0x85, 0xc6, 0x9f, 0xc7, 0xb5, 0xc8, 0xc7, 0xc9, 0xd5,
        0xca, 0xe0, 0xcb, 0xe7, 0xcc, 0xec, 0xcd, 0xf4, 0xce, 0xfa, 0xcf, 0xff,

        ------------------------------------------------/
        ------------------/   YCP  ----------------------
        ------------------------------------------------/
        0xd0, 0x40, 0xd1, 0x38, -- 0x34
        0xd2, 0x38, -- 0x34
        0xd3, 0x50, -- 0x40 
        0xd6, 0xf2, 0xd7, 0x1b, 0xd8, 0x18, 0xdd, 0x03,

        ------------------------------------------------/
        --------------------   AEC   --------------------
        ------------------------------------------------/
        0xfe, 0x01, 0x05, 0x30, 0x06, 0x75, 0x07, 0x40, 0x08, 0xb0, 0x0a, 0xc5,
        0x0b, 0x11, 0x0c, 0x00, 0x12, 0x52, 0x13, 0x38, 0x18, 0x95, 0x19, 0x96,
        0x1f, 0x20, 0x20, 0xc0, 0x3e, 0x40, 0x3f, 0x57, 0x40, 0x7d, 0x03, 0x60,

        0x44, 0x02, ------------------------------------------------/
        --------------------   AWB   --------------------
        ------------------------------------------------/
        0xfe, 0x01, 0x1c, 0x91, 0x21, 0x15, 0x50, 0x80, 0x56, 0x04, 0x59, 0x08,
        0x5b, 0x02, 0x61, 0x8d, 0x62, 0xa7, 0x63, 0xd0, 0x65, 0x06, 0x66, 0x06,
        0x67, 0x84, 0x69, 0x08, 0x6a, 0x25, 0x6b, 0x01, 0x6c, 0x00, 0x6d, 0x02,
        0x6e, 0xf0, 0x6f, 0x80, 0x76, 0x80, 0x78, 0xaf, 0x79, 0x75, 0x7a, 0x40,
        0x7b, 0x50, 0x7c, 0x0c, 0x90, 0xc9, -- stable AWB 
        0x91, 0xbe, 0x92, 0xe2, 0x93, 0xc9, 0x95, 0x1b, 0x96, 0xe2, 0x97, 0x49,
        0x98, 0x1b, 0x9a, 0x49, 0x9b, 0x1b, 0x9c, 0xc3, 0x9d, 0x49, 0x9f, 0xc7,
        0xa0, 0xc8, 0xa1, 0x00, 0xa2, 0x00, 0x86, 0x00, 0x87, 0x00, 0x88, 0x00,
        0x89, 0x00, 0xa4, 0xb9, 0xa5, 0xa0, 0xa6, 0xba, 0xa7, 0x92, 0xa9, 0xba,
        0xaa, 0x80, 0xab, 0x9d, 0xac, 0x7f, 0xae, 0xbb, 0xaf, 0x9d, 0xb0, 0xc8,
        0xb1, 0x97, 0xb3, 0xb7, 0xb4, 0x7f, 0xb5, 0x00, 0xb6, 0x00, 0x8b, 0x00,
        0x8c, 0x00, 0x8d, 0x00, 0x8e, 0x00, 0x94, 0x55, 0x99, 0xa6, 0x9e, 0xaa,
        0xa3, 0x0a, 0x8a, 0x00, 0xa8, 0x55, 0xad, 0x55, 0xb2, 0x55, 0xb7, 0x05,
        0x8f, 0x00, 0xb8, 0xcb, 0xb9, 0x9b,

        ------------------------------------------------/
        --------------------  CC ------------------------
        ------------------------------------------------/
        0xfe, 0x01, 0xd0, 0x38, -- skin red
        0xd1, 0x00, 0xd2, 0x02, 0xd3, 0x04, 0xd4, 0x38, 0xd5, 0x12, 0xd6, 0x30,
        0xd7, 0x00, 0xd8, 0x0a, 0xd9, 0x16, 0xda, 0x39, 0xdb, 0xf8,
        ------------------------------------------------/
        --------------------   LSC   --------------------
        ------------------------------------------------/
        0xfe, 0x01, 0xc1, 0x3c, 0xc2, 0x50, 0xc3, 0x00, 0xc4, 0x40, 0xc5, 0x30,
        0xc6, 0x30, 0xc7, 0x10, 0xc8, 0x00, 0xc9, 0x00, 0xdc, 0x20, 0xdd, 0x10,
        0xdf, 0x00, 0xde, 0x00,

        ------------------------------------------------/
        ------------------/  Histogram  ----------------/
        ------------------------------------------------/
        0x01, 0x10, 0x0b, 0x31, 0x0e, 0x50, 0x0f, 0x0f, 0x10, 0x6e, 0x12, 0xa0,
        0x15, 0x60, 0x16, 0x60, 0x17, 0xe0,

        ------------------------------------------------/
        --------------   Measure Window   --------------/
        ------------------------------------------------/
        0xcc, 0x0c, 0xcd, 0x10, 0xce, 0xa0, 0xcf, 0xe6,

        ------------------------------------------------/
        ----------------/   dark sun   ------------------
        ------------------------------------------------/
        0x45, 0xf7, 0x46, 0xff, 0x47, 0x15, 0x48, 0x03, 0x4f, 0x60,

        ------------------------------------------------/
        ------------------/  banding  ------------------/
        ------------------------------------------------/
        0xfe, 0x00, 0x05, 0x01, 0x06, 0x12, -- HB
        0x07, 0x00, 0x08, 0x1c, -- VB
        0xfe, 0x01, 0x25, 0x00, -- step 
        0x26, 0x1f, 0x27, 0x01, -- 6fps
        0x28, 0xf0, 0x29, 0x01, -- 6fps
        0x2a, 0xf0, 0x2b, 0x01, -- 6fps
        0x2c, 0xf0, 0x2d, 0x03, -- 3.3fps
        0x2e, 0xe0, 0x3c, 0x20,
        --------------------/  SPI   --------------------
        ------------------------------------------------/
        0xfe, 0x03, 0x01, 0x00, 0x02, 0x00, 0x10, 0x00, 0x15, 0x00, 0x17, 0x00, -- 01--03
        0x04, 0x10, -- fifo full level
        0x40, 0x00, 0x52, 0x82, -- zwb 02改成da
        0x53, 0x24, -- 24
        0x54, 0x20, 0x55, 0x20, -- QQ--01
        0x5a, 0x00, -- 00 --yuv 
        0x5b, 0x40, 0x5c, 0x01, 0x5d, 0xf0, 0x5e, 0x00, 0x51, 0x03, 0xfe, 0x00

    }
}

local WIDTH, HEIGHT, BPP = disp.getlcdinfo()
local CHAR_WIDTH = 8
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 128, 160
local qrCodeWidth, data = qrencode.encode("二维码生成测试")
local WIDTH1, HEIGHT1 = 132, 162
local appid, str1, str2, str3, callback, callbackpara

function getxpos(str) return (WIDTH - string.len(str) * CHAR_WIDTH) / 2 end

function setcolor(color) if BPP ~= 1 then return disp.setcolor(color) end end

function sendFile(uartID)
    local fileHandle = io.open("/testCamera.jpg", "rb")
    if not fileHandle then
        log.error("DispTest.SendFile", "OpenFile Error")
        return
    end

    pm.wake("UART_SENT2MCU")
    uart.on(uartID, "sent", function() sys.publish("UART_SENT2MCU_OK") end)
    uart.setup(uartID, 115200, 8, uart.PAR_NONE, uart.STOP_1, nil, 1)
    while true do
        local data = fileHandle:read(1460)
        if not data then break end
        uart.write(uartID, data)
        sys.waitUntil("UART_SENT2MCU_OK")
    end

    uart.close(uartID)
    pm.sleep("UART_SENT2MCU")
    fileHandle:close()
end

local pos = {
    {24}, -- 显示1行字符串时的Y坐标
    {10, 37}, -- 显示2行字符串时，每行字符串对应的Y坐标
    {4, 24, 44} -- 显示3行字符串时，每行字符串对应的Y坐标
}

--[[
函数名：refresh
功能  ：窗口刷新处理
参数  ：无
返回值：无
]]
local function refresh()
    disp.clear()
    if str3 then disp.puttext(str3, getxpos(str3), pos[3][3]) end
    if str2 then disp.puttext(str2, getxpos(str2), pos[str3 and 3 or 2][2]) end
    if str1 then
        disp.puttext(str1, getxpos(str1),
                     pos[str3 and 3 or (str2 and 2 or 1)][1])
    end
    disp.update()
end

--[[
函数名：close
功能  ：关闭提示框窗口
参数  ：无
返回值：无
]]
local function close()
    if not appid then return end
    sys.timerStop(close)
    if callback then callback(callbackpara) end
    uiWin.remove(appid)
    appid = nil
end

-- 窗口的消息处理函数表
local app = {onUpdate = refresh}

--[[
函数名：open
功能  ：打开提示框窗口
参数  ：
        s1：string类型，显示的第1行字符串
        s2：string类型，显示的第2行字符串，可以为空或者nil
        s3：string类型，显示的第3行字符串，可以为空或者nil
        cb：function类型，提示框关闭时的回调函数，可以为nil
        cbpara：提示框关闭时回调函数的参数，可以为nil
        prd：number类型，提示框自动关闭的超时时间，单位毫秒，默认3000毫秒
返回值：无
]]
function openprompt(s1, s2, s3, cb, cbpara, prd)
    str1, str2, str3, callback, callbackpara = s1, s2, s3, cb, cbpara
    appid = uiWin.add(app)
    sys.timerStart(close, prd or 3000)
end

--[[
函数名：refresh
功能  ：窗口刷新处理
参数  ：无
返回值：无
]]
local function refresh()
    -- 清空LCD显示缓冲区
    disp.clear()
    local oldColor = setcolor(0xF100)
    disp.puttext(common.utf8ToGb2312("待机界面"),
                 getxpos(common.utf8ToGb2312("待机界面")), 0)
    local tm = misc.getClock()
    local datestr = string.format("%04d", tm.year) .. "-" ..
                        string.format("%02d", tm.month) .. "-" ..
                        string.format("%02d", tm.day)
    local timestr = string.format("%02d", tm.hour) .. ":" ..
                        string.format("%02d", tm.min)
    -- 显示日期
    setcolor(0x07E0)
    disp.puttext(datestr, getxpos(datestr), 24)
    -- 显示时间
    setcolor(0x001F)
    disp.puttext(timestr, getxpos(timestr), 44)

    -- 刷新LCD显示缓冲区到LCD屏幕上
    disp.update()
    setcolor(oldColor)
end

-- 窗口类型的消息处理函数表
local winapp = {onUpdate = refresh}

--[[
函数名：open
功能  ：打开待机界面窗口
参数  ：无
返回值：无
]]
function openidle() appid2 = uiWin.add(winapp) end

function scanCodeCb(result, codeType, codeStr)
    -- 关闭摄像头预览
    disp.camerapreviewclose()
    -- 关闭摄像头
    disp.cameraclose()
    -- 允许系统休眠
    pm.sleep("DispTest.ScanTest")
    -- 如果有LCD，显示扫描结果
    if WIDTH ~= 0 and HEIGHT ~= 0 then
        disp.clear()
        if result then
            disp.puttext(common.utf8ToGb2312("扫描成功"), 0, 5)
            disp.puttext(common.utf8ToGb2312("类型: ") .. codeType, 0, 35)
            log.info("DispTest.ScanCodeCb.CodeStr", codeStr:toHex())
            disp.puttext(common.utf8ToGb2312("结果: ") .. codeStr, 0, 65)
        else
            disp.puttext(common.utf8ToGb2312("扫描失败"), 0, 5)
        end
        disp.update()
    end
end

if LuaTaskTestConfig.dispTest.lvglTest then

    local tag = "LvglTest"

    -- lcd_config
    local function init()
        local para = {
            width = 128, -- 分辨率宽度，128像素；用户根据屏的参数自行修改
            height = 160, -- 分辨率高度，160像素；用户根据屏的参数自行修改
            bpp = 16, -- 位深度，彩屏仅支持16位
            bus = lvgl.BUS_SPI4LINE, -- LCD专用SPI引脚接口，不可修改
            xoffset = 2, -- X轴偏移
            yoffset = 1, -- Y轴偏移
            freq = 13000000, -- spi时钟频率，支持110K到13M（即110000到13000000）之间的整数（包含110000和13000000）
            pinrst = pio.P0_14, -- reset，复位引脚
            pinrs = pio.P0_18, -- rs，命令/数据选择引脚
            -- 初始化命令
            -- 前两个字节表示类型：0001表示延时，0000或者0002表示命令，0003表示数据
            -- 延时类型：后两个字节表示延时时间（单位毫秒）
            -- 命令类型：后两个字节命令的值
            -- 数据类型：后两个字节数据的值
            initcmd = {
                0x00020011, 0x00010078, 0x000200B1, 0x00030002, 0x00030035,
                0x00030036, 0x000200B2, 0x00030002, 0x00030035, 0x00030036,
                0x000200B3, 0x00030002, 0x00030035, 0x00030036, 0x00030002,
                0x00030035, 0x00030036, 0x000200B4, 0x00030007, 0x000200C0,
                0x000300A2, 0x00030002, 0x00030084, 0x000200C1, 0x000300C5,
                0x000200C2, 0x0003000A, 0x00030000, 0x000200C3, 0x0003008A,
                0x0003002A, 0x000200C4, 0x0003008A, 0x000300EE, 0x000200C5,
                0x0003000E, 0x00020036, 0x000300C0, 0x000200E0, 0x00030012,
                0x0003001C, 0x00030010, 0x00030018, 0x00030033, 0x0003002C,
                0x00030025, 0x00030028, 0x00030028, 0x00030027, 0x0003002F,
                0x0003003C, 0x00030000, 0x00030003, 0x00030003, 0x00030010,
                0x000200E1, 0x00030012, 0x0003001C, 0x00030010, 0x00030018,
                0x0003002D, 0x00030028, 0x00030023, 0x00030028, 0x00030028,
                0x00030026, 0x0003002F, 0x0003003B, 0x00030000, 0x00030003,
                0x00030003, 0x00030010, 0x0002003A, 0x00030005, 0x00020029
            },
            -- 休眠命令
            sleepcmd = {0x00020010},
            -- 唤醒命令
            wakecmd = {0x00020011}
        }
        lvgl.disp_init(para)
    end

    -- 控制SPI引脚的电压域
    pmd.ldoset(15, pmd.LDO_VLCD)

    init()

    -- LCD适配
    local disp_pin = pins.setup(11, 0)

    -- LCD分辨率的宽度和高度(单位是像素)
    WIDTH, HEIGHT, BPP = lvgl.disp_get_lcd_info()
    -- 1个ASCII字符宽度为8像素，高度为16像素；汉字宽度和高度都为16像素
    CHAR_WIDTH = 8

    sys.taskInit(function() disp_pin(1) end)

    lvgl.SYMBOL_AUDIO = "\xef\x80\x81"
    lvgl.SYMBOL_VIDEO = "\xef\x80\x88"
    lvgl.SYMBOL_LIST = "\xef\x80\x8b"
    lvgl.SYMBOL_OK = "\xef\x80\x8c"
    lvgl.SYMBOL_CLOSE = "\xef\x80\x8d"
    lvgl.SYMBOL_POWER = "\xef\x80\x91"
    lvgl.SYMBOL_SETTINGS = "\xef\x80\x93"
    lvgl.SYMBOL_HOME = "\xef\x80\x95"
    lvgl.SYMBOL_DOWNLOAD = "\xef\x80\x99"
    lvgl.SYMBOL_DRIVE = "\xef\x80\x9c"
    lvgl.SYMBOL_REFRESH = "\xef\x80\xa1"
    lvgl.SYMBOL_MUTE = "\xef\x80\xa6"
    lvgl.SYMBOL_VOLUME_MID = "\xef\x80\xa7"
    lvgl.SYMBOL_VOLUME_MAX = "\xef\x80\xa8"
    lvgl.SYMBOL_IMAGE = "\xef\x80\xbe"
    lvgl.SYMBOL_EDIT = "\xef\x8C\x84"
    lvgl.SYMBOL_PREV = "\xef\x81\x88"
    lvgl.SYMBOL_PLAY = "\xef\x81\x8b"
    lvgl.SYMBOL_PAUSE = "\xef\x81\x8c"
    lvgl.SYMBOL_STOP = "\xef\x81\x8d"
    lvgl.SYMBOL_NEXT = "\xef\x81\x91"
    lvgl.SYMBOL_EJECT = "\xef\x81\x92"
    lvgl.SYMBOL_LEFT = "\xef\x81\x93"
    lvgl.SYMBOL_RIGHT = "\xef\x81\x94"
    lvgl.SYMBOL_PLUS = "\xef\x81\xa7"
    lvgl.SYMBOL_MINUS = "\xef\x81\xa8"
    lvgl.SYMBOL_EYE_OPEN = "\xef\x81\xae"
    lvgl.SYMBOL_EYE_CLOSE = "\xef\x81\xb0"
    lvgl.SYMBOL_WARNING = "\xef\x81\xb1"
    lvgl.SYMBOL_SHUFFLE = "\xef\x81\xb4"
    lvgl.SYMBOL_UP = "\xef\x81\xb7"
    lvgl.SYMBOL_DOWN = "\xef\x81\xb8"
    lvgl.SYMBOL_LOOP = "\xef\x81\xb9"
    lvgl.SYMBOL_DIRECTORY = "\xef\x81\xbb"
    lvgl.SYMBOL_UPLOAD = "\xef\x82\x93"
    lvgl.SYMBOL_CALL = "\xef\x82\x95"
    lvgl.SYMBOL_CUT = "\xef\x83\x84"
    lvgl.SYMBOL_COPY = "\xef\x83\x85"
    lvgl.SYMBOL_SAVE = "\xef\x83\x87"
    lvgl.SYMBOL_CHARGE = "\xef\x83\xa7"
    lvgl.SYMBOL_PASTE = "\xef\x83\xAA"
    lvgl.SYMBOL_BELL = "\xef\x83\xb3"
    lvgl.SYMBOL_KEYBOARD = "\xef\x84\x9c"
    lvgl.SYMBOL_GPS = "\xef\x84\xa4"
    lvgl.SYMBOL_FILE = "\xef\x85\x9b"
    lvgl.SYMBOL_WIFI = "\xef\x87\xab"
    lvgl.SYMBOL_BATTERY_FULL = "\xef\x89\x80"
    lvgl.SYMBOL_BATTERY_3 = "\xef\x89\x81"
    lvgl.SYMBOL_BATTERY_2 = "\xef\x89\x82"
    lvgl.SYMBOL_BATTERY_1 = "\xef\x89\x83"
    lvgl.SYMBOL_BATTERY_EMPTY = "\xef\x89\x84"
    lvgl.SYMBOL_USB = "\xef\x8a\x87"
    lvgl.SYMBOL_BLUETOOTH = "\xef\x8a\x93"
    lvgl.SYMBOL_TRASH = "\xef\x8B\xAD"
    lvgl.SYMBOL_BACKSPACE = "\xef\x95\x9A"
    lvgl.SYMBOL_SD_CARD = "\xef\x9F\x82"
    lvgl.SYMBOL_NEW_LINE = "\xef\xA2\xA2"

    -- page1
    function page1create()
        scr = lvgl.cont_create(nil, nil)
        cv = lvgl.canvas_create(scr, nil)
        lvgl.canvas_set_buffer(cv, 100, 100)
        lvgl.obj_align(cv, nil, lvgl.ALIGN_CENTER, 0, 0)
        layer_id = lvgl.canvas_to_disp_layer(cv)
        disp.setactlayer(layer_id)
        width, data = qrencode.encode('http://www.openluat.com')
        l_w, l_h = disp.getlayerinfo()
        displayWidth = 100
        disp.putqrcode(data, width, displayWidth, (l_w - displayWidth) / 2,
                       (l_h - displayWidth) / 2)
        disp.update()
        label = lvgl.label_create(scr, nil)
        lvgl.label_set_recolor(label, true)
        lvgl.label_set_text(label, "#008080 上海合宙")
        lvgl.obj_align(label, cv, lvgl.ALIGN_OUT_BOTTOM_MID, 0, 2)
        return scr
    end

    -- page2
    arc = nil

    angles = 0

    local function arc_loader()
        angles = angles + 5
        if angles < 180 then
            lvgl.arc_set_angles(arc, 180 - angles, 180)
        else
            lvgl.arc_set_angles(arc, 540 - angles, 180)
        end
        if angles == 360 then angles = 0 end
    end

    function page2create()
        scr = lvgl.cont_create(nil, nil)
        style = lvgl.style_t()
        lvgl.style_copy(style, lvgl.style_plain)
        style.line.color = lvgl.color_hex(0x800000)
        style.line.width = 4

        arc = lvgl.arc_create(scr, nil)
        lvgl.arc_set_style(arc, lvgl.ARC_STYLE_MAIN, style)
        lvgl.arc_set_angles(arc, 180, 180)
        lvgl.obj_set_size(arc, 40, 40)
        lvgl.obj_align(arc, nil, lvgl.ALIGN_CENTER, -30, -30)
        arc_label = lvgl.label_create(scr, nil)
        lvgl.label_set_text(arc_label, "加载器")
        lvgl.obj_align(arc_label, arc, lvgl.ALIGN_OUT_RIGHT_MID, 4, 0)

        btn = lvgl.btn_create(scr, nil)
        btn_label = lvgl.label_create(btn, nil)
        lvgl.label_set_text(btn_label, "按钮")
        lvgl.obj_align(btn, nil, lvgl.ALIGN_CENTER, 0, 40)
        lvgl.obj_set_size(btn, 60, 60)

        sys.timerLoopStart(arc_loader, 100)

        return scr
    end

    -- page3
    btn = nil

    local function set_y(btn, value) lvgl.obj_set_y(btn, value) end

    anim = nil

    local function stop_anim()
        lvgl.anim_del(anim, set_y)
        lvgl.obj_set_y(btn, 10)
    end

    function page3create()
        theme = lvgl.theme_material_init(460, nil)
        lvgl.theme_set_current(theme)
        scr = lvgl.cont_create(nil, nil)
        btn = lvgl.btn_create(scr, nil)
        lvgl.obj_set_pos(btn, 10, 10)
        lvgl.obj_set_size(btn, 80, 50)
        label = lvgl.label_create(btn, nil)
        lvgl.label_set_text(label, "动画")
        anim = lvgl.anim_t()

        lvgl.anim_set_values(anim, -lvgl.obj_get_height(btn),
                             lvgl.obj_get_y(btn), lvgl.ANIM_PATH_OVERSHOOT)
        lvgl.anim_set_time(anim, 300, -2000)
        lvgl.anim_set_repeat(anim, 500)
        lvgl.anim_set_playback(anim, 500)
        lvgl.anim_set_exec_cb(anim, btn, set_y)
        lvgl.anim_create(anim)

        btn2 = lvgl.btn_create(scr, nil)
        lvgl.obj_set_pos(btn2, 10, 80)
        lvgl.obj_set_size(btn2, 100, 50)
        btn2_label = lvgl.label_create(btn2, nil)
        lvgl.label_set_text(btn2_label, "样式动画")

        btn2_style = lvgl.style_t()
        lvgl.style_copy(btn2_style, lvgl.btn_get_style(btn, lvgl.BTN_STYLE_REL))
        lvgl.btn_set_style(btn2, lvgl.BTN_STYLE_REL, btn2_style)
        style_anim = lvgl.anim_t()
        lvgl.style_anim_init(style_anim)
        lvgl.style_anim_set_styles(style_anim, btn2_style, lvgl.style_btn_rel,
                                   lvgl.style_pretty)
        lvgl.style_anim_set_time(style_anim, 500, 500)
        lvgl.style_anim_set_playback(style_anim, 500)
        lvgl.style_anim_set_repeat(style_anim, 500)
        lvgl.style_anim_create(style_anim)
        sys.timerStart(stop_anim, 3000)
        return scr
    end

    -- page4
    function page4create()
        black = lvgl.color_make(0, 0, 0)
        white = lvgl.color_make(0xff, 0xff, 0xff)
        scr = lvgl.cont_create(nil, nil)
        style_sb = lvgl.style_t()
        style_sb.body.main_color = black
        style_sb.body.grad_color = black
        style_sb.body.border.color = white
        style_sb.body.border.width = 1
        style_sb.body.border.opa = lvgl.OPA_70
        style_sb.body.radius = lvgl.RADIUS_CIRCLE
        style_sb.body.opa = lvgl.OPA_60
        style_sb.body.padding.right = 3
        style_sb.body.padding.bottom = 3
        style_sb.body.padding.inner = 8

        page = lvgl.page_create(scr, nil)
        lvgl.obj_set_size(page, 100, 150)
        lvgl.obj_align(page, nil, lvgl.ALIGN_CENTER, 0, 0)
        lvgl.page_set_style(page, lvgl.PAGE_STYLE_SB, style_sb)

        label = lvgl.label_create(page, nil)
        lvgl.label_set_long_mode(label, lvgl.LABEL_LONG_BREAK)
        lvgl.obj_set_width(label, lvgl.page_get_fit_width(page))
        lvgl.label_set_recolor(label, true)
        lvgl.label_set_text(label, [[
			Air722UG
			Air724UG
			行1
			行2
			行3]])
        return scr
    end

    -- page5

    function page5create()
        scr = lvgl.cont_create(nil, nil)
        list = lvgl.list_create(scr, nil)
        lvgl.obj_set_size(list, 100, 140)
        lvgl.obj_align(list, nil, lvgl.ALIGN_CENTER, 0, 0)
        lvgl.list_add_btn(list, lvgl.SYMBOL_LIST, "我是列表")
        lvgl.list_add_btn(list, lvgl.SYMBOL_OK, "确认")
        lvgl.list_add_btn(list, lvgl.SYMBOL_PAUSE, "暂停")
        return scr
    end

    -- page6

    cb = nil

    test_data = "blablabla"

    local function test_cb(cb, e)
        if e == lvgl.EVENT_CLICKED then
            lvgl.cb_set_checked(cb, true)
            print(lvgl.event_get_data())
        end
    end

    local function click() lvgl.event_send(cb, lvgl.EVENT_CLICKED, test_data) end

    function page6create()
        scr = lvgl.cont_create(nil, nil)
        cb = lvgl.cb_create(scr, nil)
        lvgl.cb_set_text(cb, "我同意")
        lvgl.obj_align(cb, nil, lvgl.ALIGN_CENTER, 0, 0)
        lvgl.obj_set_event_cb(cb, test_cb)
        sys.timerStart(click, 2000)
        return scr
    end

    -- page7

    scr2 = nil

    local function close_win(btn, event)
        if event == lvgl.EVENT_RELEASED then
            win = lvgl.win_get_from_btn(btn)
            lvgl.obj_del(win)
            lvgl.disp_load_scr(scr2)
        end
    end

    function page7create()
        scr = lvgl.cont_create(nil, nil)
        scr2 = lvgl.cont_create(nil, nil)
        win = lvgl.win_create(scr, nil)

        lvgl.win_set_title(win, "标题")

        close_btn = lvgl.win_add_btn(win, lvgl.SYMBOL_CLOSE)
        lvgl.obj_set_event_cb(close_btn, close_win)
        lvgl.win_add_btn(win, lvgl.SYMBOL_SETTINGS)

        txt = lvgl.label_create(win, nil)
        lvgl.label_set_recolor(txt, true)
        lvgl.label_set_text(txt, [[This #987654 is the# content of the window
							   You can add control buttons to
							   the window header
							   The content area becomes automatically
							   scrollable is it's large enough.
							   You can scroll the content
							   See the scroll bar on the right!]])

        ml = lvgl.label_create(scr2, nil)
        lvgl.label_set_recolor(ml, true)
        lvgl.label_set_text(ml, "#123456 窗口# #897632 已关闭#")
        lvgl.obj_align(ml, nil, lvgl.ALIGN_CENTER, 0, 0)
        sys.timerStart(lvgl.event_send, 3000, close_btn, lvgl.EVENT_RELEASED,
                       nil)
        return scr
    end

    -- page8
    function page8create()
        scr = lvgl.cont_create(nil, nil)
        style_bg = lvgl.style_t()
        style_indic = lvgl.style_t()
        style_knob = lvgl.style_t()

        lvgl.style_copy(style_bg, lvgl.style_pretty)
        style_bg.body.main_color = lvgl.color_hex(0x00ff00)
        style_bg.body.grad_color = lvgl.color_hex(0x000080)
        style_bg.body.radius = lvgl.RADIUS_CIRCLE
        style_bg.body.border.color = lvgl.color_hex(0xffffff)

        lvgl.style_copy(style_indic, lvgl.style_pretty_color)
        style_indic.body.radius = lvgl.RADIUS_CIRCLE
        style_indic.body.shadow.width = 8
        style_indic.body.shadow.color = style_indic.body.main_color
        style_indic.body.padding.left = 3
        style_indic.body.padding.right = 3
        style_indic.body.padding.top = 3
        style_indic.body.padding.bottom = 3

        lvgl.style_copy(style_knob, lvgl.style_pretty)
        style_knob.body.radius = lvgl.RADIUS_CIRCLE
        style_knob.body.opa = lvgl.OPA_70
        style_knob.body.padding.top = 10
        style_knob.body.padding.bottom = 10

        slider = lvgl.slider_create(scr, nil)
        lvgl.obj_set_size(slider, 100, 20)
        lvgl.slider_set_style(slider, lvgl.SLIDER_STYLE_BG, style_bg)
        lvgl.slider_set_style(slider, lvgl.SLIDER_STYLE_INDIC, style_indic)
        lvgl.slider_set_style(slider, lvgl.SLIDER_STYLE_KNOB, style_knob)
        lvgl.obj_align(slider, nil, lvgl.ALIGN_CENTER, 0, 0)

        label = lvgl.label_create(scr, nil)
        lvgl.label_set_text(label, "滑动条")
        lvgl.obj_align(label, slider, lvgl.ALIGN_OUT_BOTTOM_MID, 0, 0)
        return scr
    end

    -- page9
    sw = nil

    local function sw_on() lvgl.sw_on(sw, lvgl.ANIM_ON) end

    local function sw_off() lvgl.sw_off(sw, lvgl.ANIM_ON) end

    local function sw_toggle(on)
        if on then
            sw_on()
        else
            sw_off()
        end
        sys.timerStart(sw_toggle, 1000, not on)
    end

    function page9create()
        scr = lvgl.cont_create(nil, nil)
        bg_style = lvgl.style_t()
        indic_style = lvgl.style_t()
        knob_on_style = lvgl.style_t()
        knob_off_style = lvgl.style_t()

        lvgl.style_copy(bg_style, lvgl.style_pretty)
        bg_style.body.radius = lvgl.RADIUS_CIRCLE
        bg_style.body.padding.top = 6
        bg_style.body.padding.bottom = 6

        lvgl.style_copy(indic_style, lvgl.style_pretty_color)
        indic_style.body.radius = lvgl.RADIUS_CIRCLE
        indic_style.body.main_color = lvgl.color_hex(0x9fc8ef)
        indic_style.body.grad_color = lvgl.color_hex(0x9fc8ef)
        indic_style.body.padding.left = 0
        indic_style.body.padding.right = 0
        indic_style.body.padding.top = 0
        indic_style.body.padding.bottom = 0

        lvgl.style_copy(knob_off_style, lvgl.style_pretty_color)
        knob_off_style.body.radius = lvgl.RADIUS_CIRCLE
        knob_off_style.body.shadow.width = 4
        knob_off_style.body.shadow.type = lvgl.SHADOW_BOTTOM

        lvgl.style_copy(knob_on_style, lvgl.style_pretty_color)
        knob_on_style.body.radius = lvgl.RADIUS_CIRCLE
        knob_on_style.body.shadow.width = 4
        knob_on_style.body.shadow.type = lvgl.SHADOW_BOTTOM

        sw = lvgl.sw_create(scr, nil)
        lvgl.obj_align(sw, nil, lvgl.ALIGN_CENTER, 0, 0)

        lvgl.sw_set_style(sw, lvgl.SW_STYLE_BG, bg_style)
        lvgl.sw_set_style(sw, lvgl.SW_STYLE_INDIC, indic_style)
        lvgl.sw_set_style(sw, lvgl.SW_STYLE_KNOB_ON, knob_on_style)
        lvgl.sw_set_style(sw, lvgl.SW_STYLE_KNOB_OFF, knob_off_style)

        label = lvgl.label_create(scr, nil)
        lvgl.label_set_text(label, "开关")
        lvgl.obj_align(label, sw, lvgl.ALIGN_OUT_BOTTOM_MID, 0, 2)
        sys.timerStart(sw_toggle, 1000, true)
        return scr

    end

    scrs = {
        page1create, page2create, page3create, page4create, page5create,
        page6create, page7create, page8create, page9create
    }
    obj = {}
    local function empty()
        c = lvgl.cont_create(nil, nil)
        img = lvgl.img_create(c, nil)
        lvgl.img_set_src(img, "/lua/logo_color.png")
        lvgl.obj_align(img, nil, lvgl.ALIGN_CENTER, 0, 0)
        lvgl.disp_load_scr(c)
    end

    sys.taskInit(function()
        local count = 1
        lvgl.init(empty, nil)
        sys.wait(1000)
        for k, v in ipairs(scrs) do
            obj[#obj + 1] = v()
            sys.wait(1000)
        end

        while true do
            log.info(tag, "第" .. count .. "次")
            for i = 1, #obj do
                lvgl.disp_load_scr(obj[i])
                sys.wait(5000)
            end
            count = count + 1
        end
    end)

else
    sys.taskInit(function()

        local count = 1

        sys.wait(5000)

        while true do

            if LuaTaskTestConfig.dispTest.logoTest then
                log.info("DispTest.LogoTest", "第" .. count .. "次")
                -- 显示logo
                -- 清空LCD显示缓冲区
                disp.clear()
                -- 从坐标16,0位置开始显示"欢迎使用Luat"
                log.info("DispTest.PutText", "LuatTest" .. count)
                disp.puttext(common.utf8ToGb2312("LuatTest" .. count),
                             getxpos(common.utf8ToGb2312("LuatTest" .. count)),
                             0)
                -- 显示logo图片
                log.info("DispTest.PutImage", "Logo_color")
                disp.putimage("/lua/logo_color.png", 1, 33)
                -- 刷新LCD显示缓冲区到LCD屏幕上
                disp.update()
                sys.wait(waitTime2)
            end

            if LuaTaskTestConfig.dispTest.scanTest then
                log.info("DispTest.ScanTest", "第" .. count .. "次")
                pm.wake("DispTest.ScanTest")
                local ret = 0
                log.info("DispTest.ScanTest", "开始扫描")
                -- 设置扫码回调函数，默认10秒超时
                scanCode.request(scanCodeCb)
                -- 打开摄像头
                ret = disp.cameraopen_ext(gc0310_sdr)
                -- 打开摄像头预览   
                -- log.info("DispTest.scan cameraopen_ext ret ", ret)
                -- disp.camerapreviewzoom(-2)

                ret = disp.camerapreview(0, 0, 0, 0, WIDTH, HEIGHT)

                -- log.info("DispTest.scan camerapreview ret ", ret)
                sys.wait(10000)
            end

            if LuaTaskTestConfig.dispTest.photoTest then
                log.info("DispTest.PhotoTest", "第" .. count .. "次")
                -- 拍照并显示
                pm.wake("DispTest.PhotoTest")
                -- 打开摄像头
                disp.cameraopen(1, 0, 0, 1)
                -- 打开摄像头预览
                disp.camerapreview(0, 0, 0, 0, WIDTH, HEIGHT)
                -- 设置照片的宽和高像素并且开始拍照
                disp.cameracapture(WIDTH, HEIGHT, 101)
                -- 设置照片保存路径
                disp.camerasavephoto("/testCamera.jpg")
                log.info("DispTest.PhotoSize", io.fileSize("/testCamera.jpg"))
                -- 关闭摄像头预览
                disp.camerapreviewclose()
                -- 关闭摄像头
                disp.cameraclose()
                -- 允许系统休眠
                pm.sleep("DispTest.PhotoTest")
                -- 显示拍照图片   
                if WIDTH ~= 0 and HEIGHT ~= 0 then
                    disp.clear()
                    disp.putimage("/testCamera.jpg", 0, 0)
                    disp.puttext(common.utf8ToGb2312("照片尺寸: " ..
                                                         io.fileSize(
                                                             "/testCamera.jpg")),
                                 0, 5)
                    disp.update()
                end
                sys.wait(waitTime2)
            end

            if LuaTaskTestConfig.dispTest.photoSendTest then
                log.info("DispTest.PhotoSendTest", "第" .. count .. "次")
                -- 拍照并通过uart1发送出去
                pm.wake("DispTest.PhotoSendTest")
                -- 打开摄像头
                disp.cameraopen(1, 0, 0, 1)
                -- 打开摄像头预览
                disp.camerapreview(0, 0, 0, 0, WIDTH, HEIGHT)
                -- 设置照片的宽和高像素并且开始拍照
                disp.cameracapture(WIDTH, HEIGHT)
                -- 设置照片保存路径
                disp.camerasavephoto("/testCamera.jpg")
                log.info("DispTest.PhotoSize", io.fileSize("/testCamera.jpg"))
                -- 关闭摄像头预览
                disp.camerapreviewclose()
                -- 关闭摄像头
                disp.cameraclose()
                -- 允许系统休眠
                pm.sleep("DispTest.PhotoSendTest")

                sendFile(1)
                if WIDTH ~= 0 and HEIGHT ~= 0 then
                    disp.clear()
                    disp.putimage("/testCamera.jpg", 0, 0)
                    disp.puttext(common.utf8ToGb2312("照片尺寸: " ..
                                                         io.fileSize(
                                                             "/testCamera.jpg")),
                                 0, 5)
                    disp.update()
                end
                sys.wait(waitTime2)
            end

            if LuaTaskTestConfig.dispTest.qrcodeTest then
                log.info("DispTest.QrCodeTest", "第" .. count .. "次")
                -- 显示二维码
                disp.clear()
                local displayWidth = 100
                disp.puttext(common.utf8ToGb2312("二维码生成测试"),
                             getxpos(
                                 common.utf8ToGb2312("二维码生成测试")),
                             10)
                disp.putqrcode(data, qrCodeWidth, displayWidth,
                               (WIDTH1 - displayWidth) / 2,
                               (HEIGHT1 - displayWidth) / 2)
                disp.update()
                sys.wait(waitTime2)
            end

            if LuaTaskTestConfig.dispTest.uiWinTest then
                log.info("DispTest.UIWinTest", "第" .. count .. "次")
                -- 1秒后，打开提示框窗口，提示"3秒后进入待机界面"
                -- 提示框窗口关闭后，自动进入待机界面
                sys.timerStart(openprompt, 1000, common.utf8ToGb2312("3秒后"),
                               common.utf8ToGb2312("进入待机界面"), nil,
                               openidle)
                sys.wait(waitTime2)
            end

            count = count + 1

        end
    end)
end
