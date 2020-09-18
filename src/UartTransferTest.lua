module(..., package.seeall)

-- 串口配置
local uartId = 1
local baud = 115200
local databits = 8
uart.setup(uartId, baud, databits, uart.PAR_NONE, uart.STOP_1)

-- 透传服务器配置
local tcpClient
local ip = "wiki.airm2m.com"
local port = 49001
local lenofrdata = 0
local lenofsdata = 0

-- sys.taskInit(
--     function()
--         uart.setup(uartId, baud, databits, uart.PAR_NONE, uart.STOP_1)

--         uart.on(
--             uartId, 
--             "receive", 
--             function()
--                 uart_data = uart.read(uartId, "*l")
--                 log.info("UartTransferTest.receive.uart_data", uart_data)
--                 tcpClient:asyncSend(uart_data)
--                 log.info("UartTransferTest.tcpClient.send", uart_data)
--             end
--         )

--         sys.waitUntil("IP_READY_IND")
--         log.info("UartTransferTest","成功访问网络, UartTransferTest测试开始")
--         tcpClient = socket.tcp()
--         connectResult, socketId = tcpClient:connect(ip, port)
--         log.info("UartTransferTest.tcpClient.connectResult, socketId", connectResult, socketId)
--         if connectResult then
--             sys.publish("AsyncTcpSocketInitComplete")
--         else
--             log.error("UartTransferTest.tcpClient.connect", "FAIL")
--         end
--         while tcpClient:asyncSelect() do end
--         tcpClient:close()

--     end
-- )

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("UartTransferTest","成功访问网络, UartTransferTest测试开始")
        tcpClient = socket.tcp()
        connectResult, socketId = tcpClient:connect(ip, port)
        log.info("UartTransferTest.tcpClient.connectResult, socketId", connectResult, socketId)
        if connectResult then
            sys.publish("AsyncTcpSocketInitComplete")
        else
            log.error("UartTransferTest.tcpClient.connect", "FAIL")
        end
        while tcpClient:asyncSelect() do end
        tcpClient:close()
    end
)

sys.taskInit(
    function()
        
        while true do
            uart_data = uart.read(uartId, "*l")
            
            if string.len(uart_data) > 0 then
                lenofsdata = lenofsdata + uart_data:len()
                log.info("gw:length of sent data =",lenofsdata)
                log.info("UartTransferTest.receive.uart_data", uart_data)
                tcpClient:asyncSend(uart_data)
                log.info("UartTransferTest.tcpClient.send", uart_data)
            end
            sys.wait(1)
        end
    end
)

sys.taskInit(
    function()
        
        sys.waitUntil("AsyncTcpSocketInitComplete")
        while true do
            local asyncReceiveData = tcpClient:asyncRecv()
            if string.len(asyncReceiveData) > 0 then
                lenofrdata = lenofrdata + uart_data:len()
                log.info("gw:length of recv data =",lenofrdata)
                log.info("UartTransferTest.tcpClient.recv", asyncReceiveData)
                uart.write(uartId, asyncReceiveData)
            end
            sys.wait(10)
        end
    end
)
