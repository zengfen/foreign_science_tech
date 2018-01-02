#! /bin/sh 
basepath=$(cd `dirname $0`; pwd)
pids_path=${basepath}/tmp/pids/
echo $pids_path
if [ ! -d "$pids_path"]; then  
　　mkdir "$pids_path"  
fi  
bundle exec puma -C ./config/puma.rb -e development