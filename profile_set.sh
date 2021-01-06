#! /bin/bash
 # @filename            
 # @use                 
 # @datetime            2020-11-05 12:12:56.437282655 ,45, 4 310 CST +08:00:00
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
 #                      2020-11-05 12:12:56.437282655 ,45, 4 310 CST +08:00:00
 #                       建立本文件
 # @algorithm           --------- 算法↓ ---------
 #                      
 #                      
 # ---------  ---------
 # ---------  ---------
 # 
 # 
 
#





#aliyun configure set \
#  --profile akProfile \
#  --mode AK \
#  --region cn-hangzhou \
#  --access-key-id AccessKeyId \
#  --access-key-secret AccessKeySecret


# -- 程序安装 --
wget -c https://aliyuncli.alicdn.com/aliyun-cli-linux-latest-amd64.tgz

#aliyun-cli-linux-latest-amd64.tgz
tar -xzvf aliyun-cli-linux-latest-amd64.tgz

sudo cp aliyun /usr/local/bin
# -- 程序安装 ^ --

# -- 参数变量定义 --
profile_name='001'
mode='AK'
region='cn-hangzhou'
ak_id='' #AccessKeyId
ak_se='' #AccessKeySecret
# -- 参数变量定义 ^ --

# -- cli配置添加 --
aliyun configure set \
  --profile $profile_name \
  --mode $mode \
  --region $region \
  --access-key-id $ak_id \
  --access-key-secret $ak_se
# -- cli配置添加 ^ --

# -- cli配置查看 --
aliyun configure list
# -- cli配置查看 ^ --
