-- BaseTest
-- Author:LuatTest
-- CreateDate:20201013
-- UpdateDate:20201025

module(..., package.seeall)

-- 测试配置 设置为true代表开启此项测试
local baseTestConfig = {
    adcTest      = true,
    bitTest      = false,
    packTest     = false,
    stringTest   = false,
    commonTest   = false,
    miscTest     = false,
    netTest      = false,
    ntpTest      = false,
    nvmTest      = false,
    tableTest    = false,
    pmTest       = false,
    powerKeyTest = false,
    rilTest      = false,
    simTest      = false,
    sysTest      = false,
    jsonTest     = false,
    rtosTest     = false,
    mathTest     = false,
    pbTest       = false
}

local loopTime = 10000

-- ADC测量精度(10bit，电压测量范围为0到1.85V，分辨率为1850/1024=1.8MV，测量精度误差为20MV)
local function getAdcVal()

    local ADC2 = 2
    local ADC3 = 3

    -- 读取adc
    -- adcval为number类型，表示adc的原始值，无效值为0xFFFF
    -- voltval为number类型，表示转换后的电压值，单位为毫伏，无效值为0xFFFF
    local adcval, voltval

    adc.open(ADC2)
    adc.open(ADC3)

    adcval, voltval = adc.read(ADC2)
    log.info("AdcTest.ADC2.read", adcval, voltval)

    adcval, voltval = adc.read(ADC3)
    log.info("AdcTest.ADC3.read", adcval, voltval)

    adc.colse(ADC2)
    adc.colse(ADC3)
end

if baseTestConfig.adcTest then
    sys.timerLoopStart(getAdcVal, loopTime)
end

-- BitTest
local function bitTest()
    --参数是位数，作用是1向左移动两位
    -- 0001 -> 0100 
    for i = 1, 32 do
        log.info("BitTest.bit", bit.bit(i))
    end
    
    -- 测试位数是否被置1
    --第一个参数是是测试数字，第二个是测试位置。从右向左数0到7。是1返回true，否则返回false
    -- 0101
    -- log.info("BitTest.isset", bit.isset(5, 0))
    -- log.info("BitTest.isset", bit.isset(5, 1))
    -- log.info("BitTest.isset", bit.isset(5, 2))
    -- log.info("BitTest.isset", bit.isset(5, 3))
    -- TODO for i = 1, 32
    log.info("BitTest.isset", bit.isset(0xFFFFFFFF, 1))
    log.info("BitTest.isset", bit.isset(0x00000000, 1))
    
    -- 测试位数是否被置0
    -- TODO 和isset一样
    log.info("BitTest.isclear", bit.isclear(5, 0))
    log.info("BitTest.isclear", bit.isclear(5, 1))
    log.info("BitTest.isclear", bit.isclear(5, 2))
    log.info("BitTest.isclear", bit.isclear(5, 3))
    
    --在相应的位数置1
    -- 0000 -> 1111
    -- TODO 设置的位置不按顺序
    -- TODO 循环置1 少传位置 多传位置
    log.info("BitTest.set", bit.set(0, 0, 1, 2, 3))
    
    --在相应的位置置0
    -- 0101 -> 0000
    -- TODO 和置1相同
    log.info("BitTest.clear", bit.clear(5, 0, 2))
    
    --按位取反
    -- 0101 -> 1010
    -- TODO 0xFFFFFFF 0x00000000 0xF0F0F0F0
    log.info("BitTest.bnot", bit.bnot(0x0101))
    
    --与
    -- 0001 && 0001 -> 0001
    -- TODO 0xFFFFFFFF &&  &&  三个数字相与
    log.info("BitTest.band", bit.band(1, 1))
    
    --或
    -- 0001 | 0010 -> 0011
    -- TODO 和与相同的修改
    log.info("BitTest.bor", bit.bor(1, 2))
    
    --异或,相同为0，不同为1
    -- 0001 ⊕ 0010 -> 0011
    -- TODO 同上
    log.info("BitTest.bxor", bit.bxor(1, 2))
    
    --逻辑左移
    -- 0001 -> 0100
    -- TODO 0x00000000 0xFFFFFFFF 
    log.info("BitTest.lshift", bit.lshift(1, 2))
    
    --逻辑右移，“001”
    -- 0100 -> 0001
    log.info("BitTest.rshift", bit.rshift(4, 2))
    
    --算数右移，左边添加的数与符号有关
    -- 0010 -> 0000
    -- TODO 0xFFFFFFFF 
    log.info("BitTest.arshift", bit.arshift(2, 2))
