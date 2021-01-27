-- UartTransferTest
-- Author:LuatTest
-- CreateDate:20200920
-- UpdateDate:20200925

module(..., package.seeall)

local new_fifo = require "fifo"
-- local f1 = new_fifo()
local f2 = new_fifo()

-- 串口配置
local uartId = 1
local baud = 115200
local databits = 8

-- 透传服务器配置
local tcpClient
local ip = "wiki.airm2m.com"
local port = 23333
local lenofrdata = 0
local lenofsdata = 0

local function read()
    local uartData = ""
    while true do        
        uartData = uart.read(uartId, "*l")
	
        if not uartData or string.len(uartData) == 0 then 
			break 
        end
        
        tcpClient:asyncSend(uartData)
        lenofsdata =  lenofsdata + string.len(uartData)
        log.info("UartTransferTest.lenofsdata", lenofsdata)
	end
end

uart.setup(uartId, baud, databits, uart.PAR_NONE, uart.STOP_1)
uart.on(uartId, "receive", read)

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("UartTransferTest","成功访问网络, UartTransferTest测试开始")
        tcpClient = socket.tcp()
        connectResult, socketId = tcpClient:connect(ip, port)
        log.info("UartTransferTest.tcpClient.connectResult, socketId", connectResult, socketId)
        if connectResult then
            sys.publish("AsyncTcpSocketInitComplete")
            log.info("UartTransferTest.tcpClient.connect", "SUCCESS")
        else
            log.error("UartTransferTest.tcpClient.connect", "FAIL")
        end
        while tcpClient:asyncSelect() do end
        tcpClient:close()
        log.error("UartTransferTest.tcpClient", "连接断开")
    end
)

sys.taskInit(
    function()
        sys.waitUntil("AsyncTcpSocketInitComplete")
        while true do
            local asyncReceiveData = tcpClient:asyncRecv()
            if string.len(asyncReceiveData) > 0 then
                lenofrdata = lenofrdata + asyncReceiveData:len()
                log.info("UartTransferTest.lenofrdata", lenofrdata)
                f2:push(asyncReceiveData)
                -- log.info("UartTransferTest.tcpClient.recv", asyncReceiveData)
                -- uart.write(uartId, asyncReceiveData)
            end
            sys.wait(1)
        end
    end
)

sys.taskInit(
    function()
        while true do
            if f2:length() > 0 then
                log.info("f2len", f2:length())
                uart.write(uartId, f2:pop())
            end
            sys.wait(20)
        end
    end
)
