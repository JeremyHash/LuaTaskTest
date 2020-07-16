-- HttpTest
-- Author LuatTest
-- CreateDate:20200716
-- UpdateDate:20200716

module(...,package.seeall)

require"http"

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
        count = 1
        while true do
            -- Http GET 请求测试
            log.info("HttpTest.GetTest","第"..count.."次")
            http.request("GET","www.lua.org",nil,nil,nil,nil,cbFunc1)
            sys.wait(2000)
            
            -- Https Get 请求测试（服务端证书验证）
            log.info("HttpTest.GetTestWithCA","第"..count.."次")
            http.request("GET","https://www.baidu.com",{caCert="ca.cer"},nil,nil,nil,cbFunc2)
            sys.wait(2000)

            -- Https Get 请求测试（保存结果到文件,文件较大）
            log.info("HttpTest.GetTestAndSaveToBigFile","第"..count.."次")
            http.request("GET","https://www.baidu.com",{caCert="ca.cer"},nil,nil,nil,cbFuncFile,"index.html")
            sys.wait(2000)

            -- Https Get 请求测试（保存结果到文件,文件较小）
            log.info("HttpTest.GetTestAndSaveToSmallFile","第"..count.."次")
            http.request("GET","www.lua.org",nil,nil,nil,nil,cbFuncFile,"index.html")
            sys.wait(2000)

            -- Https Post 请求测试
            log.info("HttpTest.PostTest","第"..count.."次")
            http.request("POST","wiki.airm2m.com:48080/getContentLength",nil,nil,"PostTest!",nil,cbFunc3)
            sys.wait(2000)

            count = count + 1
        end
    end
)

--http.request("POST","36.7.87.100:6500",nil,{head1="value1"},{[1]="begin\r\n",[2]={file="/lua/http.lua"},[3]="end\r\n"},30000,cbFnc)
--http.request("POST","http://lq946.ngrok.xiaomiqiu.cn/",nil,nil,{[1]="begin\r\n",[2]={file_base64="/lua/http.lua"},[3]="end\r\n"},30000,cbFnc)

--如下示例代码是利用文件流模式，上传录音文件的demo，使用的URL是随意编造的
--[[
http.request("POST","www.test.com/postTest?imei=1&iccid=2",nil,
         {['Content-Type']="application/octet-stream",['Connection']="keep-alive"},
         {[1]={['file']="/RecDir/rec001"}},
         30000,cbFnc)
]]


--如下示例代码是利用x-www-form-urlencoded模式，上传3个参数，通知openluat的sms平台发送短信
--[[
function urlencodeTab(params)
    local msg = {}
    for k, v in pairs(params) do
        table.insert(msg, string.urlEncode(k) .. '=' .. string.urlEncode(v))
        table.insert(msg, '&')
    end
    table.remove(msg)
    return table.concat(msg)
end

http.request("POST","http://api.openluat.com/sms/send",nil,
         {
             ["Authorization]"="Basic jffdsfdsfdsfdsfjakljfdoiuweonlkdsjdsjapodaskdsf",
             ["Content-Type"]="application/x-www-form-urlencoded",
         },
         urlencodeTab({content="您的煤气检测处于报警状态，请及时通风处理！", phone="13512345678", sign="短信发送方"}),
         30000,cbFnc)
]]
         
         


--如下示例代码是利用multipart/form-data模式，上传2参数和1个照片文件
--[[
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

postMultipartFormData(
    "1.202.80.121:4567/api/uploadimage",
    nil,
    {
        texts = 
        {
            ["imei"] = "862991234567890",
            ["time"] = "20180802180345"
        },
        
        files =
        {
            ["logo_color.jpg"] = "/ldata/logo_color.jpg"
        }
    },
    60000,
    cbFnc
)
]]