-- FtpTest
-- Author:LuatTest
-- CreateDate:20210510
-- UpdateDate:20210518

module(..., package.seeall)

local ftp_server_addr = "36.7.87.100"
local ftp_port = 21
local ftp_user_name = "User"
local ftp_password = "123456"
local ftp_mode = "PASV"

local waitTime = 300000
local tag = "FtpTest"
local testPath = "/Luat_Lua_FTP_Test"
local test_upload_local_file = "/lua/logo_color.png"
local test_download_local_file = "/ftp_download_file"

sys.taskInit(
    function ()
        local upload_file_md5 = crypto.md5(test_upload_local_file, "file")
        while true do
            local res_code, res_msg = ftp.login(ftp_mode, ftp_server_addr, ftp_port, ftp_user_name, ftp_password)
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
            res_code, res_msg = ftp.rmd(testPath .. "/DIRTest/")
            log.info(tag .. ".rmd ", res_code, res_msg)
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
            res_code, res_msg = ftp.upload(testPath .. "/logo_color.png", test_upload_local_file)
            if res_code ~= "200" then
                log.error(tag .. ".upload", "FAIL")
                continue
            end
            res_code, res_msg = ftp.download(testPath .. "/logo_color.png", test_download_local_file)
            log.info(tag .. ".download ", res_code, res_msg)
            if res_code ~= "200" then
                log.error(tag .. ".download", "FAIL")
                continue
            end
            local download_file_md5 = crypto.md5(test_download_local_file, "file")
            print(upload_file_md5)
            print(download_file_md5)
            print(io.fileSize(test_download_local_file))
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