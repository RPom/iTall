export me_brhtmp=
export me_brhtmp2=
export me_brh=`git branch|grep -E '^\*'|sed 's/^\* *//g'`
export me_mode=$1
export me_mode=${me_mode:-auto}

if   [ "-a" = ${me_mode} ]; then export me_mode=auto
elif [ "-l" = ${me_mode} ]; then export me_mode=load
elif [ "-s" = ${me_mode} ]; then export me_mode=save
fi

if [ "auto" = ${me_mode} ]; then
	if   [ ! -z `git branch|grep -E '^\*'|grep -v 'temp'|sed 's/^\* *//g'` ]; then export me_mode=save
	elif [ ! -z `git branch|grep -E '^\*'|grep temp|sed 's/^\* *//g'`      ]; then export me_mode=load
	fi
	echo auto mode ${me_mode}
fi

if [ "save" = ${me_mode} ]; then
	export me_brh=`git branch|grep -E '^\*'|grep -v 'temp'|sed 's/^\* *//g'`
	if [ ! -z $me_brh ]; then  # {
		export me_brhtmp=`date +"%Y%m%d"|sed 's/\(.*\)/temp\/'${me_brh}'\/'${USER}'\/\1/g'`
		export me_brhtmp2=$me_brhtmp`git branch |grep $me_brhtmp|nl|tail -n 1|sed 's/^ *\([0-9][0-9]*\).*/\1/g'|xargs printf "%02s\n"`

		git branch $me_brhtmp2 && git checkout $me_brhtmp2
		#git reset --soft HEAD~1 && git reset
		git add -A && git reset *.sh && git commit -m "# DO NOT MERGE TEMP DATA "
		#git push
		git push -u origin $me_brhtmp2
		echo "temp $me_brh to $me_brhtmp2" # }
	else # {

		git branch|grep -E '^\*' |xargs echo "faild temp" # }
	fi
elif [ "load" = ${me_mode} ]; then
	export me_brhtmp=`git branch|grep -E '^\*'|grep temp|sed 's/^\* *//g'`
	export me_brh=
	if [ ! -z $me_brhtmp ]; then
		export me_brh=`echo $me_brhtmp|sed 's/^temp\/\([^\/]*\).*/\1/g'`
	fi
	if [ ! -z $me_brh ]; then
		git fetch -p && git pull
		#del remote branch
		git push origin --delete $me_brhtmp

		git checkout $me_brh && git pull
		git merge --no-commit $me_brhtmp
		git reset -q --soft origin/$me_brh
		git reset
		echo "load $me_brhtmp to $me_brh"
	else
		git branch|grep -E '^\*' |xargs echo "faild load"
	fi
else
	echo 
	echo "wrong mode" $me_mode "with" $me_brh
	echo 
	echo "sh temp.sh [-s][save][-l][load][-a][auto]"
	echo "   -s ,save : change work branch to new temp branch as 'temp/{BRANCH}/{USER}/{DATE}{SEQNO}' and push to remote."
	echo "   -l ,load : update work branch and temp branch from remote, and merge each other to work branch."
	echo "   -a ,auto : auto check mode."
	echo
	echo "git branch"
	echo
	echo "ex: at branch * iss0001"
	echo "    sh temp.sh -s"
	echo "    -> temp iss0001 to temp/iss0001/user001/20160101"
	echo
	echo "ex: at branch * temp/iss0001/user001/20160101"
	echo "    sh temp.sh -l"
	echo "    -> load temp/iss0001/user001/20160101 to iss0001"
fi
