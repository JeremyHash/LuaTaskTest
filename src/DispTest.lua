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

local gc0310_sdr =
{
	zbar_scan = 1,
	i2c_addr = 0x21, 
	sensor_width = 320, 
	sensor_height = 240, 
	id_reg = 0xf1, 
	id_value = 0x10,
	spi_mode = disp.CAMERA_SPI_MODE_LINE2, 
	spi_speed = disp.CAMERA_SPEED_SDR, 
	spi_yuv_out = disp.CAMERA_SPI_OUT_Y1_V0_Y0_U0, 
	
	init_cmd = 
	{
		
		 0xfe,0xf0 ,
		 0xfe,0xf0 ,
		 0xfe,0x00 ,

		 0xfc,0x16 , --4e 
		 0xfc,0x16 , --4e -- [0]apwd [6]regf_clk_gate 
		 0xf2,0x07 , --sync output
		 0xf3,0x83 , --ff--1f--01 data output
		 0xf5,0x07 , --sck_dely

		 0xf7,0x88 , --f8/   88
		 0xf8,0x00 ,           -- 00
		 0xf9,0x4f , --0f--01   4d
		 0xfa,0x32 , --32

		 0xfc,0xce ,
		 0xfd,0x00 ,
		------------------------------------------------/
		----------------/   CISCTL reg  ----------------/
		------------------------------------------------/
		 0x00,0x2f , 
		 0x01,0x0f , 
		 0x02,0x04 ,

		 0x03,0x02 ,
		 0x04,0x12 ,

		 0x09,0x00 , 
		 0x0a,0x00 , 
		 0x0b,0x00 , 
		 0x0c,0x02 ,--04 
		 0x0d,0x01 , 
		 0x0e,0xec ,--e8 
		 0x0f,0x02 , 
		 0x10,0x88 , 
		 0x16,0x00 ,
		 0x17,0x14 ,
		 0x18,0x6a ,--1a 
		 0x19,0x14 , 
		 0x1b,0x48 ,
		 0x1c,0x1c ,
		 0x1e,0x6b ,
		 0x1f,0x28 ,
		 0x20,0x8b ,--0x89 travis20140801
		 0x21,0x49 ,
		 0x22,0xb0 ,
		 0x23,0x04 , 
		 0x24,0xff , 
		 0x34,0x20 , 


		------------------------------------------------/
		--------------------   BLK   --------------------
		------------------------------------------------/
		 0x26,0x23 ,
		 0x28,0xff ,
		 0x29,0x00 ,
		 0x32,0x00 ,
		 0x33,0x10 , 
		 0x37,0x20 ,
		 0x38,0x10 ,
		 0x47,0x80 ,
		 0x4e,0x0f ,--66
		 0xa8,0x02 ,
		 0xa9,0x80 ,


		------------------------------------------------/
		------------------   ISP reg  ------------------/
		------------------------------------------------/
		 0x40,0xff ,
		 0x41,0x21 ,
		 0x42,0xcf ,
		 0x44,0x02 ,
		 0x45,0xa8 , 
		 0x46,0x02 , --sync
		 0x4a,0x11 ,
		 0x4b,0x01 ,
		 0x4c,0x20 ,
		 0x4d,0x05 ,
		 0x4f,0x01 ,
		 0x50,0x01 ,
		 0x55,0x00 ,
		 0x56,0xf0 ,
		 0x57,0x01 ,
		 0x58,0x40 ,
		------------------------------------------------/
		------------------/   GAIN   --------------------
		------------------------------------------------/
		 0x70,0x70 ,
		 0x5a,0x84 ,
		 0x5b,0xc9 ,
		 0x5c,0xed ,
		 0x77,0x74 ,
		 0x78,0x40 ,
		 0x79,0x5f , 


		------------------------------------------------/ 
		------------------/   DNDD  --------------------/
		------------------------------------------------/ 
		 0x82,0x08 ,--0x14 
		 0x83,0x0b ,
		 0x89,0xf0 ,
		------------------------------------------------/ 
		------------------   EEINTP  --------------------
		------------------------------------------------/ 
		 0x8f,0xaa ,
		 0x90,0x8c ,
		 0x91,0x90 ,
		 0x92,0x03 ,
		 0x93,0x03 ,
		 0x94,0x05 ,
		 0x95,0x43 , --0x65
		 0x96,0xf0 , 
		------------------------------------------------/ 
		--------------------/  ASDE  --------------------
		------------------------------------------------/ 
		 0xfe,0x00 ,

		 0x9a,0x20 ,
		 0x9b,0x80 ,
		 0x9c,0x40 ,
		 0x9d,0x80 ,
		 
		 0xa1,0x30 ,
			 0xa2,0x32 ,
		 0xa4,0x30 ,
		 0xa5,0x30 ,
		 0xaa,0x10 , 
		 0xac,0x22 ,
		 

		------------------------------------------------/
		------------------/   GAMMA   ------------------/
		------------------------------------------------/
		 0xfe,0x00,
		0xbf,0x08,
		0xc0,0x1d,
		0xc1,0x34,
		0xc2,0x4b,
		0xc3,0x60,
		0xc4,0x73,
		0xc5,0x85,
		0xc6,0x9f,
		0xc7,0xb5,
		0xc8,0xc7,
		0xc9,0xd5,
		0xca,0xe0,
		0xcb,0xe7,
		0xcc,0xec,
		0xcd,0xf4,
		0xce,0xfa,
		0xcf,0xff,

		------------------------------------------------/
		------------------/   YCP  ----------------------
		------------------------------------------------/
		 0xd0,0x40 , 
		 0xd1,0x38 , --0x34
		 0xd2,0x38 , --0x34
		 0xd3,0x50 ,--0x40 
		 0xd6,0xf2 , 
		 0xd7,0x1b , 
		 0xd8,0x18 , 
		 0xdd,0x03 , 

		------------------------------------------------/
		--------------------   AEC   --------------------
		------------------------------------------------/
		 0xfe,0x01 ,
		 0x05,0x30 ,
		 0x06,0x75 ,
		 0x07,0x40 ,
		 0x08,0xb0 ,
		 0x0a,0xc5 ,
		 0x0b,0x11 ,
		 0x0c,0x00 ,
		 0x12,0x52 ,
		 0x13,0x38 ,
		 0x18,0x95 ,
		 0x19,0x96 ,
		 0x1f,0x20 , 
		 0x20,0xc0 , 
		 0x3e,0x40 , 
		 0x3f,0x57 , 
		 0x40,0x7d , 

		 0x03,0x60 , 

		 0x44,0x02 , 
		------------------------------------------------/
		--------------------   AWB   --------------------
		------------------------------------------------/
		 0xfe,0x01 ,
		 0x1c,0x91 , 
		 0x21,0x15 , 
		 0x50,0x80 ,
		 0x56,0x04 ,
		 0x59,0x08 , 
		 0x5b,0x02 ,
		 0x61,0x8d , 
		 0x62,0xa7 , 
		 0x63,0xd0 , 
		 0x65,0x06 ,
		 0x66,0x06 , 
		 0x67,0x84 , 
		 0x69,0x08 , 
		 0x6a,0x25 , 
		 0x6b,0x01 , 
		 0x6c,0x00 , 
		 0x6d,0x02 , 
		 0x6e,0xf0 , 
		 0x6f,0x80 , 
		 0x76,0x80 , 
		 0x78,0xaf , 
		 0x79,0x75 ,
		 0x7a,0x40 ,
		 0x7b,0x50 ,
		 0x7c,0x0c , 

		 0x90,0xc9 ,--stable AWB 
		 0x91,0xbe ,
		 0x92,0xe2 ,
		 0x93,0xc9 ,
		 0x95,0x1b ,
		 0x96,0xe2 ,
		 0x97,0x49 ,
		 0x98,0x1b ,
		 0x9a,0x49 ,
		 0x9b,0x1b ,
		 0x9c,0xc3 ,
		 0x9d,0x49 ,
		 0x9f,0xc7 ,
		 0xa0,0xc8 ,
		 0xa1,0x00 ,
		 0xa2,0x00 ,
		 0x86,0x00 ,
		 0x87,0x00 ,
		 0x88,0x00 ,
		 0x89,0x00 ,
		 0xa4,0xb9 ,
		 0xa5,0xa0 ,
		 0xa6,0xba ,
		 0xa7,0x92 ,
		 0xa9,0xba ,
		 0xaa,0x80 ,
		 0xab,0x9d ,
		 0xac,0x7f ,
		 0xae,0xbb ,
		 0xaf,0x9d ,
		 0xb0,0xc8 ,
		 0xb1,0x97 ,
		 0xb3,0xb7 ,
		 0xb4,0x7f ,
		 0xb5,0x00 ,
		 0xb6,0x00 ,
		 0x8b,0x00 ,
		 0x8c,0x00 ,
		 0x8d,0x00 ,
		 0x8e,0x00 ,
		 0x94,0x55 ,
		 0x99,0xa6 ,
		 0x9e,0xaa ,
		 0xa3,0x0a ,
		 0x8a,0x00 ,
		 0xa8,0x55 ,
		 0xad,0x55 ,
		 0xb2,0x55 ,
		 0xb7,0x05 ,
		 0x8f,0x00 ,
		 0xb8,0xcb ,
		 0xb9,0x9b ,  
		 

		------------------------------------------------/
		--------------------  CC ------------------------
		------------------------------------------------/
		 0xfe,0x01 ,

		 0xd0,0x38 ,--skin red
		 0xd1,0x00 ,
		 0xd2,0x02 ,
		 0xd3,0x04 ,
		 0xd4,0x38 ,
		 0xd5,0x12 ,	

		 0xd6,0x30 ,
		 0xd7,0x00 ,
		 0xd8,0x0a ,
		 0xd9,0x16 ,
		 0xda,0x39 ,
		 0xdb,0xf8 ,
		------------------------------------------------/
		--------------------   LSC   --------------------
		------------------------------------------------/
		 0xfe,0x01 , 
		 0xc1,0x3c ,
		 0xc2,0x50 ,
		 0xc3,0x00 ,
		 0xc4,0x40 ,
		 0xc5,0x30 ,
		 0xc6,0x30 ,
		 0xc7,0x10 ,
		 0xc8,0x00 ,
		 0xc9,0x00 ,
		 0xdc,0x20 ,
		 0xdd,0x10 ,
		 0xdf,0x00 , 
		 0xde,0x00 , 


		------------------------------------------------/
		------------------/  Histogram  ----------------/
		------------------------------------------------/
		 0x01,0x10 , 
		 0x0b,0x31 , 
		 0x0e,0x50 , 
		 0x0f,0x0f , 
		 0x10,0x6e , 
		 0x12,0xa0 , 
		 0x15,0x60 , 
		 0x16,0x60 , 
		 0x17,0xe0 , 


		------------------------------------------------/
		--------------   Measure Window   --------------/
		------------------------------------------------/
		 0xcc,0x0c , 
		 0xcd,0x10 , 
		 0xce,0xa0 , 
		 0xcf,0xe6 , 


		------------------------------------------------/
		----------------/   dark sun   ------------------
		------------------------------------------------/
		 0x45,0xf7 ,
		 0x46,0xff , 
		 0x47,0x15 ,
		 0x48,0x03 , 
		 0x4f,0x60 , 
									
		------------------------------------------------/
		------------------/  banding  ------------------/
		------------------------------------------------/
		 0xfe,0x00 ,
		 0x05,0x01 ,
		 0x06,0x12 , --HB
		 0x07,0x00 ,
		 0x08,0x1c , --VB
		 0xfe,0x01 ,
		 0x25,0x00 , --step 
		 0x26,0x1f , 
		 0x27,0x01 , --6fps
		 0x28,0xf0 ,  
		 0x29,0x01 , --6fps
		 0x2a,0xf0 , 
		 0x2b,0x01 , --6fps
		 0x2c,0xf0 , 
		 0x2d,0x03 , --3.3fps
		 0x2e,0xe0 ,
		 0x3c,0x20 ,
		--------------------/  SPI   --------------------
		------------------------------------------------/
		 0xfe,0x03 ,
		 0x01,0x00 ,
		 0x02,0x00 ,
		 0x10,0x00 ,
		 0x15,0x00 ,
		 0x17,0x00 , --01--03
		 0x04,0x10 ,--fifo full level
		 0x40,0x00 ,
		 0x52,0x82 , --zwb 02改成da
		 0x53,0x24 , --24
		 0x54,0x20 ,
		 0x55,0x20 , --QQ--01
		 0x5a,0x00 , --00 --yuv 
		 0x5b,0x40 ,
		 0x5c,0x01 ,
		 0x5d,0xf0 ,
		 0x5e,0x00 ,
		 0x51,0x03 ,
		 0xfe,0x00 ,

	}
}

local WIDTH, HEIGHT, BPP = disp.getlcdinfo()
local CHAR_WIDTH = 8
local DEFAULT_WIDTH, DEFAULT_HEIGHT = 128, 160
local qrCodeWidth, data = qrencode.encode("二维码生成测试")
local WIDTH1, HEIGHT1 = 132, 162
local appid, str1, str2, str3, callback, callbackpara

function getxpos(str)
    return (WIDTH - string.len(str) * CHAR_WIDTH) / 2
end

function setcolor(color)
    if BPP~=1 then return disp.setcolor(color) end
end

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

local pos = 
{
    {24},--显示1行字符串时的Y坐标
    {10,37},--显示2行字符串时，每行字符串对应的Y坐标
    {4,24,44},--显示3行字符串时，每行字符串对应的Y坐标
}

--[[
函数名：refresh
功能  ：窗口刷新处理
参数  ：无
返回值：无
]]
local function refresh()
    disp.clear()
    if str3 then
        disp.puttext(str3, getxpos(str3), pos[3][3])
    end
    if str2 then
        disp.puttext(str2, getxpos(str2), pos[str3 and 3 or 2][2])
    end
    if str1 then
        disp.puttext(str1, getxpos(str1), pos[str3 and 3 or (str2 and 2 or 1)][1])
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

