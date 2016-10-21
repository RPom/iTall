# 1 INIT ENV
# 1.1 Set Java Verion
if [ ! -z $JAVA_VER ]; then
   export JAVA_HOME=`/usr/libexec/java_home -v $JAVA_VER`
fi
# 1.2 Set Maven Path
if [ ! -z $M2_HOME ]; then
   export PATH=${PATH};${M2_HOME}/bin
else

# 2 UPDATE M2 MODULES
if [ ! -z $MODULES_PATH ]; then
   cd $MODULES_PATH
# 2.1 M2 REINSTALL lcc common
   mvn install
fi

# 3 MAIN
if [ ! -z $SERVER_PATH ]; then
   cd $SERVER_PATH
fi

# 3.1 REMOVE CACHE SNAPSHOT JARS
if [ ! -z $PLAY_PATH ]; then
   for x in `find $PLAY_PATH -name *SNAPSHOT.jar`; do rm $x; done
fi

# 3.2 UPDATE PLAY MODULES
play update

# 3.3 DEBUG MODE
play debug
