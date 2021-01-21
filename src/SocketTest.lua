-- SocketTest
-- Author:LuatTest
-- CreateDate:20200723
-- UpdateDate:20201230

module(..., package.seeall)

local waitTime = 10000

-- ip1 -> TCPSSL单双向认证,TCP回环以及大文件下载,UDP回环以及大文件下载
-- ip2 -> 错误ip模块表现
local ip1, ip2 = "airtest.openluat.com", "hhhhhh.zzz"

-- port1 -> TCPSSL单向认证
-- port2 -> TCPSSL双向认证
-- port3 -> TCP回环以及大文件下载
-- port4 -> UDP回环以及大文件下载
local port1, port2, port3, port4 = 2903, 2903, 2901, 2902

-- 10KB 数据
local testSendData1 = string.rep("SocketTest", 1000)

-- 10KB 数据
local testSendData2 = string.rep("\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09", 1000)

local connectResult, socketId, result, data, para

-- tcpClient1 -> 同步 TCP SSL单向认证回环客户端
-- tcpClient2 -> 同步 TCP SSL双向认证客户端
-- tcpClient3 -> 同步 无SSL TCP客户端
-- tcpClient4 -> 异步 无SSL TCP客户端
-- tcpClient5 -> 错误IP TCP客户端
-- udpClient1 -> 同步 UDP客户端
-- udpClient2 -> 异步 UDP客户端
local tcpClient1, tcpClient2, tcpClient3, tcpClient4, tcpClient5, udpClient1, udpClient2

