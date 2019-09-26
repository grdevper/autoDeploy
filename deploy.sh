#!/usr/bin/env bash

# 环境感知
if [ $1 == 'release' ];then
  runtime='release'
  host=''
  user=''
  remotePath='/home/tomcat/node'
  buildCommand='build:preprod'
  remoteBranch='release'
  projectName=$2
  remoteProjectName=
  branchName='master'
else
  runtime='test'
  host='172.16.40.200'
  user='guorui'
  remotePath='gushou-work'
  buildCommand='build:test'
  remoteBranch='test'
  projectName=$2
  remoteProjectName=${projectName}'-test'
  branchName='test'
fi 

# 连接远程服务器
echo "正在连接远程"${runtime}"服务器"

ssh ${user}@${host} << eeooff
echo "构建环境中..."

cd ${remotePath}
# 删除老的文件夹
rm -rf ${remoteProjectName}
# 新建远程工程目录
mkdir ${remoteProjectName}
cd ${remoteProjectName}

# 创建git裸仓库，工作区目录
mkdir repos
mkdir ${projectName}

# 初始化裸仓库
cd repos
git init --bare ${projectName}-bare.git

# 修改裸仓库hook配置
cd ${projectName}-bare.git/hooks
cp post-update.sample post-update
cat >post-update<< EOF
#!/bin/bash

unset GIT_DIR
DIR_ONE=${remotePath}/${remoteProjectName}/${projectName}

cd $DIR_ONE
git init
git remote add origin ~/repos/${projectName}-bare.git
git clean -df
git pull origin ${branchName}

# npm run ${buildCommand}
# pm2 restart ${projectName}

exec git update-server-inf
EOF
exit
eeooff
echo '远程环境构建完成, 构建本地环境中'

# 初始化本地git
rm -rf .git
git init

#git remote set-url --add orgin ssh://${user}@${host}:20/${remotePath}/${remoteProjectName}/repos/${projectName}-bare.git

#git remote set-url --add origin https://github.com/grdevper/autoDeploy

git remote add origin https://github.com/grdevper/autoDeploy





