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



# -- 这一段里面的变量根据实际情况修改为你自己的 --
domain='so-u.info' #这个值根据实际情况修改
record='ddns' #这个值根据实际情况修改
# -- 这一段里面的变量根据实际情况修改为你自己的 ^ --

internet_ip=$(wget -qO - ifconfig.co) #得到目前的公网ip地址

record_id='' #后面会覆盖这个值，这里只作为声明用
value='' #后面会覆盖这个值，这里只作为声明用

#查出域名当前的解析情况
aliyun alidns DescribeDomainRecords --DomainName $domain --profile 001 > ~/domain_record.txt


# -- 解析结果json --

num=$(jq .TotalCount ~/domain_record.txt | tr -d '"' ) #得到解析数量
#echo $num

# 循环，找出 RR 为 $record 的数组序号

j=0 #同键冲突解决
for((i = 0; i < $num; i++)) #这个可以
do
    #echo "$integer"
    rr=$(jq ".DomainRecords.Record | .[$i].RR" ~/domain_record.txt | tr -d '"' ) #
    #echo $rr
    if [[ $rr == $record ]]
    then
	#遇到匹配的就放进数组里，然后将 $j 加一，
	record_indexs[$j]=$i
	((j++))
	record_index=$i
    else
	continue # for whild until
    fi
done

record_num=${#record_indexs[*]} #数组长度

#遍历 $record 的这些记录，确定 status 是enable 还是 disable ，找出 enable 的记录
j=0 #同键冲突解决
for((i = 0; i < $record_num; i++)) #
do
    status=$(jq ".DomainRecords.Record | .[${record_indexs[$i]}].Status" ~/domain_record.txt | tr -d '"' ) #

    #统计 enable 的个数，新建数组
    if [[ $status == "ENABLE" ]]
    then
	#遇到匹配的就放进数组里，然后将 $j 加一，
	enable_record[$j]=${record_indexs[$i]}
	((j++))
    fi
done

enable_num=${#enable_record[*]}

if [ "$enable_num" == "0" ]
then
    # -- 没找到记录时 --
    #添加一条记录
    aliyun alidns AddDomainRecord  --profile 001 --region cn-hangzhou --DomainName $domain --RR $record --Type TXT --Value "$internet_ip" > ~/add_record.txt
    # -- 解析结果json --
    total=$(jq ". | length"  ~/add_record.txt | tr -d '"' ) #
    if [[ $total == "2" ]] #阿里云的cli在成功时只会返回两行，这里以此为判断依据，以后或许会修改
    then
	#echo "Successfully modified."
	echo "Added successfully. ddns record now points to $internet_ip "
    else
	echo "Add failed."
    fi
    # -- 解析结果json ^ --
    rm ~/add_record.txt
    # -- 没找到记录时 ^ --
else
    # -- 找到了记录时 --
    if [[ $enable_num == "1" ]]
    then
	#只有一条记录
	record_id=$(jq ".DomainRecords.Record | .[${enable_record[0]}].RecordId" ~/domain_record.txt | tr -d '"' ) #
	value=$(jq ".DomainRecords.Record | .[${enable_record[0]}].Value" ~/domain_record.txt | tr -d '"' ) #
    else
	#不只一条记录
	for((i = 0; i < $enable_num ; i++)) #
	do
	    if [[ $i == "0" ]];
	    then
		record_id=$(jq ".DomainRecords.Record | .[${enable_record[$i]}].RecordId" ~/domain_record.txt | tr -d '"' ) #
		value=$(jq ".DomainRecords.Record | .[${enable_record[$i]}].Value" ~/domain_record.txt | tr -d '"' ) #
	    elif [[ $i > "0" ]];
	    then
		record_id_temp=$(jq ".DomainRecords.Record | .[${enable_record[$i]}].RecordId" ~/domain_record.txt | tr -d '"' ) #
		aliyun alidns DeleteDomainRecord  --profile 001 --region cn-hangzhou --RecordId $record_id_temp > ~/delete_record.txt
		echo "The redundant records have been deleted."
		rm ~/delete_record.txt
	    fi
	done
    fi
    # -- 检查并处理剩下的记录 --
    if [[ $value == $internet_ip ]]
    then
	echo "The domain name is resolved correctly, no need to modify."
    else
	aliyun alidns UpdateDomainRecord --profile 001 --region cn-hangzhou --RecordId $record_id --RR $record --Type A --Value $internet_ip > ~/update_record.txt

	# -- 解析结果json --
	total=$(jq ". | length"  ~/update_record.txt | tr -d '"' ) #
	if [[ $total == "2" ]] #阿里云的cli在成功时只会返回两行，这里以此为判断依据，以后或许会修改
	then
	    echo "Successfully modified."
	else
	    echo "Fail to edit."
	fi
	# -- 解析结果json ^ --
	rm ~/update_record.txt
    fi
    # -- 检查并处理剩下的记录 ^ --
    # -- 找到了记录时 ^ --
fi
# -- 解析结果json ^ --

rm ~/domain_record.txt