end

if baseTestConfig.bitTest then
    sys.timerLoopStart(bitTest, loopTime)
end
    
local function packTest()
    --[[将一些变量按照格式包装在字符串.'z'有限零字符串，'p'长字节优先，'P'长字符优先，
    'a'长词组优先，'A'字符串型，'f'浮点型,'d'双精度型,'n'Lua 数字,'c'字符型,'b'无符号字符型,'h'短型,'H'无符号短型
    'i'整形,'I'无符号整形,'l'长符号型,'L'无符号长型，">"表示大端，"<"表示小端。]]
    log.info("PackTest", string.toHex(pack.pack(">H", 0x3234)))
    log.info("PackTest", string.toHex(pack.pack("<H", 0x3234)))
    --字符串，无符号短整型，字节型，打包成二进制字符串。由于二进制不能输出，所以转化为十六进制输出。
    log.info("PackTest", string.toHex(pack.pack(">AHb", "LUAT", 100, 10)))
    --"LUAT\x00\x64\x0A"
    local stringtest = pack.pack(">AHb", "luat", 999, 10)
    --"nextpos"解析开始的位置，解析出来的第一个值val1，第二个val2，第三个val3，根据后面的格式解析
    --这里的字符串要截取出来，如果截取字符串，后面的短整型和一个字节的数都会被覆盖。
    nextpox1, val1, val2 = pack.unpack(string.sub(stringtest, 5, -1), ">Hb")
    --nextpox1表示解包后最后的位置，如果包的长度是3，nextpox1输出就是4。匹配输出999,10
    log.info("PackTest", nextpox1, val1, val2)
end

if baseTestConfig.packTest then
    sys.timerLoopStart(packTest, loopTime)
end
        
local function stringTest()

    local testStr = "Luat is very NB,NB (10086)"

    log.info("StringTest.Upper", string.upper(testStr))
    log.info("StringTest.Lower", string.lower(testStr))

    --第一个参数是目标字符串，第二个参数是标准字符串，第三个是待替换字符串,打印出"luat great"
    -- TODO 添加正则匹配的情况
    log.info("StringTest.Gsub", string.gsub(testStr, "Luat", "AirM2M"))

    --打印出目标字符串在查找字符串中的首尾位置
    -- TODO 搜索初始位置 plain
    log.info("StringTest.Find", string.find(testStr, "NB"))

    log.info("StringTest.Reverse", string.reverse(testStr))

    local i = 12345
    
    -- TODO %x %X
    log.info("StringTest.Format", string.format("This is %d test string : %s", i, testStr))

    --注意string.char或者string.byte只针对一个字节，数值不可大于256
    --将相应的数值转化为字符
    log.info("String.Char", string.char(33, 48, 49, 50, 97, 98, 99))

    --第一个参数是字符串，第二个参数是位置。功能是：将字符串中所给定的位置转化为数值
    log.info("String.Byte", string.byte("abc", 1))
    log.info("String.Byte", string.byte("abc", 2))
    log.info("String.Byte", string.byte("abc", 3))

    log.info("String.len", string.len(testStr))

    log.info("String.rep", string.rep(testStr, 2))
    
    --匹配字符串,加()指的是返回指定格式的字符串,截取字符串中的数字
    log.info("String.Match", string.match(testStr, "Luat (..) very NB"))

    --截取字符串，第二个参数是截取的起始位置，第三个是终止位置。
    log.info("String.Sub", string.sub(testStr, 1, 4))
   
    log.info("String.ToHex", string.toHex(testStr))
    log.info("String.ToHex", string.toHex(testStr, ","))
    
    log.info("String.FromHex", string.fromHex("313233616263"))

    -- log.info("String.ToValue", string.toValue("123abc"))

    -- TODO 增加一些外文字符的长度测试
    local utf8Len = string.utf8Len("Luat中国a")
    log.info("String.Utf8Len", utf8Len, utf8Len == 10)

    local table1 = string.utf8ToTable("中国2018")

    for k, v in pairs(table1) do
        log.info("String.Utf8ToTable", k, v)
    end

    -- TODO 增加测试字符串的复杂度
    log.info("String.RawurlEncode", string.rawurlEncode("####133"))
    log.info("String.RawurlEncode", string.rawurlEncode("中国2018"))

    log.info("String.UrlEncode", string.urlEncode("####133"))
    log.info("String.UrlEncode", string.urlEncode("中国2018"))

    log.info("String.FormatNumberThousands", string.formatNumberThousands(1234567890))

    local table2 = string.split("Luat,is,very,nb,", ",")

    for k, v in pairs(table2) do
        log.info("String.Split", k, v)
    end

