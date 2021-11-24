#!/bin/bash

set -o nounset  # Treat unset variables as an error

export LC_ALL=C
#export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

logfile="agent360.log"

logtoken=${2:-notset}

#: Check root privilege :#
if [ "$(id -u)" != "0" ];
then
   echo "error: Installer needs root permission to run, please run as root."
   exit 1
fi

touch /var/log/agent360.log

pathfix () {
        if ! echo "$PATH" | /bin/grep -Eq "(^|:)$1($|:)" ; then
           if [ "$2" = "after" ] ; then
              PATH="$PATH:$1"
           else
              PATH="$1:$PATH"
           fi
        fi
}

pathfix /usr/local/bin/ after

__Requirements(){
   cat<<REQUIREMENTS

   An error occured, please check the install log file (agent360.log)!

REQUIREMENTS
}


__Norce(){
   cat<<Notic

   Notic: Userid argument missing
   Example: bash agent360.sh userid

Notic
}

Linux_Release(){

   FORCE_OS="defaultv"

   for i in $ARGUMENTS;
   do
       case $i in
           --os=*)
           FORCE_OS="${i#*=}"
           shift # past argument=value
           ;;
       esac
   done

   if [[ "$FORCE_OS" != "defaultv" ]]; then
      echo "$FORCE_OS"
   elif [ -e '/etc/os-release' ] || [ -e '/etc/redhat-release' ] || [ -e 'lsb_release' ] || [ -e '/etc/debian-release' ]; then
      Debian=$( cat /etc/*-release | grep -o debian | head -1 )
      Ubuntu=$( cat /etc/*-release | grep -o ubuntu | head -1 )
      CentOS=$( cat /etc/*-release | grep -io centos| head -1 )
      Sangoma=$( cat /etc/*-release | grep -io sangoma| head -1 )
      Scientific=$( cat /etc/*-release | grep -io scientific| head -1 )
      Oracle=$( cat /etc/*-release | grep -io Oracle| head -1 )
      Fedora=$( cat /etc/*-release | grep -o fedora | head -1 )
      CloudLinux=$( cat /etc/*-release | grep -io cloudlinux| head -1 )
      Freepbx=$( cat /etc/*-release | grep -io SHMZ | head -1 )
      Amazon=$( cat /etc/*-release | grep -o amazon | head -1 )

      if [ -e 'lsb_release' ]; then
          Debian=$( lsb_release -ds | grep -io debian | head -1 | tr '[:upper:]' '[:lower:]')
          Ubuntu=$( lsb_release -ds | grep -io ubuntu | head -1 | tr '[:upper:]' '[:lower:]')
          CentOS=$( lsb_release -ds | grep -io centos| head -1 | tr '[:upper:]' '[:lower:]')
          Fedora=$( lsb_release -ds | grep -io fedora | head -1 | tr '[:upper:]' '[:lower:]')
      fi

      if [ "$Ubuntu" == 'ubuntu' ]; then
         echo "Ubuntu"
      elif [ "$Debian" == 'debian' ]; then
         echo "Debian"
      elif [ "$Oracle" == 'Oracle' ]; then
         echo "CentOS"
      elif [ "$Sangoma" == 'Sangoma' ]; then
         echo "CentOS"
      elif [ "$CentOS" == 'centos' ]; then
         echo "CentOS"
      elif [ "$CentOS" == 'CentOS' ]; then
         echo "CentOS"
      elif [ "$Freepbx" == 'SHMZ' ]; then
         echo "CentOS"
      elif [ "$Scientific" == 'Scientific' ]; then
         echo "CentOS"
      elif [ "$CloudLinux" == 'CloudLinux' ]; then
         echo "CentOS"
      elif [ "$Amazon" == 'amazon' ]; then
         echo "Amazon"
      elif [ "$Fedora" == 'fedora' ]; then
         echo "CentOS"
      else
         __Requirements
      fi
   elif [ "$(uname)" == 'FreeBSD' ]; then
      echo "FreeBSD"
   fi
}

ARGUMENTS="$@"

Linux_Version(){

   install "$(get_installer)" less
   FORCE_VERSION="defaultv"

   for i in $ARGUMENTS;
   do
       case $i in
           --osversion=*)
           FORCE_VERSION="${i#*=}"
           shift # past argument=value
           ;;
       esac
   done

   if [[ "$FORCE_VERSION" != "defaultv" ]]; then
      echo "$FORCE_VERSION"
   elif command -v lsb_release >/dev/null 2>&1; then
      VERSION_ID=$(lsb_release -r | sed 's/[\t: a-z A-Z()]//g' | head -1 | cut -d "." -f1)
      VERSION=${VERSION_ID%.*}
      echo "$VERSION"
   elif [ -e "/etc/os-release" ]; then
      VERSION_ID=$(less /etc/os-release | grep VERSION_ID | head -1 | sed 's/VERSION_ID=//' | sed 's/"//' | sed 's/"//')
      VERSION=${VERSION_ID%.*}
      echo "$VERSION"
   elif [ -e "/etc/centos-release" ]; then
      CentOS_ID=$(less /etc/centos-release | sed 's/[a-z A-Z()]//g' | head -1)
      CentOS_VERSION=${CentOS_ID%.*}
      echo "$CentOS_VERSION"
   elif [ -e "/etc/system-release" ]; then
      CentOS_ID=$(less /etc/system-release | sed 's/[a-z A-Z()]//g' | head -1)
      CentOS_VERSION=${CentOS_ID%.*}

      echo "$CentOS_VERSION"
   elif [ -e "/etc/redhat-release" ]; then
      CentOS_ID=$(less /etc/redhat-release | sed 's/[a-z A-Z()]//g' | head -1)
      CentOS_VERSION=${CentOS_ID%.*}

      echo "$CentOS_VERSION"
   elif [ -e "/etc/debian-release" ]; then
      Debian_ID=$(less /etc/debian-release | sed 's/[a-z A-Z()]//g' | head -1)
      Debian_ID=${VERSION_ID%.*}

      echo "$Debian_ID"
  fi

}

#: Function for install programes :#
install () {
   installer="$1"
   program="$2"
   "$installer" install -y "$program" >> $logfile 2>&1
   rc=$?
   if [ "$rc" != "0" ]; then
        echo Installer exited with error code $?. See $logfile for details.
        exit
   fi
 }

#: Get installer for courrect platform :#
get_installer () {
   case $(Linux_Release) in
      Debian*)
         apt-get update >> $logfile 2>&1
         rc=$?
         if [ "$rc" != "0" ]; then
                echo apt-get upgrade returned error code $rc. Please see $logfile for details.
                exit
         fi
         echo "apt-get";;
      Ubuntu*)
         apt-get update >> $logfile 2>&1
         rc=$?
         if [ "$rc" != "0" ]; then
                echo apt-get upgrade returned error code $rc. Please see $logfile for details.
                exit
         fi
         echo "apt-get";;
      CentOS*)
         echo "yum";;
      Fedora*)
         echo "yum";;
      Amazon*)
         echo "yum";;
      FreeBSD*)
         echo "pkg";;
   esac
}

ensure_PIP(){
   if [ -e '/usr/bin/pip' ] || [ -e '/usr/bin/pip3' ] || [ -e '/usr/bin/easy_install' ]; then
      echo "installed"
   else
      echo "pip is not installed"
   fi
}


ensure_agent360(){
   if [ -e "$( command which agent360)" ]; then
      echo "installed"
   else
      echo "agent360 is not installed"
   fi
}

Service_Name="agent360"
setupsystemd(){


   if [ -e "$( command which agent360)" ]; then
      agent360_path="$(which agent360)"
   else
      agent360_path="/usr/local/bin/agent360"
   fi

      echo "Creating and starting service"
cat << EOF > /etc/systemd/system/agent360.service
[Unit]
Description=agent360

[Service]
ExecStart=$agent360_path
User=agent360

[Install]
WantedBy=multi-user.target
EOF
    if test -x /usr/bin/agent360 && ! test -x /usr/local/bin/agent360; then
        ln -s /usr/bin/agent360 /usr/local/bin
    fi
      command chmod 644 /etc/systemd/system/agent360.service
      command systemctl daemon-reload; systemctl enable agent360; systemctl start agent360
      echo "Created the agent360 service"
}
setupchkconfig(){
agent360_path="$(which agent360)"
cat << EOF > "/etc/init.d/agent360"
#!/bin/sh
#       /etc/rc.d/init.d/agent360
#       Init script for agent360
# chkconfig:   2345 20 80
# description: Init script for agent360 monitoring agent

### BEGIN INIT INFO
# Provides:       daemon
# Required-Start: \$rsyslog
# Required-Stop:
# Should-Start:
# Should-Stop:
# Default-Start: 2 3 4 5
# Default-Stop:  0 1 6
# Short-Description: agent360 monitoring agent
# Description: agent360 monitoring agent
### END INIT INFO

# Source function library.
. /etc/rc.d/init.d/functions

prog=agent360
app=$agent360_path
pid_file=/var/run/agent360.pid
lock_file=/var/lock/subsys/agent360
proguser=agent360

[ -e /etc/sysconfig/\$prog ] && . /etc/sysconfig/\$prog

start() {
    [ -x \$exec ] || exit 5
    echo -n \$"Starting \$prog: "
    daemon --user \$proguser --pidfile \$pid_file "nohup \$app >/dev/null 2>&1 &"
    RETVAL=\$?
    [ \$RETVAL -eq 0 ] && touch \$lock_file
    echo
    return \$RETVAL
}

stop() {
    echo -n \$"Stopping \$prog: "
    killproc \$prog
    RETVAL=\$?
    echo
    [ \$RETVAL -eq 0 ] && rm -f \$lock_file
    return \$RETVAL
}

restart() {
    stop
    start
}

rh_status() {
    status \$prog
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "\$1" in
    start)
        rh_status_q && exit 0
        \$1
        ;;
    stop)
        rh_status_q || exit 0
        \$1
        ;;
    restart)
        \$1
        ;;
    status)
        rh_status
        ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
        ;;
    *)
        echo \$"Usage: \$0 {start|stop|status|restart}"
        exit 2
esac
exit \$?
EOF
 chmod +x /etc/init.d/agent360
 command chkconfig --add agent360
 command chkconfig agent360 on
 command service agent360 start

}
setupbsd(){
agent360_path="$(which agent360)"
      echo
      echo "Creating and starting service"
      echo
cat << EOF > "/etc/rc.d/agent360"
#!/bin/sh
#
# PROVIDE: agent360
# REQUIRE: networking
# KEYWORD: shutdown

. /etc/rc.subr

name="agent360"
rcvar="\${name}_enable"

load_rc_config \$name
: \${agent360_enable:=no}
: \${agent360_bin_path="/usr/local/bin/agent360"}
: \${agent360_run_user="agent360"}

pidfile="/var/run/agent360.pid"
logfile="/var/log/agent360.log"

command="\${agent360_bin_path}"

start_cmd="agent360_start"
status_cmd="agent360_status"
stop_cmd="agent360_stop"

agent360_start() {
    echo "Starting \${name}..."
    /usr/sbin/daemon -u \${agent360_run_user} -c -p \${pidfile} -f \${command}
}

agent360_status() {
    if [ -f \${pidfile} ]; then
       echo "\${name} is running as \$(cat \$pidfile)."
    else
       echo "\${name} is not running."
       return 1
    fi
}

agent360_stop() {
    if [ ! -f \${pidfile} ]; then
      echo "\${name} is not running."
      return 1
    fi

    echo -n "Stopping \${name}..."
    kill -KILL \$(cat \$pidfile) 2> /dev/null && echo "stopped"
    rm -f \${pidfile}
}

run_rc_command "\$1"
EOF
      command chmod +x /etc/rc.d/agent360

      command echo $'\n'"agent360_enable=\"YES\"" >> /etc/rc.conf
      command service agent360 start
      echo
      echo "Service is created. Service Name is agent360"
      echo
}


amazonlinux() {
agent360_path="$(which agent360)"

if  [ -x "$(command -v systemctl)" ]; then
cat << EOF > /etc/systemd/system/agent360.service
[Unit]
Description=agent360

[Service]
ExecStart=$agent360_path
User=agent360

[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl start agent360
else
        wget -O /etc/init.d/agent360 https://monitoring.platform360.io/scripts/init/amazonlinux.txt
        chmod 755 /etc/init.d/agent360
        service agent360 start
        chkconfig agent360 on
fi

}

setupinitd() {
agent360_path="$(which agent360)"
cat << EOF > /etc/init.d/agent360
#!/bin/bash

### BEGIN INIT INFO
# Provides:          agent360
# Required-Start:    \$remote_fs \$syslog
# Required-Stop:     \$remote_fs \$syslog
# Should-Start:      \$network \$named \$time
# Should-Stop:       \$network \$named \$time
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start and stop the agent360 daemon
# Description:       Controls the agent360 monitoring daemon agent360
### END INIT INFO

. /lib/lsb/init-functions

PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
DAEMON=$agent360_path
NAME=agent360
DESC=agent360
PIDFILE=/var/run/agent360.pid

test -x \$DAEMON || exit 0
set -e

function _start() {
    start-stop-daemon --start --quiet --name \$NAME --oknodo --pidfile \$PIDFILE --chuid agent360 --background --make-pidfile --startas \$DAEMON
}

function _stop() {
    start-stop-daemon --stop --quiet --name \$NAME --pidfile \$PIDFILE --oknodo --retry 3
    rm -f \$PIDFILE
}

function _status() {
    start-stop-daemon --status --quiet --pidfile \$PIDFILE
    return \$?
}

case "\$1" in
        start)
                echo -n "Starting \$DESC: "
                _start
                echo "ok"
                ;;
        stop)
                echo -n "Stopping \$DESC: "
                _stop
                echo "ok"
                ;;
        restart|force-reload)
                echo -n "Restarting \$DESC: "
                _stop
                sleep 1
                _start
                echo "ok"
                ;;
        status)
                echo -n "Status of \$DESC: "
                _status && echo "running" || echo "stopped"
                ;;
        *)
                N=/etc/init.d/\$NAME
                echo "Usage: \$N {start|stop|restart|force-reload|status}" >&2
                exit 1
                ;;
esac

exit 0
EOF
chmod 755 /etc/init.d/agent360
update-rc.d agent360 defaults
service agent360 start

if [ -x "$agent360_path" ];
then
   echo "agent360 succesfully started and is running."
else
   echo "agent360 failed to start, check check agent360.log for debug information."
   exit 1
fi
}
systemd(){
   if [ "$(uname)" == 'FreeBSD' ]; then
    setupbsd
   elif which systemctl > /dev/null 2>&1; then
        setupsystemd
   elif [ "$(Linux_Release)" == 'CentOS' ] && ! which systemctl > /dev/null 2>&1; then
    setupchkconfig
   else
    setupinitd
   fi
}

if [ ! -f /etc/agent360.ini ]; then
    wget -qO /etc/agent360.ini https://monitoring.platform360.io/agent360.ini
fi
case $(Linux_Release) in
   Debian*)
      if [ "$(Linux_Version)" -ge 6 ]; then
         if [ $# -lt 1 ]; then
            echo "agent360 userid missing from the installer."
            __Norce
            exit 1
            #else
         fi

        id agent360 &>/dev/null
        if [[ $? -ne 0 ]]; then
                useradd --system --user-group --key USERGROUPS_ENAB=yes -M agent360 --shell /bin/false
                chown agent360 /var/log/agent360.log
        fi

         if [ "$(ensure_PIP)" != 'installed' ]  || ! which pip >/dev/null 2>&1; then
            echo "Installing ..."

           if [ "$(Linux_Version)" -ge 9 ]; then
               echo "Installing python3-pip ..."
               install "$(get_installer)" python3-dev
               install "$(get_installer)" python3-setuptools
               install "$(get_installer)" gcc
               install "$(get_installer)" python3-pip
           else
                echo "Installing python2-pip ..."
                install "$(get_installer)" python-dev
                install "$(get_installer)" libffi-dev
                install "$(get_installer)" libssl-dev
                install "$(get_installer)" python-setuptools
                install "$(get_installer)" gcc
                install "$(get_installer)" libevent-dev
                install "$(get_installer)" python-pip
                hash -r

                echo "Installing agent360 ... "
                command  pip install --upgrade pip >>$logfile 2>&1
                rc=$?
                    if [ "$rc" != "0" ]; then
                    echo pip install/upgrade returned error $?. Please see $logfile for details.
                    exit
                fi
                command  pip install agent360 --upgrade >>$logfile 2>&1
                rc=$?
                if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                    # 127 is warning probably on urllib3
                    command  pip2.7 install agent360 --upgrade >>$logfile 2>&1

                    rca=$?
                    if [ "$rca" != "0" ] && [ "$rca" != "127" ]; then
                        echo pip install of agent360 returned error $?. Please see $logfile for details.
                        exit
                    fi
                fi
            fi
         else
            install "$(get_installer)" python-dev
            install "$(get_installer)" libffi-dev
            install "$(get_installer)" libssl-dev
            install "$(get_installer)" python-setuptools
            install "$(get_installer)" libevent-dev
            install "$(get_installer)" gcc
            install "$(get_installer)" python-pip
            hash -r
         fi

         if [ "$(ensure_agent360)" != 'installed' ]; then
            echo "Installing agent360 ... "
           if [ "$(Linux_Version)" -ge 9 ]; then
               echo "Installing agent360 ... "
               command  pip3 install agent360 --upgrade >>$logfile 2>&1
               rc=$?
               if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                   echo pip install of agent360 returned error $?. Please see $logfile for details.
                   exit
               fi
           else
                install "$(get_installer)" python-dev
                install "$(get_installer)" libffi-dev
                install "$(get_installer)" libssl-dev
                install "$(get_installer)" python-setuptools
                install "$(get_installer)" gcc
                install "$(get_installer)" libevent-dev
                install "$(get_installer)" python-pip
                command  pip install agent360 --upgrade >>$logfile 2>&1
                rc=$?
                if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                    # 127 is warning probably on urllib3
                    command  pip2.7 install agent360 --upgrade >>$logfile 2>&1

                    rca=$?
                    if [ "$rca" != "0" ] && [ "$rca" != "127" ]; then
                        echo pip install of agent360 returned error $?. Please see $logfile for details.
                        exit
                    fi
                fi
                command  pip install --upgrade pip >> $logfile 2>&1
                rc=$?
                    if [ "$rc" != "0" ]; then
                    echo pip install/upgrade returned error $?. Please see $logfile for details.
                    exit
                fi
            fi

            echo "Generating a server id ..."

            if [ ! -f /etc/agent360-token.ini ]; then
                command hello360 "$1" /etc/agent360-token.ini
            fi
            systemd "$1"

         else
               hash -r
               echo "Upgrading agent360"
              if [ "$(Linux_Version)" -ge 9 ]; then
                  echo "Installing python3-pip ..."
                  install "$(get_installer)" python3-dev
                  install "$(get_installer)" python3-setuptools
                  install "$(get_installer)" gcc
                  install "$(get_installer)" python3-pip
                  echo "Installing agent360 ... "
                  command  pip3 install agent360 --upgrade >>$logfile 2>&1
                  rc=$?
                  if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                      echo pip install of agent360 returned error $?. Please see $logfile for details.
                      exit
                  fi
              else
                    install "$(get_installer)" python-dev
                    install "$(get_installer)" libffi-dev
                    install "$(get_installer)" libssl-dev
                    install "$(get_installer)" python-setuptools
                    install "$(get_installer)" gcc
                    install "$(get_installer)" libevent-dev
                    install "$(get_installer)" python-pip
                   command  pip install agent360 --upgrade >>$logfile 2>&1
                   rc=$?
                   if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                       # 127 is warning probably on urllib3
                       command  pip2.7 install agent360 --upgrade >>$logfile 2>&1

                       rca=$?
                       if [ "$rca" != "0" ] && [ "$rca" != "127" ]; then
                           echo pip install of agent360 returned error $?. Please see $logfile for details.
                           exit
                       fi
                   fi
               fi
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"
         fi
      else
         __Requirements
      fi;;

   Ubuntu*)
      if [ $# -lt 1 ]; then
         echo "agent360 userid missing from runner command."
         __Norce
         exit 1
      else

        id agent360 &>/dev/null
        if [[ $? -ne 0 ]]; then
                useradd --system --user-group --key USERGROUPS_ENAB=yes -M agent360 --shell /bin/false
                chown agent360 /var/log/agent360.log
        fi

         if [ "$(Linux_Version)" -ge 12 ]; then

            STR=$(dpkg -l libc6 | grep 2.31-0ubuntu9.3)
            SUB='2.31-0ubuntu9.3'

            if [[ "$STR" =~ .*"$SUB".* ]]; then
                echo "Broken libc version (2.31-0ubuntu9.3) found, we will try to fix it!"
                apt-get install libc6=2.31-0ubuntu9.2 libc-bin=2.31-0ubuntu9.2 libc6-i386=2.31-0ubuntu9.2 -y --allow-downgrades >> $logfile 2>&1
            fi

            if [ "$(ensure_PIP)" != 'installed' ]; then
               echo "Found Ubuntu ..."
               echo "Installing ..."
               echo "Installing Python2-PIP ..."
               if [ "$(Linux_Version)" -ge 16 ]; then
                   install "$(get_installer)"  python3-dev
                   install "$(get_installer)"  python3-setuptools
                   install "$(get_installer)"  gcc
                   install "$(get_installer)"  python3-pip
                   echo "Installing agent360 ... "
                   command  pip3 install agent360 --upgrade >>$logfile 2>&1
                   rc=$?
                   if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                       echo pip install of agent360 returned error $?. Please see $logfile for details.
                       exit
                   fi
               else
                   install "$(get_installer)"  python-dev
                   install "$(get_installer)"  python-setuptools
                   install "$(get_installer)"  gcc
                   install "$(get_installer)"  python-pip
                   echo "Installing agent360 ... "
                   command  pip install --upgrade pip urllib3 >> $logfile 2>&1
                   command  pip install agent360 --upgrade >> $logfile 2>&1
                   rc=$?
                   if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                       # 127 is warning probably on urllib3
                       if which pip2 >/dev/null; then
                           command  pip2 install agent360 --upgrade >>$logfile 2>&1
                           rcb=$?
                       else
                           command  pip2.7 install agent360 --upgrade >>$logfile 2>&1
                           rcb=$?
                       fi

                       if [ "$rcb" != "0" ] && [ "$rcb" != "127" ]; then
                           echo pip install of agent360 returned error $?. Please see $logfile for details.
                           exit
                       fi
                   fi
               fi


               echo "Generating a server id ..."
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"
            elif [ "$(ensure_agent360)" != 'installed' ]; then
               echo "Installing agent360 ... "
               if [ "$(Linux_Version)" -ge 16 ]; then
                   install "$(get_installer)"  python3-dev
                   install "$(get_installer)"  python3-setuptools
                   install "$(get_installer)"  gcc
                   install "$(get_installer)"  python3-pip
                   echo "Installing agent360 ... "
                   command  pip3 install agent360 --upgrade >>$logfile 2>&1
                   rc=$?
                   if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                       echo pip install of agent360 returned error $?. Please see $logfile for details.
                       exit
                   fi
               else
                   install "$(get_installer)"  python-dev
                   install "$(get_installer)"  python-setuptools
                   install "$(get_installer)"  gcc
                   install "$(get_installer)"  python-pip
                   echo "Installing agent360 ... "
                   command  pip install --upgrade pip urllib3 >> $logfile 2>&1
                   command  pip install agent360 --upgrade >> $logfile 2>&1
                   rc=$?
                   if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                       # 127 is warning probably on urllib3
                       if which pip2 >/dev/null; then
                           command  pip2 install agent360 --upgrade >>$logfile 2>&1
                           rcb=$?
                       else
                           command  pip2.7 install agent360 --upgrade >>$logfile 2>&1
                           rcb=$?
                       fi

                       if [ "$rcb" != "0" ] && [ "$rcb" != "127" ]; then
                           echo pip install of agent360 returned error $?. Please see $logfile for details.
                           exit
                       fi
                   fi
               fi

               echo "Generating a server id ..."
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"

            else
               echo "Upgrading agent360"

               if [ "$(Linux_Version)" -ge 16 ]; then
                   install "$(get_installer)"  python3-dev
                   install "$(get_installer)"  python3-setuptools
                   install "$(get_installer)"  gcc
                   install "$(get_installer)"  python3-pip
                   echo "Installing agent360 ... "
                   command  pip3 install agent360 --upgrade >>$logfile 2>&1
                   rc=$?
                   if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                       echo pip install of agent360 returned error $?. Please see $logfile for details.
                       exit
                   fi
               else
                   install "$(get_installer)"  python-dev
                   install "$(get_installer)"  python-setuptools
                   install "$(get_installer)"  gcc
                   install "$(get_installer)"  python-pip
                   echo "Installing agent360 ... "
                   command  pip install --upgrade pip urllib3 >> $logfile 2>&1
                   command  pip install agent360 --upgrade >> $logfile 2>&1
                   rc=$?
                   if [ "$rc" != "0" ] && [ "$rc" != "127" ]; then
                       # 127 is warning probably on urllib3
                       if which pip2 >/dev/null; then
                           command  pip2 install agent360 --upgrade >>$logfile 2>&1
                           rcb=$?
                       else
                           command  pip2.7 install agent360 --upgrade >>$logfile 2>&1
                           rcb=$?
                       fi

                       if [ "$rcb" != "0" ] && [ "$rcb" != "127" ]; then
                           echo pip install of agent360 returned error $?. Please see $logfile for details.
                           exit
                       fi
                   fi
               fi
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"
            fi
         fi
      fi;;

   CentOS*)
      if [ $# -lt 1 ]; then
         echo "agent360 userid missing from runner command."
         __Norce
         exit 1
      else
      echo "Found CentOS..."

        id agent360 &>/dev/null
        if [[ $? -ne 0 ]]; then
                useradd --system --user-group --key USERGROUPS_ENAB=yes -M agent360 --shell /bin/false
                chown agent360 /var/log/agent360.log
        fi

        if [ "$(Linux_Version)" -le 6 ] ; then
            echo "Got CentOS 6"
           if [ "$(ensure_PIP)" != 'installed' ]; then
              echo "Installing ..."
              echo "Installing python2-setuptools ..."
              install "$(get_installer)" python-devel
              install "$(get_installer)" python-setuptools
              install "$(get_installer)" gcc
              install "$(get_installer)" which
              if [ "$(cat /etc/*-release | grep -io Oracle| head -1)" != 'Oracle' ]; then
                install "$(get_installer)" libevent-devel
              fi
              echo "Installing agent360 ... "
              command easy_install agent360
              command easy_install netifaces
              command easy_install psutil

              echo "Generating a server id ..."
              if [ ! -f /etc/agent360-token.ini ]; then
                  command hello360 "$1" /etc/agent360-token.ini
              fi
              systemd "$1"

           elif [ "$(ensure_agent360)" != 'installed' ]; then
              echo "Installing agent360 ... "
              install "$(get_installer)" python-devel
              install "$(get_installer)" python-setuptools
              install "$(get_installer)" gcc
              install "$(get_installer)" which
              if [ "$(cat /etc/*-release | grep -io Oracle| head -1)" != 'Oracle' ]; then
                install "$(get_installer)" libevent-devel
              fi
              echo "Installing agent360 ... "
              command easy_install agent360
              command easy_install netifaces
              command easy_install psutil

              echo "Generating a server id ..."
              if [ ! -f /etc/agent360-token.ini ]; then
                  command hello360 "$1" /etc/agent360-token.ini
              fi
              systemd "$1"
           else
              echo "Upgrading agent360"
              install "$(get_installer)" python-devel
              install "$(get_installer)" python-setuptools
              install "$(get_installer)" gcc
              install "$(get_installer)" which
              if [ "$(cat /etc/*-release | grep -io Oracle| head -1)" != 'Oracle' ]; then
                install "$(get_installer)" libevent-devel
              fi
              install "$(get_installer)" which
              command easy_install -U agent360 >> $logfile 2>&1
              if [ ! -f /etc/agent360-token.ini ]; then
                  command hello360 "$1" /etc/agent360-token.ini
              fi
              systemd "$1"
           fi
        elif [ "$(Linux_Version)" -gt 7 ]; then
            echo "Got CentOS 8..."
            if [ "$(ensure_PIP)" != 'installed' ]; then
               echo "Installing agent360 for CentOS 8..."
               echo "Installing python3-pip ..."
               install "$(get_installer)" gcc
               install "$(get_installer)" which
               install "$(get_installer)" python36-devel
               install "$(get_installer)" python36

               echo "Installing agent360 ... "
               command pip3.6 install setuptools --upgrade
               command pip3.6 install agent360 --upgrade

               echo "Generating a server id ..."
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"
            elif [ "$(ensure_PIP)" == 'installed' ]; then
               echo "Installing agent360 for CentOS 8..."
               echo "Installing python3-pip ..."
               install "$(get_installer)" gcc
               install "$(get_installer)" which
               install "$(get_installer)" python36-devel
               install "$(get_installer)" python36

               echo "Installing agent360 ... "
               command pip3.6 install setuptools --upgrade
               command pip3.6 install agent360 --upgrade

               echo "Generating a server id ..."
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"
            elif [ "$(ensure_agent360)" != 'installed' ]; then
               echo "Installing agent360 for CentOS 8..."
               echo "Installing python3-pip ..."
               install "$(get_installer)" gcc
               install "$(get_installer)" which
               install "$(get_installer)" python36-devel
               install "$(get_installer)" python36

               echo "Installing agent360 ... "
               command pip3.6 install setuptools --upgrade
               command pip3.6 install agent360 --upgrade

               echo "Generating a server id ..."
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"
            else
               echo "Upgrading agent360"
               install "$(get_installer)" gcc
               install "$(get_installer)" which
               install "$(get_installer)" python36-devel
               install "$(get_installer)" python36
               command  pip3.6 install agent360 --upgrade >> $logfile 2>&1
               command  pip3.6 install psutil --upgrade >> $logfile 2>&1
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"

            fi
                 elif [ "$(Linux_Version)" -gt 6 ]; then
                    echo "Installing agent360 for CentOS 7..."
                     if [ "$(ensure_PIP)" != 'installed' ]; then
                        echo "Installing python-pip ..."
                        #if ! rpm -qa | grep -qw epel; then
                        #    command rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm >>$logfile 2>&1
                        #    rc=$?
                        #    if [ "$rc" != "0" ]; then
                        #        echo epel repo install returned error code $?. Please see $logfile for details.
                        #    fi
                        #fi
                        #install "$(get_installer)" epel-release
                        install "$(get_installer)" python3-devel
                        install "$(get_installer)" python3-pip
                        #install "$(get_installer)" python-wheel
                        install "$(get_installer)" python3-setuptools
                        if [ "$(cat /etc/*-release | grep -io Oracle| head -1)" != 'Oracle' ]; then
                          install "$(get_installer)" libevent-devel
                        fi
                        install "$(get_installer)" gcc
                        install "$(get_installer)" which
                        #wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
                        #python get-pip.py

                        echo "Installing agent360 ... "
                        #command pip3 install pip --upgrade
                        command pip3 install setuptools --upgrade
                        command pip3 install agent360 --upgrade

                        echo "Generating a server id ..."
                        if [ ! -f /etc/agent360-token.ini ]; then
                            command hello360 "$1" /etc/agent360-token.ini
                        fi
                        systemd "$1"
                     elif [ "$(ensure_PIP)" == 'installed' ]; then
                        echo "Installing agent360"
                        #install "$(get_installer)" epel-release
                        install "$(get_installer)" python3-devel
                        install "$(get_installer)" python3-pip
                        #install "$(get_installer)" python-wheel
                        install "$(get_installer)" python3-setuptools
                        install "$(get_installer)" which
                        install "$(get_installer)" gcc
                        if [ "$(cat /etc/*-release | grep -io Oracle| head -1)" != 'Oracle' ]; then
                          install "$(get_installer)" libevent-devel
                        fi
                        #command wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
                        #command python get-pip.py
                        #command easy_install pip
                        #command pip3 install pip --upgrade
                        command pip3 install setuptools --upgrade
                        command pip3 install agent360 --upgrade

                        #command easy_install pip
                        #command pip install agent360 --upgrade
                        #command easy_install netifaces
                        #command easy_install psutil

                        echo "Generating a server id ..."
                        if [ ! -f /etc/agent360-token.ini ]; then
                            command hello360 "$1" /etc/agent360-token.ini
                        fi
                        systemd "$1"
                     elif [ "$(ensure_agent360)" != 'installed' ]; then
                        echo "Installing agent360 ... "

                        install "$(get_installer)" which

                        install "$(get_installer)" python3-pip

                        install "$(get_installer)" python3-devel
                        install "$(get_installer)" python3-setuptools
                        install "$(get_installer)" gcc
                        if [ "$(cat /etc/*-release | grep -io Oracle| head -1)" != 'Oracle' ]; then
                          install "$(get_installer)" libevent-devel
                        fi
                        #command easy_install netifaces
                        #command easy_install psutil

                        command pip3 install pip --upgrade
                        command pip3 install setuptools --upgrade
                        command pip3 install agent360 --upgrade

                        echo "Generating a server id ..."
                        if [ ! -f /etc/agent360-token.ini ]; then
                            command hello360 "$1" /etc/agent360-token.ini
                        fi
                        systemd "$1"
                     else
                        echo "Upgrading agent360"
                        #install "$(get_installer)" epel-release
#                        install "$(get_installer)" python-pip
#                        install "$(get_installer)" python-wheel
#                        install "$(get_installer)" python-devel
#                        install "$(get_installer)" python-setuptools
#                        install "$(get_installer)" gcc
                        if [ "$(cat /etc/*-release | grep -io Oracle| head -1)" != 'Oracle' ]; then
                          install "$(get_installer)" libevent-devel
                        fi
                        install "$(get_installer)" which
                        command  pip install agent360 --upgrade >> $logfile 2>&1
                        command  pip install psutil --upgrade >> $logfile 2>&1
                        if [ ! -f /etc/agent360-token.ini ]; then
                            command hello360 "$1" /etc/agent360-token.ini
                        fi
                        systemd "$1"

                     fi
                  fi
      fi;;

   Amazon*)
      if [ $# -lt 1 ]; then
         echo "agent360 userid missing from runner command."
         __Norce
         exit 1
      else
      echo "Found Amazon Linux..."

        id agent360 &>/dev/null
        if [[ $? -ne 0 ]]; then
                useradd --system --user-group --key USERGROUPS_ENAB=yes -M agent360 --shell /bin/false
                chown agent360 /var/log/agent360.log
        fi
        command easy_install pip
       	install "$(get_installer)" python-devel
       	install "$(get_installer)" python-setuptools
       	install "$(get_installer)" python-pip
       	install "$(get_installer)" gcc
        install "$(get_installer)" which gcc libevent-devel python27-devel python27-setuptools python27-pip -q --skip-broken
       	if [ ! -f /usr/local/bin/pip2.7 ]; then
            pip install --upgrade pip
       	fi

       	if  [ -x "$(command -v pip)" ]; then
                command pip install --upgrade pip
               	command pip install agent360 --upgrade
        else
             	command /usr/local/bin/pip install --upgrade pip
                command /usr/local/bin/pip install agent360 --upgrade
       	fi

        if [ ! -f /etc/agent360-token.ini ]; then
           echo "Generating a server id ..."
           command hello360 "$1" /etc/agent360-token.ini
        fi
        amazonlinux "$1"
      fi;;

   Fedora*)
      if [ $# -lt 1 ]; then
         echo "agent360 userid missing from runner command."
         __Norce
         exit 1
      else

        id agent360 &>/dev/null
        if [[ $? -ne 0 ]]; then
                useradd --system --user-group --key USERGROUPS_ENAB=yes -M agent360 --shell /bin/false
                chown agent360 /var/log/agent360.log
        fi

        if [ "$(Linux_Version)" -ge 24 ]; then
            if [ "$(ensure_PIP)" != 'installed' ]; then
               echo "Installing ..."
               echo "Installing python2-pip ..."

               install "$(get_installer)" python-devel
               install "$(get_installer)" cairo-devel
               install "$(get_installer)" libffi-devel
               install "$(get_installer)" gcc
               install "$(get_installer)" gcc-c++
               install "$(get_installer)" kernel-devel
               install "$(get_installer)" libxslt-devel
               install "$(get_installer)" libffi-devel
               install "$(get_installer)" openssl-devel
               install "$(get_installer)" redhat-rpm-config
               install "$(get_installer)" python-pip

               echo "Installing agent360 ... "
               command  pip install --upgrade pip >> $logfile 2>&1
               command  pip install --upgrade agent360 >> $logfile 2>&1
               rc=$?
                if [ "$rc" != "0" ]; then
                   echo pip install/upgrade returned error $?. Please see $logfile for details.
                   exit
               fi
               command  pip install agent360 --upgrade >> $logfile 2>&1
               rc=$?
                if [ "$rc" != "0" ]; then
                   echo pip install of agent360 returned error $?. Please see $logfile for details.
                   exit
               fi


               echo "Generating a server id ..."
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"

            elif [ "$(ensure_agent360)" != 'installed' ]; then
               echo "Installing agent360 ... "
               install "$(get_installer)" cairo-devel
               install "$(get_installer)" libffi-devel
               install "$(get_installer)" gcc
               install "$(get_installer)" gcc-c++
               install "$(get_installer)" kernel-devel
               install "$(get_installer)" python-devel
               install "$(get_installer)" libxslt-devel
               install "$(get_installer)" libffi-devel
               install "$(get_installer)" openssl-devel
               install "$(get_installer)" redhat-rpm-config
               install "$(get_installer)" python-pip
               command pip install --upgrade pip urllib3 >> $logfile 2>&1
               rc=$?
               if [ "$rc" != "0" ]; then
                      command  pip-2.7 install pip urllib3 --upgrade >>$logfile 2>&1
                      rcb=$?
               fi

               command pip install agent360 --upgrade >> $logfile 2>&1
               rc=$?
               if [ "$rc" != "0" ]; then
                     command  pip-2.7 install agent360 --upgrade >>$logfile 2>&1
                     rcb=$?
               fi


               if ! test -x /usr/local/bin/agent360 && test -x /usr/bin/agent360; then
                    ln -s /usr/bin/agent360 /usr/local/bin
               fi
               rc=$?
                if [ "$rc" != "0" ]; then
                   echo pip install of agent360 returned error $?. Please see $logfile for details.
                   exit
               fi

               echo "Generating a server id ..."
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"

            else

               echo "Upgrading agent360"
               install "$(get_installer)" python-devel
               install "$(get_installer)" cairo-devel
               install "$(get_installer)" libffi-devel
               install "$(get_installer)" gcc
               install "$(get_installer)" gcc-c++
               install "$(get_installer)" kernel-devel
               install "$(get_installer)" libxslt-devel
               install "$(get_installer)" libffi-devel
               install "$(get_installer)" openssl-devel
               install "$(get_installer)" redhat-rpm-config
               install "$(get_installer)" python-pip
               command pip install agent360 --upgrade >> $logfile 2>&1
               if [ ! -f /etc/agent360-token.ini ]; then
                   command hello360 "$1" /etc/agent360-token.ini
               fi
               systemd "$1"

            fi
         fi
      fi;;

   FreeBSD*)
      if [ $# -lt 1 ]; then
         echo "agent360 userid missing from runner command."
         __Norce
         exit 1
      else

         id agent360 &>/dev/null
         if [[ $? -ne 0 ]]; then
             pw adduser agent360 -c "User for agent360" -s /usr/local/bin/bash
         fi
         if [ "$(ensure_PIP)" != 'installed' ]; then
            echo "Installing ..."
            echo "Installing python2-pip ..."
            install "$(get_installer)" py27-pip
            install "$(get_installer)" bash

            echo "Installing agent360 ... "
               command pip install --upgrade pip urllib3 >> $logfile 2>&1
               rc=$?
                if [ "$rc" != "0" ]; then
                   echo pip install/upgrade returned error $?. Please see $logfile for details.
                   exit
               fi
               command pip install agent360 --upgrade >> $logfile 2>&1
               rc=$?
                if [ "$rc" != "0" ]; then
                   echo pip install of agent360 returned error $?. Please see $logfile for details.
                   exit
               fi

            echo "Generating a server id ..."
            if [ ! -f /etc/agent360-token.ini ]; then
                command hello360 "$1" /etc/agent360-token.ini
            fi
            systemd "$1"

         elif [ "$(ensure_agent360)" != 'installed' ]; then
            echo "Installing agent360 ... "
               command pip install --upgrade pip urllib3 >> $logfile 2>&1
               rc=$?
                if [ "$rc" != "0" ]; then
                   echo pip install/upgrade returned error $?. Please see $logfile for details.
                   exit
               fi
               command pip install agent360 --upgrade >> $logfile 2>&1
               rc=$?
                if [ "$rc" != "0" ]; then
                   echo pip install of agent360 returned error $?. Please see $logfile for details.
                   exit
               fi

            echo "Generating a server id ..."
            if [ ! -f /etc/agent360-token.ini ]; then
                command hello360 "$1" /etc/agent360-token.ini
            fi
            systemd "$1"

         else

            echo "Generating a server id ..."
            if [ ! -f /etc/agent360-token.ini ]; then
                command hello360 "$1" /etc/agent360-token.ini
            fi
            systemd "$1"

         fi


      fi;;
   *)

      __Requirements
esac

chmod u+s $(which ping)