-- BluetoothTest
-- Author:LuatTest
-- CreateDate:20210322
-- UpdateDate:20210325

module(..., package.seeall)

local waitTime = 5000

-- 蓝牙消息码
-- [MSG_BLE_DATA_IND] 100
-- [MSG_BT_AVRCP_DISCONNECT_IND] 27
-- [MSG_BLE_FIND_SERVICE_IND] 71
-- [MSG_BLE_SCAN_CNF] 64
-- [MSG_BLE_FIND_CHARACTERISTIC_IND] 70
-- [MSG_BLE_CONNECT_IND] 68
-- [MSG_BLE_SCAN_IND] 66
-- [MSG_BT_HFP_CALLSETUP_OUTGOING] 22
-- [MSG_BLE_FIND_CHARACTERISTIC_UUID_IND] 72
-- [MSG_BLE_DISCONNECT_IND] 69
-- [MSG_BLE_DISCONNECT_CNF] 57
-- [MSG_BLE_CONNECT_CNF] 56
-- [MSG_BT_AVRCP_CONNECT_IND] 26
-- [MSG_BT_HFP_RING_INDICATION] 25
-- [MSG_BT_HFP_CALLSETUP_INCOMING] 23
-- [MSG_BT_HFP_CONNECT_IND] 18

rtos.on(
    rtos.MSG_BLUETOOTH,
    function(msg)
        local tag = "BluetoothTest"
        log.info(tag .. ".rtosMsg", "table_info")
        for k, v in pairs(msg) do
            log.info(k, v)
        end
        if msg.event == btcore.MSG_OPEN_CNF then
            sys.publish("BT_OPEN", msg.result)
        elseif msg.event == btcore.MSG_BLE_CONNECT_CNF then
            sys.publish("BT_CONNECT_IND", {["handle"] = msg.handle, ["result"] = msg.result})
        elseif msg.event == btcore.MSG_BLE_CONNECT_IND then
            log.info(tag .. ".msg", "蓝牙连接SUCCESS")
            sys.publish("BT_CONNECT_IND", {["handle"] = msg.handle, ["result"] = msg.result})
        elseif msg.event == btcore.MSG_BLE_DISCONNECT_CNF then
            log.info(tag, "设备断开连接")
        elseif msg.event == btcore.MSG_BLE_DISCONNECT_IND then
            log.info(tag .. ".msg", "蓝牙断开连接")
        elseif msg.event == btcore.MSG_BLE_DATA_IND then
            sys.publish("BT_DATA_IND", {["data"] = msg.data, ["uuid"] = msg.uuid, ["len"] = msg.len})
        elseif msg.event == btcore.MSG_BLE_SCAN_CNF then
            sys.publish("BT_SCAN_CNF", msg.result)
        elseif msg.event == btcore.MSG_BLE_SCAN_IND then
            sys.publish("BT_SCAN_IND", {["name"] = msg.name, ["addr_type"] = msg.addr_type, ["addr"] = msg.addr, ["manu_data"] = msg.manu_data, ["raw_data"] = msg.raw_data, ["raw_len"] = msg.raw_len, ["rssi"] = msg.rssi})
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
    end
)

-- 自定义服务
local function service(uuid, struct)
    btcore.addservice(uuid)
    for i = 1, #struct do
		btcore.addcharacteristic(struct[i][1], struct[i][2], struct[i][3])
		if(type(struct[i][4]) == "table") then
			for j = 1, #struct[i][4] do
                btcore.adddescriptor(struct[i][4][j][1], struct[i][4][j][2])
			end
		end
	end
end

