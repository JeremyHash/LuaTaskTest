-- MqttTest
-- Author:LuatTest
-- CreateDate:20200724
-- UpdateDate:20210107

module(..., package.seeall)

local timeout1 = 3000
local timeout2 = 10000

local result, data

local connected = true

local count1 = 1
local count3 = 1
local count4 = 1

local ip1 = "airtest.openluat.com"
-- 普通MQTT端口
local port1 = 1883
-- 单双向认证的MQTT端口
local port2 = 8883

-- 发布消息
local function publishTest(id, client, topic, pubData, qos, retain)
    if client:publish(topic, pubData, qos, retain) then
        log.info("MqttTest.MqttClient" .. id .. ".publish." .. topic, "发布SUCCESS")
        -- log.info("MqttTest.MqttClient" .. id .. ".publish." .. "pubData", pubData)
    else
        log.error("MqttTest.MqttClient" .. id .. ".publish." .. topic, "发布FAIL")
        connected = false
    end
    sys.wait(timeout1)
end

-- 设置发布消息任务
local function mqttPubTask(id, ip, port, transport, cert, count)
    local client
    local testImei = misc.getImei()
    local topic1 = "topic1-" .. testImei
    local topic2 = "topic2-" .. testImei
    local topic3 = "合宙测试-" .. testImei
    while true do
        client = mqtt.client("client" .. id .. "-" .. misc.getImei(), 60)
        log.info("MqttTest.MqttClient" .. id .. ".connect", "开始连接")
        -- TODO 第五个参数timeout 没有传 看 doc 没有相应的描述
        while not client:connect(ip, port, transport, cert) do 
            log.info("MqttTest.MqttClient" .. id, "连接失败，重新连接")
            client:disconnect()
            client = mqtt.client("client" .. id .. "-" .. misc.getImei(), 60)
            sys.wait(2000)
        end
        log.info("MqttTest.MqttClient" .. id .. ".connect", "连接SUCCESS")
        connected = true
        while connected do
            publishTest(id, client, topic1, "MqttClient" .. id .. "PubTest" .. count, 0, 0)
            publishTest(id, client, topic2, "MqttClient" .. id .. "PubTest" .. count, 1, 1)
            publishTest(id, client, topic3, "MqttClient" .. id .. "PubTest" .. count, 2, 0)
            count = count + 1
        end
        log.info("MqttTest.MqttClient" .. id .. ".connect", "连接异常，开始断开连接")
        client:disconnect()
        log.info("MqttTest.MqttClient" .. id .. ".connect", "断开连接SUCCESS")
    end
end

-- 接收消息任务
local function mqttRecTask(id, client, ip, port, transport)
    local testImei = misc.getImei()
    local topic1 = "topic1-" .. testImei
    local topic2 = "topic2-" .. testImei
    local topic3 = "合宙测试-" .. testImei
    while true do
        log.info("MqttTest.MqttClient" .. id .. ".connect", "开始连接")
        while not client:connect(ip, port, transport, cert) do
            log.info("MqttTest.MqttClient" .. id, "连接失败，重新连接")
            sys.wait(2000)
        end

        log.info("MqttTest.MqttClient" .. id .. ".connect", "连接SUCCESS")
        
        if client:subscribe({[topic1] = 0, [topic2] = 1, [topic3] = 2}) then
            log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅SUCCESS")
            connected = true
            -- TODO unsubscribe 流程应该是先订阅 再取消订阅 再订阅
        else
            log.error("MqttTest.MqttClient" .. id .. ".subscribe", "订阅FAIL")
            connected = false
        end

        -- if client:subscribe(topic1, 0) then
        --     log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅SUCCESS")
        --     connected = true
        -- else
        --     log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅FAIL")
        --     connected = false
        -- end

        -- if client:subscribe(topic2, 1) then
        --     log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅SUCCESS")
        --     connected = true
        -- else
        --     log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅FAIL")
        --     connected = false
        -- end

        -- if client:subscribe(topic3, 2) then
        --     log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅SUCCESS")
        --     connected = true
        -- else
        --     log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅FAIL")
        --     connected = false
        -- end

        while connected do
            -- TODO 推出阻塞的msg
            result, data = client:receive(timeout2)
            if result then
                log.info("MqttTest.MqttClient" .. id .. ".receive", "接收SUCCESS")
                for k, v in pairs(data) do
                    -- TODO 格式应该改成log
                    print(k, v)
                end
            else
                log.error("MqttTest.MqttClient" .. id .. ".receive", "接收FAIL")
                log.error("data", data)
                connected = false
            end
        end

        log.info("MqttTest.MqttClient" .. id .. ".connect", "连接异常，开始断开连接")
        client:disconnect()
        log.info("MqttTest.MqttClient" .. id .. ".connect", "断开连接SUCCESS")
    end
end


-- TODO mqtt的用户名和密码认证方式
sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络, MqttPublish测试开始")
        mqttPubTask(1, ip1, port1, "tcp", nil, count1)
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络, MqttReceive测试开始")
        local mqttClient2 = mqtt.client("client2-" .. misc.getImei(), 30, "user", "password", nil, {qos = 2, retain = 1, topic = "topic2", payload = "WILL MESSAGE"}, "3.1")
        mqttRecTask(2, mqttClient2, ip1, port1, "tcp")
    end
)

-- TODO TCPSSL 接收消息client 再加上recv推出阻塞的测试

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络, MqttSSL单向认证Publish测试开始")
        local mqttClient3 = mqtt.client("单向认证客户端-" .. misc.getImei(), 60, "user", "password")
        mqttPubTask(3, ip1, port2, "tcp_ssl", {["caCert"] = "cacert.pem"}, count3)
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络, MqttSSL双向认证Publish测试开始")
        local mqttClient4 = mqtt.client("双向认证客户端-" .. misc.getImei(), 60, "user", "password")
        mqttPubTask(4, ip1, port2, "tcp_ssl", {["caCert"] = "cacert.pem", ["clientCert"] = "client-cert.pem", ["clientKey"] = "client-key.pem"}, count4)
    end
)

-- TODO zbar消息写错了 写成了 zabr
-- sys.timerLoopStart(fnc, ms, ...)

-- TODO 加一个关掉MQTT服务器模块状态的测试

-- TODO pwrKey和keypad冲突