end

if baseTestConfig.stringTest then
    sys.timerLoopStart(stringTest, loopTime)
end

local function commonTest()
    log.info("CommonTest.ucs2ToAscii", common.ucs2ToAscii("0030003100320033003400350036003700380039"))
    log.info("CommonTest.nstrToUcs2Hex", common.nstrToUcs2Hex("+0123456789+0123456789+0123456789+0123456789+0123456789"))
    log.info("CommonTest.numToBcdNum", string.toHex(common.numToBcdNum("8618126324567F")))
    log.info("CommonTest.bcdNumToNum", common.bcdNumToNum(string.fromHex("688121364265F7")))
    log.info("CommonTest.ucs2ToGb2312", common.ucs2ToGb2312(string.fromHex("xd98f2f66004e616755004300530032000f5cef7a167f017884768551b95b6c8f62633a4e470042003200330031003200167f017884764b6dd58b8551b95b")))
    log.info("CommonTest.gb2312ToUcs2", string.toHex(common.gb2312ToUcs2(string.fromHex("D5E2CAC7D2BBCCF555544638B1E0C2EBB5C4C4DAC8DDD7AABBBBCEAA55435332B1E0C2EBB5C4B2E2CAD4C4DAC8DD"))))
    log.info("CommonTest.ucs2beToGb2312", common.ucs2beToGb2312(string.fromHex("8fd9662f4e006761005500430053003259277aef7f167801768451855bb98f6c63624e3a0047004200320033003100327f16780176846d4b8bd551855bb9")))
    log.info("CommonTest.gb2312ToUcs2be", string.toHex(common.gb2312ToUcs2be(string.fromHex("D5E2CAC7D2BBCCF555544638B1E0C2EBB5C4C4DAC8DDD7AABBBBCEAA55435332B1E0C2EBB5C4B2E2CAD4C4DAC8DD"))))
    log.info("CommonTest.ucs2ToUtf8", common.ucs2ToUtf8(string.fromHex("d98f2f66004e61675500430053003200167f017884768551b95b6c8f62633a4e5500540046003800167f017884764b6dd58b8551b95b")))
    log.info("CommonTest.utf8ToUcs2", string.toHex(common.utf8ToUcs2("这是一条UTF8编码的内容转换为UCS2编码的测试内容")))
    log.info("CommonTest.ucs2beToUtf8", common.ucs2beToUtf8(string.fromHex("8fd9662f4e00676100550043005300327f167801768451855bb98f6c63624e3a00550054004600387f16780176846d4b8bd551855bb9")))
    log.info("CommonTest.utf8ToUcs2be", string.toHex(common.utf8ToUcs2be("这是一条UTF8编码的内容转换为UCS2大端编码的测试内容")))
    log.info("CommonTest.utf8ToGb2312", common.utf8ToGb2312("这是一条UTF8编码的内容转换为GB2312编码的测试内容"))
    log.info("CommonTest.gb2312ToUtf8", common.gb2312ToUtf8(string.fromHex("D5E2CAC7D2BBCCF5474232333132B1E0C2EBB5C4C4DAC8DDD7AABBBBCEAA55544638B1E0C2EBB5C4B2E2CAD4C4DAC8DD")))

    local table1 = common.timeZoneConvert(2020, 10, 14, 11, 24, 25, 8, 8)
    for k, v in pairs(table1) do
        log.info("CommonTest.timeZoneConvert", k, v)
    end
