-- BluetoothTest
-- Author:LuatTest
-- CreateDate:20210322
-- UpdateDate:20210322

module(..., package.seeall)

if LuaTaskTestConfig.bluetoothTest.masterTest then
    sys.taskInit(
        function ()
            local tag = "BluetoothTest.masterTest"
            sys.wait(5000)
            log.info(tag .. ".init", "start")
            rtos.on(rtos.MSG_BLUETOOTH, function(msg)
                if msg.event == btcore.MSG_OPEN_CNF then
                    sys.publish("BT_OPEN", msg.result)
                elseif msg.event == btcore.MSG_BLE_CONNECT_CNF then
                    sys.publish("BT_CONNECT_IND", {["handle"] = msg.handle, ["result"] = msg.result})
                elseif msg.event == btcore.MSG_BLE_DISCONNECT_CNF then
                    log.info(tag, "设备断开连接")
                elseif msg.event == btcore.MSG_BLE_DATA_IND then
                    sys.publish("BT_DATA_IND", {["data"] = msg.data, ["uuid"] = msg.uuid, ["len"] = msg.len})
                elseif msg.event == btcore.MSG_BLE_SCAN_CNF then
                    sys.publish("BT_SCAN_CNF", msg.result)
                elseif msg.event == btcore.MSG_BLE_SCAN_IND then
                    sys.publish("BT_SCAN_IND", {["name"] = msg.name, ["addr_type"] = msg.addr_type, ["addr"] = msg.addr, ["manu_data"] = msg.manu_data, 
                    ["raw_data"] = msg.raw_data, ["raw_len"] = msg.raw_len, ["rssi"] = msg.rssi})
                elseif msg.event == btcore.MSG_BLE_FIND_CHARACTERISTIC_IND then
                    sys.publish("BT_FIND_CHARACTERISTIC_IND", msg.result)
                elseif msg.event == btcore.MSG_BLE_FIND_SERVICE_IND then
                    log.info(tag, "find service UUID", msg.uuid)
                    if msg.uuid == 0x1800 then
                        sys.publish("BT_FIND_SERVICE_IND", msg.result)
                    end
                elseif msg.event == btcore.MSG_BLE_FIND_CHARACTERISTIC_UUID_IND then
                    log.info(tag, "find characteristic uuid", msg.uuid)
                end
            end)

            -- 打开蓝牙主模式
            local btOpenRes = btcore.open(1)
            -- 等待蓝牙打开成功
            sys.waitUntil("BT_OPEN", 5000)

            if btOpenRes == 0 then
                log.info(tag .. ".open", "打开蓝牙SUCCESS")
                log.info(tag .. ".scan", "开始扫描")
                local scanRes = btcore.scan(1)
                if scanRes == 0 then
                    log.info(tag .. ".scan", "打开扫描SUCCESS")
                    local _, scanCnfMsgData = sys.waitUntil("BT_SCAN_CNF", 50000)
                    if scanCnfMsgData ~= 0 then
                        log.error(tag .. ".scancnf", "FAIL")
                    else
                        while true do
                            local _, bt_device = sys.waitUntil("BT_SCAN_IND", 5000)
                            if not bt_device then
                                log.info(tag .. ".scancnf", "扫描蓝牙设备结束")
                                btcore.scan(0)
                                break
                            else
                                local deviceJsonInfo = json.encode(bt_device)

                                log.info(tag .. ".deviceJsonInfo", deviceJsonInfo)

                                if (bt_device.name == "LuatBleSlaveTest") then
                                    local slaveName = bt_device.name
                                    local slaveAddrType = bt_device.addr_type
                                    local slaveAddr = bt_device.addr
                                    local slaveManuData = bt_device.manu_data
                                    local slaveRawData = bt_device.raw_data
                                    btcore.scan(0)
                                    local connectRes = btcore.connect(bt_device.addr)
                                    if connectRes == 0 then
                                        log.info(tag .. "connect", "连接从设备SUCCESS")
                                        local _, bt_connect = sys.waitUntil("BT_CONNECT_IND")
                                        if bt_connect.result ~= 0 then
                                            log.error(tag .. ".connectInd", "连接FAIL")
                                        else
                                            log.info(tag .. ".connectInd", "连接SUCCESS")
                                            log.info(tag .. ".connect_handle", bt_connect.handle)
                                            log.info(tag, "开启蓝牙发现服务")
                                            btcore.findservice()
                                            local _, result = sys.waitUntil("BT_FIND_SERVICE_IND")
                                            if not result then
                                                log.error(tag .. ".findServiceInd", "没有发现服务")
                                            else
                                                btcore.findcharacteristic(0xfee0)
                                                local _, result = sys.waitUntil("BT_FIND_CHARACTERISTIC_IND")
                                                if not result then
                                                    log.error(tag .. ".findServiceInd", "没有发现服务")
                                                else
                                                    btcore.opennotification(0xfee2)

                                                    while true do
                                                        local data = "LuaTaskTest.BluetoothTest.masterTest.data"
                                                        btcore.send(data, 0xfee1, bt_connect.handle)
	                                                	sys.waitUntil("BT_DATA_IND")
                                                        local data = ""
                                                        local len = 0
                                                        local uuid = ""
                                                        while true do
                                                            local recvuuid, recvdata, recvlen = btcore.recv(3)
                                                            if recvlen == 0 then
                                                                break
                                                            end
                                                            uuid = recvuuid
                                                            len = len + recvlen
                                                            data = data .. recvdata
                                                        end
                                                        if len ~= 0 then
                                                            log.info(tag .. ".recvData", data)
                                                            log.info(tag .. ".recvDataLen", len)
                                                            log.info(tag .. ".recvUUID", uuid)
                                                        end
                                                        sys.wait(10000)
                                                    end
                                                end

                                            end
                                        end
                                    else
                                        log.error(tag .. "connect", "连接从设备FAIL")
                                    end
                                end
                            end
                        end
                    end
                    
                else
                    log.error("BluetoothTest.scan", "打开扫描FAIL")
                end
            else
                log.error("BluetoothTest.open", "打开蓝牙FAIL")
            end
        end
    )
