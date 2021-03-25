-- GpioTest
-- Author:LuatTest
-- CreateDate:20200724
-- UpdateDate:20210324

module(..., package.seeall)

--[[
有些GPIO需要打开对应的ldo电压域才能正常工作，电压域和对应的GPIO关系如下
pmd.ldoset(x, pmd.LDO_VSIM1) -- GPIO 29、30、31

pmd.ldoset(x, pmd.LDO_VLCD) -- GPIO 0、1、2、3、4

pmd.ldoset(x, pmd.LDO_VMMC) -- GPIO 24、25、26、27、28
x=0时：关闭LDO
x=1时：LDO输出1.716V
x=2时：LDO输出1.828V
x=3时：LDO输出1.939V
x=4时：LDO输出2.051V
x=5时：LDO输出2.162V
x=6时：LDO输出2.271V
x=7时：LDO输出2.375V
x=8时：LDO输出2.493V
x=9时：LDO输出2.607V
x=10时：LDO输出2.719V
x=11时：LDO输出2.831V
x=12时：LDO输出2.942V
x=13时：LDO输出3.054V
x=14时：LDO输出3.165V
x=15时：LDO输出3.177V
]]

local gpio_8910_list = {0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31}

local gpio_led_list = {19, 18, 13, 9, 12, 10, 11, 23}

local gpio_in_functions = {}

local x = 2

-- pmd.ldoset(x, pmd.VLDO6)

pmd.ldoset(x, pmd.LDO_VSIM1) -- GPIO 29、30、31

pmd.ldoset(x, pmd.LDO_VLCD) -- GPIO 0、1、2、3、4

pmd.ldoset(x, pmd.LDO_VMMC) -- GPIO 24、25、26、27、28

local modType = LuaTaskTestConfig.modType

function gpioIntFnc(msg)
    --上升沿中断
    if msg == cpu.INT_GPIO_POSEDGE then
        log.info("GpioIntTest.msg", "上升")
    --下降沿中断
    else
        log.info("GpioIntTest.msg", "下降")
    end
end

local UP_DOWN_STATUS = pio.PULLDOWN

