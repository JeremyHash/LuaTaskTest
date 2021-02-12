-- AliyunTest
-- Author:LuatTest
-- CreateDate:20201208
-- UpdateDate:20210106
-- 这个测试代码需要提前在阿里云平台上创建好产品和设备

module(..., package.seeall)

require "OneDeviceOneSecret"

local PRODUCT_KEY = OneDeviceOneSecret.AliyunInfo["PRODUCT_KEY"]
local PRODUCE_SECRET

--阿里云客户端是否处于连接状态
local sConnected

local publishCnt = 1

local publishCntTmp = 0

local function getDeviceName()

    return OneDeviceOneSecret.AliyunInfo["DEVICE_NAME"]

end

local function getDeviceSecret()

    return OneDeviceOneSecret.AliyunInfo["DEVICE_SECRET"]

end

local function setDeviceSecret(s)
    misc.setSn(s)
end

local function publishTestCb(result, para)
    log.info("AliyunTest.publishTestCb", result, para)
    if result then
        log.info("AliyunTest.publishTestCb.result", "SUCCESS")
        sys.timerStart(publishTest, 30000)
    else
        log.error("AliyunTest.publishTestCb.result", "FAIL")
    end
end

function publishTest()
    if sConnected then
        aLiYun.publish("/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/Jeremy", json.encode({["qos"] = 0, ["data"] = "qos0data" .. publishCnt, ["time"] = os.time()}), 0, publishTestCb, "qos0data" .. publishCnt)
        publishCnt = publishCnt + 1
        aLiYun.publish("/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/Jeremy", json.encode({["qos"] = 1, ["data"] = "qos1data" .. publishCnt, ["time"] = os.time()}), 1, publishTestCb, "qos1data" .. publishCnt)
        publishCnt = publishCnt + 1
    end
end

-- 数据接收的处理函数
local function receiveCb(topic, qos, payload)
    log.info("AliyunTest.receiveCb.topic", topic)
    log.info("AliyunTest.receiveCb.qos", qos)
    log.info("AliyunTest.receiveCb.payload", payload)
    local tjsondata, result, errinfo = json.decode(payload)
    if result and type(tjsondata) == "table" then
        for k, v in pairs(tjsondata) do
            if k == "data" then
                if string.match(v, "qos(%d)data") == tostring(qos) then
                    log.info("AliyunTest.qosCheck", "SUCCESS")
                else
                    log.error("AliyunTest.qosCheck", "FAIL")
                end
                if publishCntTmp < tonumber(string.match(v, "data(%d+)")) then
                    log.info("AliyunTest.publishCntCheck", "SUCCESS")
                else
                    log.error("AliyunTest.publishCntCheck", "FAIL")
                end
                publishCntTmp = publishCntTmp + 1
            end
            if k == "time" then
                local curTime = os.time()
                -- log.info("AliyunTest.curTime", curTime)
                -- log.info("AliyunTest.time", v)
                if curTime - tostring(v) < 5 then
                    log.info("ALiyunTest.timeCheck", "SUCCESS")
                else
                    log.info("ALiyunTest.timeCheck", "FAIL")
                end
            end
        end
    else
        log.error("AliyunTest.json.decode.err", errinfo)
    end
end

-- 连接结果的处理函数
local function connectCb(result)
    log.info("AliyunTest.connectCb.result", result)
    sConnected = result
    if result then
        log.info("AliyunTest.connectCb", "SUCCESS")
        -- 订阅主题，不需要考虑订阅结果，如果订阅失败，aLiYun库中会自动重连
        aLiYun.subscribe({["/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/get"] = 0, ["/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/Jeremy"] = 1})
        -- 注册数据接收的处理函数
        aLiYun.on("receive", receiveCb)
        -- PUBLISH消息测试
        publishTest()
    else
        log.error("AliyunTest.connectCb", "FAIL")
    end
end

-- 认证结果的处理函数
local function authCb(result)
    log.info("AliyunTest.authCb", result)
    if result then
        log.info("AliyunTest.authCb", "SUCCESS")
    else
        log.error("AliyunTest.authCb", "FAIL")
    end
end

-- 重连的处理函数
local function reConnectCb()
    log.info("AliyunTest.reConnectCb", "阿里云重连")
end

sys.taskInit(
    function ()
        if LuaTaskTestConfig.aliyunTest.aliyunMqttTest then

            -- TODO aLiYun.setRegion(region) (BUG)
            -- 华南1（深圳）
            -- aLiYun.setRegion("cn-shenzhen")

            --setMqtt接口不是必须的，aLiYun.lua中有这个接口设置的参数默认值，如果默认值满足不了需求，参考下面注释掉的代码，去设置参数
            --aLiYun.setMqtt(0)

            -- TODO 测试过程中禁用设备观察情况
            -- aLiYun.setErrHandle(
            --     function ()
            --         sys.restart("ALIYUN_TASK_INACTIVE")
            --     end,
            --     300
            -- )

            -- 一机一密
            aLiYun.setup(PRODUCT_KEY, nil, getDeviceName, getDeviceSecret)
        
            -- 一型一密
            -- aLiYun.setup(PRODUCT_KEY, PRODUCT_SECRET, getDeviceName, getDeviceSecret, setDeviceSecret)
        
            aLiYun.on("auth", authCb)
            aLiYun.on("connect", connectCb)
            aLiYun.on("reconnect", reConnectCb)

            while true do
                sys.wait(600000)
                aLiYun.sleep()
                log.info("AliYunTest.Sleep", "AliYun进入休眠")
                log.info("AliYunTest.SleepStatus", aLiYun.sleepStatus())
                sys.wait(600000)
                aLiYun.wakeup()
                log.info("AliYunTest.WakeUp", "AliYun唤醒")
                log.info("AliYunTest.SleepStatus", aLiYun.sleepStatus())
            end
        end
    end
)

if LuaTaskTestConfig.aliyunTest.aliyunOtaTest then
    require "aLiYunOta"
end