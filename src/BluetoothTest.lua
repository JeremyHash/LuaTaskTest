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
                    log.info(tag, "发现设备UUID", msg.uuid)
                    if msg.uuid == 0x1800 then
                        sys.publish("BT_FIND_SERVICE_IND", msg.result)
                    end
                elseif msg.event == btcore.MSG_BLE_FIND_CHARACTERISTIC_UUID_IND then
                    uuid_c = msg.uuid
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
                        -- sys.timerStart(
                        --     function()
                        --         sys.publish("BT_SCAN_IND", nil)
                        --     end,
                        --     10000
                        -- )
                        while true do
                            local _, bt_device = sys.waitUntil("BT_SCAN_IND")
                            if not bt_device then
                                log.info(tag .. ".scancnf", "没有扫描到蓝牙设备")
                                btcore.scan(0)
                                break
                            else
                                log.info(tag .. ".scanName", bt_device.name)
	                	    	log.info(tag .. ".rssi", bt_device.rssi)
                                log.info(tag .. ".addr_type", bt_device.addr_type)
                                log.info(tag .. ".scan_addr", bt_device.addr)
                                if bt_device.manu_data ~= nil then
                                    log.info(tag .. ".manu_data", string.toHex(bt_device.manu_data))
                                end
                                log.info(tag .. ".raw_len", bt_device.raw_len)
                                if bt_device.raw_data ~= nil then
                                    log.info(tag .. ".raw_data", string.toHex(bt_device.raw_data))
                                end

                                if (bt_device.name == "LuatBleSlaveTest") then
                                    name = bt_device.name
                                    addr_type = bt_device.addr_type
                                    addr = bt_device.addr
                                    manu_data = bt_device.manu_data
                                    adv_data = bt_device.raw_data
                                end
                                if addr == bt_device.addr and bt_device.raw_data ~= adv_data then
                                    scanrsp_data = bt_device.raw_data
                                    btcore.scan(0)
                                    btcore.connect(bt_device.addr)
                                    log.info(tag .. ".connect_name", name)
                                    log.info(tag .. ".connect_addr_type", addr_type)
                                    log.info(tag .. ".connect_addr", addr)
                                    if manu_data ~= nil then
                                        log.info("bt.connect_manu_data", manu_data)
                                    end
                                    if adv_data ~= nil then
                                        log.info("bt.connect_adv_data", adv_data)
                                    end
                                    if scanrsp_data ~= nil then
                                        log.info("bt.connect_scanrsp_data", scanrsp_data)
                                    end
                                end
                            end
                        end
                        local _, bt_connect = sys.waitUntil("BT_CONNECT_IND")
                        if bt_connect.result ~= 0 then
                            log.error(tag .. ".connectInd", "连接FAIL")
                        else
                            log.info(tag .. ".connectInd", "连接SUCCESS")
                            log.info(tag .. ".connect_handle", bt_connect.handle)
                            log.info(tag, "find all service uuid")
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
                                            log.info(tag .. ".recv_data", data)
                                            log.info(tag .. ".recv_data len", len)
                                            log.info(tag .. ".recv_uuid", uuid)
                                        end
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
            sys.wait(5000)
            log.info("BluetoothTest.init", "start")
            rtos.on(rtos.MSG_BLUETOOTH, function(msg)
                -- 蓝牙打开成功
                if msg.event == btcore.MSG_OPEN_CNF then
                    log.info("BluetoothTest.msg", "蓝牙打开SUCCESS")
                    sys.publish("BT_OPEN", msg.result)
                -- 蓝牙连接成功
                elseif msg.event == btcore.MSG_BLE_CONNECT_IND then
                    log.info("BluetoothTest.msg", "蓝牙连接SUCCESS")
                    sys.publish("BT_CONNECT_IND", {["handle"] = msg.handle, ["result"] = msg.result})
                -- 蓝牙断开连接
	        	elseif msg.event == btcore.MSG_BLE_DISCONNECT_IND then
                    log.info("BluetoothTest.msg", "蓝牙断开连接")
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
                log.info("BluetoothTest.open", "打开蓝牙SUCCESS")
                local setNameRes = btcore.setname("LuatBleSlaveTest")

                if setNameRes == 0 then
                    log.info("BluetoothTest.setName", "设置名称SUCCESS")
                    -- 打开广播
                    local advertisingRes = btcore.advertising(1)

                    if advertisingRes == 0 then
                        log.info("BluetoothTest.advertising", "打开广播SUCCESS")
                        local _, btConnectMsgRes = sys.waitUntil("BT_CONNECT_IND")
                    
                        if btConnectMsgRes.result == 0 then
                            log.info("BluetoothTest.connect", "连接SUCCESS")
                            log.info("BluetoothTest.connect.handle", btConnectMsgRes.handle)
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
                                    log.info("Bluetooth.receiveData", data)
                                    log.info("Bluetooth.receiveDataLen", len)
                                    log.info("Bluetooth.receiveUUID", string.toHex(uuid))
                                    if data == "close" then
                                        btcore.disconnect()
                                    end
                                    btcore.send("BluetoothTest.receiveConfirm", 0xfee2, btConnectMsgRes.handle)
                                end
                            end
                        else
                            log.error("BluetoothTest.connect", "连接FAIL")
                        end
                    else
                        log.error("BluetoothTest.advertising", "打开广播FAIL")
                    end
                else
                    log.error("BluetoothTest.setName", "设置名称FAIL")
                end
            else
                log.error("BluetoothTest.open", "打开蓝牙FAIL")
            end
        end
    )
end