end

if baseTestConfig.commonTest then
    sys.timerLoopStart(commonTest, loopTime)
end

local function miscTest()
    -- misc.setClock({year=2017, month=2, day=14, hour=14, min=2, sec=58})
    local table1 = misc.getClock()
    for k, v in pairs(table1) do
        log.info("MiscTest.GetClock", k, v)
    end
    log.info("MiscTest.GetWeek", misc.getWeek())
    -- 获取校准标志
    log.info("MiscTest.GetCalib", misc.getCalib())
    -- TODO SN长度
    misc.setSn("Jeremy", function() log.info("MiscTest.SetSnCb", "SUCCESS") end)
    log.info("MiscTest.GetSn", misc.getSn())
    log.info("MiscTest.GetImei", misc.getImei())
    log.info("MiscTest.GetVbatt", misc.getVbatt())
    log.info("MiscTest.GetMuid", misc.getMuid())
    -- 通道0，频率为50000Hz，占空比为0.2：
    misc.openPwm(0, 500, 100)
    log.info("MiscTest.OpenPwm.0.Open", "SUCCESS")
    -- 通道1，时钟周期为500ms，高电平时间为125毫秒：
    misc.openPwm(1, 2, 8)
    log.info("MiscTest.OpenPwm.1.Open", "SUCCESS")

    -- sys.wait(loopTime)

    misc.closePwm(0)
    log.info("MiscTest.OpenPwm.0.Close", "SUCCESS")
    misc.closePwm(1)
    log.info("MiscTest.OpenPwm.1.Close", "SUCCESS")
end

if baseTestConfig.miscTest then
    sys.timerLoopStart(miscTest, loopTime)
end

if baseTestConfig.netTest == true then
    sys.taskInit(
        function()
            sys.waitUntil("IP_READY_IND")
            while true do
                net.switchFly(true)
                log.info("NetTest.SwitchFly", "打开飞行模式")
                sys.wait(10000)
                net.switchFly(false)
                log.info("NetTest.SwitchFly", "关闭飞行模式")
                -- TODO 查询到的NETMODE和实际情况是否一致（欠费卡 未注册的状态）
                log.info("NetTest.GetNetMode", net.getNetMode())
                log.info("NetTest.GetState", net.getState())
                log.info("NetTest.GetMcc", net.getMcc())
                log.info("NetTest.GetMnc", net.getMnc())
                log.info("NetTest.GetLac", net.getLac())
                log.info("NetTest.GetCi", net.getCi())
                log.info("NetTest.GetRssi", net.getRssi())
                log.info("NetTest.GetCellInfo", net.getCellInfo())
                log.info("NetTest.GetCellInfoExt", net.getCellInfoExt())
                log.info("NetTest.GetTa", net.getTa())
                -- net.getMultiCell(function(cells)
                --     for k, v in pairs(cells) do
                --         log.info("NetTest.GetMultiCell" .. k, v)
                --         if type(v) == "table" then
                --             for i, j in pairs(v) do
                --                 print(i, j)
                --             end
                --         end
                --     end
                -- end)
                log.info("NetTest.CengQueryPoll.开启查询", net.cengQueryPoll(10000))
                log.info("NetTest.CsqQueryPoll.开启查询", net.csqQueryPoll(10000))
                log.info("NetTest.StartQueryAll.开启查询", net.startQueryAll(10000))
                sys.wait(600000)
                log.info("NetTest.StopQueryAll.关闭查询", net.stopQueryAll())
                log.info("NetTest.SetEngMode.关闭工程模式", net.setEngMode(0))
                sys.wait(10000)
                log.info("NetTest.SetEngMode.开启工程模式", net.setEngMode(1))
            end
        end
    )
