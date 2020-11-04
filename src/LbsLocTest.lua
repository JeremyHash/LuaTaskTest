-- LbsLocTest
-- Author:LuatTest
-- CreateDate:20201013
-- UpdateDate:20201025

module(..., package.seeall)

-- 测试配置 设置为true代表开启此项测试
local LbsLocTestConfig = {
    lbsLocTest  = true,
    wifiLocTest = true
}

local serverAddress = "http://wiki.airm2m.com:48080/postLbsLocInfo"

local lattmp, lngtmp = 0, 0

function getLocCb(result, lat, lng, addr)
    log.info("LbsLocTest.getLocCb.result", result)
    log.info("LbsLocTest.getLocCb.lat", lat)
    log.info("LbsLocTest.getLocCb.lng", lng)
    if result == 0 then
        log.info("LbsLocTest.getLocCb.result", "SUCCESS")
        if lat == lattmp and lng == lngtmp then
            log.info("LbsLocTest.getLocCb", "定位信息未发生改变，本次定位结果不上传服务器")
        else
            lattmp = lat
            lngtmp = lng
            local lbsLocInfo = {
                lat = lat,
                lng = lng,
                timestamp = os.time()
            }
            http.request("POST",
                        serverAddress,
                        nil,
                        {
                            ["Content-Type"] = "application/json",
                        },
                        json.encode(lbsLocInfo),
                        nil,
                        function (result, prompt, head, body)
                            if result then
                                log.info("LbsLocTest.postLbsLocInfo.result", "SUCCESS")
                            else
                                log.info("LbsLocTest.postLbsLocInfo.result", "FAIL")
                            end
                            log.info("LbsLocTest.postLbsLocInfo.prompt", "Http状态码:", prompt)
                            if result and head then
                                log.info("LbsLocTest.postLbsLocInfo.Head", "遍历响应头")
                                for k, v in pairs(head) do
                                    log.info("LbsLocTest.postLbsLocInfo.Head", k .. " : " .. v)
                                end
                            end
                            if result and body then
                                log.info("LbsLocTest.postLbsLocInfo.Body","body=" .. body)
                                log.info("LbsLocTest.postLbsLocInfo.Body","bodyLen=" .. body:len())
                            end
                        end
            )
        end
    else
        log.info("LbsLocTest.getLocCb", "FALSE")
    end
end

if LbsLocTestConfig.lbsLocTest then
    sys.timerLoopStart(
        function()
            log.info("LbsLocTest", "开始定位")
            lbsLoc.request(getLocCb)
        end,
        10000
    )
end

local function wifiLocTest()
    wifiScan.request(
        function(result, cnt, tInfo)
            if result then
                log.info("WifiLocTest.ScanCb", "SUCCESS")
                for k, v in pairs(tInfo) do
                    log.info("WifiLocTest.WifiInfo", k, v)
                end
                
                lbsLoc.request(
                    function(result, lat, lng)
                        log.info("WifiLocTest.GetLocCb", result, lat, lng)
                    end, false, false, false, false, false, false, tInfo)
            else
                log.info("WifiLocTest.ScanCb", "FAIL")
            end
        end
    )
end

if LbsLocTestConfig.wifiLocTest then
    sys.timerLoopStart(wifiLocTest, 30000)
end