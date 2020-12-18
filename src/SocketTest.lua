-- SocketTest
-- Author:LuatTest
-- CreateDate:20200723
-- UpdateDate:20201023

module(..., package.seeall)

local waitTime = 10000

-- ip1用来测试单双向认证
-- ip2用来测试tcp
-- ip3用来测试udp
local ip1, ip2, ip3 = "36.7.87.100", "wiki.airm2m.com", "erp.openluat.com"
local port1, port2, port3, port4 = 4433, 4434, 48888, 12414

-- TODO 现在是5KB -> 100KB
local testSendData = string.rep("SocketTest", 50)
-- TODO 十六进制数据

local connectResult, socketId, result, data
local r, s, p
-- TODO 写清每个client是什么链接
local tcpClient1, tcpClient2, tcpClient3, tcpClient4, udpClient1, udpClient2

-- 启动socket客户端任务
sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("SocketTest", "成功访问网络, 同步Socket测试开始")
        local count = 1

        -- tcp client
        tcpClient3 = socket.tcp()

        -- udp client
        udpClient1 = socket.udp()

        while true do

            log.info("SocketTest", "同步Socket测试第" .. count .. "次开始")

            -- TODO c = socket.tcp(true, {caCert="ca.crt", clientCert="client.crt", clientKey="client.key", clientPassword="123456"})

            -- 单向认证Client1
            for i=1, 10 do
                tcpClient1 = socket.tcp(true, {caCert = "ca.crt"})
                connectResult, socketId = tcpClient1:connect(ip1, port1)
                log.info("SocketTest.tcpClient1.connectResult, socketId", connectResult, socketId)
                if connectResult then
                    if tcpClient1:send("GET / HTTP/1.1\r\nHost: 36.7.87.100\r\nConnection: keep-alive\r\n\r\n") then
                        log.info("SocketTest.tcpClient1.sendResult", "SUCCESS")
                        -- TODO mt:recv(timeout, msg, msgNoResume)
                        result, data = tcpClient1:recv(5000)
                        if result then
                            log.info("SocketTest.tcpClient1.recv", data)
                        end
                        result, data = tcpClient1:recv(5000)
                        if result then
                            log.info("SocketTest.tcpClient1.recv", data)
                        end
                    else
                        log.error("SocketTest.tcpClient1.sendResult", "FAIL")
                    end
                else
                    log.error("SocketTest.tcpClient1.connect","FAIL")
                end
                log.info("SocketTest.tcpClient1.connection", "disconnecting")
                tcpClient1:close()
                log.info("SocketTest.tcpClient1.connection", "disconnected")
                sys.wait(waitTime)
            end
            
            -- 双向认证Client2
            for i=1, 10 do
                tcpClient2 = socket.tcp(true, {caCert = "ca.crt", clientCert = "client.crt", clientKey = "client.key"})
                connectResult, socketId = tcpClient2:connect(ip1, port2)
                log.info("SocketTest.tcpClient2.connectResult, socketId", connectResult, socketId)
                if connectResult then
                    if tcpClient2:send("GET / HTTP/1.1\r\nHost: 36.7.87.100\r\nConnection: keep-alive\r\n\r\n") then
                        log.info("SocketTest.tcpClient2.sendResult", "SUCCESS")
                        result, data = tcpClient2:recv(5000)
                        if result then
                            log.info("SocketTest.tcpClient2.recv", data)
                        end
                        result, data = tcpClient2:recv(5000)
                        if result then
                            log.info("SocketTest.tcpClient2.recv", data)
                        end
                    else
                        log.error("SocketTest.tcpClient2.sendResult", "FAIL")
                    end
                else
                    log.error("SocketTest.tcpClient2.connect","FAIL")
                end
                log.info("SocketTest.tcpClient2.connection", "disconnecting")
                tcpClient2:close()
                log.info("SocketTest.tcpClient2.connection", "disconnected")
                sys.wait(waitTime)
            end

            connectResult, socketId = tcpClient3:connect(ip2, port3)
            log.info("SocketTest.tcpClient3.connectResult,socketId", connectResult, socketId)
            if connectResult then
                for i=1, 10 do
                    if tcpClient3:send(testSendData) then
                        log.info("SocketTest.tcpClient3.sendResult", "SUCCESS")
                        r, s, p = tcpClient3:recv(5000)
                        log.info("SocketTest.tcpClient3.result", r)
                        log.info("SocketTest.tcpClient3.recv", s)
                        log.info("SocketTest.tcpClient3.para", p)
                    else
                        log.error("SocketTest.tcpClient3.sendResult", "FAIL")
                    end
                    sys.wait(waitTime)
                end
            else
                log.error("SocketTest.tcpClient3.connect", "FAIL")
            end

            tcpClient3:close()

            sys.wait(waitTime)

            connectResult,socketId = udpClient1:connect(ip3, port4)
            log.info("SocketTest.udpClient1.connectResult, socketId", connectResult, socketId)
            if connectResult then
                for i=1, 10 do
                    if udpClient1:send(testSendData) then
                        log.info("SocketTest.udpClient1.sendResult", "SUCCESS")
                        r, s, p = udpClient1:recv(5000)
                        log.info("SocketTest.udpClient1.result", r)
                        log.info("SocketTest.udpClient1.recv", s)
                        log.info("SocketTest.udpClient1.para", p)
                    else
                        log.error("SocketTest.udpClient1.sendResult", "FAIL")
                    end
                    sys.wait(waitTime)
                end
            else
                log.error("SocketTest.udpClient1.connect", "FAIL")
            end

            udpClient1:close()

            sys.wait(waitTime)

            log.info("SocketTest", "同步Socket测试第" .. count .. "次结束")

            count = count + 1
            
        end

    end
)

