-- I2CAndSPITest
-- Author:LuatTest
-- CreateDate:20201023
-- UpdateDate:20210427

module(..., package.seeall)

-- I2C外设 使用 AHT10 温湿度传感器
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

-- SPI外设 使用 W25Q64
if LuaTaskTestConfig.i2cAndSpiTest.SPITest then
    local tag = "SPITest"
    local waitTime = 1000

    local flashList = {
        [0xEF15] = 'w25q32',
        [0xEF16] = 'w25q64',
        [0xEF17] = 'w25q128',
        [0x6815] = 'bh25q32',
    }
    sys.taskInit(
        function ()
            sys.wait(5000)
            local spiSetupRes = spi.setup(spi.SPI_1, 0, 0, 8, 100000, 1)
            if spiSetupRes == 0 then
                log.error(tag .. ".setup", "FAIL")
            elseif spiSetupRes == 1 then
                log.info(tag .. ".setup", "SUCCESS")
                spi.send_recv(spi.SPI_1, string.char(0x06))
                sys.wait(waitTime)
                while true do
                    local flashInfo = spi.send_recv(spi.SPI_1, string.char(0x90, 0, 0, 0, 0, 0))
                    -- log.info(tag .. ".readFlashInfo", string.toHex(flashInfo))
                    local manufactureID, deviceID = string.byte(flashInfo, 5, 6)
                    log.info(tag .. ".FlashName", flashList[manufactureID * 256 + deviceID])
                    sys.wait(waitTime)
                    spi.send_recv(spi.SPI_1, string.char(0x06))
                    sys.wait(waitTime)
                    spi.send_recv(spi.SPI_1,string.char(0x20,0,0x10,0))
                    sys.wait(waitTime)
                    spi.send_recv(spi.SPI_1, string.char(0x06))
                    sys.wait(waitTime)
                    spi.send_recv(spi.SPI_1, string.char(0x02, 0, 0x10, 0) .. "LuaTaskSPITest")
                    sys.wait(waitTime)
                    log.info(tag .. ".readData", spi.send_recv(spi.SPI_1, string.char(0x03, 0, 0x10, 0) .. string.rep("1", 14)):sub(5))
                    sys.wait(waitTime)
                end
            else
                log.error(tag .. ".setup", "unknown spi setup status", spiSetupRes)
            end
        end
    )
end