--窗口的消息处理函数表
local app = {
    onUpdate = refresh,
}

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
function openprompt(s1, s2 , s3, cb, cbpara, prd)
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
    --清空LCD显示缓冲区
    disp.clear()
    local oldColor = setcolor(0xF100)
    disp.puttext(common.utf8ToGb2312("待机界面"), getxpos(common.utf8ToGb2312("待机界面")), 0)
    local tm = misc.getClock()
    local datestr = string.format("%04d", tm.year) .. "-" .. string.format("%02d", tm.month) .. "-" .. string.format("%02d", tm.day)
    local timestr = string.format("%02d", tm.hour) .. ":" .. string.format("%02d", tm.min)
    --显示日期
    setcolor(0x07E0)
    disp.puttext(datestr, getxpos(datestr), 24)
    --显示时间
    setcolor(0x001F)
    disp.puttext(timestr, getxpos(timestr), 44)
    
    --刷新LCD显示缓冲区到LCD屏幕上
    disp.update()
    setcolor(oldColor)
end

--窗口类型的消息处理函数表
local winapp =
{
    onUpdate = refresh,
}

--[[
函数名：open
功能  ：打开待机界面窗口
参数  ：无
返回值：无
]]
function openidle()
    appid2 = uiWin.add(winapp)
end

