# ddns

如果你和我一样用的是阿里云的dns解析，就先调用 profile_set.sh 来配置阿里云的cli（记得先修改这个文件，写入你自己的密钥）

再调用 up_record.sh 这个脚本需要使用 jq 程序来解析 json ，所以请先安装它

