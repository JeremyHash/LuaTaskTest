-- SocketTest
-- Author:LuatTest
-- CreateDate:20200723
-- UpdateDate:20201230

module(..., package.seeall)

local waitTime = 20000

-- ip1 -> TCPSSL单双向认证,TCP回环以及大文件下载,UDP回环以及大文件下载
-- ip2 -> 错误ip模块表现
local ip1, ip2 = "114.55.242.59", "hhhhhh.zzz"

-- port1 -> TCPSSL双向认证
-- port2 -> TCP回环以及大文件下载
-- port3 -> UDP回环以及大文件下载
local port1, port2, port3 = 2903, 2901, 2902

-- 10KB 数据
local testSendData1 = string.rep("SocketTest", 100)

-- 10KB 数据
local testSendData2 = string.rep("\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09", 1000)

local connectResult, socketId, result, data, para

-- tcpClient1 -> 同步 TCP SSL双向认证回环测试客户端
-- tcpClient2 -> 同步 无SSL TCP客户端
-- tcpClient3 -> 异步 无SSL TCP客户端
-- tcpClient4 -> 错误IP TCP客户端
-- udpClient1 -> 同步 UDP客户端
-- udpClient2 -> 异步 UDP客户端
local tcpClient1, tcpClient2, tcpClient3, tcpClient4, udpClient1, udpClient2

