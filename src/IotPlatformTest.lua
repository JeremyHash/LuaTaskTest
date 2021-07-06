-- IotPlatformTest
-- Author:LuatTest
-- CreateDate:20210706
-- UpdateDate:20210706

module(..., package.seeall)

if LuaTaskTestConfig.iotplatformTest.ctwingTest then

    local tag1 = "CtwingTest"

    local DevicetId = "15030111001"
    local DeviceSecret = "03Az3Wxe9nRmMRvohykD_HqYA1T65Bof0Igm2lbzx9c"
    
    local ctwing_mqttClient
    local function getDeviceName()
        return misc.getImei()
    end
    
    local ctwing_iot_subscribetopic = {
        ["test"]=0
    }
    
    function ctwingiot_publish()
        ctwing_mqttClient:publish("$thing/up/property/"..ProductId.."/"..getDeviceName(), "publish from luat mqtt client", 0)
        local body = {
            pci=-32768,
            rsrp=-32768,
            cell_id=-2147483648,
            sinr=-32768,
            ecl=-33333,
        }
        local body_json = json.encode(body)
    
        ctwing_mqttClient:publish("signal_report", body_json, 0)
    end

    local rstTim, flyTim = 600000, 300000
    local mqtt_ready = false
    function isReady()
        return mqtt_ready
    end

    local function proc(mqttClient)
        local result,data
        while true do
            result,data = mqttClient:receive(120000,"APP_SOCKET_SEND_DATA")
            --接收到数据(需要通过平台手动发送指令)
            if result then
                log.info(tag1,"mqttInMsg.proc：",data.topic,string.toHex(data.payload))
    
                --TODO：根据需求自行处理data.payload
            else
                log.info(tag1,"mqttInMsg.proc：","未接收到数据")
                break
            end
        end
        return result or data=="timeout" or data=="APP_SOCKET_SEND_DATA"
    end
    
    
    local function ctwing_iot()
        while true do
            if not socket.isReady() and not sys.waitUntil("IP_READY_IND", rstTim) then sys.restart("网络初始化失败!") end
            --创建一个MQTT客户端
            ctwing_mqttClient = mqtt.client(DevicetId,300,"123456789",DeviceSecret)
            --阻塞执行MQTT CONNECT动作，直至成功
                while not ctwing_mqttClient:connect("mqtt.ctwing.cn",1883,"tcp",nil,2000) do sys.wait(2000) end
                log.info(tag1,"mqtt连接成功")
    
                --订阅主题
                if ctwing_mqttClient:subscribe(ctwing_iot_subscribetopic, nil) then
                    log.info(tag1,"mqtt订阅成功")
                    --循环处理接收和发送的数据
                    while true do
                        mqtt_ready = true
                        if not proc(ctwing_mqttClient) then log.error(tag,"mqttTask.mqttInMsg.proc error") break end
                    end
                else
                    log.info(tag1,"mqtt订阅失败")
                end
                mqtt_ready = false
            --断开MQTT连接
            ctwing_mqttClient:disconnect()
        end
    end
    
    local function iot()
        ntp.timeSync()
        if not socket.isReady() and not sys.waitUntil("IP_READY_IND", rstTim) then sys.restart("网络初始化失败!") end
        while not ntp.isEnd() do sys.wait(1000) end
        ctwing_iot()
    end
    
    net.switchFly(false)
    -- NTP同步失败强制重启
    local tid = sys.timerStart(function()
        net.switchFly(true)
        sys.timerStart(net.switchFly, 5000, false)
    end, flyTim)
    sys.subscribe("IP_READY_IND", function()
        sys.timerStop(tid)
        log.info("---------------------- 网络注册已成功 ----------------------")
    end)
    sys.taskInit(iot)

end