end

local function ntpTest()
    local ntpServers = ntp.getServers()
    for k, v in pairs(ntpServers) do
        log.info("NtpTest.NtpServer" .. k, v)
    end
    ntp.setServers({"www.baidu.com", "www.sina.com"})
    local ntpServers = ntp.getServers()
    for k, v in pairs(ntpServers) do
        log.info("NtpTest.NtpServer" .. k, v)
    end
    local ntpStatus = ntp.isEnd()
    log.info("NtpTest.Status", ntpStatus)
end

if baseTestConfig.ntpTest then
    sys.timerLoopStart(ntpTest, loopTime)
end

if baseTestConfig.nvmTest then
    sys.taskInit(
        function()
            require "Config"
            local count = 2
            local boolVal = true
            nvm.init("Config.lua")

            while true do
                log.info("NvmTest.StrPara", nvm.get("strPara"))
                log.info("NvmTest.NumPara", nvm.get("numPara"))
                log.info("NvmTest.BoolPara", nvm.get("boolPara"))
                local personTablePara = nvm.get("personTablePara")
                log.info("NvmTest.PersonTablePara", personTablePara[1], personTablePara[2], personTablePara[3])
                log.info("NvmTest.ScoreTablePara.chinese", nvm.gett("scoreTablePara", "chinese"))
                log.info("NvmTest.ScoreTablePara.math", nvm.gett("scoreTablePara", "math"))
                log.info("NvmTest.ScoreTablePara.english", nvm.gett("scoreTablePara", "english"))
                local table2 = nvm.gett("manyTablePara", "table2")
                for k, v in pairs(table2) do
                    log.info("NvmTest.manyTablePara.table2." .. k, v)
                end
                sys.wait(10000)
                table2.table23 = boolVal
                nvm.sett("manyTablePara", "table2", table2)
                nvm.set("strPara", "LuatTest" .. count)
                nvm.set("numPara", count)
                nvm.set("boolPara", boolVal)
                nvm.set("personTablePara", {"name" .. count, "age" .. count, "sex" .. count})
                nvm.sett("scoreTablePara", "chinese", count)
                nvm.flush()
                log.info("NvmTest.Flush", "SUCCESS")
                count = count + 1
                boolVal = not boolVal
                -- TODO BUG?
                nvm.restore()
            end
        end
    )
end

local function tableTest()
    local fruits = {"banana", "orange", "apple"}

    log.info("TableTest.Concat", table.concat(fruits))
    log.info("TableTest.Concat", table.concat(fruits, ", "))
    log.info("TableTest.Concat", table.concat(fruits,", ", 2, 3))

    table.insert(fruits, "mango")
    log.info("TableTest.Insert.4", fruits[4])
    table.insert(fruits, 2, "grapes")
    log.info("TableTest.Insert.2", fruits[2])
    log.info("TableTest.Insert.5",fruits[5])

    lastest = table.remove(fruits)
    log.info("TableTest.Remove", lastest)
    firstest = table.remove(fruits, 1)
    log.info("TableTest.Remove", firstest)
end

if baseTestConfig.tableTest then
    sys.timerLoopStart(tableTest, loopTime)