if LuaTaskTestConfig.bluetoothTest.masterTest then
    sys.taskInit(
        function()
            local tag = "BluetoothTest.masterTest"
            local msgRes, msgData
            sys.wait(5000)
            log.info(tag, "start")
            while true do
                if btcore.open(1) == 0 then
                    msgRes, msgData = sys.waitUntil("BT_OPEN", 5000)
                    if msgRes == true and msgData == 0 then
                        log.info(tag .. ".open", "打开蓝牙SUCCESS")
                        log.info(tag .. ".scan", "开始扫描")
                        if btcore.scan(1) == 0 then
                            msgRes, msgData = sys.waitUntil("BT_SCAN_CNF", 50000)
                            if msgRes == false and msgData ~= 0 then
                                log.error(tag .. ".scan", "打开扫描FAIL")
                            else
                                log.info(tag .. ".scan", "打开扫描SUCCESS")
                                while true do
                                    msgRes, msgData = sys.waitUntil("BT_SCAN_IND", 5000)
                                    if not msgData and msgRes == false then
                                        log.info(tag .. ".scan", "没有扫描到蓝牙设备")
                                        break
                                    else
                                        local deviceJsonInfo = json.encode(msgData)
                                        log.info(tag .. ".deviceJsonInfo", deviceJsonInfo)
                                        if (msgData.name == "LuaTaskTestBleTest") then
                                            local slaveName = msgData.name
                                            local slaveAddrType = msgData.addr_type
                                            local slaveAddr = msgData.addr
                                            local slaveManuData = msgData.manu_data
                                            local slaveRawData = msgData.raw_data
                                            btcore.scan(0)
                                            local connectRes = btcore.connect(msgData.addr)
                                            if connectRes == 0 then
                                                log.info(tag .. "connect", "连接从设备SUCCESS")
                                                local _, bt_connect = sys.waitUntil("BT_CONNECT_IND")
                                                if bt_connect.result ~= 0 then
                                                    log.error(tag .. ".connectInd", "连接FAIL")
                                                else
                                                    log.info(tag .. ".connectInd", "连接SUCCESS")
                                                    log.info(tag, "开启蓝牙发现服务")
                                                    btcore.findservice()
                                                    local _, result = sys.waitUntil("BT_FIND_SERVICE_IND")
                                                    if not result then
                                                        log.error(tag .. ".findServiceInd", "没有发现服务")
                                                    else
                                                        -- btcore.findcharacteristic(0xfee0)
                                                        -- local _, result = sys.waitUntil("BT_FIND_CHARACTERISTIC_IND")
                                                        btcore.findcharacteristic("9ecadc240ee5a9e093f3a3b50100406e")
                                                        local _, result = sys.waitUntil("BT_FIND_CHARACTERISTIC_IND")
                                                        if not result then
                                                            log.error(tag .. ".findServiceInd", "没有发现服务")
                                                        else
                                                            -- btcore.opennotification(0xfee2)
                                                            btcore.opennotification("9ecadc240ee5a9e093f3a3b50200406e")
                                                            while true do
                                                                local data = "LuaTaskTest.BluetoothTest.masterTest.data"
                                                                -- local sendRes = btcore.send(data, 0xfee1, bt_connect.handle)
                                                                local sendRes = btcore.send(data, "9ecadc240ee5a9e093f3a3b50300406e", bt_connect.handle)
                                                                if sendRes == 0 then
                                                                    log.info(tag .. ".send", "蓝牙数据发送SUCCESS")
                                                                    sys.waitUntil("BT_DATA_IND", 5000)
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
                                                                        log.info(tag .. ".recvUUIDHex", string.toHex(uuid))
                                                                    end
                                                                    sys.wait(10000)
                                                                else
                                                                    log.error(tag .. ".send", "蓝牙数据发送FAIL")
                                                                    log.info(tag .. ".reConnect", "发起重连")
                                                                    local connectRes = btcore.connect(bt_device.addr)
                                                                    if connectRes == 0 then
                                                                        log.info(tag .. ".reConnect", "重连SUCCESS")
                                                                    else
                                                                        log.error(tag .. ".reConnect", "重连FAIL，可能是设备已无法连接")
                                                                    end
                                                                end
                                                            
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
                else
                    log.error("BluetoothTest.open", "打开蓝牙FAIL")
                end
                btcore.scan(0)
                btcore.close()
                sys.wait(waitTime)
            end
        end
    )
end

