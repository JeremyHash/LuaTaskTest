-- ModbusTest
-- Author:LuatTest
-- CreateDate:20210629
-- UpdateDate:20210629

module(...,package.seeall)

local tag = "ModbusTest"

pm.wake("ModbusTest")

local uart_id = 1
local uart_baud = 9600

local function modbus_send(slaveaddr,Instructions,reg,value)
    local data = (string.format("%02x",slaveaddr)..string.format("%02x",Instructions)..string.format("%04x",reg)..string.format("%04x",value)):fromHex()
    local modbus_crc_data= pack.pack('<h', crypto.crc16("MODBUS",data))
    local data_tx = data..modbus_crc_data
    uart.write(uart_id,data_tx)
end

local function modbus_read()
    local cacheData = ""
    while true do
        local s = uart.read(uart_id,1)
        if s == "" then
            if not sys.waitUntil("UART_RECEIVE",35000/uart_baud) then
                if cacheData:len()>0 then
                    local a,_ = string.toHex(cacheData)
                    log.info(tag..".modbus接收数据:",a)
                    cacheData = ""
                end
            end
        else
            cacheData = cacheData..s
        end
    end
end

--注册串口的数据发送通知函数
uart.on(uart_id,"receive",function() sys.publish("UART_RECEIVE") end)
--配置并且打开串口
uart.setup(uart_id,uart_baud,8,uart.PAR_NONE,uart.STOP_1)
--启动串口数据接收任务
sys.taskInit(modbus_read)

sys.taskInit(function ()
    while true do
        sys.wait(5000)
        modbus_send("0x01","0x01","0x0101","0x04")
    end
end)
