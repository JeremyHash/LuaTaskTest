module(...,package.seeall)

local timeout1 = 3000
local timeout2 = 5000

local result,data,count
count = 1

local topic1 = "Jeremy0"
local topic2 = "Jeremy1"
local topic3 = "合宙测试"

local ip1 = "wiki.airm2m.com"
local port1 = 41883
local port2 = 48883

local mqttClient1 = mqtt.client("client".."1",60,"user","password")
local mqttClient2 = mqtt.client("client".."2",60,"user","password")
local mqttClient3 = mqtt.client("单向认证客户端".."3",60,"user","password")
local mqttClient4 = mqtt.client("双向认证客户端".."4",60,"user","password")


local function publishTest(id,client,topic,pubData,qos,retain)
    if client:publish(topic,pubData,qos,retain) then
        log.info("MqttTest.MqttClient"..id..".publish."..topic,"发布成功")
    else
        log.info("MqttTest.MqttClient"..id..".publish."..topic,"发布失败")
    end
    sys.wait(timeout1)
end

local function mqttPubTask(id,client,ip,port,transport,cert,timeout)
    log.info("MqttTest.MqttClient"..id..".connect","开始连接")
    while not client:connect(ip,port,transport,cert,timeout) do sys.wait(2000) end
    log.info("MqttTest.MqttClient"..id..".connect","连接成功")
    while true do
        publishTest(id,client,topic1,topic1.."PubTest"..count,0,0)
        publishTest(id,client,topic2,topic2.."PubTest"..count,1,1)
        publishTest(id,client,topic3,topic3.."PubTest"..count,2,0)
        count = count + 1
    end
    log.info("MqttTest.MqttClient"..id..".connect","开始断开连接")
    client:disconnect()
    log.info("MqttTest.MqttClient"..id..".connect","断开连接成功")
end

local function mqttRecTask(id,client,ip,port,transport,cert,timeout3)
    while true do
        if client:connect(ip,port,transport,cert) then
            log.info("MqttTest.MqttClient"..id..".connect","连接成功")
            if client:subscribe({[topic1]=0, [topic2]=1, [topic3]=2}) then
                log.info("MqttTest.MqttClient"..id..".subscribe","订阅成功")
            else
                log.info("MqttTest.MqttClient"..id..".subscribe","订阅失败")
            end
            while true do
                result,data = client:receive(timeout2)
                if result then
                    log.info("MqttTest.MqttClient"..id..".receive","接收成功")
                    for k,v in pairs(data) do
                        print(k,v)
                    end
                else
                    log.info("MqttTest.MqttClient"..id..".receive","接收失败")
                    log.info("data", data)
                    sys.wait(1000)
                end
            end
        else
            log.info("MqttTest.MqttClient"..id..".connect","连接失败")
        end
    end
    client:disconnect()
end

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络,MqttPublish测试开始")
        mqttPubTask(1,mqttClient1,ip1,port1,"tcp")
    end
)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络,MqttReceive测试开始")
        mqttRecTask(2,mqttClient2,ip1,port1,"tcp")
    end
)

-- sys.taskInit(
--     function()
--         sys.waitUntil("IP_READY_IND")
--         log.info("MqttTest","成功访问网络,MqttSsl1Publish测试开始")
--         mqttPubTask(3,mqttClient3,ip1,port2,"tcp_ssl",{["caCert"] = "cacert.pem"},5)
--     end
-- )

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络,MqttSsl双向认证Publish测试开始")
        mqttPubTask(4,mqttClient4,ip1,port2,"tcp_ssl",{["caCert"] = "cacert.pem",["clientCert"] = "client-cert.pem",["clientKey"] = "client-key.pem"},5)
    end

sys.taskInit(
    function()
        while true do
            log.info("1connected", mqttClient1.connected)
            log.info("2connected", mqttClient2.connected)
            log.info("4connected", mqttClient4.connected)
            sys.wait(2000)
        end
    end
)