if LuaTaskTestConfig.bluetoothTest.slaveTest then
    sys.taskInit(
        function ()
            local tag = "BluetoothTest.slaveTest"
            local msgRes, msgData
            sys.wait(waitTime)
            while true do
                if btcore.open(0) == 0 then
                    msgRes, msgData = sys.waitUntil("BT_OPEN", 5000)
                    if msgRes == true and msgData == 0 then
                        log.info(tag .. ".open", "打开蓝牙从模式SUCCESS")
                        if btcore.setname("LuaTaskTestBleTest") == 0 then
                            log.info(tag .. ".setName", "设置名称SUCCESS")
                            local struct1 = {
                                {0xfee1, 0x08, 0x0002},
                                {0xfee2, 0x10, 0x0001, {
                                                        {0x2902, 0x0001},
                                                        {0x2901, "123456"}
                                                       }
                                }
                            }
                            local struct2 = {
                                {"9ecadc240ee5a9e093f3a3b50200406e", 0x10, 0x0001, {{0x2902, 0x0001}}},
                                {"9ecadc240ee5a9e093f3a3b50300406e", 0x0c, 0x0002}
                            }
                            btcore.setadvdata(string.fromHex("02010604ff000203"))
                            btcore.setscanrspdata(string.fromHex("04ff000203"))
                            -- service(0xfee0, struct1)
                            service("9ecadc240ee5a9e093f3a3b50100406e", struct2)
	                        btcore.setadvparam(0x80, 0xa0, 0, 0, 0x07, 0, 0, "11:22:33:44:55:66")
                            if btcore.advertising(1) == 0 then
                                log.info(tag .. ".advertising", "打开广播SUCCESS")
                                msgRes, msgData = sys.waitUntil("BT_CONNECT_IND")
                                if msgRes == true and msgData.result == 0 then
                                    log.info(tag .. ".connect", "蓝牙连接SUCCESS")
                                    while true do
                                        msgRes, msgData = sys.waitUntil("BT_DATA_IND")
                                        if msgRes == true then
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
                                                log.info(tag .. ".recvData", data)
                                                log.info(tag .. ".recvDataLen", len)
                                                log.info(tag .. ".recvUUIDHex", string.toHex(uuid))
                                                if data == "close" then
                                                    btcore.disconnect()
                                                end
                                                -- btcore.send("LuaTaskTest.BluetoothTest.slaveTest.data", 0xfee2, msgData.handle)
                                                btcore.send("LuaTaskTest.BluetoothTest.slaveTest.data", "9ecadc240ee5a9e093f3a3b50200406e", msgData.handle)
                                            end
                                        else
                                            log.info(tag .. ".recv", "没有接收到数据")
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
                        log.error(tag .. ".open", "打开蓝牙从模式FAIL")
                    end
                else
                    log.error(tag .. ".open", "打开蓝牙从模式FAIL")
                end
                sys.wait(5000)
            end
            btcore.close()
        end
    )
end

if LuaTaskTestConfig.bluetoothTest.beaconTest then
    sys.taskInit(
        function()
            sys.wait(5000)
            local tag = "BluetoothTest.beaconTest"        
            if btcore.open(0) == 0 then
                log.info(tag .. ".open", "SUCCESS")
                sys.waitUntil("BT_OPEN", 5000)
                if btcore.setname("LuatBleSlaveTest") == 0 then
                    log.info(tag .. ".setName", "设置名称SUCCESS")
                    if btcore.setbeacondata("AB8190D5D11E4941ACC442F30510B408", 10107, 50179) == 0 then
                        log.info(tag .. ".setbeacondata", "SUCCESS")
                        if btcore.advertising(1) == 0 then
                            log.info(tag .. ".advertising", "SUCCESS")
                        else
                            log.error(tag .. ".advertising", "FAIL")
                        end
                    else
                        log.error(tag .. ".setbeacondata", "FAIL")
                    end
                else
                    log.error(tag .. ".setName", "设置名称FAIL")
                end
            else
                log.error(tag .. ".open", "FAIL")
            end
        end
    )
end

if LuaTaskTestConfig.bluetoothTest.scanTest then
    sys.taskInit(
        function ()
            local tag = "BluetoothTest.scanTest"
            local msgRes, msgData
            sys.wait(waitTime)
            while true do
                if btcore.open(1) == 0 then
                    msgRes, msgData = sys.waitUntil("BT_OPEN", 5000)
                    if msgRes == true and msgData == 0 then
                        log.info(tag .. ".open", "打开蓝牙SUCCESS")
                        if btcore.scan(1) == 0 then
                            msgRes, msgData = sys.waitUntil("BT_SCAN_CNF", 50000)
                            if msgRes == true and msgData == 0 then
                                log.info(tag .. ".scan", "打开扫描SUCCESS")
                                for i = 1, 10 do
                                    msgRes, msgData = sys.waitUntil("BT_SCAN_IND", 5000)
                                    if not msgData then
                                        log.error(tag .. ".scan", "没有扫描到蓝牙设备")
                                        break
                                    else
                                        local deviceJsonInfo = json.encode(msgData)
                                        log.info(tag .. ".deviceJsonInfo", deviceJsonInfo)
                                    end
                                end
                            else
                                log.error(tag .. ".scan", "打开扫描FAIL")
                            end      
                        else
                            log.error("BluetoothTest.scan", "打开扫描FAIL")
                        end
                    else
                        log.error(tag .. ".open", "打开蓝牙FAIL")
                    end
                else
                    log.error(tag .. ".open", "打开蓝牙FAIL")
                end
                btcore.scan(0)
                log.info(tag .. ".scan", "关闭蓝牙扫描")
                sys.wait(3000)
                btcore.close()
                log.info(tag .. ".close", "关闭蓝牙")
                sys.wait(waitTime)
            end
        end
    )
end