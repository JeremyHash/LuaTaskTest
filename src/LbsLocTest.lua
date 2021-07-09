-- LbsLocTest
-- Author:LuatTest
-- CreateDate:20201013
-- UpdateDate:20210223

module(..., package.seeall)

local serverAddr = "http://114.55.242.59:2900"

local postCellLocInfoAddress = serverAddr .. "/postCellLocInfo"
local postWiFiLocInfoAddress = serverAddr .. "/postWiFiLocInfo"
local postGPSLocInfoAddress = serverAddr .. "/postGPSLocInfo"

local cellLattmp, cellLngtmp = 0, 0
local wifiLattmp, wifiLngtmp = 0, 0
local gpsLattmp, gpsLngtmp = "", ""

local loopTime = 30000

function getCellLocCb(result, lat, lng, addr)
    log.info("CellLocTest.getCellLocCb.result", result)
    log.info("CellLocTest.getCellLocCb.lat", lat)
    log.info("CellLocTest.getCellLocCb.lng", lng)
    if result == 0 then
        log.info("CellLocTest.getCellLocCb", "SUCCESS")
        if lat == cellLattmp and lng == cellLngtmp then
            log.info("CellLocTest.getCellLocCb", "基站定位信息未发生改变，本次定位结果不上传服务器")
        else
            cellLattmp = lat
            cellLngtmp = lng
            local cellLocInfo = {
                lat = lat,
                lng = lng,
                timestamp = os.time()
            }
            http.request(
                "POST",
                postCellLocInfoAddress,
                nil,
                {
                    ["Content-Type"] = "application/json",
                },
                json.encode(cellLocInfo),
                nil,
                function (result, prompt, head, body)
                    if result then
                        log.info("CellLocTest.postLbsLocInfo.result", "SUCCESS")
                    else
                        log.info("CellLocTest.postLbsLocInfo.result", "FAIL")
                    end
                    log.info("CellLocTest.postLbsLocInfo.prompt", "Http状态码:", prompt)
                    if result and head then
                        log.info("CellLocTest.postLbsLocInfo.Head", "遍历响应头")
                        for k, v in pairs(head) do
                            log.info("CellLocTest.postLbsLocInfo.Head", k .. " : " .. v)
                        end
                    end
                    if result and body then
                        log.info("CellLocTest.postLbsLocInfo.Body", "body=" .. body)
                        log.info("CellLocTest.postLbsLocInfo.Body", "bodyLen=" .. body:len())
                    end
                end
            )
        end
    else
        log.info("CellLocTest.getLocCb", "FAIL")
    end
end

local function getWiFiLocCb(result, lat, lng, addr)
    log.info("WifiLocTest.getWiFiLocCb.result", result)
    log.info("WifiLocTest.getWiFiLocCb.lat", lat)
    log.info("WifiLocTest.getWiFiLocCb.lng", lng)
    if result == 0 then
        log.info("WifiLocTest.getWiFiLocCb", "SUCCESS")
        if lat == wifiLattmp and lng == wifiLngtmp then
            log.info("WifiLocTest.getWiFiLocCb", "WiFi定位信息未发生改变，本次定位结果不上传服务器")
        else
            wifiLattmp = lat
            wifiLngtmp = lng
            local wifiLocInfo = {
                lat = lat,
                lng = lng,
                timestamp = os.time()
            }
            http.request(
                "POST",
                postWiFiLocInfoAddress,
                nil,
                {
                    ["Content-Type"] = "application/json",
                },
                json.encode(wifiLocInfo),
                nil,
                function (result, prompt, head, body)
                    if result then
                        log.info("WifiLocTest.postLbsLocInfo.result", "SUCCESS")
                    else
                        log.info("WifiLocTest.postLbsLocInfo.result", "FAIL")
                    end
                    log.info("WifiLocTest.postLbsLocInfo.prompt", "Http状态码:", prompt)
                    if result and head then
                        log.info("WifiLocTest.postLbsLocInfo.Head", "遍历响应头")
                        for k, v in pairs(head) do
                            log.info("WifiLocTest.postLbsLocInfo.Head", k .. " : " .. v)
                        end
                    end
                    if result and body then
                        log.info("WifiLocTest.postLbsLocInfo.Body", "body=" .. body)
                        log.info("WifiLocTest.postLbsLocInfo.Body", "bodyLen=" .. body:len())
                    end
                end
            )
        end
    else
        log.info("WifiLocTest.getWiFiLocCb", "FAIL")
    end
end

