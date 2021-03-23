-- RS485Test
-- Author:LuatTest
-- CreateDate:20210315
-- UpdateDate:20210315

module(..., package.seeall)

local function read()

    sys.taskInit(function ( ... )
        while true do
            local data = uart.read(1, "*l")
           
            if not data or string.len(data) == 0 then break end
    
            log.info("RS485Test.readData", data)
    
            log.info("RS485Test.readDataHex", data:toHex())
            sys.wait(100)
            uart.write(1, data)
        end
    end)
end

-- UART相关的测试必须要防止模块休眠，不然会有串口收发数据的问题
pm.wake("LuaTaskTest.RS485Test")

uart.setup(1, 115200, 8, uart.PAR_NONE, uart.STOP_1, nil, 1);
uart.set_rs485_oe(1, 7, 1, 5)
uart.on(1, "receive", read)