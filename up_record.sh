#! /bin/bash
 # @filename            
 # @use                 
 # @datetime            2020-11-05 15:10:33.566060680 ,45, 4 310 CST +08:00:00
 # @access              public
 # @category            类型
 # @package             包
 # @explain             功能说明
 # @relating            相关联的模块
 # @dependencies        --------- 依赖于↓ ---------
 #                      依赖关系列表
 # @author              --------- 作者↓ ---------
 #                      <timeline.menu@gmail.com>
 #                      <timeline.menu@outlook.com>
 #                      <root_@126.com>
 # @copyright           所有权
 # @license             GPL_v2 (the GNU General Public License,version 2.) <http://www.gnu.org/licenses/gpl-2.0.html>
 # @version             版本号
 # @link                --------- 链接地址↓ ---------
 #                      <http://timeline.menu>
 #                      <http://exploreroot.com>
 #                      <http://so-u.info>
 # @changetime          --------- 修订记录↓ ---------
 #                      2020-11-05 15:10:33.566060680 ,45, 4 310 CST +08:00:00
 #                       建立本文件
 # @algorithm           --------- 算法↓ ---------
 #                      
 #                      
 # ---------  ---------
 # ---------  ---------
 # 
 # 
 
#



#  aliyun alidns DescribeDomainRecords --DomainName so-u.info --profile 001
#    找出 RR 为 www 且 Status 为 ENABLE 的 RecordId
#    查看 其 Value 是否为现在的公网ip地址，
#      是，则程序结束，不做任何修改
#      否，则执行： 修改其 Value 为公网ip地址

# -- 这一段里面的变量根据实际情况修改为你自己的 --
domain='so-u.info' #这个值根据实际情况修改
record='www' #这个值根据实际情况修改
# -- 这一段里面的变量根据实际情况修改为你自己的 ^ --


internet_ip=$(wget -qO - ifconfig.co) #得到目前的公网ip地址

record_id='' #后面会覆盖这个值，这里只作为声明用
value='' #后面会覆盖这个值，这里只作为声明用


#查出域名当前的解析情况
aliyun alidns DescribeDomainRecords --DomainName $domain --profile 001 > ~/domain_record.txt

# -- 解析结果json --

num=$(jq .TotalCount ~/domain_record.txt | tr -d '"' ) #得到解析数量
#echo $num

# 循环，找出 RR 为 www 的数组序号
#/mnt/sync_1/command/shell/循环_for

j=0 #同键冲突解决
for((i = 0; i < $num; i++)) #这个可以
do
    #echo "$integer"
    rr=$(jq ".DomainRecords.Record | .[$i].RR" ~/domain_record.txt | tr -d '"' ) #
    #echo $rr
    #if [[ $rr == "www" ]]
    if [[ $rr == $record ]]
    then
	#遇到匹配的就放进数组里，然后将 $j 加一，
	www_indexs[$j]=$i
	((j++))
	www_index=$i
    else
	continue # for whild until
    fi
done

www_num=${#www_indexs[*]} #数组长度

#遍历 www 的这些记录，确定 status 是enable 还是 disable ，找出 enable 的记录
j=0 #同键冲突解决
for((i = 0; i < $www_num; i++)) #
do
    status=$(jq ".DomainRecords.Record | .[${www_indexs[$i]}].Status" ~/domain_record.txt | tr -d '"' ) #

    #统计 enable 的个数，新建数组
    if [[ $status == "ENABLE" ]]
    then
	#遇到匹配的就放进数组里，然后将 $j 加一，
	enable_record[$j]=${www_indexs[$i]}
	((j++))
    fi
done

#如果 记录为www且状态为ENABLE 的数量多于一个，
#  判断条件为 ${#enable_record[*]} 即 enable_record 数组的长度
#  只保留第一个可用，其余的全部禁用

enable_num=${#enable_record[*]}
#echo "enable_num: $enable_num"

if [[ $enable_num == "1" ]]
then
    #只有一条记录

    #取得record_id
    record_id=$(jq ".DomainRecords.Record | .[${enable_record[0]}].RecordId" ~/domain_record.txt | tr -d '"' ) #

    #取得value
    value=$(jq ".DomainRecords.Record | .[${enable_record[0]}].Value" ~/domain_record.txt | tr -d '"' ) #
else
    #不只一条记录
    #只保留第一个可用，其余的全部禁用
    #循坏
    for((i = 0; i < $enable_num ; i++)) #
    do
	if [[ $i == "0" ]];
	then
	    #echo " i == 0 "
	    #取得record_id
	    record_id=$(jq ".DomainRecords.Record | .[${enable_record[$i]}].RecordId" ~/domain_record.txt | tr -d '"' ) #

	    #取得value
	    value=$(jq ".DomainRecords.Record | .[${enable_record[$i]}].Value" ~/domain_record.txt | tr -d '"' ) #
	elif [[ $i > "0" ]];
	then
	    #echo " i > 0"
	    #调用接口或cli命令禁用这个项目

	    #取得record_id
	    record_id_temp=$(jq ".DomainRecords.Record | .[${enable_record[$i]}].RecordId" ~/domain_record.txt | tr -d '"' ) #

	    #取得value
	    value_temp=$(jq ".DomainRecords.Record | .[${enable_record[$i]}].Value" ~/domain_record.txt | tr -d '"' ) #

	    #阿里云的cli里面没有这个选项，api里面 UpdateDomainRecord 也无法传入 Status 这个参数 ，只能删除它了 DeleteDomainRecord
	    #找到了是单独一个api SetDomainRecordStatus 
	    #aliyun alidns SetDomainRecordStatus --profile 001 --region cn-hangzhou --RegionId cn-hangzhou --RecordId $record_id_temp --Status Disable # --RegionId 这个不要写在命令行里
	    #aliyun alidns SetDomainRecordStatus --profile 001 --region cn-hangzhou --RecordId $record_id_temp --Status Disable
	    #还是删掉多余的吧，修改状态会遇到ip地址被占用导致后面的记录修改失败
	    aliyun alidns DeleteDomainRecord  --profile 001 --region cn-hangzhou --RecordId $record_id_temp
	#else
	    #echo "None of the above"
	fi
    done
fi
# -- 解析结果json ^ --

if [[ $value == $internet_ip ]]
then
    #echo "域名解析正确，不需要修改"
    echo "The domain name is resolved correctly, no need to modify."
else
    #echo "域名解析错误，现在开始修改"
    echo "Domain name resolution error, now start to modify."
    #aliyun alidns UpdateDomainRecord --profile 001 --region cn-hangzhou --RecordId $record_id --RR www --Type A --Value  $internet_ip | tee ~/update_record.txt
    aliyun alidns UpdateDomainRecord --profile 001 --region cn-hangzhou --RecordId $record_id --RR www --Type A --Value $internet_ip > ~/update_record.txt
    #aliyun alidns UpdateDomainRecord --profile 001 --region cn-hangzhou --RecordId 20692214209797120 --RR www --Type A --Value  111.14.105.101 > ~/update_record.txt

    # -- 解析结果json --
    total=$(jq ". | length"  ~/update_record.txt | tr -d '"' ) #
    if [[ $total == "2" ]] #阿里云的cli在成功时只会返回两行，这里以此为判断依据，以后或许会修改
    then
	echo "Successfully modified."
    else
	echo "fail to edit."
    fi
    #requestid=$(jq ".RequestId"  ~/update_record.txt | tr -d '"' ) #
    # -- 解析结果json ^ --
fi