end

local function pmTest()
    log.info("PmTest.IsSleep", pm.isSleep())
    pm.wake("PmTest")
    log.info("PmTest.Wake", "SUCCESS")
    log.info("PmTest.IsSleep", pm.isSleep())
    pm.sleep("PmTest")
    log.info("PmTest.Sleep", "SUCCESS")
    log.info("PmTest.IsSleep", pm.isSleep())
end

if baseTestConfig.pmTest then
    sys.timerLoopStart(pmTest, loopTime)
end

local function longCb()
    log.info("PowerKeyTest", "LongCb")
    rtos.poweroff()
end

local function shortCb()
    log.info("PowerKeyTest", "ShortCb")
end

if baseTestConfig.powerKeyTest then
    powerKey.setup(3000, longCb, shortCb)
end

if baseTestConfig.rilTest then
    local rilTestCount = 1

    sys.taskInit(
        function()
            while true do
                log.info("RilTest.RilTestCount", "第" .. rilTestCount .. "次")
                ril.request("AT+CSQ")
                sys.wait(2000)
                ril.request("AT+CGDCONT?")
                sys.wait(2000)
                ril.request("AT+CGATT?")
                sys.wait(2000)
                ril.request("AT+EEMGINFO?")
                sys.wait(2000)
                rilTestCount = rilTestCount + 1
            end
        end
    )
end

local function simTest()
    log.info("SimTest.GetIccid", sim.getIccid())
    log.info("SimTest.GetImsi", sim.getImsi())
    log.info("SimTest.GetMcc", sim.getMcc())
    log.info("SimTest.GetMnc", sim.getMnc())
    log.info("SimTest.GetStatus", sim.getStatus())
    -- log.info("SimTest.GetType", sim.getType())
    -- sim.setQueryNumber(true)
    -- log.info("SimTest.SetQueryNumber", "SUCCESS")
    -- log.info("SimTest.GetNumber", sim.getNumber())
end

if baseTestConfig.simTest then
    sys.timerLoopStart(simTest, loopTime)
end

if baseTestConfig.sysTest then
    -- TODO timerSTOP timerIsActive
    sys.taskInit(
        function()
            sys.wait(5000)
            log.info("SysTest.Restart", "5秒后模块即将重启")
            sys.wait(5000)
            sys.restart("重启测试")
        end
    )
end

local function jsonTest()
    local torigin =
    {
        KEY1 = "VALUE1",
        KEY2 = "VALUE2",
        KEY3 = "VALUE3",
        KEY4 = "VALUE4",
        KEY5 = {KEY5_1 = "VALUE5_1", KEY5_2 = "VALUE5_2"},
        KEY6 = {1, 2, 3},
    }

    local jsondata = json.encode(torigin)
    log.info("JsonTest.encode", jsondata)

    --{"KEY3":"VALUE3","KEY4":"VALUE4","KEY2":"VALUE2","KEY1":"VALUE1","KEY5":{"KEY5_2":"VALU5_2","KEY5_1":"VALU5_1"}},"KEY6":[1,2,3]}
    local origin = "{\"KEY3\":\"VALUE3\",\"KEY4\":\"VALUE4\",\"KEY2\":\"VALUE2\",\"KEY1\":\"VALUE1\",\"KEY5\":{\"KEY5_2\":\"VALUE5_2\",\"KEY5_1\":\"VALUE5_1\"},\"KEY6\":[1,2,3]}"
    local tjsondata, result, errinfo = json.decode(origin)
    if result and type(tjsondata) == "table" then
        log.info("JsonTest.decode KEY1", tjsondata["KEY1"])
        log.info("JsonTest.decode KEY2", tjsondata["KEY2"])
        log.info("JsonTest.decode KEY3", tjsondata["KEY3"])
        log.info("JsonTest.decode KEY4", tjsondata["KEY4"])
        log.info("JsonTest.decode KEY5", tjsondata["KEY5"]["KEY5_1"], tjsondata["KEY5"]["KEY5_2"])
        log.info("JsonTest.decode KEY6", tjsondata["KEY6"][1], tjsondata["KEY6"][2], tjsondata["KEY6"][3])
    else
        log.info("JsonTest.decode error", errinfo)
    end