function scanCodeCb(result, codeType, codeStr)
    --关闭摄像头预览
    disp.camerapreviewclose()
    --关闭摄像头
    disp.cameraclose()
    --允许系统休眠
    pm.sleep("DispTest.ScanTest")
    --如果有LCD，显示扫描结果
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

sys.taskInit(function()

	local count = 1

	sys.wait(5000)

    while true do

		if LuaTaskTestConfig.dispTest.logoTest then
			log.info("DispTest.LogoTest", "第" .. count .. "次")
            -- 显示logo
            -- 清空LCD显示缓冲区
            disp.clear()
			--从坐标16,0位置开始显示"欢迎使用Luat"
			log.info("DispTest.PutText", "LuatTest" .. count)
            disp.puttext(common.utf8ToGb2312("LuatTest" .. count), getxpos(common.utf8ToGb2312("LuatTest" .. count)), 0)
			--显示logo图片
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
            --设置扫码回调函数，默认10秒超时
            scanCode.request(scanCodeCb)
            --打开摄像头
            ret = disp.cameraopen_ext(gc0310_sdr)
            --打开摄像头预览   
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
            --打开摄像头
            disp.cameraopen(1, 0, 0, 1)
            --打开摄像头预览
            disp.camerapreview(0, 0, 0, 0, WIDTH, HEIGHT)
            --设置照片的宽和高像素并且开始拍照
            disp.cameracapture(WIDTH, HEIGHT, 101)
            --设置照片保存路径
            disp.camerasavephoto("/testCamera.jpg")
            log.info("DispTest.PhotoSize", io.fileSize("/testCamera.jpg"))
            --关闭摄像头预览
            disp.camerapreviewclose()
            --关闭摄像头
            disp.cameraclose()
            --允许系统休眠
            pm.sleep("DispTest.PhotoTest")    
            --显示拍照图片   
            if WIDTH ~= 0 and HEIGHT ~= 0 then
                disp.clear()
                disp.putimage("/testCamera.jpg", 0, 0)
                disp.puttext(common.utf8ToGb2312("照片尺寸: " .. io.fileSize("/testCamera.jpg")), 0, 5)
                disp.update()
            end 
            sys.wait(waitTime2)
        end

		if LuaTaskTestConfig.dispTest.photoSendTest then
			log.info("DispTest.PhotoSendTest", "第" .. count .. "次")
            -- 拍照并通过uart1发送出去
            pm.wake("DispTest.PhotoSendTest")
            --打开摄像头
            disp.cameraopen(1, 0, 0, 1)
            --打开摄像头预览
            disp.camerapreview(0, 0, 0, 0, WIDTH, HEIGHT)
            --设置照片的宽和高像素并且开始拍照
            disp.cameracapture(WIDTH, HEIGHT)
            --设置照片保存路径
            disp.camerasavephoto("/testCamera.jpg")
            log.info("DispTest.PhotoSize", io.fileSize("/testCamera.jpg"))
            --关闭摄像头预览
            disp.camerapreviewclose()
            --关闭摄像头
            disp.cameraclose()
            --允许系统休眠
            pm.sleep("DispTest.PhotoSendTest")    

            sendFile(1)   
            if WIDTH ~= 0 and HEIGHT ~= 0 then
                disp.clear()
                disp.putimage("/testCamera.jpg", 0, 0)
                disp.puttext(common.utf8ToGb2312("照片尺寸: " .. io.fileSize("/testCamera.jpg")), 0, 5)
                disp.update()
            end
            sys.wait(waitTime2)
        end

		if LuaTaskTestConfig.dispTest.qrcodeTest then
			log.info("DispTest.QrCodeTest", "第" .. count .. "次")
            --显示二维码
            disp.clear()
            local displayWidth = 100
            disp.puttext(common.utf8ToGb2312("二维码生成测试"), getxpos(common.utf8ToGb2312("二维码生成测试")), 10)
            disp.putqrcode(data, qrCodeWidth, displayWidth, (WIDTH1-displayWidth)/2, (HEIGHT1-displayWidth)/2)
            disp.update()
            sys.wait(waitTime2)
        end

		if LuaTaskTestConfig.dispTest.uiWinTest then
			log.info("DispTest.UIWinTest", "第" .. count .. "次")
            --1秒后，打开提示框窗口，提示"3秒后进入待机界面"
            --提示框窗口关闭后，自动进入待机界面
            sys.timerStart(openprompt, 1000, common.utf8ToGb2312("3秒后"), common.utf8ToGb2312("进入待机界面"), nil, openidle)
            sys.wait(waitTime2)
		end
		
		count = count + 1

    end
end)
