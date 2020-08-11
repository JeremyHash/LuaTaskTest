-- LogoTest
-- Author:LuatTest
-- CreateDate:20200719
-- UpdateDate:20200719

module(...,package.seeall)

require"uiWin"
require"prompt"
require"idle"
require"pm"
require"scanCode"
require"utils"
require"common"
require"testUartSentFile"

local WIDTH,HEIGHT = disp.getlcdinfo()
local DEFAULT_WIDTH,DEFAULT_HEIGHT = 320,240
local width, data = qrencode.encode('http://www.openluat.com')
local WIDTH1, HEIGHT1 = 132,162

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

        testUartSentFile.sendFile()   
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

        -- 提示"3秒后进入待机界面"
        -- 提示框窗口关闭后，自动进入待机界面
        sys.timerStart(prompt.open,18000,common.utf8ToGb2312("3秒后"),common.utf8ToGb2312("进入待机界面"))
        idle.open()
        sys.wait(3000)
    end
end)