end

if baseTestConfig.jsonTest then
    sys.timerLoopStart(jsonTest, loopTime)
end

local function rtosTest()
    -- TODO 多层路径
    local testPath = "/RtosTestPath"

    log.info("RtosTest.Poweron_reason", rtos.poweron_reason())

    if rtos.make_dir(testPath) then
        log.info("RtosTest.MakeDir", "SUCCESS")
    else
        log.info("RtosTest.MakeDir", "FAIL")
    end

    if rtos.remove_dir(testPath) then
        log.info("RtosTest.RemoveDir", "SUCCESS")
    else
        log.info("RtosTest.RemoveDir", "FAIL")
    end

    log.info("RtosTest.Toint64", string.toHex(rtos.toint64("12345678", "little")))
end

if baseTestConfig.rtosTest then
    sys.timerLoopStart(rtosTest, loopTime)
end

local function mathTest()
    log.info("MathTest.Abs", math.abs(-10086))
    log.info("MathTest.Ceil", math.ceil(101.456))
    log.info("MathTest.Floor", math.floor(101.456))
    log.info("MathTest.Fmod", math.fmod(10, 3))
    log.info("MathTest.Huge", math.huge)
    log.info("MathTest.Max", math.max(1, 2, 3, 4.15, 5.78))
    log.info("MathTest.Min", math.min(1, 2, 3, 4.15, 5.78))
    log.info("MathTest.MaxInteger", math.maxinteger)
    log.info("MathTest.MinInteger", math.mininteger)
    log.info("MathTest.Modf", math.modf(1.15))
    log.info("MathTest.Pi", math.pi)
    log.info("MathTest.Sqrt", math.sqrt(9))
    -- log.info("MathTest.ToInteger", math.tointeger(1.123))
    -- log.info("MathTest.Type", math.type(1))
    -- log.info("MathTest.Type", math.type(1.123))
    -- log.info("MathTest.Type", math.type("1.123"))
    -- log.info("MathTest.Ult", math.ult(1.1,2.2))
    -- log.info("MathTest.Ult", math.ult(2.2,1.1))
end

if baseTestConfig.mathTest then
    sys.timerLoopStart(mathTest, loopTime)
end

local function setStorageCb(result)
    if result then
        log.info("PbTest.SetStorageCb", "SUCCESS")
    else
        log.info("PbTest.SetStorageCb", "FAIL")
    end
end

local function deleteCb(result)
    if result then
        log.info("PbTest.DeleteCb", "SUCCESS")
    else
        log.info("PbTest.DeleteCb", "FAIL")
    end
end

local function writeCb(result)
    if result then
        log.info("PbTest.WriteCb", "SUCCESS")
    else
        log.info("PbTest.WriteCb", "FAIL")
    end
end

function readCb(result, name, number)
    if result then
        log.info("PbTest.ReadCb", "SUCCESS", name, number)
    else
        log.info("PbTest.ReadCb", "FAIL", name, number)
    end
end

if baseTestConfig.pbTest then
    sys.taskInit(
        function()
            local index = 1
            pb.setStorage("SM", setStorageCb)
            while true do
                sys.wait(5000)
                pb.delete(index, deleteCb)
                sys.wait(5000)
                pb.write(index, "LuatTest" .. index, "1234567890", writeCb)
                sys.wait(5000)
                pb.read(index, readCb)
                -- TODO 查询卡电话本容量 写满
                -- TODO LuaTask 库消息 doc 缺少说明 
                index = (index == 20) and 1 or (index + 1)
            end
        end
    )
end