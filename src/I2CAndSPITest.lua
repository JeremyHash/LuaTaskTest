-- I2CAndSPITest
-- Author:LuatTest
-- CreateDate:20201023
-- UpdateDate:20201023

module(..., package.seeall)

local i2cid = 2
local i2cslaveaddr = 0x70

local function getI2CData()
    log.info("I2CTest.getI2CData", string.toHex(i2c.read(i2cid, 0x08, 1)))
end

if LuaTaskTestConfig.i2cAndSpiTest.I2CTest then
    if i2c.setup(i2cid, i2c.SLOW, i2cslaveaddr) == i2c.SLOW then
        log.info("I2CTest.Setup", "SUCCESS")
        sys.timerLoopStart(
            function ()
                getI2CData()
            end,
            5000
        )
    else
        log.info("I2CTest.Setup", "FAIL")
    end
end