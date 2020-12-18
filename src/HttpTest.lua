-- HttpTest
-- Author:LuatTest
-- CreateDate:20200716
-- UpdateDate:20201028

module(..., package.seeall)

local waitTime = 30000

--multipart/form-data封装函数
local function postTestWithMultipartFormData(url, cert, params, timeout, cbFnc, rcvFileName)
    local boundary, body, k, v, kk, vv = "--------------------------" .. os.time() .. rtos.tick(), {}
    
    for k, v in pairs(params) do
        if k == "texts" then
            local bodyText = ""
            for kk, vv in pairs(v) do
                bodyText = bodyText .. "--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"" .. kk .. "\"\r\n\r\n" .. vv .. "\r\n"
            end
            body[#body + 1] = bodyText
        elseif k == "files" then
            local contentType =
            {
                jpg = "image/jpeg",
                jpeg = "image/jpeg",
                png = "image/png",
                txt = "text/plain",
                lua = "text/plain"
            }
            for kk, vv in pairs(v) do
                print(kk, vv)
                body[#body + 1] = "--" .. boundary .. "\r\nContent-Disposition: form-data; name=\"" .. kk .. "\"; filename=\"" .. kk .. "\"\r\nContent-Type: " .. contentType[vv:match("%.(%w+)$")] .. "\r\n\r\n"
                body[#body + 1] = {file = vv}
                body[#body + 1] = "\r\n"
            end
        end
    end    
    body[#body + 1] = "--" .. boundary .. "--\r\n"
        
    http.request(
        "POST",
        url,
        cert,
        {
            ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
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
local function getTestCb(result, prompt, head, body)
    if result then
        log.info("HttpTest.GetTestCb.result", "SUCCESS")
        log.info("HttpTest.GetTestCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.GetTestCb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.GetTestCb.Head", k .. " : " .. v)
            end
        else
            log.error("HttpTest.GetTestCb.Head", "读取响应头FAIL")
        end

        if body then
            log.info("HttpTest.GetTestCb.Body", body)
            log.info("HttpTest.GetTestCb.BodyLen", body:len())
            if body == "getTestSuccess" then
                log.info("HttpTest.GetTestCb", "getTestSuccess")
            else
                log.error("HttpTest.GetTestCb", "getTestFail")
            end
        else
            log.error("HttpTest.GetTestCb.Body", "读取响应体FAIL")
        end
    else
        log.error("HttpTest.GetTestCb.result", "FAIL")
        log.error("HttpTest.GetTestCb.prompt", prompt)
    end
end

-- getTest回调
local function getWaitTestCb(result, prompt, head, body)
    local tag = "HttpTest.GetWaitTestCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end

        if body then
            log.info(tag .. ".Body", body)
            log.info(tag .. ".BodyLen", body:len())
            if body == "waitTestSuccess" then
                log.info(tag, "getTestSuccess")
            else
                log.error(tag, "getTestFail")
            end
        else
            log.error(tag .. ".Body", "读取响应体FAIL")
        end
    else
        log.error(tag .. ".result", result)
        log.error(tag .. ".prompt", prompt)
        if prompt == "receive timeout" then
            log.info(tag, "getWaitTestSuccess")
        end
    end
end

-- get301Test回调
local function get301TestCb(result, prompt, head, body)
    local tag = "HttpTest.get301TestCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end

        if body then
            log.info(tag .. ".Body", body)
            log.info(tag .. ".BodyLen", body:len())
        else
            log.error(tag .. ".Body", "读取响应体FAIL")
        end
    else
        log.error(tag .. ".result", "FAIL")
        log.error(tag .. ".prompt", prompt)
    end
end

-- get302Test回调
local function get302TestCb(result, prompt, head, body)
    local tag = "HttpTest.get302TestCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end

        if body then
            log.info(tag .. ".Body", body)
            log.info(tag .. ".BodyLen", body:len())
        else
            log.error(tag .. ".Body", "读取响应体FAIL")
        end
    else
        log.error(tag .. ".result", "FAIL")
        log.error(tag .. ".prompt", prompt)
    end
end

-- getTestWithCA回调
local function getTestWithCACb(result, prompt, head, body)
    if result then
        log.info("HttpTest.GetTestWithCACb.result", "SUCCESS")
        log.info("HttpTest.GetTestWithCACb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.GetTestWithCACb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.GetTestWithCACb.Head", k .. " : " .. v)
            end
        else
            log.error("HttpTest.GetTestWithCACb.Head", "读取响应头FAIL")
        end

        if body then
            log.info("HttpTest.GetTestWithCACb.Body", body)
            log.info("HttpTest.GetTestWithCACb.BodyLen", body:len())
        else
            log.error("HttpTest.GetTestWithCACb.Body", "读取响应体FAIL")
        end
    else
        log.error("HttpTest.GetTestWithCACb.result", "FAIL")
        log.error("HttpTest.GetTestWithCACb.prompt", prompt)
    end
end

-- getTestWithCAAndKey回调
local function GetTestWithCAAndKeyCb(result, prompt, head, body)
    if result then
        log.info("HttpTest.GetTestWithCAAndKeyCb.result", "SUCCESS")
        log.info("HttpTest.GetTestWithCAAndKeyCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.GetTestWithCAAndKeyCb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.GetTestWithCAAndKeyCb.Head", k .. " : " .. v)
            end
        else
            log.error("HttpTest.GetTestWithCAAndKeyCb.Head", "读取响应头FAIL")
        end

        if body then
            log.info("HttpTest.GetTestWithCAAndKeyCb.Body", body)
            log.info("HttpTest.GetTestWithCAAndKeyCb.BodyLen", body:len())
        else
            log.error("HttpTest.GetTestWithCAAndKeyCb.Body", "读取响应体FAIL")
        end
    else
        log.error("HttpTest.GetTestWithCAAndKeyCb.result", "FAIL")
        log.error("HttpTest.GetTestWithCAAndKeyCb.prompt", prompt)
    end
end

-- 处理大文件回调
local function getTestAndSaveToBigFileCb(result, prompt, head, filePath)
    local MD5Header, fileSize
    if result then
        log.info("HttpTest.GetTestAndSaveToBigFileCb.result", "SUCCESS")
        log.info("HttpTest.GetTestAndSaveToBigFileCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.GetTestAndSaveToBigFileCb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.GetTestAndSaveToBigFileCb.Head", k .. " : " .. v)
                if k == "MD5" then
                    MD5Header = v
                end
                if k == "Content-Length" then
                    fileSize = v
                end
            end
        end
        if filePath then
            log.info("HttpTest.GetTestAndSaveToBigFileCb.filePath", filePath)
            local size = io.fileSize(filePath)
            log.info("HttpTest.GetTestAndSaveToBigFileCb.fileSize", size)

            if size <= 4096 then
                log.info("HttpTest.GetTestAndSaveToBigFileCb.fileContent", io.readFile(filePath))
            else
	    		log.info("HttpTest.GetTestAndSaveToBigFileCb.fileContent", filePath .. "文件过大")
            end

            if size == tonumber(fileSize) then
                log.info("HttpTest.GetTestAndSaveToBigFileCb.fileSize", "fileSize验证SUCCESS")
                local calMD5 = crypto.md5(filePath, "file")
                log.info("HttpTest.GetTestAndSaveToBigFileCb.CalMD5", calMD5)

                if MD5Header == calMD5 then
                    log.info("HttpTest.GetTestAndSaveToBigFileCb.CalMD5", "MD5校验SUCCESS")
                else
                    log.error("HttpTest.GetTestAndSaveToBigFileCb.CalMD5", "MD5校验FAIL")
                end
            else
                log.error("HttpTest.GetTestAndSaveToBigFileCb.fileSize", "fileSize验证FAIL")
            end

            log.info("保存大文件后可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
            -- os.remove(filePath)
            local remove_dir_res = rtos.remove_dir("/Jeremy")
            if remove_dir_res then
                log.info("HttpTest.GetTestAndSaveToBigFileCb.fileDelete", filePath .. "删除SUCCESS")
                log.info("删除大文件SUCCESS后可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
            else
                log.error("HttpTest.GetTestAndSaveToBigFileCb.fileDelete", filePath.."删除FAIL")
                log.info("删除大文件FAIL后可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
            end
        end
    else
        log.error("HttpTest.GetTestAndSaveToBigFileCb.result", "FAIL")
    end
end

-- 处理小文件回调
local function getTestAndSaveToSmallFileCb(result, prompt, head, filePath)
    local MD5Header, fileSize
    if result then
        log.info("HttpTest.getTestAndSaveToSmallFileCb.result", "SUCCESS")
        log.info("HttpTest.getTestAndSaveToSmallFileCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.getTestAndSaveToSmallFileCb.Head","遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.getTestAndSaveToSmallFileCb.Head", k .. " : " .. v)
                if k == "MD5" then
                    MD5Header = v
                end
                if k == "Content-Length" then
                    fileSize = v
                end
            end
        end
        if filePath then
            log.info("HttpTest.getTestAndSaveToSmallFileCb.filePath", filePath)
            local size = io.fileSize(filePath)
            log.info("HttpTest.getTestAndSaveToSmallFileCb.fileSize", size)

            if size <= 4096 then
                log.info("HttpTest.getTestAndSaveToSmallFileCb.fileContent", io.readFile(filePath))
            else
	    		log.info("HttpTest.getTestAndSaveToSmallFileCb.fileContent", filePath .. "文件过大")
            end

            if size == tonumber(fileSize) then
                log.info("HttpTest.getTestAndSaveToSmallFileCb.fileSize", "fileSize验证SUCCESS")
                local calMD5 = crypto.md5(filePath, "file")
                log.info("HttpTest.getTestAndSaveToSmallFileCb.CalMD5", calMD5)

                if MD5Header == calMD5 then
                    log.info("HttpTest.getTestAndSaveToSmallFileCb.CalMD5", "MD5校验SUCCESS")
                else
                    log.error("HttpTest.getTestAndSaveToSmallFileCb.CalMD5", "MD5校验FAIL")
                end
            else
                log.error("HttpTest.getTestAndSaveToSmallFileCb.fileSize", "fileSize验证FAIL")
            end

            log.info("保存小文件后可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
            -- os.remove(filePath)
            local remove_dir_res = rtos.remove_dir("/Jeremy")
            if remove_dir_res then
                log.info("HttpTest.getTestAndSaveToSmallFileCb.fileDelete", filePath .. "删除SUCCESS")
                log.info("删除小文件SUCCESS后可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
            else
                log.error("HttpTest.getTestAndSaveToSmallFileCb.fileDelete", filePath.."删除FAIL")
                log.info("删除小文件FAIL后可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
            end
        end
    else
        log.error("HttpTest.getTestAndSaveToSmallFileCb.result", "FAIL")
    end
end

-- postTest回调
local function postTestCb(result, prompt, head, body)
    if result then
        log.info("HttpTest.postTestCb.result", "SUCCESS")
        log.info("HttpTest.postTestCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.postTestCb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.postTestCb.Head", k .. " : " .. v)
            end
        else
            log.error("HttpTest.postTestCb.Head", "读取响应头FAIL")
        end

        if body then
            log.info("HttpTest.postTestCb.Body", body)
            log.info("HttpTest.postTestCb.BodyLen", body:len())
            if body == "postTestSuccess" then
                log.info("HttpTest.postTestCb", "postTestSuccess")
            else
                log.error("HttpTest.postTestCb", "postTestFail")
            end
        else
            log.error("HttpTest.postTestCb.Body", "读取响应体FAIL")
        end
    else
        log.error("HttpTest.postTestCb.result", "FAIL")
        log.error("HttpTest.postTestCb.prompt", prompt)
    end
end

-- postJsonTest回调
local function postJsonTestCb(result, prompt, head, body)
    local tag = "HttpTest.postJsonTestCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end

        if body then
            log.info(tag .. ".Body", body)
            log.info(tag .. ".BodyLen", body:len())
            if body == "postJsonTestSuccess" then
                log.info(tag, "postTestSuccess")
            else
                log.error(tag, "postTestFail")
            end
        else
            log.error(tag .. ".Body", "读取响应体FAIL")
        end
    else
        log.error(tag .. ".result", "FAIL")
        log.error(tag .. ".prompt", prompt)
    end
end

-- postTestWithUserHeadCb回调
local function postTestWithUserHeadCb(result,prompt,head,body)
    if result then
        log.info("HttpTest.postTestWithUserHeadCb.result", "SUCCESS")
        log.info("HttpTest.postTestWithUserHeadCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.postTestWithUserHeadCb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.postTestWithUserHeadCb.Head", k .. " : " .. v)
            end
        else
            log.error("HttpTest.postTestWithUserHeadCb.Head", "读取响应头FAIL")
        end

        if body then
            log.info("HttpTest.postTestWithUserHeadCb.Body", body)
            log.info("HttpTest.postTestWithUserHeadCb.BodyLen", body:len())
            if body == "PostTestWithUserHeadPass" then
                log.info("HttpTest.postTestWithUserHeadCb", "PostTestWithUserHeadSuccess")
            else
                log.error("HttpTest.postTestWithUserHeadCb", "PostTestWithUserHeadFail")
            end
        else
            log.error("HttpTest.postTestWithUserHeadCb.Body", "读取响应体FAIL")
        end
    else
        log.error("HttpTest.postTestWithUserHeadCb.result", "FAIL")
        log.error("HttpTest.postTestWithUserHeadCb.prompt", prompt)
    end
end

-- postTestWithOctetStreamCb回调
local function postTestWithOctetStreamCb(result, prompt, head, body)
    if result then
        log.info("HttpTest.postTestWithOctetStreamCb.result", "SUCCESS")
        log.info("HttpTest.postTestWithOctetStreamCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.postTestWithOctetStreamCb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.postTestWithOctetStreamCb.Head", k .. " : " .. v)
            end
        else
            log.error("HttpTest.postTestWithOctetStreamCb.Head", "读取响应头FAIL")
        end

        if body then
            log.info("HttpTest.postTestWithOctetStreamCb.Body", body)
            log.info("HttpTest.postTestWithOctetStreamCb.BodyLen", body:len())
            if body == "PostTestWithOctetStreamSuccess" then
                log.info("HttpTest.postTestWithOctetStreamCb", "postTestWithOctetStreamSuccess")
            else
                log.error("HttpTest.postTestWithOctetStreamCb", "postTestWithOctetStreamFail")
            end
        else
            log.error("HttpTest.postTestWithOctetStreamCb.Body", "读取响应体FAIL")
        end
    else
        log.error("HttpTest.postTestWithOctetStreamCb.result", "FAIL")
        log.error("HttpTest.postTestWithOctetStreamCb.prompt", prompt)
    end
end

-- postTestWithMultipartFormDataCb回调
local function postTestWithMultipartFormDataCb(result, prompt, head, body)
    if result then
        log.info("HttpTest.postTestWithMultipartFormDataCb.result", "SUCCESS")
        log.info("HttpTest.postTestWithMultipartFormDataCb.prompt", "Http状态码:", prompt)
        if head then
            log.info("HttpTest.postTestWithMultipartFormDataCb.Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info("HttpTest.postTestWithMultipartFormDataCb.Head", k .. " : " .. v)
            end
        else
            log.error("HttpTest.postTestWithMultipartFormDataCb.Head", "读取响应头FAIL")
        end

        if body then
            log.info("HttpTest.postTestWithMultipartFormDataCb.Body", body)
            log.info("HttpTest.postTestWithMultipartFormDataCb.BodyLen", body:len())
            if body == "postTestWithMultipartFormDataSuccess" then
                log.info("HttpTest.postTestWithMultipartFormDataCb", "postTestWithMultipartFormDataSuccess")
            else
                log.error("HttpTest.postTestWithMultipartFormDataCb", "postTestWithMultipartFormDataFail")
            end
        else
            log.error("HttpTest.postTestWithMultipartFormDataCb.Body", "读取响应体FAIL")
        end
    else
        log.error("HttpTest.postTestWithMultipartFormDataCb.result", "FAIL")
        log.error("HttpTest.postTestWithMultipartFormDataCb.prompt", prompt)
    end
end

-- postTestWithXwwwformurlencodedCb回调
local function postTestWithXwwwformurlencodedCb(result, prompt, head, body)
    local tag = "HttpTest.postTestWithXwwwformurlencodedCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end

        if body then
            log.info(tag .. ".Body", body)
            log.info(tag .. ".BodyLen", body:len())
            if body == "postTestWithXwwwformurlencodedSuccess" then
                log.info(tag, "postTestWithXwwwformurlencodedSuccess")
            else
                log.error(tag, "postTestWithXwwwformurlencodedFail")
            end
        else
            log.error(tag .. ".Body", "读取响应体FAIL")
        end
    else
        log.error(tag .. ".result", "FAIL")
        log.error(tag .. ".prompt", prompt)
    end
end

-- headTest回调
local function headTestCb(result, prompt, head, body)
    local tag = "HttpTest.headTestCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end
    else
        log.error(tag .. ".result", "FAIL")
        log.error(tag .. ".prompt", prompt)
    end
end

-- putTest回调
local function putTestCb(result, prompt, head, body)
    local tag = "HttpTest.putTestCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end

        if body then
            log.info(tag .. ".Body", body)
            log.info(tag .. ".BodyLen", body:len())
            if body == "putTestSuccess" then
                log.info(tag, "putTestSuccess")
            else
                log.error(tag, "putTestFail")
            end
        else
            log.error(tag .. ".Body", "读取响应体FAIL")
        end
    else
        log.error(tag .. ".result", "FAIL")
        log.error(tag .. ".prompt", prompt)
    end
end

-- deleteTest回调
local function deleteTestCb(result, prompt, head, body)
    local tag = "HttpTest.deleteTestCb"
    if result then
        log.info(tag .. ".result", "SUCCESS")
        log.info(tag .. ".prompt", "Http状态码:", prompt)
        if head then
            log.info(tag .. ".Head", "遍历响应头")
            for k, v in pairs(head) do
                log.info(tag .. ".Head", k .. " : " .. v)
            end
        else
            log.error(tag .. ".Head", "读取响应头FAIL")
        end

        if body then
            log.info(tag .. ".Body", body)
            log.info(tag .. ".BodyLen", body:len())
            if body == "deleteTestSuccess" then
                log.info(tag, "deleteTestSuccess")
            else
                log.error(tag, "deleteTestFail")
            end
        else
            log.error(tag .. ".Body", "读取响应体FAIL")
        end
    else
        log.error(tag .. ".result", "FAIL")
        log.error(tag .. ".prompt", prompt)
    end
end

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("HttpTest","成功访问网络, Http测试开始")
        local serverAddress = "wiki.airm2m.com:48080"
        local count = 1
        local testCookie = string.rep("1234567890asdfghjklp", 50)
        while true do
            -- Http GET 请求测试
            if LuaTaskTestConfig.httpTest.getTest then
                log.info("HttpTest.GetTest", "第" .. count .. "次")
                http.request("GET", serverAddress .. "/?test1=1&test2=22&test3=333&test4=" .. string.urlEncode("四四四四") .. "&test5=FiveFiveFiveFiveFive&test6=" .. string.rawurlEncode("ろくろくろくろくろくろく"), nil, nil, nil, nil, getTestCb)
                sys.wait(waitTime)
            end

            -- Http GET 请求测试(waitTest)
            if LuaTaskTestConfig.httpTest.getWaitTest then
                log.info("HttpTest.GetWaitTest", "第" .. count .. "次")
                http.request("GET", serverAddress .. "/waitTest", nil, nil, nil, 10000, getWaitTestCb)
                sys.wait(waitTime)
            end

            -- Http GET 请求301重定向测试
            if LuaTaskTestConfig.httpTest.get301Test then
                log.info("HttpTest.Get301Test", "第" .. count .. "次")
                http.request("GET", serverAddress .. "/redirect301", nil, nil, nil, nil, get301TestCb)
                sys.wait(waitTime)
            end

            -- Http GET 请求302重定向测试
            if LuaTaskTestConfig.httpTest.get302Test then
                log.info("HttpTest.Get302Test", "第" .. count .. "次")
                http.request("GET", serverAddress .. "/redirect302", nil, nil, nil, nil, get302TestCb)
                sys.wait(waitTime)
            end
            
            -- Https Get 请求测试（服务端证书验证_单向认证）
            if LuaTaskTestConfig.httpTest.getTestWithCA then
                log.info("HttpTest.GetTestWithCA", "第" .. count .. "次")
                http.request("GET", "https://www.baidu.com", {caCert = "ca.cer"}, nil, nil, nil, getTestWithCACb)
                sys.wait(waitTime)
            end

            -- Https Get 请求测试（服务端客户端证书验证_双向认证）
            if LuaTaskTestConfig.httpTest.getTestWithCAAndKey then
                log.info("HttpTest.GetTestWithCAAndKey","第" .. count .. "次")
                http.request("GET", "https://36.7.87.100:4434",{caCert="ca.crt",clientCert="client.crt",clientKey="client.key"},nil,nil,nil,GetTestWithCAAndKeyCb)
                sys.wait(waitTime)
            end

            -- Https Get 请求测试（保存结果到文件,文件较大）
            if LuaTaskTestConfig.httpTest.getTestAndSaveToBigFile then
                log.info("创建文件前可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
                if rtos.make_dir("/Jeremy") then
                    log.info("HttpTest.GetTestAndSaveToBigFile.makeDir", "SUCCESS")
                else
                    log.error("HttpTest.GetTestAndSaveToBigFile.makeDir", "FAIL")
                end
                log.info("HttpTest.GetTestAndSaveToBigFile", "第" .. count .. "次")
                http.request("GET", serverAddress .. "/download/600K", nil, nil, nil, nil, getTestAndSaveToBigFileCb, "/Jeremy/600K")
                sys.wait(waitTime)
            end

            -- Https Get 请求测试（保存结果到文件,文件较小）
            if LuaTaskTestConfig.httpTest.getTestAndSaveToSmallFile then
                log.info("创建文件前可用空间 " .. rtos.get_fs_free_size() .. " Bytes")
                if rtos.make_dir("/Jeremy") then
                    log.info("HttpTest.GetTestAndSaveToSmallFile.makeDir", "SUCCESS")
                else
                    log.error("HttpTest.GetTestAndSaveToSmallFile.makeDir", "FAIL")
                end
                log.info("HttpTest.GetTestAndSaveToSmallFile", "第" .. count .. "次")
                http.request("GET", serverAddress .. "/download/2K", nil, nil, nil, nil, getTestAndSaveToSmallFileCb, "/Jeremy/2K")
                sys.wait(waitTime)
            end

            -- Https Post 请求测试(/)
            if LuaTaskTestConfig.httpTest.postTest then
                log.info("HttpTest.PostTest", "第" .. count .. "次")
                http.request("POST", serverAddress .. "/", nil, nil, "PostTest", nil, postTestCb)
                sys.wait(waitTime)
            end

            -- Https Post 请求测试(TestJson)
            if LuaTaskTestConfig.httpTest.postJsonTest then
                log.info("HttpTest.PostJsonTest", "第" .. count .. "次")
                local testJson = {
                    ["imei"] = "123456789012345",
                    ["mcc"] = "460",
                    ["mnc"] = "0",
                    ["lac"] = "21133",
                    ["ci"] = "52365",
                    ["hex"] = "10"
                }
                http.request(
                    "POST",
                    serverAddress .. "/postJsonTest",
                    nil,
                    {
                        ["Content-Type"] = "application/json",
                    },
                    json.encode(testJson),
                    nil,
                    postJsonTestCb
                )
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（自定义Head）
            if LuaTaskTestConfig.httpTest.postTestWithUserHead then
                log.info("HttpTest.PostTestWithUserHead", "第" .. count .. "次")
                http.request(
                    "POST",
                    serverAddress .. "/withUserHead",
                    nil,
                    {
                        ["Connection"] = "close",
                        ["UserHead"] = "PostTestWithUserHead",
                        ["Cookie"] = testCookie,
                        ["User-Agent"] = "AirM2M",
                        ["Authorization"] = "Basic " .. crypto.base64_encode("123:456", ("123:456"):len())
                    },
                    nil,
                    nil,
                    postTestWithUserHeadCb
                )
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（octet-stream）
            if LuaTaskTestConfig.httpTest.postTestWithOctetStream then
                log.info("HttpTest.PostTestWithOctetStream", "第" .. count .. "次")
                http.request(
                    "POST",
                    serverAddress .. "/withOctetStream",
                    nil,
                    {
                        ["Content-Type"] = "application/octet-stream",
                        ["Connection"] = "keep-alive",
                        ["MD5"] = crypto.md5("/lua/logo_color.png", "file")
                    },
                    {
                        [1] = {
                                ["file"] = "/lua/logo_color.png"
                              }
                    },
                    nil,
                    postTestWithOctetStreamCb
                )
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（postTestWithFormData）
            if LuaTaskTestConfig.httpTest.postTestWithMultipartFormData then
                log.info("HttpTest.PostTestWithMultipartFormData", "第" .. count .. "次")
                postTestWithMultipartFormData(
                    serverAddress .. "/uploadFile",
                    nil,
                    {
                        texts = 
                        {
                            ["imei"] = "862991234567890",
                            ["time"] = "20180802180345",
                            ["md5"] = crypto.md5("/lua/logo_color.png", "file")
                        },

                        files =
                        {
                            ["FormDataUploadFile"] = "/lua/logo_color.png"
                        }
                    },
                    nil,
                    postTestWithMultipartFormDataCb
                )
                sys.wait(waitTime)
            end

            -- Https Post 请求测试（withxwwwformurlencoded）
            if LuaTaskTestConfig.httpTest.postTestWithXwwwformurlencoded then
                log.info("HttpTest.PostTestWithXwwwformurlencoded", "第" .. count .. "次")
                http.request(
                    "POST",
                    serverAddress .. "/withxwwwformurlencoded",
                    nil,
                    {
                        ["Content-Type"] = "application/x-www-form-urlencoded",
                    },
                    urlencodeTab(
                        {
                            content = "x-www-form-urlencoded Test",
                            author = "LuatTest",
                            email = "yanjunjie@airm2m.com",
                            userName = "yanjunjie",
                            passwd = "1234567890!@#$%^&*()"
                        }
                    ),
                    nil,
                    postTestWithXwwwformurlencodedCb
                )
                sys.wait(waitTime)
            end

            -- Https HEAD 请求测试（/）
            if LuaTaskTestConfig.httpTest.headTest then
                log.info("HttpTest.headTest", "第" .. count .. "次")
                http.request("HEAD", serverAddress, nil, nil, nil, nil, headTestCb)
                sys.wait(waitTime)
            end

            -- Https PUT 请求测试（/）
            if LuaTaskTestConfig.httpTest.putTest then
                log.info("HttpTest.putTest", "第" .. count .. "次")
                http.request("PUT", serverAddress, nil, nil, "putTest", nil, putTestCb)
                sys.wait(waitTime)
            end

            -- Https DELETE 请求测试（/）
            if LuaTaskTestConfig.httpTest.deleteTest then
                log.info("HttpTest.deleteTest", "第" .. count .. "次")
                http.request("DELETE", serverAddress, nil, nil, "deleteTest", nil, deleteTestCb)
                sys.wait(waitTime)
            end

            count = count + 1
        end
    end
)
