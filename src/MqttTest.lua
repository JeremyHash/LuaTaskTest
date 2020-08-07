module(...,package.seeall)

local timeout1 = 3000
local timeout2 = 30000

local imei = misc.getImei()

local mqttClient1 = mqtt.client(imei.."1",600,"user","password")
local mqttClient2 = mqtt.client(imei.."2",600,"user","password")
local mqttClient3 = mqtt.client(imei.."3",600,"user","password")

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("MqttTest","成功访问网络,Mqtt测试开始")

        local topic1 = "/Jeremy0"
        local topic2 = "/Jeremy1"
        local topic3 = "/Jeremy2"
        local topic4 = "/合宙测试"

        while true do
            if mqttClient1:connect("wiki.airm2m.com",41883,"tcp") then
                log.info("MqttTest.MqttClient1.connect","连接成功")
                sys.publish("MqttClient1Connect")
                if mqttClient1:subscribe({[topic1]=0, [topic2]=1, [topic3]=2, [topic4]=2}) then
                    log.info("MqttTest.MqttClient1.subscribe","订阅成功")
                else
                    log.info("MqttTest.MqttClient1.subscribe","订阅失败")
                end
                for i=1,10 do
                    if mqttClient1:publish(topic1,"Jeremy0",0) then
                        log.info("MqttTest.MqttClient1.publish."..topic1,"发布成功")
                        sys.publish("MqttClient1Publish")
                    else
                        log.info("MqttTest.MqttClient1.publish."..topic1,"发布失败")
                    end
                    sys.wait(timeout1)
                end
            else
                log.info("MqttTest.MqttClient1.connect","连接失败")
            end
            mqttClient1:disconnect()
            sys.wait(timeout1)

            -- if mqttClient2:connect("wiki.airm2m.com",41883,"tcp") then
            --     log.info("MqttTest.MqttClient2.connect","连接成功")
            --     if mqttClient2:subscribe({[topic1]=0, [topic2]=1, [topic3]=2, [topic4]=2}) then
            --         log.info("MqttTest.MqttClient2.subscribe","订阅成功")
            --     else
            --         log.info("MqttTest.MqttClient2.subscribe","订阅失败")
            --     end
            --     for i=1,10 do
            --         if mqttClient2:publish(topic1,"Jeremy0",0) then
            --             log.info("MqttTest.MqttClient2.publish."..topic1,"发布成功")
            --             sys.publish("MqttClient2Publish")
            --         else
            --             log.info("MqttTest.MqttClient2.publish."..topic1,"发布失败")
            --         end
            --         sys.wait(timeout1)
            --     end
            -- else
            --     log.info("MqttTest.MqttClient2.connect","连接失败")
            -- end
            -- mqttClient2:disconnect()
            -- sys.wait(timeout1)

            -- if mqttClient3:connect("wiki.airm2m.com",41883,"tcp") then
            --     log.info("MqttTest.MqttClient3.connect","连接成功")
            --     if mqttClient3:subscribe({[topic1]=0, [topic2]=1, [topic3]=2, [topic4]=2}) then
            --         log.info("MqttTest.MqttClient3.subscribe","订阅成功")
            --     else
            --         log.info("MqttTest.MqttClient3.subscribe","订阅失败")
            --     end
            --     for i=1,10 do
            --         if mqttClient3:publish(topic1,"Jeremy0",0) then
            --             log.info("MqttTest.MqttClient3.publish."..topic1,"发布成功")
            --             sys.publish("MqttClient3Publish")
            --         else
            --             log.info("MqttTest.MqttClient3.publish."..topic1,"发布失败")
            --         end
            --         sys.wait(timeout1)
            --     end
            -- else
            --     log.info("MqttTest.MqttClient3.connect","连接失败")
            -- end
            -- mqttClient3:disconnect()
            -- sys.wait(timeout1)
        end
    end
)

sys.taskInit(
    function()
        local result,data
        sys.waitUntil("MqttClient1Connect")
        while true do
            -- sys.waitUntil("MqttClient1Publish")
            result,data = mqttClient1:receive(timeout2,"MqttClient1Publish")
            if result then
                log.info("MqttTest.MqttClient1.receive",data.topic,string.toHex(data.payload))
            else
                log.info("MqttTest.MqttClient1.receive","接收失败")
            end
        end
    end
)

-- sys.taskInit(
--     function()
--         local result,data
--         while true do
--             sys.waitUntil("MqttClient2Publish")
--             result,data = mqttClient2:receive(timeout1)
--             if result then
--                 log.info("MqttTest.MqttClient2.receive",data.topic,string.toHex(data.payload))
--             else
--                 log.info("MqttTest.MqttClient2.receive","接收失败")
--             end
--         end
--     end
-- )

-- sys.taskInit(
--     function()
--         local result,data
--         while true do
--             sys.waitUntil("MqttClient3Publish")
--             result,data = mqttClient3:receive(timeout1)
--             if result then
--                 log.info("MqttTest.MqttClient3.receive",data.topic,string.toHex(data.payload))
--             else
--                 log.info("MqttTest.MqttClient3.receive","接收失败")
--             end
--         end
--     end
-- )