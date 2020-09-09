-- HttpTest
-- Author:LuatTest
-- CreateDate:20200716
-- UpdateDate:20200717

module(...,package.seeall)

-- 测试配置 设置为true代表开启此项测试
local httpTestConfig = {
    getTest = true,
    getTestWithCA = true,
    getTestWithCAAndKey = true,
    getTestAndSaveToBigFile = true,
    getTestAndSaveToSmallFile = true,
    postTest = true,
    postTestWithUserHead = true,
    postTestWithOctetStream = true,
    postTestWithMultipartFormData = true,
    postTestWithXwwwformurlencoded = true
}

local waitTime = 20000

--同步网络时间，因为证书校验时会用到系统时间
ntp.timeSync()

--multipart/form-data封装函数
local function postTestWithMultipartFormData(url,cert,params,timeout,cbFnc,rcvFileName)
    local boundary,body,k,v,kk,vv = "--------------------------"..os.time()..rtos.tick(),{}
    
    for k,v in pairs(params) do
        if k=="texts" then
            local bodyText = ""
            for kk,vv in pairs(v) do
                bodyText = bodyText.."--"..boundary.."\r\nContent-Disposition: form-data; name=\""..kk.."\"\r\n\r\n"..vv.."\r\n"
            end
            body[#body+1] = bodyText
        elseif k=="files" then
            local contentType =
            {
                jpg = "image/jpeg",
                jpeg = "image/jpeg",
                png = "image/png",
                txt = "text/plain",
                lua = "text/plain"
            }
            for kk,vv in pairs(v) do
                print(kk,vv)
                body[#body+1] = "--"..boundary.."\r\nContent-Disposition: form-data; name=\""..kk.."\"; filename=\""..kk.."\"\r\nContent-Type: "..contentType[vv:match("%.(%w+)$")].."\r\n\r\n"
                body[#body+1] = {file = vv}
                body[#body+1] = "\r\n"
            end
        end
    end    
    body[#body+1] = "--"..boundary.."--\r\n"
        
    http.request(
        "POST",
        url,
        cert,
        {
            ["Content-Type"] = "multipart/form-data; boundary="..boundary,
            ["Connection"] = "keep-alive"
        },
        body,
        timeout,
        cbFnc,
        rcvFileName
        )    
end

-- x-www-form-urlencoded转换函数
local function urlencodeTab(params)
    local msg = {}
    for k, v in pairs(params) do
        table.insert(msg, string.urlEncode(k) .. '=' .. string.urlEncode(v))
        table.insert(msg, '&')
    end
    table.remove(msg)
    return table.concat(msg)
end

-- getTest回调
local function getTestCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.GetTestCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.GetTestCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.GetTestCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.GetTestCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.GetTestCb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.GetTestCb.Body","body="..body)
        log.info("HttpTest.GetTestCb.Body","bodyLen="..body:len())
        if body=="LuatHttpTestServerGetTestOK" then
            log.info("HttpTest.GetTestCb","getTestPass!!!")
        end
    end
end

-- getTestWithCA回调
local function getTestWithCACb(result,prompt,head,body)
    if result then
        log.info("HttpTest.GetTestWithCACb.result","Http请求成功:",result)
    else
        log.info("HttpTest.GetTestWithCACb.result","Http请求失败:",result)
    end
    log.info("HttpTest.GetTestWithCACb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.GetTestWithCACb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.GetTestWithCACb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.GetTestWithCACb.Body","body="..body)
        log.info("HttpTest.GetTestWithCACb.Body","bodyLen="..body:len())
    end
end

-- getTestWithCAAndKey回调
local function GetTestWithCAAndKeyCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.GetTestWithCAAndKeyCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.GetTestWithCAAndKeyCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.GetTestWithCAAndKeyCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.GetTestWithCAAndKeyCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.GetTestWithCAAndKeyCb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.GetTestWithCAAndKeyCb.Body","body="..body)
        log.info("HttpTest.GetTestWithCAAndKeyCb.Body","bodyLen="..body:len())
    end
end

-- 处理大文件回调
local function getTestAndSaveToBigFileCb(result,prompt,head,filePath)
    if result then
        log.info("HttpTest.GetTestAndSaveToBigFileCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.GetTestAndSaveToBigFileCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.GetTestAndSaveToBigFileCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.GetTestAndSaveToBigFileCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.GetTestAndSaveToBigFileCb.Head",k.." : "..v)
        end
    end
    if result and filePath then
        log.info("HttpTest.GetTestAndSaveToBigFileCb.filePath", filePath)
        local size = io.fileSize(filePath)
        log.info("HttpTest.GetTestAndSaveToBigFileCb.fileSize","fileSize="..size)
        
        --输出文件内容，如果文件太大，一次性读出文件内容可能会造成内存不足，分次读出可以避免此问题
        if size<=4096 then
            log.info("HttpTest.GetTestAndSaveToBigFileCb.fileContent", io.readFile(filePath))
        else
			log.info("HttpTest.GetTestAndSaveToBigFileCb.fileContent", filePath.."文件过大")
        end
    end
    log.info("保存文件后可用空间 "..rtos.get_fs_free_size().." Bytes")
    --文件使用完之后，如果以后不再用到，需要自行删除
    if filePath then 
        -- os.remove(filePath)
        local remove_dir_res = rtos.remove_dir("/Jeremy")
        if remove_dir_res == true then
            log.info("HttpTest.GetTestAndSaveToBigFileCb.fileDelete", filePath.." deletion success")
            log.info("删除文件后可用空间 "..rtos.get_fs_free_size().." Bytes")
        else
            log.error("HttpTest.GetTestAndSaveToBigFileCb.fileDelete", filePath.." deletion fail")
            log.info("删除文件后可用空间 "..rtos.get_fs_free_size().." Bytes")
        end
    end
end

-- 处理小文件回调
local function getTestAndSaveToSmallFileCb(result,prompt,head,filePath)
    if result then
        log.info("HttpTest.GetTestAndSaveToSmallFileCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.GetTestAndSaveToSmallFileCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.GetTestAndSaveToSmallFileCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.GetTestAndSaveToSmallFileCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.GetTestAndSaveToSmallFileCb.Head",k.." : "..v)
        end
    end
    if result and filePath then
        log.info("HttpTest.GetTestAndSaveToSmallFileCb.filePath", filePath)
        local size = io.fileSize(filePath)
        log.info("HttpTest.GetTestAndSaveToSmallFileCb.fileSize","fileSize="..size)
        
        --输出文件内容，如果文件太大，一次性读出文件内容可能会造成内存不足，分次读出可以避免此问题
        if size<=4096 then
            log.info("HttpTest.GetTestAndSaveToSmallFileCb.fileContent", io.readFile(filePath))
        else
			log.info("HttpTest.GetTestAndSaveToSmallFileCb.fileContent", filePath.."文件过大")
        end
    end
    log.info("保存文件后可用空间 "..rtos.get_fs_free_size().." Bytes")
    --文件使用完之后，如果以后不再用到，需要自行删除
    if filePath then 
        os.remove(filePath)
        -- local remove_dir_res = rtos.remove_dir("/Jeremy")
        if remove_dir_res == true then
            log.info("HttpTest.GetTestAndSaveToSmallFileCb.fileDelete", filePath.." deletion success")
            log.info("删除文件后可用空间 "..rtos.get_fs_free_size().." Bytes")
        else
            log.error("HttpTest.GetTestAndSaveToSmallFileCb.fileDelete", filePath.." deletion fail")
            log.info("删除文件后可用空间 "..rtos.get_fs_free_size().." Bytes")
        end
    end
end

-- postTest回调
local function postTestCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.PostTestCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.PostTestCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.PostTestCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.PostTestCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.PostTestCb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.PostTestCb.Body","body="..body)
        log.info("HttpTest.PostTestCb.Body","bodyLen="..body:len())
    end
end

-- postTestWithUserHeadCb回调
local function postTestWithUserHeadCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.PostTestWithUserHeadCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.PostTestWithUserHeadCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.PostTestWithUserHeadCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.PostTestWithUserHeadCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.PostTestWithUserHeadCb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.PostTestWithUserHeadCb.Body","body="..body)
        log.info("HttpTest.PostTestWithUserHeadCb.Body","bodyLen="..body:len())
    end
end

-- postTestWithOctetStreamCb回调
local function postTestWithOctetStreamCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.PostTestWithOctetStreamCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.PostTestWithOctetStreamCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.PostTestWithOctetStreamCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.PostTestWithOctetStreamCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.PostTestWithOctetStreamCb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.PostTestWithOctetStreamCb.Body","body="..body)
        log.info("HttpTest.PostTestWithOctetStreamCb.Body","bodyLen="..body:len())
    end
end

-- postTestWithMultipartFormDataCb回调
local function postTestWithMultipartFormDataCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.PostTestWithMultipartFormDataCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.PostTestWithMultipartFormDataCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.PostTestWithMultipartFormDataCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.PostTestWithMultipartFormDataCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.PostTestWithMultipartFormDataCb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.PostTestWithMultipartFormDataCb.Body","body="..body)
        log.info("HttpTest.PostTestWithMultipartFormDataCb.Body","bodyLen="..body:len())
    end
end

-- postTestWithXwwwformurlencodedCb回调
local function postTestWithXwwwformurlencodedCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.PostTestWithXwwwformurlencodedCb.result","Http请求成功:",result)
    else
        log.info("HttpTest.PostTestWithXwwwformurlencodedCb.result","Http请求失败:",result)
    end
    log.info("HttpTest.PostTestWithXwwwformurlencodedCb.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.PostTestWithXwwwformurlencodedCb.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.PostTestWithXwwwformurlencodedCb.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.PostTestWithXwwwformurlencodedCb.Body","body="..body)
        log.info("HttpTest.PostTestWithXwwwformurlencodedCb.Body","bodyLen="..body:len())
    end
end

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("HttpTest","成功访问网络,Http测试开始")
        local serverAddress = "wiki.airm2m.com:48080"
        local count = 1
        while true do
            -- Http GET 请求测试
            if httpTestConfig.getTest == true then
                log.info("HttpTest.GetTest","第"..count.."次")
                http.request("GET",serverAddress,nil,nil,nil,nil,getTestCb)
                sys.wait(waitTime)
            end
            
            -- Https Get 请求测试（服务端证书验证_单向认证）
            if httpTestConfig.getTestWithCA == true then
                log.info("HttpTest.GetTestWithCA","第"..count.."次")
                http.request("GET","https://www.baidu.com",{caCert="ca.cer"},nil,nil,nil,getTestWithCACb)
                sys.wait(waitTime)
            end

            -- Https Get 请求测试（服务端客户端证书验证_双向认证）
            if httpTestConfig.getTestWithCAAndKey == true then
                log.info("HttpTest.GetTestWithCAAndKey","第"..count.."次")
                http.request("GET","https://36.7.87.100:4434",{caCert="ca.crt",clientCert="client.crt",clientKey="client.key"},nil,nil,nil,GetTestWithCAAndKeyCb)
                sys.wait(waitTime)
            end

            -- Https Get 请求测试（保存结果到文件,文件较大）
            if httpTestConfig.getTestAndSaveToBigFile == true then
                log.info("创建文件前可用空间 "..rtos.get_fs_free_size().." Bytes")
                if rtos.make_dir("/Jeremy/") == true then
                    log.info("HttpTest.makeDir", "success")
                else
                    log.error("HttpTest.makeDir", "fail")
                end
                log.info("HttpTest.GetTestAndSaveToBigFile","第"..count.."次")
                http.request("GET","https://www.baidu.com",{caCert="ca.cer"},nil,nil,nil,getTestAndSaveToBigFileCb,"/Jeremy/baidu.html")
                sys.wait(waitTime)
            end

            -- Https Get 请求测试（保存结果到文件,文件较小）
            if httpTestConfig.getTestAndSaveToSmallFile == true then
                log.info("创建文件前可用空间 "..rtos.get_fs_free_size().." Bytes")
                if rtos.make_dir("/Jeremy/") == true then
                    log.info("HttpTest.makeDir", "success")
                else
                    log.error("HttpTest.makeDir", "fail")
                end
                log.info("HttpTest.GetTestAndSaveToSmallFile","第"..count.."次")
                http.request("GET","https://www.lua.org/",nil,nil,nil,nil,getTestAndSaveToSmallFileCb,"/Jeremy/lua.html")
                sys.wait(waitTime)
            end

            -- Https Post 请求测试(/)
            if httpTestConfig.postTest == true then
                log.info("HttpTest.PostTest","第"..count.."次")
                http.request("POST",serverAddress.."/",nil,nil,"PostTest!",nil,postTestCb)
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（自定义Head）
            if httpTestConfig.postTestWithUserHead == true then
                log.info("HttpTest.PostTestWithUserHead","第"..count.."次")
                http.request("POST",serverAddress.."/withUserHead",nil,{UserHead="Jeremy"},nil,nil,postTestWithUserHeadCb)
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（octet-stream）
            if httpTestConfig.postTestWithOctetStream == true then
                log.info("HttpTest.PostTestWithOctetStream","第"..count.."次")
                http.request("POST",serverAddress.."/withOctetStream",nil,{['Content-Type']="application/octet-stream",['Connection']="keep-alive"},{[1]={['file']="/lua/http.lua"}},nil,postTestWithOctetStreamCb)
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（postTestWithFormData）
            if httpTestConfig.postTestWithMultipartFormData == true then
                log.info("HttpTest.PostTestWithMultipartFormData","第"..count.."次")
                postTestWithMultipartFormData(
                    serverAddress.."/uploadFile",
                    nil,
                    {
                        texts = 
                        {
                            ["imei"] = "862991234567890",
                            ["time"] = "20180802180345"
                        },

                        files =
                        {
                            ["FormDataUploadFile"] = "/lua/http.lua"
                        }
                    },
                    nil,
                    postTestWithMultipartFormDataCb
                )
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（withxwwwformurlencoded）
            if httpTestConfig.postTestWithXwwwformurlencoded == true then
                log.info("HttpTest.PostTestWithXwwwformurlencoded","第"..count.."次")
                http.request("POST",serverAddress.."/withxwwwformurlencoded",nil,
                {
                    ["Content-Type"]="application/x-www-form-urlencoded",
                },
                urlencodeTab({content="x-www-form-urlencoded Test!", author="Jeremy"}),nil,postTestWithXwwwformurlencodedCb)
                sys.wait(waitTime)
            end

            count = count + 1
        end
    end
)
