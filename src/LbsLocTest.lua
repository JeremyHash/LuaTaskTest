module(...,package.seeall)

local serverAddress = "http://wiki.airm2m.com:58080/postLbsLocInfo"

local lattmp, lngtmp = 0, 0

function getLocCb(result,lat,lng,addr)
    log.info("LbsLocTest.getLocCb.result",result)
    log.info("LbsLocTest.getLocCb.lat",lat)
    log.info("LbsLocTest.getLocCb.lng",lng)
    if result == 0 then
        log.info("LbsLocTest.getLocCb","定位成功")
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
                        ["Content-Type"]="application/json",
                    },
                    json.encode(lbsLocInfo),
                    nil,
                    function (result,prompt,head,body)
                        if result then
                            log.info("LbsLocTest.postLbsLocInfo.result","Http请求成功:",result)
                        else
                            log.info("LbsLocTest.postLbsLocInfo.result","Http请求失败:",result)
                        end
                        log.info("LbsLocTest.postLbsLocInfo.prompt","Http状态码:",prompt)
                        if result and head then
                            log.info("LbsLocTest.postLbsLocInfo.Head","遍历响应头")
                            for k,v in pairs(head) do
                                log.info("LbsLocTest.postLbsLocInfo.Head",k.." : "..v)
                            end
                        end
                        if result and body then
                            log.info("LbsLocTest.postLbsLocInfo.Body","body="..body)
                            log.info("LbsLocTest.postLbsLocInfo.Body","bodyLen="..body:len())
                        end
                    end
        )
        end
    else
        log.info("LbsLocTest.getLocCb","定位失败")
    end
end

sys.taskInit(
function()
    sys.waitUntil("IP_READY_IND")
    log.info("LbsLocTest","成功访问网络,LbsLoc测试开始")
    while true do
        log.info("LbsLocTest", "开始定位")
        lbsLoc.request(getLocCb)
        sys.wait(5000)
    end
end
)