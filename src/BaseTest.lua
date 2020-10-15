-- BaseTest
-- Author:LuatTest
-- CreateDate:20201013
-- UpdateDate:20201013

module(..., package.seeall)

-- 测试配置 设置为true代表开启此项测试
local baseTestConfig = {
    adcTest    = false,
    bitTest    = false,
    packTest   = false,
    stringTest = false,
    commonTest = false,
    miscTest   = false,
    netTest    = false,
    tableTest  = true
}

local loopTime = 10000

-- ADC测量精度(10bit，电压测量范围为0到1.85V，分辨率为1850/1024=1.8MV，测量精度误差为20MV)
local function getAdcVal()

    --ADC2接口用来读取电压
    local ADC2 = 2
    local ADC3 = 3

    -- 读取adc
    -- adcval为number类型，表示adc的原始值，无效值为0xFFFF
    -- voltval为number类型，表示转换后的电压值，单位为毫伏，无效值为0xFFFF
    local adcval,voltval

    adcval,voltval = adc.read(ADC2)
    log.info("AdcTest.ADC2.read", adcval, voltval)

    adcval,voltval = adc.read(ADC3)
    log.info("AdcTest.ADC3.read", adcval, voltval)
end

if baseTestConfig.adcTest == true then
    -- 开启对应的adc通道
    adc.open(2)
    adc.open(3)
    -- 定时每秒读取adc值
    sys.timerLoopStart(getAdcVal, loopTime)
end

-- BitTest
local function bitTest()
    --参数是位数，作用是1向左移动两位
    -- 0001 -> 0100 
    log.info("BitTest.bit", bit.bit(2))
    
    -- 测试位数是否被置1
    --第一个参数是是测试数字，第二个是测试位置。从右向左数0到7。是1返回true，否则返回false
    -- 0101
    log.info("BitTest.isset", bit.isset(5, 0))
    log.info("BitTest.isset", bit.isset(5, 1))
    log.info("BitTest.isset", bit.isset(5, 2))
    log.info("BitTest.isset", bit.isset(5, 3))
    
    -- 测试位数是否被置0
    log.info("BitTest.isclear", bit.isclear(5, 0))
    log.info("BitTest.isclear", bit.isclear(5, 1))
    log.info("BitTest.isclear", bit.isclear(5, 2))
    log.info("BitTest.isclear", bit.isclear(5, 3))
    
    --在相应的位数置1
    -- 0000 -> 1111
    log.info("BitTest.set", bit.set(0, 0, 1, 2, 3))
    
    --在相应的位置置0
    -- 0101 -> 0000
    log.info("BitTest.clear", bit.clear(5, 0, 2))
    
    --按位取反
    -- 0101 -> 1010
    log.info("BitTest.bnot", bit.bnot(5))
    
    --与
    -- 0001 && 0001 -> 0001
    log.info("BitTest.band", bit.band(1, 1))
    
    --或
    -- 0001 | 0010 -> 0011
    log.info("BitTest.bor", bit.bor(1, 2))
    
    --异或,相同为0，不同为1
    -- 0001 ⊕ 0010 -> 0011
    log.info("BitTest.bxor", bit.bxor(1, 2))
    
    --逻辑左移
    -- 0001 -> 0100
    log.info("BitTest.lshift", bit.lshift(1, 2))
    
    --逻辑右移，“001”
    -- 0100 -> 0001
    log.info("BitTest.rshift", bit.rshift(4, 2))
    
    --算数右移，左边添加的数与符号有关
    -- 0010 -> 0000
    log.info("BitTest.arshift", bit.arshift(2, 2))
end

if baseTestConfig.bitTest == true then
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

if baseTestConfig.packTest == true then
    sys.timerLoopStart(packTest, loopTime)
end
        
local function stringTest()

    local testStr = "Luat is very NB"

    log.info("StringTest.Upper", string.upper(testStr))
    log.info("StringTest.Lower", string.lower(testStr))

    --第一个参数是目标字符串，第二个参数是标准字符串，第三个是待替换字符串,打印出"luat great"
    log.info("StringTest.Gsub", string.gsub(testStr, "Luat", "AirM2M"))

    --打印出目标字符串在查找字符串中的首尾位置
    log.info("StringTest.Find", string.find(testStr, "NB"))

    log.info("StringTest.Reverse", string.reverse(testStr))

    local i = 12345
    
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

    log.info("String.Utf8Len", string.utf8Len("Luat中国a"))

    local table1 = string.utf8ToTable("中国2018")

    for k, v in pairs(table1) do
        log.info("String.Utf8ToTable", k, v)
    end

    log.info("String.RawurlEncode", string.rawurlEncode("####133"))
    log.info("String.RawurlEncode", string.rawurlEncode("中国2018"))

    log.info("String.UrlEncode", string.urlEncode("####133"))
    log.info("String.UrlEncode", string.urlEncode("中国2018"))

    log.info("String.FormatNumberThousands", string.formatNumberThousands(1234567890))

    local table2 = string.split("Luat,is,very,nb", ",")

    for k, v in pairs(table2) do
        log.info("String.Split", k, v)
    end