if LuaTaskTestConfig.gpioTest.gpioIntTest then
    if modType == "8910" then
        log.info("GpioIntTest", "初始化GPIO中断模式开始")
        for k, v in pairs(gpio_8910_list) do
            log.info("GpioIntTest", "初始化GPIO" .. v .. "中断模式")
            pins.setup(v, gpioIntFnc, UP_DOWN_STATUS)
        end
    elseif modType == "1802" or modType == "1802S" then
        pins.setup(10, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(11, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(17, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(18, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(20, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(21, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(22, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(23, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(24, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(25, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(26, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(27, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(28, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(29, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(30, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(31, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(32, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(33, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(34, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(35, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(36, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(37, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(38, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(39, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(40, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(41, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(42, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(49, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(50, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(51, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(52, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(61, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(62, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(63, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(64, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(65, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(66, gpioIntFnc, UP_DOWN_STATUS)
    end
end

if LuaTaskTestConfig.gpioTest.gpioInTest then
    local tag = "GpioInTest"
    if modType == "8910" then
        log.info(tag, "初始化GPIO输入模式开始")
        local count = 1
        for k, v in pairs(gpio_8910_list) do
            log.info(tag, "初始化GPIO" .. v .. "输入模式")
            gpio_in_functions[count] = pins.setup(v)
            count = count + 1
        end
    elseif modType == "1802" or modType == "1802S" then
        pins.setup(10, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(11, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(17, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(18, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(20, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(21, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(22, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(23, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(24, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(25, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(26, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(27, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(28, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(29, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(30, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(31, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(32, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(33, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(34, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(35, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(36, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(37, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(38, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(39, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(40, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(41, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(42, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(49, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(50, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(51, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(52, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(61, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(62, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(63, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(64, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(65, gpioIntFnc, UP_DOWN_STATUS)
        pins.setup(66, gpioIntFnc, UP_DOWN_STATUS)
    end
    sys.taskInit(
        function()
            while true do
                for k, v in gpio_in_functions do
                    local res = v()
                    log.info(tag, "获取GPIO输入方法" .. k .. "读取的输入" .. res)
                end
                sys.wait(5000)
            end
        end
    )
end

if LuaTaskTestConfig.gpioTest.gpioOutTest then
    sys.taskInit(
        function()
            local value = 0
            while true do
                sys.wait(1000)
                if modType == "8910" then
                    for k, v in pairs(gpio_8910_list) do
                        pins.setup(v, value)
                    end
                elseif modType == "1802" or modType == "1802S" then
                    pins.setup(10, value)
                    pins.setup(11, value)
                    pins.setup(17, value)
                    pins.setup(18, value)
                    pins.setup(20, value)
                    pins.setup(21, value)
                    pins.setup(22, value)
                    pins.setup(23, value)
                    pins.setup(24, value)
                    pins.setup(25, value)
                    pins.setup(26, value)
                    pins.setup(27, value)
                    pins.setup(28, value)
                    pins.setup(29, value)
                    pins.setup(30, value)
                    pins.setup(31, value)
                    pins.setup(32, value)
                    pins.setup(33, value)
                    pins.setup(34, value)
                    pins.setup(35, value)
                    pins.setup(36, value)
                    pins.setup(37, value)
                    pins.setup(38, value)
                    pins.setup(39, value)
                    pins.setup(40, value)
                    pins.setup(41, value)
                    pins.setup(42, value)
                    pins.setup(49, value)
                    pins.setup(50, value)
                    pins.setup(51, value)
                    pins.setup(52, value)
                    pins.setup(61, value)
                    pins.setup(62, value)
                    pins.setup(63, value)
                    pins.setup(64, value)
                    pins.setup(65, value)
                    pins.setup(66, value)
                end

                if value == 0 then
                    value = 1
                else
                    value = 0
                end
            end
        end
    )   
end

local function led_shut()
    local x = 0
    gpio19(x)
    gpio18(x)
    gpio13(x)
    gpio9(x)
    gpio12(x)
    gpio10(x)
    gpio11(x)
    gpio23(x)
end

local function led_blink(time)

    local x = 1
    for i = 1, time do
        gpio19(x)
        gpio18(x)
        gpio13(x)
        gpio9(x)
        gpio12(x)
        gpio10(x)
        gpio11(x)
        gpio23(x)
        sys.wait(1000)
        led_shut()
    end
end

local function led_single_switch(gpio, time)
    gpio(1)
    sys.wait(time)
    gpio(0)
end

local function led_liushui(time)
    local lightTime = 1000
    for i = 1, time do
        led_single_switch(gpio19, lightTime)
        led_single_switch(gpio18, lightTime)
        led_single_switch(gpio13, lightTime)
        led_single_switch(gpio9, lightTime)
        led_single_switch(gpio12, lightTime)
        led_single_switch(gpio10, lightTime)
        led_single_switch(gpio11, lightTime)
        led_single_switch(gpio23, lightTime)
    end

end

local function led_leijia(time)
    local waitTime = 1000
    for i = 1, time do
        sys.wait(waitTime)
        gpio23(1)
        sys.wait(waitTime)
        gpio11(1)
        sys.wait(waitTime)
        gpio10(1)
        sys.wait(waitTime)
        gpio12(1)
        sys.wait(waitTime)
        gpio9(1)
        sys.wait(waitTime)
        gpio13(1)
        sys.wait(waitTime)
        gpio18(1)
        sys.wait(waitTime)
        gpio19(1)
        sys.wait(waitTime)
        led_shut()
    end
    
end


if LuaTaskTestConfig.gpioTest.ledTest then
    gpio19 = pins.setup(19)
    gpio18 = pins.setup(18)
    gpio13 = pins.setup(13)
    gpio9 = pins.setup(9)
    gpio12 = pins.setup(12)
    gpio10 = pins.setup(10)
    gpio11 = pins.setup(11)
    gpio23 = pins.setup(23)

    
    sys.taskInit(
        function ()
            while true do
                led_blink(1)
                led_leijia(1)
                led_liushui(1)
            end
        end
    )

end