# /etc/profile.d/oraenv.sh - set Oracle env

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export TNS_ADMIN=$ORACLE_HOME/network/admin
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE
