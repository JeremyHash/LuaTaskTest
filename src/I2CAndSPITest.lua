-- I2CAndSPITest
-- Author:LuatTest
-- CreateDate:20201023
-- UpdateDate:20210319

module(..., package.seeall)

-- I2C 外设 使用 AHT10 温湿度传感器

if LuaTaskTestConfig.i2cAndSpiTest.I2CTest then
    -- 使用I2C通道2
    local i2cId = 2

    -- 从设备地址 0x38
    local i2cSlaveAddr = 0x38

    -- I2C 时钟频率
    local i2cSpeed = 100000

    sys.taskInit(
        function ()

            local setupResult = i2c.setup(i2cId, i2cSpeed)

            if setupResult == i2cSpeed then

                log.info("I2CTest.setup", "SUCCESS")
                sys.wait(1000)

                while true do
                    local sentDataSize = i2c.send(i2cId, i2cSlaveAddr, {0xac, 0x22, 0x00})

                    if sentDataSize == 3 then

                        log.info("I2CTest.发送成功字节数", sentDataSize)

                        sys.wait(1000)

                        local receivedData = i2c.recv(i2cId, i2cSlaveAddr, 6)

                        if #receivedData == 6 then
                            log.info("I2CTest.receivedDataHex", receivedData:toHex())

                            local tempBit = string.byte(receivedData, 6) + 0x100 * string.byte(receivedData, 5) + 0x10000 * bit.band(string.byte(receivedData, 4), 0x0F)
                        
                            local humidityBit = bit.band(string.byte(receivedData, 4), 0xF0) + 0x100 * string.byte(receivedData, 3) + 0x10000 * string.byte(receivedData, 2)  

                            humidityBit = bit.rshift(humidityBit, 4)
                            
                            log.info("I2CTest.tempBit", tempBit)

                            log.info("I2CTest.humidityBit", humidityBit)
                        
                            local calcTemp = (tempBit / 1048576) * 200 - 50

                            local calcHum = humidityBit / 1048576
                        
                            log.info("I2CTest.calcTemp", calcTemp)

                            log.info("I2CTest.calcHum", calcHum)

                            log.info("I2CTest.当前温度", string.format("%.1f℃", calcTemp))

                            log.info("I2CTest.当前湿度", string.format("%.1f%%", calcHum * 100))
                        
                            sys.wait(1000)
                        else
                            log.error("I2CTest.receive", "FAIL")
                        end
                    else
                        log.error("I2CTest.send", "FAIL")
                    end

                    sys.wait(1000)
                end
            else
                log.error("I2CTest.setup", "FAIL")
            end
        end
    )
end