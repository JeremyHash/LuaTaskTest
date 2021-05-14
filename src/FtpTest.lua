-- FtpTest
-- Author:LuatTest
-- CreateDate:20210510
-- UpdateDate:20210510

module(..., package.seeall)

local waitTime = 3000
local tag = "FtpTest"
local testPath = "/Luat_Lua_FTP_Test"

sys.taskInit(
    function ()
        local upload_file_md5 = crypto.md5("/lua/logo_color.png", "file")
        while true do
            local res_code, res_msg = ftp.login("PASV", "36.7.87.100", 21, "user", "123456")
            -- log.info(tag .. ".login", res_code, res_msg)
            if res_code ~= "200" then
                log.error(tag .. ".login", "FAIL")
                continue
            end
            log.info(tag .. ".login", "SUCCESS")
            log.info(tag .. ".command.SYST", ftp.command("SYST"))
            res_code, res_msg = ftp.list("/")
            if res_code == false then
                log.error(tag .. ".list./", "FAIL")
                continue
            end
            log.info(tag .. ".list./", res_code, res_msg)
            res_code, res_msg = ftp.list(testPath .. "/ftp_get_test.txt")
            if res_code == false then
                log.error(tag .. ".list." .. testPath .. "/ftp_get_test.txt", "FAIL")
                continue
            end
            log.info(tag .. ".list." .. testPath .. "/ftp_get_test.txt", res_code, res_msg)
            res_code, res_msg = ftp.pwd()
            log.info(tag .. ".pwd ", res_code, res_msg)
            res_code, res_msg = ftp.deletefolder(testPath .. "/DIRTest/")
            log.info(tag .. ".deletefolder ", res_code, res_msg)
            res_code, res_msg = ftp.mkd(testPath .. "/DIRTest/")
            log.info(tag .. ".mkd ", res_code, res_msg)
            res_code, res_msg = ftp.cwd(testPath .. "/DIRTest/")
            log.info(tag .. ".cwd ", res_code, res_msg)
            res_code, res_msg = ftp.pwd()
            log.info(tag .. ".ftp_pwd ", res_code, res_msg)
            res_code, res_msg = ftp.cdup()
            log.info(tag .. ".ftp_cdup ", res_code, res_msg)
            res_code, res_msg = ftp.pwd()
            log.info(tag .. ".ftp_pwd ", res_code, res_msg)
            res_code, res_msg = ftp.deletefile(testPath .. "/logo_color.png")
            log.info(tag .. ".deletefile ", res_code, res_msg)
            res_code, res_msg = ftp.upload(testPath .. "/logo_color.png", "/lua/logo_color.png")
            log.info(tag .. ".upload ", res_code, res_msg)
            if io.exists("/ftp_download_file.png") then
                log.info(tag .. ".remove", os.remove("/ftp_download_file.png"))
            end
            res_code, res_msg = ftp.download(testPath .. "/logo_color.png", "/ftp_download_file.png")
            log.info(tag .. ".download ", res_code, res_msg)
            local download_file_md5 = crypto.md5("/ftp_download_file.png", "file")
            print(upload_file_md5)
            print(download_file_md5)
            print(io.fileSize("/ftp_download_file.png"))
            if download_file_md5 == upload_file_md5 then
                log.info(tag .. ".MD5Check", "SUCCESS")
            else
                log.error(tag .. ".MD5Check", "FAIL")
            end
            ftp.close()
            sys.wait(waitTime)
        end
    end
)