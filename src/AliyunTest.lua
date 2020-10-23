-- AliyunTest
-- Author:LuatTest
-- CreateDate:20201023
-- UpdateDate:20201023

module(..., package.seeall)

local AliyunTestConfig = {
    aliyunMqttTest = false,
    aliyunOtaTest  = false
}

local PRODUCT_KEY = "a1K4TWp6E6z"
local PRODUCE_SECRET = "oqBAqpeFwQTKyn4M"


--阿里云客户端是否处于连接状态
local sConnected

local publishCnt = 1

local function getDeviceName()
    return "866714044920188"
end

local function getDeviceSecret()
    return misc.getSn()
    -- return "a044c473cdb320c9b698a3592af0e762"
end

local function setDeviceSecret(s)
    misc.setSn(s)
end

--[[
函数名：pubqos1testackcb
功能  ：发布1条qos为1的消息后收到PUBACK的回调函数
参数  ：
		usertag：调用mqttclient:publish时传入的usertag
		result：true表示发布成功，false或者nil表示失败
返回值：无
]]
local function publishTestCb(result, para)
    log.info("AliyunTest.publishTestCb", result, para)
    sys.timerStart(publishTest, 20000)
    publishCnt = publishCnt + 1
end

--发布一条QOS为1的消息
function publishTest()
    if sConnected then
        --注意：在此处自己去控制payload的内容编码，aLiYun库中不会对payload的内容做任何编码转换
        aLiYun.publish("/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/Jeremy", "qos1data" .. publishCnt, 1, publishTestCb, "publishTest_" .. publishCnt)
    end
end

---数据接收的处理函数
local function rcvCbFnc(topic, qos, payload)
    log.info("AliyunTest.rcvCbFnc", topic, qos, payload)
end

--- 连接结果的处理函数
local function connectCbFnc(result)
    log.info("AliyunTest.ConnectCbFnc", result)
    sConnected = result
    if result then
        --订阅主题，不需要考虑订阅结果，如果订阅失败，aLiYun库中会自动重连
        aLiYun.subscribe({["/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/get"] = 0, ["/" .. PRODUCT_KEY .. "/" .. getDeviceName() .. "/user/Jeremy"] = 1})
        --注册数据接收的处理函数
        aLiYun.on("receive", rcvCbFnc)
        --PUBLISH消息测试
        publishTest()
    end
end

-- 认证结果的处理函数
local function authCbFnc(result)
    log.info("AliyunTest.AuthCbFnc", result)
    if result then
        log.info("AliyunTest.AuthCbFnc", "SUCCESS")
    else
        log.info("AliyunTest.AuthCbFnc", "FAIL")
    end
end

aLiYun.setErrHandle(function() sys.restart("ALIYUN_TASK_INACTIVE") end, 300)

if AliyunTestConfig.aliyunMqttTest then
    -- 一机一密
    -- aLiYun.setup(PRODUCT_KEY, nil, getDeviceName, getDeviceSecret)

    -- 一型一密
    aLiYun.setup(PRODUCT_KEY, PRODUCE_SECRET, getDeviceName, getDeviceSecret, setDeviceSecret)

    --setMqtt接口不是必须的，aLiYun.lua中有这个接口设置的参数默认值，如果默认值满足不了需求，参考下面注释掉的代码，去设置参数
    --aLiYun.setMqtt(0)
    aLiYun.on("auth", authCbFnc)
    aLiYun.on("connect", connectCbFnc)
end

if AliyunTestConfig.aliyunOtaTest then
    require "aLiYunOta"
end