end

if baseTestConfig.stringTest == true then
    sys.timerLoopStart(stringTest, loopTime)
end

local function commonTest()
    log.info("CommonTest.ucs2ToAscii", common.ucs2ToAscii("0031003200330034"))
    log.info("CommonTest.nstrToUcs2Hex", common.nstrToUcs2Hex("+1234"))
    log.info("CommonTest.numToBcdNum", common.numToBcdNum("8618126324567"))
    log.info("CommonTest.bcdNumToNum", common.bcdNumToNum(string.fromHex("688121364265f7")))
    log.info("CommonTest.ucs2ToGb2312", common.ucs2ToGb2312(string.fromHex("1162")))
    log.info("CommonTest.gb2312ToUcs2", string.toHex(common.gb2312ToUcs2(string.fromHex("CED2"))))
    log.info("CommonTest.ucs2beToGb2312", common.ucs2beToGb2312(string.fromHex("6211")))
    log.info("CommonTest.gb2312ToUcs2be", string.toHex(common.gb2312ToUcs2be(string.fromHex("CED2"))))
    log.info("CommonTest.ucs2ToUtf8", string.toHex(common.ucs2ToUtf8(string.fromHex("1162"))))
    log.info("CommonTest.utf8ToUcs2", string.toHex(common.utf8ToUcs2(string.fromHex("E68891"))))
    log.info("CommonTest.ucs2beToUtf8", string.toHex(common.ucs2beToUtf8(string.fromHex("6211"))))
    log.info("CommonTest.utf8ToUcs2be", string.toHex(common.utf8ToUcs2be(string.fromHex("E68891"))))
    log.info("CommonTest.utf8ToGb2312", common.utf8ToGb2312(string.fromHex("E68891")))
    log.info("CommonTest.gb2312ToUtf8", common.gb2312ToUtf8(string.fromHex("CED2")))

    local table1 = common.timeZoneConvert(2020, 10, 14, 11, 24, 25, 8, 8)
    for k, v in pairs(table1) do
        log.info("CommonTest.timeZoneConvert", k, v)
    end
end

if baseTestConfig.commonTest == true then
    sys.timerLoopStart(commonTest, loopTime)
end

local function miscTest()
    -- misc.setClock({year=2017, month=2, day=14, hour=14, min=2, sec=58})
    local table1 = misc.getClock()
    for k, v in pairs(table1) do
        log.info("MiscTest.GetClock", k, v)
    end
    log.info("MiscTest.GetWeek", misc.getWeek())
    log.info("MiscTest.GetCalib", misc.getCalib())
    misc.setSn("Jeremy", function () log.info("MiscTest.SetSnCb", "SUCCESS") end)
    log.info("MiscTest.GetSn", misc.getSn())
    log.info("MiscTest.GetImei", misc.getImei())
    log.info("MiscTest.GetVbatt", misc.getVbatt())
    log.info("MiscTest.GetMuid", misc.getMuid())
    -- 通道0，频率为50000Hz，占空比为0.2：
    misc.openPwm(0,500,100)
    log.info("MiscTest.OpenPwm.0.Open", "SUCCESS")
    -- 通道1，时钟周期为500ms，高电平时间为125毫秒：
    misc.openPwm(1,2,8)
    log.info("MiscTest.OpenPwm.1.Open", "SUCCESS")

    sys.wait(loopTime)

    misc.closePwm(0)
    log.info("MiscTest.OpenPwm.0.Close", "SUCCESS")
    misc.closePwm(1)
    log.info("MiscTest.OpenPwm.1.Close", "SUCCESS")
end

if baseTestConfig.miscTest == true then
    sys.timerLoopStart(miscTest, loopTime)
end

local function netTest()
    net.switchFly(true)
    log.info("NetTest.SwitchFly", "飞行模式打开")
    sys.wait(5000)
    net.switchFly(false)
    log.info("NetTest.SwitchFly", "飞行模式关闭")

end

if baseTestConfig.netTest == true then
    sys.timerLoopStart(netTest, loopTime)
end

local function tableTest()
    local fruits = {"banana","orange","apple"}

    log.info("普通连接后的字符串 ",table.concat(fruits))
    log.info("指定连接字符连接后的字符串 ",table.concat(fruits,", "))
    log.info("指定索引连接后的字符串 ",table.concat(fruits,", ", 2,3))

    table.insert(fruits,"mango")
    log.info("索引为4的元素为 ", fruits[4])
    table.insert(fruits,2,"grapes")
    log.info("索引为2的元素为 ", fruits[2])
    log.info("最后一个元素为 ",fruits[5])

    lastest = table.remove(fruits)
    log.info("移除的最后一个元素为 ", lastest)
    firstest = table.remove(fruits, 1)
    log.info("移除的第一个元素为 ", firstest)
end

if baseTestConfig.tableTest == true then
    sys.timerLoopStart(tableTest, loopTime)
end