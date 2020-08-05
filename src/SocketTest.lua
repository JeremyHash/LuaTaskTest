module(...,package.seeall)

local waitTime = 8000

local ip1, ip2, ip3 = "36.7.87.100", "115.29.164.59", "erp.openluat.com"

local testSendData = string.rep("JeremySocketTest", 10)

local connectResult,socketId,result,data
local r, s, p
local tcpClient1,tcpClient2,tcpClient3,tcpClient4,udpClient1,udpClient2

--启动socket客户端任务
sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("SocketTest","成功访问网络,同步Socket测试开始")

        while true do
            --tcp ssl client
            tcpClient1 = socket.tcp(true,{caCert="ca.crt",clientCert="client.crt",clientKey="client.key"})
            tcpClient2 = socket.tcp(true,{caCert="ca.crt"})

            -- tcp client
            tcpClient3 = socket.tcp()

            -- udp client
            udpClient1 = socket.udp()

            -- 双向认证Client1
            connectResult,socketId = tcpClient1:connect(ip1,"4434")
            log.info("SocketTest.tcpClient1.connectResult,socketId",connectResult,socketId)
            if connectResult then
                if tcpClient1:send("GET / HTTP/1.1\r\nHost: 36.7.87.100\r\nConnection: keep-alive\r\n\r\n") then
                    result,data = tcpClient1:recv(5000)
                    if result then
                        log.info("SocketTest.tcpClient1.recv",data)
                    end
                end
            else
                log.info("SocketTest.tcpClient1.connect","连接失败！！！")
            end
            tcpClient1:close()

            sys.wait(waitTime)

            -- 单向认证Client2
            connectResult,socketId = tcpClient2:connect(ip1,"4433")
            log.info("SocketTest.tcpClient2.connectResult,socketId",connectResult,socketId)
            if connectResult then
                if tcpClient2:send("GET / HTTP/1.1\r\nHost: 36.7.87.100\r\nConnection: keep-alive\r\n\r\n") then
                    result,data = tcpClient2:recv(5000)
                    if result then
                        log.info("SocketTest.tcpClient2.recv",data)
                    end
                    result,data = tcpClient2:recv(5000)
                    if result then
                        log.info("SocketTest.tcpClient2.recv",data)
                    end
                end
            else
                log.info("SocketTest.tcpClient2.connect","连接失败！！！")
            end

            tcpClient2:close()

            sys.wait(waitTime)

            connectResult,socketId = tcpClient3:connect(ip2,"40432")
            log.info("SocketTest.tcpClient3.connectResult,socketId",connectResult,socketId)
            if connectResult then
                if tcpClient3:send(testSendData) then
                    r,s,p = tcpClient3:recv(5000)
                    log.info("SocketTest.tcpClient3.result",r)
                    log.info("SocketTest.tcpClient3.recv",s)
                    log.info("SocketTest.tcpClient3.para",p)
                end
            else
                log.info("SocketTest.tcpClient3.connect","连接失败！！！")
            end

            tcpClient3:close()

            sys.wait(waitTime)

            connectResult,socketId = udpClient1:connect(ip3,"12414")
            log.info("SocketTest.udpClient1.connectResult,socketId",connectResult,socketId)
            if connectResult then
                if udpClient1:send(testSendData) then
                    r,s,p = udpClient1:recv(5000)
                    log.info("SocketTest.udpClient1.result",r)
                    log.info("SocketTest.udpClient1.recv",s)
                    log.info("SocketTest.udpClient1.para",p)
                end
            else
                log.info("SocketTest.udpClient1.connect","连接失败！！！")
            end

            udpClient1:close()

            sys.wait(waitTime)
            
        end

    end
)

-- 异步客户端创建
sys.taskInit(function()
    sys.waitUntil("IP_READY_IND")
    log.info("SocketTest","成功访问网络,异步Socket测试开始")
    tcpClient4 = socket.tcp()
    udpClient2 = socket.udp()
    connectResult,socketId = tcpClient4:connect(ip2,"40432")
    connectResult,socketId = udpClient2:connect(ip3,"12414")
    log.info("SocketTest.tcpClient4.connectResult,socketId",connectResult,socketId)
    if connectResult then
        sys.publish("AsyncSocketInitComplete")
    else
        log.info("SocketTest.tcpClient4.connect","连接失败！！！")
    end
    while tcpClient4:asyncSelect() do end
    tcpClient4:close()
end)

-- 异步发送协程
sys.taskInit(function()
    sys.waitUntil("AsyncSocketInitComplete")
    while true do
        tcpClient4:asyncSend(testSendData)
        sys.wait(waitTime)
    end
end)

-- 异步接收协程
sys.taskInit(function()
    sys.waitUntil("AsyncSocketInitComplete")
    sys.wait(1000)
    while true do
        local asyncReceiveData = tcpClient4:asyncRecv()
        log.info("SocketTest.tcpClient4.recv",asyncReceiveData)
        sys.wait(waitTime)
    end
end)
