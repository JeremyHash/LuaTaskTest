--- 模块功能：FTP客户端
-- @module ftp
-- @author Dozingfiretruck
-- @license MIT
-- @copyright OpenLuat.com
-- @release 2020.12.08
require "socket"
require "utils"
module(..., package.seeall)

local ftp_client                                --ftp命令连接socket对象
local ftp_data_client                           --ftp数据连接socket对象
local data_client_ip,data_client_port           --ftp数据连接地址
local ftp_connect_status = false

--- FTP客户端关闭
function close()
    ftp_client:send("QUIT\r\n")
    ftp_client:close()
    ftp_connect_status = false
    log.info("ftp","ftp close")
end

--- FTP客户端命令
-- @string command,string类型,命令 例如"PWD" "HELP LIST" "SYST"
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function command(command,timeout)
    if ftp_connect_status == false then
        log.info("ftp.command", "ftp connect error")
        return
    end
    if not ftp_client:send(command.."\r\n") then close() return '426', 'SOCKET_SEND_ERROR' end
    local r,n = ftp_client:recv(timeout)
    log.info("ftp_command",n)
    if not r then close() return '503', 'SOCKET_RECV_TIMOUT'
    else return n:sub(1,3), n:sub(4,#n) end
end

--- 连接到PASV接口
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
local function pasv_connect(timeout)
    if ftp_connect_status == false then
        log.info("ftp.command", "ftp connect error")
        return
    end
    ---被动模式
    if not ftp_client:send("PASV\r\n") then close() return '426', 'SOCKET_SEND_ERROR' end
    local r, n= ftp_client:recv(timeout)
    log.info("ftp.pasv_info", r, n)
    local h1, h2, h3, h4, p1, p2 = string.match(n, "(%d+),(%d+),(%d+),(%d+),(%d+),(%d+)")
    if h1 == nil then
        return "426", "SOCKET_SEND_ERROR"
    end
    data_client_ip, data_client_port = h1..'.'..h2..'.'..h3..'.'..h4,string.format("%d",(p1*256+p2))
    if not r then close() return '503', 'SOCKET_RECV_TIMOUT' end
    ---创建ftp数据连接
    ftp_data_client = socket.tcp()
    if not ftp_data_client:connect(data_client_ip , data_client_port) then close()  ftp_data_client:close() return '502', 'SOCKET_CONN_ERROR' end
    return '200', 'ftp pasv success'
end


--- FTP客户端登录
-- @string ftp_mode,string类型,FTP模式"PASV" or "PORT"  默认PASV:被动模式,PORT:主动模式 (暂时仅支持被动模式)
-- @string host,string类型,ip地址
-- @string port,number类型,端口,默认21
-- @string username,string类型,用户名
-- @string password,string类型,密码
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @bool ssl,可选参数，默认为nil，ssl，是否为ssl连接，true表示是，其余表示否
-- @table,cert,可选参数，默认为nil，cert，ssl连接需要的证书配置，只有ssl参数为true时，才参数才有意义，cert格式如下：
--     {
--     caCert = "ca.crt", --CA证书文件(Base64编码 X.509格式)，如果存在此参数，则表示客户端会对服务器的证书进行校验；不存在则不校验
--     clientCert = "client.crt", --客户端证书文件(Base64编码 X.509格式)，服务器对客户端的证书进行校验时会用到此参数
--     clientKey = "client.key", --客户端私钥文件(Base64编码 X.509格式)
--     clientPassword = "123456", --客户端证书文件密码[可选]
--     }
-- @return string,string,返回 response_code, response_message
function login(ftp_mode,host,port,username,password,timeout,ssl,cert)
    if ftp_mode ~= "PASV" then log.error("暂不支持主动模式 ") return '-1' ,'ftp ftp_mode error' end
    while not socket.isReady() do sys.wait(1000) end
    ---创建ftp命令连接
    ftp_client = socket.tcp(ssl,cert)
    if not ftp_client:connect(host , port or 21) then close() return '502', 'SOCKET_CONN_ERROR' end
    local r = ftp_client:recv(timeout)
    if not r then close() return '503', 'SOCKET_RECV_TIMOUT' end
    ---登录
    --用户名
    if not ftp_client:send("USER "..username.."\r\n") then close() return '426', 'SOCKET_SEND_ERROR' end
    local r = ftp_client:recv(timeout)
    if not r then close() return '503', 'SOCKET_RECV_TIMOUT' end
    --密码
    if not ftp_client:send("PASS "..password.."\r\n") then close() return '426', 'SOCKET_SEND_ERROR' end
    local r ,n= ftp_client:recv(timeout)
    if not r then close() return '503', 'SOCKET_RECV_TIMOUT' end
    if n:sub(1,3) == '230' then log.info("ftp",n)
    elseif n:sub(1,3) == '530' then log.error("ftp Password error ",n) close() return '530',n end
    log.info("ftp login success")
    ftp_connect_status = true
    return '200', 'ftp login success'
end

--- FTP客户端文件上传
-- @string remote_file,string类型,远程文件名
-- @string local_file,string类型,本地文件名
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function upload(remote_file, local_file,timeout)
    if ftp_connect_status == false then
        log.info("ftp.command", "ftp connect error")
        return
    end
    local pasv_code, pasv_res = pasv_connect()
    if pasv_code ~= "200" then
        log.info("ftp.upload", "pasv fail")
        return
    end
    --文件上传
    if not ftp_client:send("STOR "..remote_file.."\r\n") then close()  ftp_data_client:close() return '426', 'SOCKET_SEND_ERROR' end
    local r, n = ftp_client:recv(timeout)
    if not r then close()  ftp_data_client:close() return '503', 'SOCKET_RECV_TIMOUT' end
    if n:sub(1,3) == '553' then log.error("ftp STOR error ",n) close()  ftp_data_client:close() return '553', n end
    local file = io.open(local_file, "r")
    if file then
        while true do
            file_data = file:read(1024)
            if file_data == nil then
                break
            end
            local send_res = ftp_data_client:send(file_data, timeout)
            if send_res == false then
                return '426', 'SOCKET_SEND_ERROR'
            end
        end
    else
        log.error("ftp", "can not open the file to upload")
    end
    file:close()
    ftp_data_client:close()
    local r, n = ftp_client:recv(timeout)
    log.info("ftp.upload", r, n)
    return '200', 'ftp success'
end

--- FTP客户端文件下载
-- @string remote_file,string类型,远程文件名
-- @string local_file,string类型,本地文件名
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function download(remote_file,local_file,timeout)
    if ftp_connect_status == false then
        log.info("ftp.command", "ftp connect error")
        return
    end
    local pasv_code, pasv_res = pasv_connect()
    if pasv_code ~= "200" then
        log.info("ftp.download", "pasv fail")
        return
    end
    --文件大小
    -- if not ftp_client:send("SIZE "..remote_file.."\r\n") then close()  ftp_data_client:close() return '426', 'SOCKET_SEND_ERROR' end
    -- local r , n= ftp_client:recv(timeout)
    -- if not r then close()  ftp_data_client:close() return '503', 'SOCKET_RECV_TIMOUT' end
    -- if n:sub(1,3) == '213' then log.info("ftp filename size",n:sub(5,#n)) filename_size = tonumber(n:sub(5,#n))
    -- elseif n:sub(1,3) == '550' then log.error("ftp filename error ",n) return end
    --文件下载
    if not ftp_client:send("RETR "..remote_file.."\r\n") then close()  ftp_data_client:close() return '426', 'SOCKET_SEND_ERROR' end
    -- local r, n= ftp_client:recv(timeout)
    -- log.info("ftp.download",r, n)
    -- if not r then close()  ftp_data_client:close() return '503', 'SOCKET_RECV_TIMOUT' end
    if io.exists(local_file)then
        os.remove(local_file)
        log.info("ftp.download.remove", local_file)
    end
    local file = io.open(local_file,"a+")
    while true do
        local r, n= ftp_data_client:recv(timeout)
        if r then
            file:write(n)
        else
            ftp_data_client:close()
            break
        end
    end
    file:close()
    -- local r, n= ftp_client:recv(timeout)
    -- log.info("ftp.download",r, n)
    return '200', 'ftp success'
end

--- 设置FTP传输类型 A:ascii I:Binary
-- @string mode,A:ascii I:Binary
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function checktype(mode,timeout)
    return command("TYPE "..mode,timeout)
end

--- 显示当前工作目录
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function pwd(timeout)
    return command("PWD ",timeout)
end

--- 更改工作目录
-- @string path,工作目录
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function cwd(path,timeout)
    return command("CWD "..path,timeout)
end

--- 回到上级目录
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function cdup(timeout)
    return command("CDUP",timeout)
end

--- 创建目录
-- @string path,目录
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function mkd(path,timeout)
    return command("MKD "..path,timeout)
end

--- 列出目录列表或文件信息
-- @string file_directory,目录或文件
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function list(file_directory,timeout)
    if ftp_connect_status == false then
        log.info("ftp.command", "ftp connect error")
        return
    end
    local pasv_code, pasv_res = pasv_connect()
    if pasv_code ~= "200" then
        log.info("ftp.upload", "pasv fail")
        return
    end
    command("LIST "..file_directory,timeout)
    --
    local r , n= ftp_client:recv(timeout)
    log.info("ftp",r,n)
    if not r then close()  ftp_data_client:close() return '503', 'SOCKET_RECV_TIMOUT' end
    local data = ""
    while true do
        local r , n= ftp_data_client:recv(timeout)
        if r then
            data = data .. n
        else
            break
        end
    end
    ftp_data_client:close()
    return r, data
end

--- 删除目录
-- @string file_directory,string类型,路径目录
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function rmd(file_directory, timeout)
    return deletefolder(file_directory, timeout)
end


--- 删除目录
-- @string file_directory,string类型,路径目录
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function deletefolder(file_directory,timeout)
    return command("RMD "..file_directory,timeout)
end

--- 删除文件
-- @string file_directory,string类型,路径文件(相对/绝对)
-- @number timeout,number类型,可选参数，接收超时时间，单位毫秒,默认为0
-- @return string,string,返回 response_code, response_message
function deletefile(file_directory,timeout)
    return command("DELE "..file_directory,timeout)
end


