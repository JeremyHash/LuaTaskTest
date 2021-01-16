-- MqttTest
-- Author:LuatTest
-- CreateDate:20200724
-- UpdateDate:20210114

module(..., package.seeall)

local timeout1 = 3000
local timeout2 = 10000

local result, data

local connected = true

local count1 = 1
local count2 = 1
local count3 = 1
local count4 = 1
local count5 = 1

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
local function mqttRecTask(id, ip, port, transport, cert, count, msg)
    local client
    local testImei = misc.getImei()
    local topic1 = "topic1-" .. testImei
    local topic2 = "topic2-" .. testImei
    local topic3 = "合宙测试-" .. testImei
    while true do
        client = mqtt.client("client" .. id .. "-" .. misc.getImei(), 60)
        log.info("MqttTest.MqttClient" .. id .. ".connect", "开始连接")
        while not client:connect(ip, port, transport, cert) do
            log.info("MqttTest.MqttClient" .. id, "连接失败，重新连接")
            client:disconnect()
            client = mqtt.client("client" .. id .. "-" .. misc.getImei(), 60)
            sys.wait(2000)
        end

        log.info("MqttTest.MqttClient" .. id .. ".connect", "连接SUCCESS")
        
        if client:subscribe({[topic1] = 0, [topic2] = 1, [topic3] = 2}) then
            log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅SUCCESS")
            connected = true
            if client:unsubscribe({topic1, topic2, topic3}) then
                log.info("MqttTest.MqttClient" .. id .. ".subscribe", "取消订阅SUCCESS")
                if client:subscribe({[topic1] = 0, [topic2] = 1, [topic3] = 2}) then
                    log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅SUCCESS")
                    connected = true
                else
                    log.error("MqttTest.MqttClient" .. id .. ".subscribe", "订阅FAIL")
                    connected = false
                end
            else
                log.error("MqttTest.MqttClient" .. id .. ".subscribe", "取消订阅FAIL")
                connected = false
            end
        else
            log.error("MqttTest.MqttClient" .. id .. ".subscribe", "订阅FAIL")
            connected = false
        end

        if msg then
            while connected do
                -- TODO 推出阻塞的msg
                result, data, param = client:receive(timeout2, msg)
                if result then
                    log.info("MqttTest.MqttClient" .. id .. ".receive", "接收SUCCESS")
                    for k, v in pairs(data) do
                        log.info("MqttTest.MqttClient" .. id .. ".receive." .. k , v)
                    end
                    log.info("MqttTest.MqttClient" .. id .. ".receive.count", count)
                    count = count + 1
                else
                    log.error("MqttTest.MqttClient" .. id .. ".receive", "接收FAIL")
                    log.error("MqttTest.MqttClient" .. id .. ".receive.data", data)
                    log.error("MqttTest.MqttClient" .. id .. ".receive.param", param)
                    if data == "timeout" then
                        connected = false
                    end
                end
            end
        else
            while connected do
                result, data = client:receive(timeout2)
                if result then
                    log.info("MqttTest.MqttClient" .. id .. ".receive", "接收SUCCESS")
                    for k, v in pairs(data) do
                        log.info("MqttTest.MqttClient" .. id .. ".receive." .. k , v)
                    end
                    log.info("MqttTest.MqttClient" .. id .. ".receive.count", count)
                    count = count + 1
                else
                    log.error("MqttTest.MqttClient" .. id .. ".receive", "接收FAIL")
                    log.error("data", data)
                    connected = false
                end
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
        mqttPubTask(1, ip1, port1, "tcp", nil, count1)
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        mqttRecTask(2, ip1, port1, "tcp", nil, count2)
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        mqttPubTask(3, ip1, port2, "tcp_ssl", {["caCert"] = "cacert.pem"}, count3)
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        mqttPubTask(4, ip1, port2, "tcp_ssl", {["caCert"] = "cacert.pem", ["clientCert"] = "client-cert.pem", ["clientKey"] = "client-key.pem"}, count4)
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        mqttRecTask(5, ip1, port2, "tcp_ssl", {["caCert"] = "cacert.pem"}, count5, "RECEIVE_INTER")
    end
)

sys.timerLoopStart(
    function ()
       sys.publish("RECEIVE_INTER", "1234")
    end,
    1000
)