-- GpioTest
-- Author:LuatTest
-- CreateDate:20200724
-- UpdateDate:20200724

module(...,package.seeall)

require"pins"

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

local x = 1
pmd.ldoset(x,pmd.LDO_VSIM1) -- GPIO 29、30、31

pmd.ldoset(x,pmd.LDO_VLCD) -- GPIO 0、1、2、3、4

pmd.ldoset(x,pmd.LDO_VMMC) -- GPIO 24、25、26、27、28

-- local level = 0
-- --GPIO18配置为输出，默认输出低电平，可通过setGpio18Fnc(0或者1)设置输出电平
-- local setGpio18Fnc = pins.setup(pio.P0_18,0)
-- sys.timerLoopStart(function()
--     level = level==0 and 1 or 0
--     setGpio18Fnc(level)
--     log.info("testGpioSingle.setGpio18Fnc",level)
-- end,1000)

--GPIO19配置为输入，可通过getGpio19Fnc()获取输入电平
-- local getGpio19Fnc = pins.setup(pio.P0_19)
-- sys.timerLoopStart(function()
--     log.info("testGpioSingle.getGpio19Fnc",getGpio19Fnc())
-- end,1000)
--pio.pin.setpull(pio.PULLUP,pio.P0_19)  --配置为上拉
--pio.pin.setpull(pio.PULLDOWN,pio.P0_19)  --配置为下拉
--pio.pin.setpull(pio.NOPULL,pio.P0_19)  --不配置上下拉



function gpio0IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio1IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio2IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio3IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio4IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio5IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio6IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio9IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio10IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio11IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio12IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio13IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio14IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio15IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio16IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio17IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio18IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio19IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio20IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio21IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio22IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio23IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio24IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio25IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio26IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio27IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

function gpio28IntFnc(msg)
    log.info("testGpioSingle.gpioIntFnc",msg,getGpio13Fnc())
    --上升沿中断
    if msg==cpu.INT_GPIO_POSEDGE then
        log.info("Jeremy_GPIO", "上升")
    --下降沿中断
    else
        log.info("Jeremy_GPIO", "下降")
    end
end

--GPIO13配置为中断，可通过getGpio13Fnc()获取输入电平，产生中断时，自动执行gpio13IntFnc函数
getGpio0Fnc = pins.setup(0,gpio0IntFnc)
getGpio1Fnc = pins.setup(1,gpio1IntFnc)
getGpio2Fnc = pins.setup(2,gpio3IntFnc)
getGpio3Fnc = pins.setup(3,gpio3IntFnc)
getGpio4Fnc = pins.setup(4,gpio4IntFnc)
getGpio5Fnc = pins.setup(5,gpio5IntFnc)
getGpio6Fnc = pins.setup(6,gpio6IntFnc)
getGpio9Fnc = pins.setup(9,gpio9IntFnc)
getGpio10Fnc = pins.setup(10,gpio10IntFnc)
getGpio11Fnc = pins.setup(11,gpio11IntFnc)
getGpio12Fnc = pins.setup(12,gpio12IntFnc)
getGpio13Fnc = pins.setup(13,gpio13IntFnc)
getGpio14Fnc = pins.setup(14,gpio14IntFnc)
getGpio15Fnc = pins.setup(15,gpio15IntFnc)
getGpio16Fnc = pins.setup(16,gpio16IntFnc)
getGpio17Fnc = pins.setup(17,gpio17IntFnc)
getGpio18Fnc = pins.setup(18,gpio18IntFnc)
getGpio19Fnc = pins.setup(19,gpio19IntFnc)
getGpio20Fnc = pins.setup(20,gpio20IntFnc)
getGpio21Fnc = pins.setup(21,gpio21IntFnc)
getGpio22Fnc = pins.setup(22,gpio22IntFnc)
getGpio23Fnc = pins.setup(23,gpio23IntFnc)
getGpio24Fnc = pins.setup(24,gpio24IntFnc)
getGpio25Fnc = pins.setup(25,gpio25IntFnc)
getGpio26Fnc = pins.setup(26,gpio26IntFnc)
getGpio27Fnc = pins.setup(27,gpio27IntFnc)
getGpio28Fnc = pins.setup(28,gpio28IntFnc)




--[[
pmd.ldoset(0,pmd.LDO_VLCD)
pins.setup(pio.P0_0,1)
levelTest = 0

pmd.ldoset(15,pmd.LDO_VMMC)
pins.setup(pio.P0_27,1)

pmd.ldoset(15,pmd.LDO_VSIM1)
pins.setup(pio.P0_29,1)
pins.setup(pio.P0_30,1)
pins.setup(pio.P0_31,1)


sys.timerLoopStart(function()
    pmd.ldoset(levelTest,pmd.LDO_VMMC)
    pmd.ldoset(levelTest,pmd.LDO_VLCD)
    pmd.ldoset(levelTest,pmd.LDO_VSIM1)
    log.info("levelTest",levelTest)
    
    levelTest = levelTest+1
    if levelTest>15 then levelTest=0 end
end,10000)
]]