local function wifiLocTest()
    wifiScan.request(
        function(result, cnt, apInfo)
            if result then
                log.info("WifiLocTest.ScanCb", "SUCCESS")
                for k, v in pairs(apInfo) do
                    log.info("WifiLocTest.WifiInfo", k, v)
                end
                log.info("WiFiLocTest", "开始WiFi定位")
                lbsLoc.request(getWiFiLocCb, false, false, false, false, false, false, apInfo)
            else
                log.info("WifiLocTest.ScanCb", "FAIL")
            end
        end
    )
end

local function sendGPSInfoToServer(lat, lng)
    local gpsLocInfo = {
        lat = lat,
        lng = lng,
        timestamp = os.time()
    }
    http.request(
        "POST",
        postGPSLocInfoAddress,
        nil,
        {
            ["Content-Type"] = "application/json",
        },
        json.encode(gpsLocInfo),
        nil,
        function (result, prompt, head, body)
            if result then
                log.info("GPSLocTest.sendGPSInfoToServer.result", "SUCCESS")
            else
                log.info("GPSLocTest.sendGPSInfoToServer.result", "FAIL")
            end
            log.info("GPSLocTest.sendGPSInfoToServer.prompt", "Http状态码:", prompt)
            if result and head then
                log.info("GPSLocTest.sendGPSInfoToServer.Head", "遍历响应头")
                for k, v in pairs(head) do
                    log.info("GPSLocTest.sendGPSInfoToServer.Head", k .. " : " .. v)
                end
            end
            if result and body then
                log.info("GPSLocTest.sendGPSInfoToServer.Body", "body=" .. body)
                log.info("GPSLocTest.sendGPSInfoToServer.Body", "bodyLen=" .. body:len())
            end
        end
    )
end

local function printGpsInfo()
    if gpsZkw.isOpen() and gpsZkw.isFix() then
        local tLocation = gpsZkw.getLocation()
        local lat = tLocation.lat
        local lng = tLocation.lng
        log.info("GPSLocTest.LocInfo", lat, lng)
        -- local UTCTime = gpsZkw.getUtcTime()
        -- log.info("GPSLocTest.UTCTime", string.format("%d-%d-%d %d:%d:%d", UTCTime.year, UTCTime.month, UTCTime.day, UTCTime.hour, UTCTime.min, UTCTime.sec))
        
        if lat == gpsLattmp and lng == gpsLngtmp then
            log.info("GPSLocTest", "GPS定位信息未发生改变，本次定位结果不上传服务器")
        else
            gpsLattmp = lat
            gpsLngtmp = lng
            sendGPSInfoToServer(lat, lng)
        end
    end
end

if LuaTaskTestConfig.lbsLocTest.cellLocTest then
    sys.timerLoopStart(
        function()
            log.info("CellLocTest", "开始基站定位")
            lbsLoc.request(getCellLocCb)
        end,
        loopTime
    )
end

if LuaTaskTestConfig.lbsLocTest.wifiLocTest then
    sys.timerLoopStart(wifiLocTest, loopTime)
end

local function nmeaCb(nmeaData)
    log.info("GPSTest.nmeaCb", nmeaData)
end

if LuaTaskTestConfig.lbsLocTest.gpsLocTest then
    sys.taskInit(
        function ()
            sys.wait(5000)
            pmd.ldoset(15, pmd.LDO_VMMC)

            require "gpsZkw"
            require "agpsZkw"
            require "color_lcd_spi_gc9106l"

            log.info("GPSTest", "打开GPS")
            gpsZkw.setUart(3, 9600, 8, uart.PAR_NONE, uart.STOP_1)
            gpsZkw.open(gpsZkw.DEFAULT, {tag = "GPSLocTest"})

            sys.timerLoopStart(printGpsInfo, 50000)
        end
    )

    -- sys.taskInit(
    --     function ()
    --         sys.wait(10000)
    --         while true do
    --             if gpsZkw.isOpen() and gpsZkw.isFix() then
    --                 local tLocation = gpsZkw.getLocation()
    --                 local lat = tLocation.lat
    --                 local lng = tLocation.lng
    --                 log.info("GPSLocTest.LocInfo", lat, lng)
                    
    --                 if lat == gpsLattmp and lng == gpsLngtmp then
    --                     log.info("GPSLocTest", "GPS定位信息未发生改变，本次定位结果不上传服务器")
    --                 else
    --                     disp.clear()
    --                     disp.puttext(common.utf8ToGb2312(lat), 0, 0)
    --                     disp.puttext(common.utf8ToGb2312(lng), 0, 50)
    --                     disp.update()
    --                 end
    --             else
    --                 disp.clear()
    --                 disp.puttext(common.utf8ToGb2312("还没有定位成功"), 0, 0)
    --                 disp.update()
    --             end
    --             sys.wait(1000)
    --         end
    --     end
    -- )
end