-- 启动socket客户端任务
sys.taskInit(
    function ()

        if LuaTaskTestConfig.socketTest.syncTcpTest or LuaTaskTestConfig.socketTest.syncUdpTest then

            sys.waitUntil("IP_READY_IND")
            log.info("SocketTest", "成功访问网络, 同步Socket测试开始")
            local count = 1

            -- tcp client
            tcpClient3 = socket.tcp()

            -- udp client
            udpClient1 = socket.udp()

            while true do

                log.info("SocketTest", "同步Socket测试第" .. count .. "次开始")

                -- TODO 带密码的TCPSSL测试
                -- c = socket.tcp(true, {caCert="ca.crt", clientCert="client.crt", clientKey="client.key", clientPassword="123456"})

                if LuaTaskTestConfig.socketTest.syncTcpTest then
                -- 单向认证Client1
                -- for i=1, 10 do
                --     tcpClient1 = socket.tcp(true, {caCert = "hashjeremy.crt"})
                --     connectResult, socketId = tcpClient1:connect(ip1, port1)
                --     log.info("SocketTest.tcpClient1.connectResult, socketId", connectResult, socketId)
                --     if connectResult then
                --         if tcpClient1:send(testSendData1) then
                --             log.info("SocketTest.tcpClient1.sendResult", "SUCCESS")
                --             -- TODO mt:recv(timeout, msg, msgNoResume)
                --             while true do
                --                 result, data = tcpClient1:recv(5000)
                --                 if result then
                --                     log.info("SocketTest.tcpClient1.recv", #data, data:sub(1, 30))
                --                 else
                --                     log.info("SocketTest.tcpClient1.recv", "接收完毕")
                --                     break
                --                 end
                --             end
                --         else
                --             log.error("SocketTest.tcpClient1.sendResult", "FAIL")
                --         end
                --     else
                --         log.error("SocketTest.tcpClient1.connect", "FAIL")
                --     end
                --     log.info("SocketTest.tcpClient1.connection", "disconnecting")
                --     tcpClient1:close()
                --     log.info("SocketTest.tcpClient1.connection", "disconnected")
                --     sys.wait(waitTime)
                -- end

                -- 双向认证Client2
                for i=1, 10 do
                    tcpClient2 = socket.tcp(true, {caCert = "ca.crt", clientCert = "client.crt", clientKey = "client.key"})
                    connectResult, socketId = tcpClient2:connect(ip1, port2)
                    log.info("SocketTest.tcpClient2.connectResult, socketId", connectResult, socketId)
                    if connectResult then
                        if tcpClient2:send(testSendData2) then
                            log.info("SocketTest.tcpClient2.sendResult", "SUCCESS")
                            local recvLen = 0
                            while true do
                                result, data, para = tcpClient2:recv(5000)
                                if result then
                                    recvLen = recvLen + #data
                                    log.info("SocketTest.tcpClient2.result", result)
                                    -- log.info("SocketTest.tcpClient3.recv", #data, data:sub(1, 30))
                                    -- log.info("SocketTest.tcpClient2.para", para)
                                else
                                    log.error("SocketTest.tcpClient2.recv", "接收完毕")
                                    break
                                end
                            end
                            log.info("SocketTest.tcpClient2.RecvLen", recvLen)
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

                connectResult, socketId = tcpClient3:connect(ip1, port3)
                log.info("SocketTest.tcpClient3.connectResult,socketId", connectResult, socketId)
                if connectResult then
                    for i=1, 10 do
                        if tcpClient3:send("recv_big_file") then
                            log.info("SocketTest.tcpClient3.sendResult", "SUCCESS")
                            local recvLen = 0
                            while true do
                                result, data, para = tcpClient3:recv(5000)
                                if result then
                                    recvLen = recvLen + #data
                                    log.info("SocketTest.tcpClient3.result", result)
                                    -- log.info("SocketTest.tcpClient3.recv", #data, data:sub(1, 30))
                                    -- log.info("SocketTest.tcpClient3.para", para)
                                else
                                    log.error("SocketTest.tcpClient3.recv", "接收完毕")
                                    break
                                end
                            end
                            log.info("SocketTest.tcpClient3.RecvLen", recvLen)
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
                end

                if LuaTaskTestConfig.socketTest.syncUdpTest then
                connectResult,socketId = udpClient1:connect(ip1, port4)
                log.info("SocketTest.udpClient1.connectResult, socketId", connectResult, socketId)
                if connectResult then
                    for i=1, 10 do
                        if udpClient1:send("big_data_md5_test") then
                            log.info("SocketTest.udpClient1.sendResult", "SUCCESS")
                            local recvLen = 0
                            local getMD5 = ""
                            local fmd5Obj = crypto.flow_md5()
                            local flag = true
                            while true do
                                result, data, para = udpClient1:recv(5000)
                                if result then
                                    if recvLen == 0 and flag then
                                        getMD5 = string.sub(data, 1, 32)
                                        log.info("SocketTest.udpClient1.getMD5", string.upper(getMD5))
                                        recvLen = recvLen + #data - 32
                                        fmd5Obj:update(string.sub(data, 33))
                                        flag = false
                                    else
                                        recvLen = recvLen + #data
                                        -- log.info("SocketTest.udpClient1.result", result)
                                        -- log.info("SocketTest.udpClient1.recv", #data, data:sub(1, 30))
                                        -- log.info("SocketTest.udpClient1.para", para)
                                        fmd5Obj:update(data)  
                                    end
                                else
                                    log.error("SocketTest.udpClient1.recv", "接收完毕")
                                    break
                                end
                            end
                            log.info("SocketTest.udpClient1.RecvLen", recvLen)
                            local calcMD5 = fmd5Obj:hexdigest()
                            log.info("SocketTest.udpClient1.CalcMD5", calcMD5)
                            if calcMD5 == string.upper(getMD5) then
                                log.info("SocketTest.udpClient1.MD5Check", "SUCCESS")
                            else
                                log.error("SocketTest.udpClient1.MD5Check", "FAIL")
                            end
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
                end

                log.info("SocketTest", "同步Socket测试第" .. count .. "次结束")

                count = count + 1

            end
            
        end

    end
)

if LuaTaskTestConfig.socketTest.asyncTcpTest then
    -- 异步TCP客户端创建
    sys.taskInit(
        function()
            sys.waitUntil("IP_READY_IND")
            log.info("SocketTest","成功访问网络, 异步TcpSocket测试开始")
            tcpClient4 = socket.tcp()
            connectResult,socketId = tcpClient4:connect(ip1, port3)
            log.info("SocketTest.tcpClient4.connectResult, socketId", connectResult, socketId)
            if connectResult then
                sys.publish("AsyncTcpSocketInitComplete")
                tcpClient4:setRcvProc(
                    function(readFnc, socketIndex, rcvDataLen)
                        log.info("SocketTest.tcpClient4.readFnc", readFnc(socketIndex, rcvDataLen))
                    end
                )
            else
                log.error("SocketTest.tcpClient4.connect", "FAIL")
            end
            -- TODO 这个api缺少demo说明 可以写一篇文章分析一下
            while tcpClient4:asyncSelect() do
            end
            tcpClient4:close()
        end
    )

    -- 异步TCP发送协程
    sys.taskInit(
        function()
            sys.waitUntil("AsyncTcpSocketInitComplete")
            while true do
                tcpClient4:asyncSend(testSendData1)
                log.info("SocketTest.tcpClient4.send", "SUCCESS")
                sys.wait(waitTime)
            end
        end
    )

    -- 异步TCP接收协程
    -- sys.taskInit(
    --     function()
    --         sys.waitUntil("AsyncTcpSocketInitComplete")
    --         sys.wait(1000)
    --         while true do
    --             local asyncReceiveData = tcpClient4:asyncRecv()
    --             log.info("SocketTest.tcpClient4.recv", asyncReceiveData)
    --             sys.wait(waitTime)
    --         end
    --     end
    -- )

    sys.subscribe(
        "SOCKET_RECV",
        function(id)
            if tcpClient4.id == id then
                local data = tcpClient4:asyncRecv()
                log.info("SocketTest.tcpClient4.recv", #data, data:sub(1, 30))
            end
        end
    )

end

if LuaTaskTestConfig.socketTest.asyncUdpTest then
    -- 异步UDP客户端创建
    sys.taskInit(
        function()
            sys.waitUntil("IP_READY_IND")
            log.info("SocketTest","成功访问网络,异步UdpSocket测试开始")
            udpClient2 = socket.udp()
            connectResult,socketId = udpClient2:connect(ip1, port4)
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

    -- 异步UDP发送协程
    sys.taskInit(
        function()
            sys.waitUntil("AsyncUdpSocketInitComplete")
            while true do
                udpClient2:asyncSend(testSendData1)
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
                local data = udpClient2:asyncRecv()
                log.info("SocketTest.udpClient2.recv", #data, data:sub(1, 30))
                sys.wait(waitTime)
            end
        end
    )
end

sys.timerLoopStart(
    function ()
        log.info("SocketTest.PrintStatus", socket.printStatus())
    end,
    60000
)

if LuaTaskTestConfig.socketTest.errorIPTest then
    sys.taskInit(
        function ()
            tcpClient5 = socket.tcp()
            sys.waitUntil("IP_READY_IND")
            while not tcpClient5:connect(ip2, port1) do
                log.info("SocketTest.错误IP连接测试", "SUCCESS")
                sys.wait(60000)
            end 
        end
    )
end



-- TODO mt:setRcvProc(rcvCbFnc) (BUG)
-- TODO socket.setTcpResendPara(retryCnt, retryMaxTimeout)
-- TODO socket.setDnsParsePara(retryCnt, retryTimeoutMulti)
-- 设置域名解析参数
-- 注意：0027以及之后的core版本才支持此功能