--- 模块功能：蓝牙功能测试
-- @author openLuat
-- @module bluetooth.master
-- @license MIT
-- @copyright openLuat
-- @release 2020.09.27
-- @注意 需要使用core(Luat_VXXXX_RDA8910_BT_FLOAT)版本
module(..., package.seeall)

local timeout = 5000

-- 主
local function init1()
    log.info("bt", "init")
    rtos.on(rtos.MSG_BLUETOOTH, function(msg)
        if msg.event == btcore.MSG_OPEN_CNF then
            sys.publish("BT_OPEN", msg.result) --蓝牙打开成功
        elseif msg.event == btcore.MSG_BLE_CONNECT_CNF then
            sys.publish("BT_CONNECT_IND", {["handle"] = msg.handle, ["result"] = msg.result}) --蓝牙连接成功
        elseif msg.event == btcore.MSG_BLE_DISCONNECT_CNF then
            log.info("蓝牙断开连接SUCCESS") --蓝牙断开连接
        elseif msg.event == btcore.MSG_BLE_DATA_IND then
            sys.publish("BT_DATA_IND", {["data"] = msg.data, ["uuid"] = msg.uuid, ["len"] = msg.len})  --接收到的数据内容
        elseif msg.event == btcore.MSG_BLE_SCAN_CNF then
            sys.publish("BT_SCAN_CNF", msg.result) --打开扫描成功
        elseif msg.event == btcore.MSG_BLE_SCAN_IND then
            sys.publish("BT_SCAN_IND", {["name"] = msg.name, ["addr_type"] = msg.addr_type, ["addr"] = msg.addr, ["manu_data"] = msg.manu_data, 
            ["raw_data"] = msg.raw_data, ["raw_len"] = msg.raw_len, ["rssi"] = msg.rssi})  --接收到扫描广播包数据
        elseif msg.event == btcore.MSG_BLE_FIND_CHARACTERISTIC_IND then
            sys.publish("BT_FIND_CHARACTERISTIC_IND", msg.result)  --发现服务包含的特征
        elseif msg.event == btcore.MSG_BLE_FIND_SERVICE_IND then
            log.info("bt", "find service uuid",msg.uuid)  --发现蓝牙包含的16bit uuid
            if msg.uuid == 0x1800 then          --根据想要的uuid修改
                sys.publish("BT_FIND_SERVICE_IND", msg.result)
            end
        elseif msg.event == btcore.MSG_BLE_FIND_CHARACTERISTIC_UUID_IND then
            uuid_c = msg.uuid
            log.info("bt", "find characteristic uuid",msg.uuid) --发现到服务内包含的特征uuid
        end
    end)
end

-- 从
local function init2()
    log.info("bt", "init")
    rtos.on(rtos.MSG_BLUETOOTH, function(msg)
        if msg.event == btcore.MSG_OPEN_CNF then
            sys.publish("BT_OPEN", msg.result) --蓝牙打开成功
        elseif msg.event == btcore.MSG_BLE_CONNECT_IND then
            sys.publish("BT_CONNECT_IND", {["handle"] = msg.handle, ["result"] = msg.result}) --蓝牙连接成功
		elseif msg.event == btcore.MSG_BLE_DISCONNECT_IND then
            log.info("蓝牙断开连接SUCCESS") --蓝牙断开连接
        elseif msg.event == btcore.MSG_BLE_DATA_IND then
            sys.publish("BT_DATA_IND", {["result"] = msg.result})--接收到的数据内容
        end
    end)
end

local function poweron()
    log.info("bt", "poweron")
    if LuaTaskTestConfig.bluetoothTest.masterTest then
        btcore.open(1) --打开蓝牙主模式
    else
        btcore.open(0) --打开蓝牙从模式
    end
    _, result = sys.waitUntil("BT_OPEN", timeout) --等待蓝牙打开成功
end

-- 关闭连接
local function unInit()
    local result = btcore.close()
    if result == 0 then
        log.info("关闭蓝牙SUCCESS")
    else
        log.error("关闭蓝牙FAIL")
    end
end

-- 主 扫描
local function scan()
    log.info("bt", "scan")
    btcore.scan(1) --开启扫描
    _, result = sys.waitUntil("BT_SCAN_CNF", timeout) --等待扫描打开成功
    if result ~= 0 then
        return false
    end
    sys.timerStart(
        function()
            sys.publish("BT_SCAN_IND", nil)
        end,
        timeout)  
    while true do
        _, bt_device = sys.waitUntil("BT_SCAN_IND") --等待扫描回复数据
        if not bt_device then
            -- 超时结束
            btcore.scan(0) --停止扫描
            return false
        else
            log.info("bt", "scan result")
            log.info("bt.scan_name", bt_device.name)  --蓝牙名称
			log.info("bt.rssi", bt_device.rssi)  --蓝牙信号强度
            log.info("bt.addr_type", bt_device.addr_type) --地址种类
            log.info("bt.scan_addr", bt_device.addr) --蓝牙地址
            if bt_device.manu_data ~= nil then
                log.info("bt.manu_data", string.toHex(bt_device.manu_data)) --厂商数据
            end
            log.info("bt.raw_len", bt_device.raw_len)
            if bt_device.raw_data ~= nil then
                log.info("bt.raw_data", string.toHex(bt_device.raw_data)) --广播包原始数据
            end

            --蓝牙连接   根据设备蓝牙广播数据协议解析广播原始数据(bt_device.raw_data)
            if (bt_device.name == "Luat_Air724UG**") then   --连接的蓝牙名称根据要连接的蓝牙设备修改
                name = bt_device.name
                addr_type = bt_device.addr_type
                addr = bt_device.addr
                manu_data = bt_device.manu_data
                adv_data = bt_device.raw_data -- 广播包数据 根据蓝牙广播包协议解析
            end
            if addr == bt_device.addr and bt_device.raw_data ~= adv_data then --接收到两包广播数据
                scanrsp_data = bt_device.raw_data --响应包数据 根据蓝牙广播包协议解析
                btcore.scan(0)  --停止扫描
                btcore.connect(bt_device.addr)
                log.info("bt.connect_name", name)
                log.info("bt.connect_addr_type", addr_type)
                log.info("bt.connect_addr", addr)
                if manu_data ~= nil then
                    log.info("bt.connect_manu_data", manu_data)
                end
                if adv_data ~= nil then
                    log.info("bt.connect_adv_data", adv_data)
                end
                if scanrsp_data ~= nil then
                    log.info("bt.connect_scanrsp_data", scanrsp_data)
                end
                return true
            end

        end
    end
    return true
