-- GpioTest
-- Author:LuatTest
-- CreateDate:20200724
-- UpdateDate:20201027

module(..., package.seeall)

--[[
有些GPIO需要打开对应的ldo电压域才能正常工作，电压域和对应的GPIO关系如下
pmd.ldoset(x,pmd.LDO_VSIM1) -- GPIO 29、30、31

pmd.ldoset(x,pmd.LDO_VLCD) -- GPIO 0、1、2、3、4

pmd.ldoset(x,pmd.LDO_VMMC) -- GPIO 24、25、26、27、28
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


local x = 2

-- pmd.ldoset(x,pmd.VLDO6)

-- pmd.ldoset(x,pmd.LDO_VSIM1) -- GPIO 29、30、31

pmd.ldoset(x, pmd.LDO_VLCD) -- GPIO 0、1、2、3、4

-- pmd.ldoset(x,pmd.LDO_VMMC) -- GPIO 24、25、26、27、28



function gpioIntFnc(msg)
    --上升沿中断
    if msg == cpu.INT_GPIO_POSEDGE then
        log.info("GpioIntTest.msg", "上升")
    --下降沿中断
    else
        log.info("GpioIntTest.msg", "下降")
    end
end

if LuaTaskTestConfig.gpioTest.gpioIntTest then
    getGpio0Fnc = pins.setup(0, gpioIntFnc)
    getGpio1Fnc = pins.setup(1, gpioIntFnc)
    getGpio2Fnc = pins.setup(2, gpioIntFnc)
    getGpio3Fnc = pins.setup(3, gpioIntFnc)
    getGpio4Fnc = pins.setup(4, gpioIntFnc)
    getGpio5Fnc = pins.setup(5, gpioIntFnc)
    getGpio5Fnc = pins.setup(7, gpioIntFnc)
    getGpio5Fnc = pins.setup(8, gpioIntFnc)
    getGpio9Fnc = pins.setup(9, gpioIntFnc)
    getGpio10Fnc = pins.setup(10, gpioIntFnc)
    getGpio11Fnc = pins.setup(11, gpioIntFnc)
    getGpio12Fnc = pins.setup(12, gpioIntFnc)
    getGpio13Fnc = pins.setup(13, gpioIntFnc)
    getGpio14Fnc = pins.setup(14, gpioIntFnc)
    getGpio15Fnc = pins.setup(15, gpioIntFnc)
    getGpio17Fnc = pins.setup(17, gpioIntFnc)
    getGpio18Fnc = pins.setup(18, gpioIntFnc)
    getGpio19Fnc = pins.setup(19, gpioIntFnc)
    getGpio20Fnc = pins.setup(20, gpioIntFnc)
    getGpio21Fnc = pins.setup(21, gpioIntFnc)
    getGpio22Fnc = pins.setup(22, gpioIntFnc)
    getGpio23Fnc = pins.setup(23, gpioIntFnc)
    getGpio24Fnc = pins.setup(24, gpioIntFnc)
    getGpio25Fnc = pins.setup(25, gpioIntFnc)
    getGpio26Fnc = pins.setup(26, gpioIntFnc)
    getGpio27Fnc = pins.setup(27, gpioIntFnc)
    getGpio28Fnc = pins.setup(28, gpioIntFnc)
    -- getGpio29Fnc = pins.setup(29, gpioIntFnc)
    -- getGpio30Fnc = pins.setup(30, gpioIntFnc)
    -- getGpio31Fnc = pins.setup(31, gpioIntFnc)
    -- getGpio32Fnc = pins.setup(32, gpioIntFnc)
    -- getGpio33Fnc = pins.setup(33, gpioIntFnc)
    -- getGpio34Fnc = pins.setup(34, gpioIntFnc)
    -- getGpio35Fnc = pins.setup(35, gpioIntFnc)
    -- getGpio36Fnc = pins.setup(36, gpioIntFnc)
    -- getGpio37Fnc = pins.setup(37, gpioIntFnc)
    -- getGpio38Fnc = pins.setup(38, gpioIntFnc)
    -- getGpio39Fnc = pins.setup(39, gpioIntFnc)
    -- getGpio40Fnc = pins.setup(40, gpioIntFnc)
    -- getGpio41Fnc = pins.setup(41, gpioIntFnc)
    -- getGpio42Fnc = pins.setup(42, gpioIntFnc)
    -- getGpio49Fnc = pins.setup(49, gpioIntFnc)
    -- getGpio50Fnc = pins.setup(50, gpioIntFnc)
    -- getGpio51Fnc = pins.setup(51, gpioIntFnc)
    -- getGpio52Fnc = pins.setup(52, gpioIntFnc)
    -- getGpio61Fnc = pins.setup(61, gpioIntFnc)
    -- getGpio62Fnc = pins.setup(62, gpioIntFnc)
    -- getGpio63Fnc = pins.setup(63, gpioIntFnc)
    -- getGpio64Fnc = pins.setup(64, gpioIntFnc)
    -- getGpio65Fnc = pins.setup(65, gpioIntFnc)
    -- getGpio66Fnc = pins.setup(66, gpioIntFnc)
end

if LuaTaskTestConfig.gpioTest.gpioOutTest then
    sys.taskInit(
        function()
            local value = 0
            while true do

                sys.wait(2000)

                pins.setup(0, value)
                pins.setup(1, value)
                pins.setup(2, value)
                pins.setup(3, value)
                pins.setup(4, value)
                pins.setup(5, value)
                pins.setup(7, value)
                pins.setup(8, value)
                pins.setup(9, value)
                pins.setup(10, value)
                pins.setup(11, value)
                pins.setup(12, value)
                pins.setup(13, value)
                pins.setup(14, value)
                pins.setup(15, value)
                pins.setup(17, value)
                pins.setup(18, value)
                pins.setup(19, value)
                pins.setup(20, value)
                pins.setup(21, value)
                pins.setup(22, value)
                pins.setup(23, value)
                pins.setup(24, value)
                pins.setup(25, value)
                pins.setup(26, value)
                pins.setup(27, value)
                pins.setup(28, value)

                if value == 0 then
                    value = 1
                else
                    value = 0
                end
            end
        end
    )   
end

-- local function ledTest()
--     local gpio1 = pins.setup(1)
--     led.blinkPwm(gpio1, 500, 500)
--     local gpio4 = pins.setup(4)
--     led.blinkPwm(gpio4, 100, 500)
-- end

-- if LuaTaskTestConfig.gpioTest.ledTest then
--     ledTest()
-- end