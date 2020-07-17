-- HttpTest
-- Author LuatTest
-- CreateDate:20200716
-- UpdateDate:20200716

module(...,package.seeall)

require"http"

--multipart/form-data封装函数
local function postMultipartFormData(url,cert,params,timeout,cbFnc,rcvFileName)
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

-- 普通回调1
local function cbFunc1(result,prompt,head,body)
    if result then
        log.info("HttpTest.cbFunc1.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFunc1.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFunc1.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFunc1.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFunc1.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.cbFunc1.Body","body="..body)
        log.info("HttpTest.cbFunc1.Body","bodyLen="..body:len())
        if body=="LuatHttpTestServerGetTestOK" then
            log.info("HttpTest.cbFunc1","getTestPass!!!")
        end
    end
end

-- 普通回调2
local function cbFunc2(result,prompt,head,body)
    if result then
        log.info("HttpTest.cbFunc2.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFunc2.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFunc2.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFunc2.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFunc2.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.cbFunc2.Body","body="..body)
        log.info("HttpTest.cbFunc2.Body","bodyLen="..body:len())
    end
end

-- 普通回调3
local function cbFunc3(result,prompt,head,body)
    if result then
        log.info("HttpTest.cbFunc3.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFunc3.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFunc3.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFunc3.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFunc3.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.cbFunc3.Body","body="..body)
        log.info("HttpTest.cbFunc3.Body","bodyLen="..body:len())
    end
end

-- 普通回调4
local function cbFunc4(result,prompt,head,body)
    if result then
        log.info("HttpTest.cbFunc4.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFunc4.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFunc4.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFunc4.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFunc4.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.cbFunc4.Body","body="..body)
        log.info("HttpTest.cbFunc4.Body","bodyLen="..body:len())
    end
end

-- 普通回调5
local function cbFunc5(result,prompt,head,body)
    if result then
        log.info("HttpTest.cbFunc5.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFunc5.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFunc5.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFunc5.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFunc5.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.cbFunc5.Body","body="..body)
        log.info("HttpTest.cbFunc5.Body","bodyLen="..body:len())
    end
end

-- 普通回调6
local function cbFunc6(result,prompt,head,body)
    if result then
        log.info("HttpTest.cbFunc6.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFunc6.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFunc6.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFunc6.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFunc6.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.cbFunc6.Body","body="..body)
        log.info("HttpTest.cbFunc6.Body","bodyLen="..body:len())
    end
end

-- 普通回调7
local function cbFunc6(result,prompt,head,body)
    if result then
        log.info("HttpTest.cbFunc7.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFunc7.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFunc7.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFunc7.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFunc7.Head",k.." : "..v)
        end
    end
    if result and body then
        log.info("HttpTest.cbFunc7.Body","body="..body)
        log.info("HttpTest.cbFunc7.Body","bodyLen="..body:len())
    end
end

-- 处理文件回调
local function cbFuncFile(result,prompt,head,filePath)
    if result then
        log.info("HttpTest.cbFuncFile.result","Http请求成功:",result)
    else
        log.info("HttpTest.cbFuncFile.result","Http请求失败:",result)
    end
    log.info("HttpTest.cbFuncFile.prompt","Http状态码:",prompt)
    if result and head then
        log.info("HttpTest.cbFuncFile.Head","遍历响应头")
        for k,v in pairs(head) do
            log.info("HttpTest.cbFuncFile.Head",k.." : "..v)
        end
    end
    if result and filePath then
        log.info("HttpTest.cbFuncFile.filePath", filePath)
        local size = io.fileSize(filePath)
        log.info("HttpTest.cbFuncFile.fileSize","fileSize="..size)
        
        --输出文件内容，如果文件太大，一次性读出文件内容可能会造成内存不足，分次读出可以避免此问题
        if size<=4096 then
            log.info("HttpTest.cbFuncFile.fileContent",io.readFile(filePath))
        else
			log.info("HttpTest.cbFuncFile.fileContent", filePath.."文件过大")
        end
    end
    --文件使用完之后，如果以后不再用到，需要自行删除
    if filePath then 
        os.remove(filePath)
        log.info("HttpTest.cbFuncFile.fileDelete", filePath.." deletion completed")
    end
end

sys.taskInit(
    function()
        sys.waitUntil("IP_READY_IND")
        log.info("HttpTest","成功访问网络,Http测试开始")
        local serverAddress = "wiki.airm2m.com:58080"
        local count = 1
        while true do
            -- Http GET 请求测试
            log.info("HttpTest.GetTest","第"..count.."次")
            http.request("GET",serverAddress,nil,nil,nil,nil,cbFunc1)
            sys.wait(10000)
            
            -- Https Get 请求测试（服务端证书验证）
            log.info("HttpTest.GetTestWithCA","第"..count.."次")
            http.request("GET","https://www.baidu.com",{caCert="ca.cer"},nil,nil,nil,cbFunc2)
            sys.wait(10000)

            -- Https Get 请求测试（保存结果到文件,文件较大）
            log.info("HttpTest.GetTestAndSaveToBigFile","第"..count.."次")
            http.request("GET","https://www.baidu.com",{caCert="ca.cer"},nil,nil,nil,cbFuncFile,"index.html")
            sys.wait(10000)

            -- Https Get 请求测试（保存结果到文件,文件较小）
            log.info("HttpTest.GetTestAndSaveToSmallFile","第"..count.."次")
            http.request("GET","www.lua.org",nil,nil,nil,nil,cbFuncFile,"index.html")
            sys.wait(10000)

            -- Https Post 请求测试(/)
            log.info("HttpTest.PostTest","第"..count.."次")
            http.request("POST",serverAddress.."/",nil,nil,"PostTest!",nil,cbFunc3)
            sys.wait(10000)

            -- Https Post 请求测试(getContentLength)
            log.info("HttpTest.PostTest","第"..count.."次")
            http.request("POST",serverAddress.."/getContentLength",nil,nil,"PostTest!",nil,cbFunc4)
            sys.wait(10000)

            -- Https Post 请求测试（自定义Head）
            log.info("HttpTest.UserHead","第"..count.."次")
            http.request("POST",serverAddress.."/withUserHead",nil,{UserHead="Jeremy"},nil,nil,cbFunc5)
            sys.wait(10000)

            -- Https Post 请求测试（octet-stream）
            log.info("HttpTest.postTest","第"..count.."次")
            http.request("POST",serverAddress.."/withOctetStream",nil,{['Content-Type']="application/octet-stream",['Connection']="keep-alive"},{[1]={['file']="/lua/http.lua"}},nil,cbFunc6)
            sys.wait(10000)

            -- Https Post 请求测试（postTestWithFormData）
            log.info("HttpTest.postTest","第"..count.."次")
            postMultipartFormData(
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
                        ["file"] = "/lua/http.lua"
                    }
                },
                nil,
                cbFunc7
            )
            sys.wait(10000)

            -- Https Post 请求测试（withxwwwformurlencoded）
            log.info("HttpTest.postTest","第"..count.."次")
            http.request("POST",serverAddress.."/withxwwwformurlencoded",nil,
            {
                ["Content-Type"]="application/x-www-form-urlencoded",
            },
            urlencodeTab({content="x-www-form-urlencoded Test!", author="Jeremy"}),nil,cbFunc8)
            sys.wait(10000)

            count = count + 1
        end
    end
)
