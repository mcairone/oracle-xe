FROM oraclelinux
MAINTAINER Mario Cairone

ENV NGIX_URL  http://<ngix url and port>/files/xe

ENV _SCRATCH /tmp/scratch
ENV PASSWORD welcome1

ENV JDK_FILE jdk-8u77-linux-x64.tar.gz
ENV XE_ZIP  oracle-xe-11.2.0-1.0.x86_64.rpm.zip
ENV SCRIPT oraenv.sh

ENV ORA_HOME /u01/app/home  

RUN yum install -y -q libaio bc net-tools less telnet unzip && \
	mkdir -p ${ORA_HOME} && \
	mkdir -p ${_SCRATCH} && \
	curl -o  /etc/profile.d/oraenv.sh ${NGIX_URL}/${SCRIPT}&& \
    curl -o  ${_SCRATCH}/${XE_ZIP} ${NGIX_URL}/${XE_ZIP} && \
	curl -o  ${_SCRATCH}/${JDK_FILE} ${NGIX_URL}/${JDK_FILE} && \	
	chmod -R go+r ${_SCRATCH}/oracle-xe-11.2.0-1.0.x86_64.rpm.zip && \
	unzip -qq ${_SCRATCH}/oracle-xe-11.2.0-1.0.x86_64.rpm.zip -d ${_SCRATCH} && \
	rpm -ivh ${_SCRATCH}/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm && \


# Work around sysctl limitation of docker
    sed -i -e 's/^\(memory_target=.*\)/#\1/' /u01/app/oracle/product/11.2.0/xe/config/scripts/initXETemp.ora \
    && sed -i -e 's/^\(memory_target=.*\)/#\1/' /u01/app/oracle/product/11.2.0/xe/config/scripts/init.ora && \

# Database Configuration
    sed -i "s/ORACLE_PASSWORD=<value required>/ORACLE_PASSWORD=${PASSWORD}/g" \
	${_SCRATCH}/Disk1/response/xe.rsp && \
	sed -i "s/ORACLE_CONFIRM_PASSWORD=<value required>/ORACLE_CONFIRM_PASSWORD=${PASSWORD}/g" \
	${_SCRATCH}/Disk1/response/xe.rsp && \
	/etc/init.d/oracle-xe configure responseFile=${_SCRATCH}/Disk1/response/xe.rsp && \

# Change hostname in listener.ora e tnsnames.ora
    sed -i -E "s/HOST = [^)]+/HOST = 0.0.0.0/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora && \
    sed -i -E "s/HOST = [^)]+/HOST = 0.0.0.0/g" /u01/app/oracle/product/11.2.0/xe/network/admin/tnsnames.ora && \
    rm -rf ${_SCRATCH}

EXPOSE 1521 8080

CMD /etc/init.d/oracle-xe start && /bin/bash