if LuaTaskTestConfig.iotplatformTest.txiotTest then

    local tag2 = "TxiotTest"

    -- 产品ID和产品动态注册秘钥
    --测试前前先将产品下的设备状态先重新激活或删除设备
    local ProductId = "BC08DQD2GB"
    local ProductSecret = "FuQZRCQ5dcfbY13430WD8zzf"
    
    -- local ProductId = "5FCW79CXYD"
    -- local ProductSecret = "XOBuiSs4EUCjmP5NcFWrwdOe"
    
    
    local tx_mqttClient

    local function getDeviceName()
        --默认使用设备的IMEI作为设备名称，用户可以根据项目需求自行修改
        return misc.getImei()
    end
    
    function txiot_publish()
        --sys.publish("APP_SOCKET_SEND_DATA")
        --mqtt发布主题
        tx_mqttClient:publish("$thing/up/property/"..ProductId.."/"..getDeviceName(), "publish from luat mqtt client", 0)
    end
    
    -- 无网络重启时间，飞行模式启动时间
    local rstTim, flyTim = 600000, 300000
    local enrol_end = false
    local mqtt_ready = false

    function isReady()
        return mqtt_ready
    end
    
    local function proc(mqttClient)
        local result,data
        while true do
            result,data = mqttClient:receive(60000,"APP_SOCKET_SEND_DATA")
            --接收到数据
            if result then
                log.info(tag2..".mqttInMsg.proc",data.topic,string.toHex(data.payload))
    
                --TODO：根据需求自行处理data.payload
            else
                break
            end
        end
        return result or data=="timeout" or data=="APP_SOCKET_SEND_DATA"
    end
    
    local function cbFnc(result,prompt,head,body)
        log.info("testHttp.cbFnc",result,prompt,head,body)
        local dat, result, errinfo = json.decode(body)
        if result then
            if dat.code==0 then
                io.writeFile("/txiot.dat", body)
                log.info(tag2,"腾讯云注册设备成功:", body)
            else
                log.info(tag2,"腾讯云设备注册失败:", body)
            end
            enrol_end = true
        end
    end
    
    local function device_enrol()
        local deviceName = getDeviceName()
        local nonce = math.random(1,100)
        local timestamp = os.time()
        local data = "deviceName="..deviceName.."&nonce="..nonce.."&productId="..ProductId.."&timestamp="..timestamp
        local hmac_sha1_data = crypto.hmac_sha1(data,#data,ProductSecret,#ProductSecret):lower()
        local signature = crypto.base64_encode(hmac_sha1_data,#hmac_sha1_data)
        local tx_body = {
            deviceName=deviceName,
            nonce=nonce,
            productId=ProductId,
            timestamp=timestamp,
            signature=signature,
        }
        local tx_body_json = json.encode(tx_body)
        http.request("POST","https://ap-guangzhou.gateway.tencentdevices.com/register/dev",nil,{["Content-Type"]="application/json; charset=UTF-8"},tx_body_json,30000,cbFnc)
    end
    
    local function tencent_iot()
        if not io.exists("/txiot.dat") then device_enrol() while not enrol_end do sys.wait(100) end end
        if not io.exists("/txiot.dat") then device_enrol() log.warn("设备注册失败或设备已注册") return end
        local dat = json.decode(io.readFile("/txiot.dat"))
        local clientid = ProductId .. getDeviceName()    --生成 MQTT 的 clientid 部分, 格式为 ${productid}${devicename}
        local connid = math.random(10000,99999)
        local expiry = tostring(os.time() + 3600)
        local username = string.format("%s;12010126;%s;%s", clientid, connid, expiry)   --生成 MQTT 的 username 部分, 格式为 ${clientid};${sdkappid};${connid};${expiry}
        local payload = json.decode(crypto.aes_decrypt("CBC","ZERO",crypto.base64_decode(dat.payload, #dat.payload),string.sub(ProductSecret,1,16),"0000000000000000"))
        local password
        if payload.encryptionType==2 then
            local raw_key = crypto.base64_decode(payload.psk, #payload.psk) --生成 MQTT 的 设备密钥 部分
            password = crypto.hmac_sha256(username, raw_key):lower() .. ";hmacsha256" --根据物联网通信平台规则生成 password 字段
        elseif payload.encryptionType==1 then
            io.writeFile("/client.crt", payload.clientCert)
            io.writeFile("/client.key", payload.clientKey)
        end
        while true do
            if not socket.isReady() and not sys.waitUntil("IP_READY_IND", rstTim) then sys.restart("网络初始化失败!") end
            --创建一个MQTT客户端
            tx_mqttClient = mqtt.client(clientid,300,username,password)
            --阻塞执行MQTT CONNECT动作，直至成功
            if payload.encryptionType==2 then
                while not tx_mqttClient:connect(ProductId..".iotcloud.tencentdevices.com",1883,"tcp",nil,2000) do sys.wait(2000) end
            elseif payload.encryptionType==1 then
                while not tx_mqttClient:connect(ProductId..".iotcloud.tencentdevices.com",8883,"tcp_ssl",{clientCert="/client.crt",clientKey="/client.key"},2000) do sys.wait(2000) end
            end
                log.info(tag,"mqtt连接SUCCESS")
                tx_mqttClient:publish("$thing/up/property/"..ProductId.."/"..getDeviceName(), "publish from luat mqtt client", 0)
                --mqtt订阅主题
                local txiot_subscribetopic = {
                    ["$thing/down/property/"..ProductId.."/"..getDeviceName()]=0
                }
                --订阅主题
                if tx_mqttClient:subscribe(txiot_subscribetopic, nil) then
                    log.info(tag2,"mqtt订阅SUCCESS")
                    --循环处理接收和发送的数据
                    while true do
                        mqtt_ready = true
                        if proc(tx_mqttClient) then 
                            log.info(tag2,"接收信息SUCCESS")
                        else
                            log.error(tag2,"接收信息FAIL") break
                        end
                    end
                else
                    log.info(tag2,"mqtt订阅FAIL")
                end
                mqtt_ready = false
            --断开MQTT连接
            tx_mqttClient:disconnect()
        end
    end
    
    local function iot()
        ntp.timeSync()
        if not socket.isReady() and not sys.waitUntil("IP_READY_IND", rstTim) then sys.restart("网络初始化失败!") end
        while not ntp.isEnd() do sys.wait(1000) end
        tencent_iot()
    end
    
    net.switchFly(false)
    -- NTP同步失败强制重启
    local tid = sys.timerStart(function()
        net.switchFly(true)
        sys.timerStart(net.switchFly, 5000, false)
    end, flyTim)
    sys.subscribe("IP_READY_IND", function()
        sys.timerStop(tid)
        log.info("---------------------- 网络注册已成功 ----------------------")
    end)
    
    sys.taskInit(iot)

end