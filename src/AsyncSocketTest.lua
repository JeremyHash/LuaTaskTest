module(..., package.seeall)
require "misc"
require "socket"
-- 此处的IP和端口请填上你自己的socket服务器和端口
--local ip, port, c = "180.97.80.55", "12415"
local ip, port, c = "iot.kang-cloud.com", "8090" --

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
			log.info("socket data to send is...",string.toHex( string.sub(str,1,50) ) )
		else
			log.info("socket data to send is",string.toHex(str ))
		end
		
		
		return str 		 
	end
	
	 
end


function app_socket_send_cmd(cmd,tb,v2,v3)

	if clientConnected then
	
		asyncClient:asyncSend( get_protocol_str(cmd,tb,v2,v3) )
	else
		log.info("App->SOCKET","socket is disconnect...")
	end
end



-- 异步接口演示代码
local asyncClient
local clientConnected
sys.taskInit(function()
    while true do
        while not socket.isReady() do 
			sys.wait(1000) 
			log.info("AsyncSocketTest", "socket准备中，请等待" )
		end
		log.info("AsyncSocketTest", "socket 准备成功" )
        asyncClient = socket.tcp()
        while not asyncClient:connect(ip, port) do 
			sys.wait(2000) 
			log.info("AsyncSocketTest", "asyncClient连接中，请等待" )	
		end
		log.info("AsyncSocketTest", "asyncClient连接成功" )
	
		if asyncClient:asyncSend( get_protocol_str(DEV_LOGIN_CMD) ) then
			log.info("AsyncSocketTest", "asyncClient 发送成功" )
		else 
			log.info("AsyncSocketTest", "asyncClient 发送失败" )
		end
        clientConnected = true
        while asyncClient:asyncSelect(60, "ping") do end
        clientConnected = false
        asyncClient:close()
		log.info("AsyncSocketTest", "asyncClient 关闭" )
    end
end)


sys.subscribe("SOCKET_RECV", function(id)
    if asyncClient.id == id then
        local data = asyncClient:asyncRecv()
        log.info("这是服务器下发数据:", #data, data:sub(1, 30))
    end
end)
