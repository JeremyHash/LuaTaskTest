-- LogoTest
-- Author:LuatTest
-- CreateDate:20200719
-- UpdateDate:20200719

module(...,package.seeall)

local WIDTH,HEIGHT = disp.getlcdinfo()
local DEFAULT_WIDTH,DEFAULT_HEIGHT = 320,240
local width, data = qrencode.encode('http://www.openluat.com')
local WIDTH1, HEIGHT1 = 132,162
local appid,str1,str2,str3,callback,callbackpara
local uartID = 1

function sendFile()
sys.taskInit(
    function()                
        local fileHandle = io.open("/testCamera.jpg","rb")
        if not fileHandle then
            log.error("testALiYun.otaCb1 open file error")
            return
        end
        
        pm.wake("UART_SENT2MCU")
        uart.on(uartID,"sent",function() sys.publish("UART_SENT2MCU_OK") end)
        uart.setup(uartID,115200,8,uart.PAR_NONE,uart.STOP_1,nil,1)
        while true do
            local data = fileHandle:read(1460)
            if not data then break end
            uart.write(uartID,data)
            sys.waitUntil("UART_SENT2MCU_OK")
        end
        
        uart.close(uartID)
        pm.sleep("UART_SENT2MCU")
        fileHandle:close()
    end
)
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
        disp.puttext(str3,lcd.getxpos(str3),pos[3][3])
    end
    if str2 then
        disp.puttext(str2,lcd.getxpos(str2),pos[str3 and 3 or 2][2])
    end
    if str1 then
        disp.puttext(str1,lcd.getxpos(str1),pos[str3 and 3 or (str2 and 2 or 1)][1])
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
function openprompt(s1,s2,s3,cb,cbpara,prd)
    str1,str2,str3,callback,callbackpara = s1,s2,s3,cb,cbpara
    appid = uiWin.add(app)
    sys.timerStart(close,prd or 3000)
end

--appid：窗口id
local appid

--[[
函数名：refresh
功能  ：窗口刷新处理
参数  ：无
返回值：无
]]
local function refresh()
    --清空LCD显示缓冲区
    disp.clear()
    local oldColor = lcd.setcolor(0xF100)
    disp.puttext(common.utf8ToGb2312("待机界面"),lcd.getxpos(common.utf8ToGb2312("待机界面")),0)
    local tm = misc.getClock()
    local datestr = string.format("%04d",tm.year).."-"..string.format("%02d",tm.month).."-"..string.format("%02d",tm.day)
    local timestr = string.format("%02d",tm.hour)..":"..string.format("%02d",tm.min)
    --显示日期
    lcd.setcolor(0x07E0)
    disp.puttext(datestr,lcd.getxpos(datestr),24)
    --显示时间
    lcd.setcolor(0x001F)
    disp.puttext(timestr,lcd.getxpos(timestr),44)
    
    --刷新LCD显示缓冲区到LCD屏幕上
    disp.update()
    lcd.setcolor(oldColor)
end

--窗口类型的消息处理函数表
local winapp =
{
    onUpdate = refresh,
}

--[[
函数名：clkind
功能  ：时间更新处理
参数  ：无
返回值：无
]]
local function clkind()
    if uiWin.isActive(appid) then
        refresh()
    end    
end

--[[
函数名：open
功能  ：打开待机界面窗口
参数  ：无
返回值：无
]]
function openidle()
    appid = uiWin.add(winapp)
end

ntp.timeSync()
-- sys.timerLoopStart(clkind,60000)
-- sys.subscribe("TIME_UPDATE_IND",clkind)

function scanCodeCb(result,codeType,codeStr)
    --关闭摄像头预览
    disp.camerapreviewclose()
    --关闭摄像头
    disp.cameraclose()
    --允许系统休眠
    pm.sleep("testScanCode")
    --如果有LCD，显示扫描结果
    if WIDTH~=0 and HEIGHT~=0 then 
        disp.clear()
        if result then
            disp.puttext(common.utf8ToGb2312("扫描成功"),0,5)
            disp.puttext(common.utf8ToGb2312("类型: ")..codeType,0,35)
            log.info("scanCodeCb",codeStr:toHex())
            disp.puttext(common.utf8ToGb2312("结果: ")..codeStr,0,65)                
        else
            disp.puttext(common.utf8ToGb2312("扫描失败"),0,5)                
        end
        disp.update()
    end
end

