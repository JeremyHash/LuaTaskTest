-- MqttTest
-- Author:LuatTest
-- CreateDate:20200724
-- UpdateDate:20201028

module(..., package.seeall)

local timeout1 = 3000
local timeout2 = 5000

local result, data

local count = 1

local ip1 = "wiki.airm2m.com"
local port1 = 41883
local port2 = 48883

local function publishTest(id, client, topic, pubData, qos, retain)
    if client:publish(topic, pubData, qos, retain) then
        log.info("MqttTest.MqttClient" .. id .. ".publish." .. topic, "发布SUCCESS")
        log.info("MqttTest.MqttClient" .. id .. ".publish." .. "pubData", pubData)
    else
        log.info("MqttTest.MqttClient" .. id .. ".publish." .. topic, "发布FAIL")
    end
    sys.wait(timeout1)
end

local function mqttPubTask(id, client, ip, port, transport, cert)
    local testImei = misc.getImei()
    local topic1 = "topic1-" .. testImei
    local topic2 = "topic2-" .. testImei
    local topic3 = "合宙测试-" .. testImei
    while true do
        log.info("MqttTest.MqttClient" .. id .. ".connect", "开始连接")
        while not client:connect(ip, port, transport, cert) do log.info("MqttTest.MqttClient" .. id, "重新连接") sys.wait(2000) end
        log.info("MqttTest.MqttClient" .. id .. ".connect", "连接SUCCESS")
        while true do
            log.info("MqttTest.MqttClient" .. id .. ".连接状态", client.connected)
            if client.connected then
                publishTest(id, client, topic1, topic1 .. "PubTest" .. count, 0, 0)
                publishTest(id, client, topic2, topic2 .. "PubTest" .. count, 1, 1)
                publishTest(id, client, topic3, topic3 .. "PubTest" .. count, 2, 0)
                count = count + 1
            else
                log.info("MqttTest.MqttClient" .. id .. ".connect", "连接中断")
                break
            end
        end
        log.info("MqttTest.MqttClient" .. id .. ".connect", "开始断开连接")
        client:disconnect()
        log.info("MqttTest.MqttClient" .. id .. ".connect", "断开连接SUCCESS")
    end
end

local function mqttRecTask(id, client, ip, port, transport)
    local testImei = misc.getImei()
    local topic1 = "topic1-" .. testImei
    local topic2 = "topic2-" .. testImei
    local topic3 = "合宙测试-" .. testImei
    while true do
        log.info("MqttTest.MqttClient" .. id .. ".connect", "开始连接")
        while not client:connect(ip, port, transport, cert) do log.info("MqttTest.MqttClient" .. id, "重新连接") sys.wait(2000) end
        log.info("MqttTest.MqttClient" .. id .. ".connect", "连接SUCCESS")
        
        if client:subscribe({[topic1] = 0, [topic2] = 1, [topic3] = 2}) then
            log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅SUCCESS")
        else
            log.info("MqttTest.MqttClient" .. id .. ".subscribe", "订阅FAIL")
        end
        while true do
            log.info("MqttTest.MqttClient" .. id .. ".连接状态", client.connected)
            result, data = client:receive(timeout2)
            if result then
                log.info("MqttTest.MqttClient" .. id .. ".receive", "接收SUCCESS")
                for k, v in pairs(data) do
                    print(k, v)
                end
            elseif client.connected ~= true then
                log.info("MqttTest.MqttClient" .. id .. ".receive", "连接中断")
                break
            else
                log.info("MqttTest.MqttClient" .. id .. ".receive", "接收FAIL")
                log.info("data", data)
                sys.wait(1000)
            end
        end

        log.info("MqttTest.MqttClient" .. id .. ".connect", "开始断开连接")
        client:disconnect()
        log.info("MqttTest.MqttClient" .. id .. ".connect", "断开连接SUCCESS")
    end
end

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","SUCCESS访问网络, MqttPublish测试开始")
        local mqttClient1 = mqtt.client("client1-" .. misc.getImei(), 60, "user", "password")
        mqttPubTask(1, mqttClient1, ip1, port1, "tcp")
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","SUCCESS访问网络, MqttReceive测试开始")
        local mqttClient2 = mqtt.client("client2-" .. misc.getImei(), 30, "user", "password", nil, {qos = 2, retain = 1, topic = "topic2", payload = "WILL MESSAGE"}, "3.1")
        mqttRecTask(2, mqttClient2, ip1, port1, "tcp")
    end
)

-- sys.taskInit(
--     function()
--         sys.waitUntil("IP_READY_IND")
--         log.info("MqttTest","SUCCESS访问网络, MqttSsl1Publish测试开始")
--         local mqttClient3 = mqtt.client("单向认证客户端-" .. randomNum1 .. randomNum2, 60, "user", "password")
--         mqttPubTask(3,mqttClient3,ip1,port2,"tcp_ssl",{["caCert"] = "cacert.pem"},5)
--     end
-- )

-- sys.taskInit(
--     function()
--         sys.waitUntil("IP_READY_IND")
--         log.info("MqttTest","SUCCESS访问网络, MqttSSL双向认证Publish测试开始")
--         local mqttClient4 = mqtt.client("双向认证客户端-" .. misc.getImei(), 60, "user", "password")
--         mqttPubTask(4, mqttClient4, ip1, port2, "tcp_ssl", {["caCert"] = "cacert.pem", ["clientCert"] = "client-cert.pem", ["clientKey"] = "client-key.pem"}, 5)
--     end
-- )