end

if LuaTaskTestConfig.bluetoothTest.slaveTest then
    sys.taskInit(
        function ()
            local tag = "BluetoothTest.slaveTest"
            sys.wait(5000)
            log.info(tag .. ".init", "start")
            rtos.on(rtos.MSG_BLUETOOTH, function(msg)
                -- 蓝牙打开成功
                if msg.event == btcore.MSG_OPEN_CNF then
                    log.info(tag .. ".msg", "蓝牙打开SUCCESS")
                    sys.publish("BT_OPEN", msg.result)
                -- 蓝牙连接成功
                elseif msg.event == btcore.MSG_BLE_CONNECT_IND then
                    log.info(tag .. ".msg", "蓝牙连接SUCCESS")
                    sys.publish("BT_CONNECT_IND", {["handle"] = msg.handle, ["result"] = msg.result})
                -- 蓝牙断开连接
	        	elseif msg.event == btcore.MSG_BLE_DISCONNECT_IND then
                    log.info(tag .. ".msg", "蓝牙断开连接")
                -- 接收到的数据内容
                elseif msg.event == btcore.MSG_BLE_DATA_IND then
                    sys.publish("BT_DATA_IND", {["result"] = msg.result})
                end
            end)

            -- 打开蓝牙从模式
            local btOpenRes = btcore.open(0)
            -- 等待蓝牙打开成功
            sys.waitUntil("BT_OPEN", 5000)

            if btOpenRes == 0 then
                log.info(tag .. ".open", "打开蓝牙SUCCESS")
                local setNameRes = btcore.setname("LuatBleSlaveTest")

                if setNameRes == 0 then
                    log.info(tag .. ".setName", "设置名称SUCCESS")
                    -- 打开广播
                    local advertisingRes = btcore.advertising(1)

                    if advertisingRes == 0 then
                        log.info(tag .. ".advertising", "打开广播SUCCESS")
                        local _, btConnectMsgRes = sys.waitUntil("BT_CONNECT_IND")
                    
                        if btConnectMsgRes.result == 0 then
                            log.info(tag .. ".connect", "连接SUCCESS")
                            log.info(tag .. ".connect.handle", btConnectMsgRes.handle)
                            sys.wait(1000)
                            while true do
                                sys.waitUntil("BT_DATA_IND")
                                local data = ""
                                local len = 0
                                local uuid = ""
                                local recvuuid, recvdata, recvlen
                                while true do
                                    recvuuid, recvdata, recvlen = btcore.recv(3)
                                    if recvlen == 0 then
                                        break
                                    end
                                    uuid = recvuuid
                                    len = len + recvlen
                                    data = data .. recvdata
                                end
                                if len ~= 0 then
                                    log.info(tag .. ".receiveData", data)
                                    log.info(tag .. ".receiveDataLen", len)
                                    log.info(tag .. ".receiveUUID", string.toHex(uuid))
                                    if data == "close" then
                                        btcore.disconnect()
                                    end
                                    btcore.send("LuaTaskTest.BluetoothTest.slaveTest.data", 0xfee2, btConnectMsgRes.handle)
                                end
                            end
                        else
                            log.error(tag .. ".connect", "连接FAIL")
                        end
                    else
                        log.error(tag .. ".advertising", "打开广播FAIL")
                    end
                else
                    log.error(tag .. ".setName", "设置名称FAIL")
                end
            else
                log.error(tag .. ".open", "打开蓝牙FAIL")
            end
        end
    )
end