sys.taskInit(function()

    while true do

        -- 显示logo
        -- 清空LCD显示缓冲区
        disp.clear()
        if lcd.WIDTH==128 and lcd.HEIGHT==128 then
            -- 显示logo图片
            disp.putimage("/lua/logo_"..(lcd.BPP==1 and "mono.bmp" or "color.png"),lcd.BPP==1 and 41 or 0,lcd.BPP==1 and 18 or 0)
        elseif lcd.WIDTH==240 and lcd.HEIGHT==320 then
            disp.puttext(common.utf8ToGb2312("欢迎使用Luat"),lcd.getxpos(common.utf8ToGb2312("欢迎使用Luat")),10)
            --显示logo图片
            disp.putimage("/lua/logo_color_240X320.png",0,80)
        else
            --从坐标16,0位置开始显示"欢迎使用Luat"
            disp.puttext(common.utf8ToGb2312("欢迎使用Luat"),lcd.getxpos(common.utf8ToGb2312("欢迎使用Luat")),0)
            --显示logo图片
            disp.putimage("/lua/logo_"..(lcd.BPP==1 and "mono.bmp" or "color.png"),lcd.BPP==1 and 41 or 1,lcd.BPP==1 and 18 or 33)
        end
        -- 刷新LCD显示缓冲区到LCD屏幕上
        disp.update()
        sys.wait(1000) 

        -- 扫码 
        --唤醒系统
        pm.wake("testScanCode")
        --设置扫码回调函数，默认5秒超时
        scanCode.request(scanCodeCb,5000)
        --打开摄像头
        disp.cameraopen(1,1)
        --打开摄像头预览
        disp.camerapreview(0,0,0,0,WIDTH or DEFAULT_WIDTH,HEIGHT or DEFAULT_HEIGHT)
        sys.wait(6000)

        -- 拍照并显示
        --唤醒系统
        pm.wake("testTakePhoto")
        --打开摄像头
        disp.cameraopen(1,0,0,1)
        --打开摄像头预览
        disp.camerapreview(0,0,0,0,WIDTH or DEFAULT_WIDTH,HEIGHT or DEFAULT_HEIGHT)
        --设置照片的宽和高像素并且开始拍照
        disp.cameracapture(WIDTH or DEFAULT_WIDTH,HEIGHT or DEFAULT_HEIGHT)
        --设置照片保存路径
        disp.camerasavephoto("/testCamera.jpg")
        log.info("testCamera.takePhotoAndDisplay fileSize",io.fileSize("/testCamera.jpg"))
        --关闭摄像头预览
        disp.camerapreviewclose()
        --关闭摄像头
        disp.cameraclose()
        --允许系统休眠
        pm.sleep("testTakePhoto")    
        --显示拍照图片   
        if WIDTH~=0 and HEIGHT~=0 then
            disp.clear()
            disp.putimage("/testCamera.jpg",0,0)
            disp.puttext(common.utf8ToGb2312("照片尺寸: "..io.fileSize("/testCamera.jpg")),0,5)
            disp.update()
        end 
        sys.wait(3000)
        
        -- 拍照并显示
        --唤醒系统
        pm.wake("testTakePhoto")
        --打开摄像头
        disp.cameraopen(1,0,0,1)
        --打开摄像头预览
        disp.camerapreview(0,0,0,0,DEFAULT_WIDTH,DEFAULT_HEIGHT)
        --设置照片的宽和高像素并且开始拍照
        disp.cameracapture(DEFAULT_WIDTH,DEFAULT_HEIGHT)
        --设置照片保存路径
        disp.camerasavephoto("/testCamera.jpg")
        log.info("testCamera.takePhotoAndSendToUart fileSize",io.fileSize("/testCamera.jpg"))
        --关闭摄像头预览
        disp.camerapreviewclose()
        --关闭摄像头
        disp.cameraclose()
        --允许系统休眠
        pm.sleep("testTakePhoto")    

        sendFile()   
        if WIDTH~=0 and HEIGHT~=0 then
            disp.clear()
            disp.putimage("/testCamera.jpg",0,0)
            disp.puttext(common.utf8ToGb2312("照片尺寸: "..io.fileSize("/testCamera.jpg")),0,5)
            disp.update()
        end
        sys.wait(3000)

        --显示二维码
        disp.clear()
        local displayWidth = 100
        disp.puttext(common.utf8ToGb2312("Luat官网"),lcd.getxpos(common.utf8ToGb2312("Luat官网")),10)
        disp.putqrcode(data, width, displayWidth, (WIDTH1-displayWidth)/2, (HEIGHT1-displayWidth)/2)
        disp.update()
        sys.wait(3000)

        -- 提示"1秒后进入待机界面"
        -- 提示框窗口关闭后，自动进入待机界面
        sys.timerStart(openprompt,20000,common.utf8ToGb2312("1秒后"),common.utf8ToGb2312("进入待机界面"))
        openidle()
        sys.wait(3000)
    end
end)
