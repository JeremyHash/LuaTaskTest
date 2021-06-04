-- FsTest
-- Author:LuatTest
-- CreateDate:20200927
-- UpdateDate:20210326

module(..., package.seeall)

local waitTime1 = 10000
local waitTime2 = 300000

local function readFile(filename)
	local filehandle = io.open(filename, "r")
	if filehandle then
		local fileval = filehandle:read("*all")
		if fileval then
		   log.info("FsTest.readFile." .. filename, fileval)
		   filehandle:close()
	  	else
		   log.info("FsTest.ReadFile." .. filename, "文件内容为空")
	  	end
	else
		log.error("FsTest.readFile." .. filename, "文件不存在或文件输入格式不正确")
	end
end

local function writeFileA(filename, value)
	local filehandle = io.open(filename, "a+")
	if filehandle then
		local res, info = filehandle:write(value)
		filehandle:close()
	else
		log.error("FsTest.WriteFileA." .. filename, "文件不存在或文件输入格式不正确")
	end
end

local function writeFileW(filename, value)
	local filehandle = io.open(filename, "w")
	if filehandle then
		filehandle:write(value)
		filehandle:close()
	else
		log.error("FsTest.WriteFileW." .. filename, "文件不存在或文件输入格式不正确")
	end
end

local function deleteFile(filename)
	os.remove(filename)
end

local getDirContent

getDirContent = function(dirPath, level)
    local ftb = {}
    local dtb = {}
    level = level or "    "
    local tag = " "
	if io.opendir(dirPath) == 0 then
		log.error("FsTest.getDirContent", "无法打开目标文件夹\"" .. dirPath .. "\"")
		return
	end
    while true do
        local fType, fName, fSize = io.readdir()
        if fType == 32 then
            table.insert(ftb, {name = fName, size = fSize})
        elseif fType == 16 then
            table.insert(dtb, {name = fName, path = dirPath .. "/" .. fName})
        else
            break
        end
    end
    io.closedir(dirPath)
    for i = 1, #ftb do 
        if i == #ftb then
            log.info(tag, level .. "└─", ftb[i].name, "[" .. ftb[i].size .. " Bytes]")
        else
            log.info(tag, level .. "├─", ftb[i].name, "[" .. ftb[i].size .. " Bytes]")
        end
    end
    for i = 1, #dtb do 
        if i == #dtb then
            log.info(tag, level.."└─", dtb[i].name)
            getDirContent(dtb[i].path, level .. "  ")
        else
            log.info(tag, level.."├─", dtb[i].name)
            getDirContent(dtb[i].path, level .. "│ ")
        end    
    end
end

-- SD卡读写测试
if LuaTaskTestConfig.fsTest.sdCardTest then
	sys.taskInit(
		function()
			local tag = "FsTest.sdCardTest"
			local sdcardPath = "/sdcard0"
	        sys.wait(waitTime1)
	        -- 挂载SD卡
			log.info(tag, "开始挂载SD卡")
	        io.mount(io.SDCARD)
		
	        -- 第一个参数1表示sd卡
	        -- 第二个参数1表示返回的总空间单位为KB
	        local sdCardTotalSize = rtos.get_fs_total_size(1, 1)
	        log.info(tag .. ".TotalSize", sdCardTotalSize .. " KB")
		
	        local sdCardFreeSize = rtos.get_fs_free_size(1, 1)
	        log.info(tag .. ".FreeSize", sdCardFreeSize .. " KB")
		
			log.info(tag .. ".getDirContent." .. sdcardPath)
	        getDirContent(sdcardPath)

			local testPath = sdcardPath .. "/FsTestPath"
			local mkdirRes = rtos.make_dir(testPath)

			deleteFile(testPath .. "/FsWriteTest1.txt")
			if mkdirRes then
				log.info(tag .. ".MkdirRes", "SUCCESS")
				while true do
					audio.play(5, "FILE", sdcardPath .. "/sms.mp3", 3)
					sys.wait(3000)
					writeFileA(testPath .. "/FsWriteTest1.txt", "This is a FsWriteATest")
					readFile(testPath .. "/FsWriteTest1.txt")
					writeFileW(testPath .. "/FsWriteTest2.txt", "This is a FsWriteWTest")
					readFile(testPath .. "/FsWriteTest2.txt")
					sys.wait(waitTime2)
				end
			else
				log.error(tag .. ".MkdirRes", "FAIL")
			end


	        --卸载SD卡
	        io.unmount(io.SDCARD)
	    end
	)
end

-- 模块内部FLASH读写测试
if LuaTaskTestConfig.fsTest.insideFlashTest then
	sys.taskInit(
		function ()
			local tag = "FsTest.insideFlashTest"
			sys.wait(waitTime1)
			log.info(tag .. ".getDirContent./")
	        getDirContent("/")
			local testPath = "/FsTestPath"
			if io.exists(testPath .. "/FsWriteTest1.txt") then
				log.info(tag .. ".exists." .. testPath .. "/FsWriteTest1.txt", "文件存在,准备删除该文件")
				deleteFile(testPath .. "/FsWriteTest1.txt")
			else
				log.info(tag .. ".exists." .. testPath .. "/FsWriteTest1.txt", "文件不存在")
			end

			if rtos.make_dir(testPath) then
				log.info(tag .. ".make_dir", "SUCCESS")
				while true do
					writeFileA(testPath .. "/FsWriteTest1.txt", "This is a FsWriteATest")
					log.info(tag .. "." .. testPath .. "/FsWriteTest1.txt.fileSize", io.fileSize(testPath .. "/FsWriteTest1.txt") .. "Bytes")
					readFile(testPath .. "/FsWriteTest1.txt")
					writeFileW(testPath .. "/FsWriteTest2.txt", "This is a FsWriteWTest")
					readFile(testPath .. "/FsWriteTest2.txt")
					log.info(tag .. ".readFile." .. testPath .. "/FsWriteTest2.txt", io.readFile(testPath .. "/FsWriteTest2.txt"))
					io.writeFile(testPath .. "/FsWriteTest3.txt", "test")
					readFile(testPath .. "/FsWriteTest3.txt")
					local pathTable = io.pathInfo(testPath .. "/FsWriteTest1.txt")
					for k, v in pairs(pathTable) do
						log.info(tag .. ".pathInfo." .. k, v)
					end
					local file = io.open("/FileSeekTest.txt", "w")
					file:write("FileSeekTest")
					file:close()
					local file = io.open("/FileSeekTest.txt", "r")
					log.info(tag .. ".seek", file:seek("end"))
					log.info(tag .. ".seek", file:seek("set"))
					log.info(tag .. ".seek", file:seek())
					log.info(tag .. ".seek", file:seek("cur", 10))
					log.info(tag .. ".seek", file:seek("cur"))
					log.info(tag .. ".seek", file:read(1))
					log.info(tag .. ".seek", file:seek("cur"))
					file:close()
					log.info(tag .. "./FileSeekTest.txt.readStream", io.readStream("/FileSeekTest.txt", 3, 5))
					sys.wait(waitTime2)
				end
			else
				log.error(tag .. ".FlashTest.make_dir", "FAIL")
			end
		end
	)
end

if LuaTaskTestConfig.fsTest.openDirTest then
	sys.taskInit(
		function ()
			local tag = "FsTest.openDirTest"
			local dirTable = {"/", "/nvm", "/openDirTest"}
			while true do
				sys.wait(waitTime1)
				for k, v in pairs(dirTable) do
					log.info(tag, v)
					getDirContent(v)
				end
			end
		end
	)
end