end

-- 主 发送数据
local function data_trans1()
    _, bt_connect = sys.waitUntil("BT_CONNECT_IND") --等待连接成功
    if bt_connect.result ~= 0 then
        return false
    end
    --链接成功
    log.info("bt.connect_handle1", bt_connect.handle)--蓝牙连接句柄
    log.info("bt", "find all service uuid")
    btcore.findservice()--发现所有16bit服务uuid
    _, result = sys.waitUntil("BT_FIND_SERVICE_IND") --等待发现uuid
    if not result then
        return false
    end

    btcore.findcharacteristic(0xfee0)--服务uuid
    _, result = sys.waitUntil("BT_FIND_CHARACTERISTIC_IND") --等待发现服务包含的特征成功
    if not result then
        return false
    end
    btcore.opennotification(0xfee2); --打开通知 对应特征uuid  
    
    log.info("bt.send", "Hello I'm Luat BLE")
    while true do
        local data = "123456"
        btcore.send(data,0xfee1, bt_connect.handle) --发送数据(数据 对应特征uuid 连接句柄)
		_, bt_recv = sys.waitUntil("BT_DATA_IND") --等待接收到数据
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
        log.info("bt.recv_data", data)
        log.info("bt.recv_data len", len)
        log.info("bt.recv_uuid", uuid)
        end
    end
end

--自定义服务
local function service(uuid,struct)
    btcore.addservice(uuid) --添加服务
    for i = 1, #struct do
		btcore.addcharacteristic(struct[i][1],struct[i][2]) --添加特征
		if(type(struct[i][3]) == "table") then
			for j = 1,#struct[i][3] do
				btcore.adddescriptor(struct[i][3][j])  --添加描述
			end
		end
	end
end

-- 从
local function advertising()
    local struct = {{0xfee1, 0x08},{0xfee2, 0x10, {0x2902}}}--{特征uuid,特征属性,描述}
    btcore.setname("Luat_Air724UG**")-- 设置广播名称
    btcore.setadvdata(string.fromHex("02010604ff010203"))-- 设置广播数据 根据蓝牙广播包协议
    btcore.setscanrspdata(string.fromHex("04ff010203"))-- 设置响应数据 根据蓝牙广播包协议
    service(0xfee0, struct)--添加服务16bit uuid   自定义服务
    local advertising = btcore.advertising(1)-- 打开广播
    if advertising == 0 then
        log.info("打开广播SUCCESS")
    else
        log.error("打开广播FAIL")
    end
end

-- 从 接收数据
local function data_trans2()
    advertising()
    _, bt_connect = sys.waitUntil("BT_CONNECT_IND") --等待连接成功
    local addr = btcore.getaddr()
    log.info("bt.connect_addr", addr)
    if bt_connect.result ~= 0 then
        log.error("蓝牙连接FAIL")  
        return false 
    else
        log.info("蓝牙连接SUCCESS")   
    end
    --链接成功
    log.info("bt.connect_handle2",bt_connect.handle) --连接句柄
    sys.wait(1000)
    log.info("bt.send", "Hello I'm Luat BLE")
    while true do
        _, bt_recv = sys.waitUntil("BT_DATA_IND") --等待接收到数据
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
            log.info("bt.recv_data", data)
            log.info("bt.recv_data len", len)
            log.info("bt.recv_uuid", string.toHex(uuid))
            if data == "close" then
                btcore.disconnect()--主动断开连接
                if LuaTaskTestConfig.bluetoothTest.btWifiTdmTest then
                    return
                end
            end
            btcore.send(data, 0xfee2, bt_connect.handle)--发送数据(数据 对应特征uuid 连接句柄)
        end
    end
end

ble_test1 = {init1, poweron, scan, data_trans1}
ble_test2 = {init2, poweron, data_trans2}

if LuaTaskTestConfig.bluetoothTest.masterTest then
    sys.taskInit(function()
        sys.wait(timeout)
        for _, f in ipairs(ble_test1) do
            f()
        end
    end)
end

if LuaTaskTestConfig.bluetoothTest.slaveTest then
    sys.taskInit(function()
        sys.wait(timeout)
        for _, f in ipairs(ble_test2) do
            f()
        end
    end)
end

if LuaTaskTestConfig.bluetoothTest.btWifiTdmTest then
    sys.taskInit(function()
        while true do
            sys.wait(timeout)
            log.info("wifiScan.request begin")
            wifiScan.request(function(result,cnt,tInfo)
                log.info("testWifi.scanCb",result,cnt)
                log.info("testLbsLoc.wifiScan.request result",result,cnt)
                sys.publish("WIFI_SCAN_IND",result,cnt,tInfo)
            end)        
            sys.waitUntil("WIFI_SCAN_IND")
            log.info("wifiScan.request end")
            
            init2()
            poweron()
            data_trans2()
            --关闭蓝牙
            unInit()
        end
    end)
end