-- 异步TCP客户端创建
sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("SocketTest","成功访问网络, 异步TcpSocket测试开始")
        tcpClient4 = socket.tcp()
        connectResult,socketId = tcpClient4:connect(ip2, port3)
        log.info("SocketTest.tcpClient4.connectResult, socketId", connectResult, socketId)
        if connectResult then
            sys.publish("AsyncTcpSocketInitComplete")
        else
            log.error("SocketTest.tcpClient4.connect", "FAIL")
        end
        -- TODO 这个api缺少demo说明
        while tcpClient4:asyncSelect() do
        end
        tcpClient4:close()
    end
)

-- 异步UDP客户端创建
sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("SocketTest","成功访问网络,异步UdpSocket测试开始")
        udpClient2 = socket.udp()
        connectResult,socketId = udpClient2:connect(ip3, port4)
        log.info("SocketTest.udpClient2.connectResult, socketId", connectResult, socketId)
        if connectResult then
            sys.publish("AsyncUdpSocketInitComplete")
        else
            log.error("SocketTest.udpClient2.connect", "FAIL")
        end
        while udpClient2:asyncSelect() do
        end
        udpClient2:close()
    end
)

-- 异步TCP发送协程
sys.taskInit(
    function()
        sys.waitUntil("AsyncTcpSocketInitComplete")
        while true do
            tcpClient4:asyncSend(testSendData)
            log.info("SocketTest.tcpClient4.send", "SUCCESS")
            sys.wait(waitTime)
        end
    end
)

-- 异步TCP接收协程
sys.taskInit(
    function()
        sys.waitUntil("AsyncTcpSocketInitComplete")
        sys.wait(1000)
        while true do
            local asyncReceiveData = tcpClient4:asyncRecv()
            log.info("SocketTest.tcpClient4.recv", asyncReceiveData)
            sys.wait(waitTime)
        end
    end
)

-- 异步UDP发送协程
sys.taskInit(
    function()
        sys.waitUntil("AsyncUdpSocketInitComplete")
        while true do
            udpClient2:asyncSend(testSendData)
            log.info("SocketTest.udpClient2.send", "SUCCESS")
            sys.wait(waitTime)
        end
    end
)

-- 异步UDP接收协程
sys.taskInit(
    function()
        sys.waitUntil("AsyncUdpSocketInitComplete")
        sys.wait(1000)
        while true do
            local asyncReceiveData = udpClient2:asyncRecv()
            log.info("SocketTest.udpClient2.recv", asyncReceiveData)
            sys.wait(waitTime)
        end
    end
)

sys.timerLoopStart(function() log.info("SocketTest.PrintStatus", socket.printStatus()) end, 30000)

-- TODO mt:setRcvProc(rcvCbFnc)
-- TODO socket.setTcpResendPara(retryCnt, retryMaxTimeout)
-- TODO socket.setDnsParsePara(retryCnt, retryTimeoutMulti)
-- 设置域名解析参数
-- 注意：0027以及之后的core版本才支持此功能

-- TODO 开一个协程对一个错误ip进行循环连接
-- TODO 对lua版本最多创建几路SSL连接确认
-- TODO 一直创建tcpclient 放入table