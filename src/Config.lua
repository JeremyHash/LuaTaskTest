-- NVM功能模块使用的Config文件
-- Author:LuatTest
-- CreateDate:20201016
-- UpdateDate:20210520

module(..., package.seeall)

strPara = "LuatTest1"
numPara = 1
boolPara = false
personTablePara = {"name1", "age1", "sex1"}
scoreTablePara = {
    chinese = 1,
    math    = 2,
    english = 3
}
manyTablePara = {
    table1 = {
        table11 = 11,
        table12 = "table12",
        table13 = true
    },
    table2 = {
        table21 = {
            table211 = 1,
            table212 = "2",
            table213 = false
        },
        table22 = "table22",
        table23 = false
    }
}