-- 启动socket客户端任务
sys.taskInit(
    function ()

        if LuaTaskTestConfig.socketTest.syncTcpTest or LuaTaskTestConfig.socketTest.syncUdpTest then

            sys.waitUntil("IP_READY_IND")
            log.info("SocketTest", "成功访问网络, 同步Socket测试开始")
            local count = 1

            while true do

                log.info("SocketTest", "同步Socket测试第" .. count .. "次开始")

                -- TODO 带密码的TCPSSL测试
                -- c = socket.tcp(true, {caCert="ca.crt", clientCert="client.crt", clientKey="client.key", clientPassword="123456"})

                if LuaTaskTestConfig.socketTest.syncTcpTest then
                    
                    -- tcpClient1 -> 同步 TCP SSL双向认证回环测试客户端
                    local tag1 = "SocketTest.tcpClient1"
                    for i=1, 10 do
                        tcpClient1 = socket.tcp(true, {caCert = "ca.crt", clientCert = "client.crt", clientKey = "client.key"})
                        connectResult, socketId = tcpClient1:connect(ip1, port1)
                        log.info(tag1 .. ".connectResult, socketId", connectResult, socketId)
                        if connectResult then
                            if tcpClient1:send(testSendData1) then
                                log.info(tag1 .. ".sendResult", "SUCCESS")
                                local recvLen = 0
                                while true do
                                    result, data, para = tcpClient1:recv(5000)
                                    if result then
                                        recvLen = recvLen + #data
                                    else
                                        log.info(tag1 .. ".recv", "接收完毕")
                                        break
                                    end
                                end
                                log.info(tag1 .. ".recvLen", recvLen)
                                if recvLen == 1000 then
                                    log.info(tag1 .. ".recvLen.check", "接收数据长度正确SUCCESS")
                                else
                                    log.error(tag1 .. ".recvLen.check", "接收数据长度有误FAIL")
                                end
                            else
                                log.error(tag1 .. ".sendResult", "FAIL")
                            end
                        else
                            log.error(tag1 .. ".connect","FAIL")
                        end
                        log.info(tag1 .. ".connection", "disconnecting")
                        tcpClient1:close()
                        log.info(tag1 .. ".connection", "disconnected")
                        sys.wait(waitTime)
                    end

                    -- tcpClient2 -> 同步 无SSL TCP客户端
                    local tag2 = "SocketTest.tcpClient2"
                    for i=1, 10 do
                        local fmd5Obj = crypto.flow_md5()
                        tcpClient2 = socket.tcp()
                        connectResult, socketId = tcpClient2:connect(ip1, port2)
                        log.info(tag2 .. ".connectResult,socketId", connectResult, socketId)
                        if connectResult then
                            if tcpClient2:send("recv_big_file") then
                                log.info(tag2 .. ".sendResult", "SUCCESS")
                                local recvLen = 0
                                while true do
                                    result, data, para = tcpClient2:recv(5000)
                                    if result then
                                        recvLen = recvLen + #data
                                        fmd5Obj:update(data)
                                    else
                                        log.info(tag2 .. ".recv", "接收完毕")
                                        break
                                    end
                                end
                                log.info(tag2 .. ".RecvLen", recvLen)
                                local calcMD5 = fmd5Obj:hexdigest()
                                if calcMD5 == "976CD4BFCA34702FE94BE41434397095" then
                                    log.info(tag2 .. ".recvLen.MD5check", "SUCCESS")
                                else
                                    log.error(tag2 .. ".recvLen.MD5check", "FAIL")
                                end
                            else
                                log.error(tag2 .. ".sendResult", "FAIL")
                            end
                        else
                            log.error(tag2 .. ".connect", "FAIL")
                        end
                        log.info(tag2 .. ".connection", "disconnecting")
                        tcpClient2:close()
                        log.info(tag2 .. ".connection", "disconnected")
                        sys.wait(waitTime)
                    end
                    
                    sys.wait(waitTime)
                end

                if LuaTaskTestConfig.socketTest.syncUdpTest then
                    udpClient1 = socket.udp()
                    connectResult, socketId = udpClient1:connect(ip1, port3)
                    log.info("SocketTest.udpClient1.connectResult, socketId", connectResult, socketId)
                    if connectResult then
                        for i=1, 10 do
                            local fmd5Obj = crypto.flow_md5()
                            if udpClient1:send("big_data_md5_test") then
                                log.info("SocketTest.udpClient1.sendResult", "SUCCESS")
                                local recvLen = 0
                                local getMD5 = ""
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
                                            fmd5Obj:update(data)  
                                        end
                                    else
                                        log.info("SocketTest.udpClient1.recv", "接收完毕")
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

if LuaTaskTestConfig.socketTest.asyncTest then

    -- 异步TCP客户端创建
    local tag3 = "SocketTest.tcpClient3"
    sys.taskInit(
        function()
            sys.waitUntil("IP_READY_IND")
            log.info("SocketTest", "成功访问网络, 异步TcpSocket测试开始")
            tcpClient3 = socket.tcp()
            connectResult, socketId = tcpClient3:connect(ip1, port2)
            log.info(tag3 .. ".connectResult, socketId", connectResult, socketId)
            if connectResult then
                sys.publish("AsyncTcpSocketInitComplete")
            else
                log.error(tag3 .. ".connect", "FAIL")
            end
            while tcpClient3:asyncSelect() do
            end
            tcpClient3:close()
        end
    )

    -- 异步TCP发送协程
    sys.taskInit(
        function()
            sys.waitUntil("AsyncTcpSocketInitComplete")
            while true do
                tcpClient3:asyncSend(testSendData1)
                log.info(tag3 .. ".send", "SUCCESS")
                sys.wait(waitTime)
            end
        end
    )

    -- 异步UDP客户端创建
    local tag4 = "SocketTest.udpClient2"
    sys.taskInit(
        function()
            sys.waitUntil("IP_READY_IND")
            log.info("SocketTest", "成功访问网络,异步UdpSocket测试开始")
            while true do
                udpClient2 = socket.udp()
                connectResult, socketId = udpClient2:connect(ip1, port3)
                log.info(tag4 .. ".connectResult, socketId", connectResult, socketId)
                if connectResult then
                    sys.publish("AsyncUdpSocketInitComplete")
                    while udpClient2:asyncSelect() do
                    end
                else
                    log.error(tag4 .. ".connect", "FAIL")
                    udpClient2:close()
                end
                sys.wait(5000)
            end
        end
    )
    -- 异步UDP发送协程
    sys.taskInit(
        function()
            sys.waitUntil("AsyncUdpSocketInitComplete")
            while true do
                udpClient2:asyncSend(testSendData1)
                log.info(tag4 .. ".send", "SUCCESS")
                sys.wait(waitTime)
            end
        end
    )

    sys.subscribe(
        "SOCKET_RECV",
        function(id)
            if tcpClient3.id == id then
                local data = tcpClient3:asyncRecv()
                log.info("SocketTest.tcpClient3.recv", #data, data:sub(1, 30))
            elseif udpClient2.id == id then
                local data = udpClient2:asyncRecv()
                log.info("SocketTest.udpClient2.recv", #data, data:sub(1, 30))
            end
        end
    )

end

if LuaTaskTestConfig.socketTest.asyncSocketTest then

    local tag5 = "AsyncSocketTest"
    --local ip, port, c = "180.97.80.55", "12415"
    local ip, port, c = "iot.kang-cloud.com", "8090" 
    
    DEV_LOGIN_CMD    					= 0x0B03 -- 登录
    local hardware_version = "V2.00"
    
     
    local software_version = "V111"
    local function get_protocol_str(cmd ,tb,FLAG,STEP)
    
        
        local str = nil
    
        
        local head_prj_imei = pack.pack(">H,>I,A",0xEF8A,0x75670002,misc.getImei() )
        local pkt_num,pkt,crc,pkt_end = 0,nil,0xFF,pack.pack(">H3",0xEFEF,0xFFFF,0xFFFF)
        
        if cmd == DEV_LOGIN_CMD then 
        
            pkt = pack.pack(">H",cmd)..hardware_version..string.rep("\0",15 - string.len(hardware_version) )
            pkt = pkt..software_version..string.rep("\0",15 - string.len(software_version) )
            pkt = pkt..pack.pack(">H,b,>H,>H",111,2222333,3333,3336)
            pkt = pkt..ip..string.rep("\0",30 - string.len(ip) )..pack.pack(">H",port)
    
        end
        
        
        if pkt ~= nil then 
        
            pkt_num = string.len(pkt)
            
            crc  = string.byte(pkt,1)
            
            for i = 2,pkt_num do
                crc = bit.bxor(crc, string.byte(pkt,i) ) 	 
            end
            
            str = head_prj_imei..pack.pack(">H",pkt_num)..pkt..string.char(crc)..pkt_end
            
            if str:len() > 300 then
                log.info(tag5.."socket data to send is...",string.toHex( string.sub(str,1,50) ) )
            else
                log.info(tag5.."socket data to send is",string.toHex(str ))
            end
            
            
            return str 		 
        end
        
         
    end
    
    
    function app_socket_send_cmd(cmd,tb,v2,v3)
    
        if clientConnected then
        
            asyncClient:asyncSend( get_protocol_str(cmd,tb,v2,v3) )
        else
            log.info(tag5.."App->SOCKET","socket is disconnect...")
        end
    end
    
    
    
    -- 异步接口演示代码
    local asyncClient
    local clientConnected
    sys.taskInit(function()
        while true do
            while not socket.isReady() do 
                sys.wait(1000) 
                log.info(tag5,"socket准备中，请等待" )
            end
            log.info(tag5,"socket 准备成功" )
            asyncClient = socket.tcp()
            while not asyncClient:connect(ip, port) do 
                sys.wait(2000) 
                log.info(tag5,"asyncClient连接中，请等待" )	
            end
            log.info(tag5,"asyncClient连接成功" )
        
            if asyncClient:asyncSend( get_protocol_str(DEV_LOGIN_CMD) ) then
                log.info(tag5, "asyncClient 发送成功" )
            else 
                log.info(tag5, "asyncClient 发送失败" )
            end
            clientConnected = true
            while asyncClient:asyncSelect(60, "ping") do end
            clientConnected = false
            asyncClient:close()
            log.info(tag5, "asyncClient 关闭" )
        end
    end)
    
    
    sys.subscribe("SOCKET_RECV", function(id)
        if asyncClient.id == id then
            local data = asyncClient:asyncRecv()
            log.info(tag5,"这是服务器下发数据:", #data, data:sub(1, 30))
        end
    end)
    


end

sys.timerLoopStart(
    function ()
        log.info("SocketTest.PrintStatus", socket.printStatus())
    end,
    60000
)

-- TODO mt:setRcvProc(rcvCbFnc) (BUG)
-- TODO socket.setTcpResendPara(retryCnt, retryMaxTimeout)
-- TODO socket.setDnsParsePara(retryCnt, retryTimeoutMulti)
-- 设置域名解析参数
-- 注意：0027以及之后的core版本才支持此功能