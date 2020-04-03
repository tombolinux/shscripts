#!/bin/bash
#
# Scarico l'archivio java-jdk nella directory corrente da 
# https://www.oracle.com/java/technologies/javase-downloads.html
# fornisco il nome dell'archivio a questo script come argomento
#
# Tipicamente l'archivio java viene esploso in una specifica directory
# che contiene tutti i files, ne ricavo il nome
JDKDIR=`tar -tf $1 | head -1 | cut -f1 -d"/"` 
# estraggo i files in una directory in opt e se non esiste la creo
if [[ ! -d "/opt/java-jdk" ]]
then
	sudo mkdir /opt/java-jdk 
fi
# se la versione di java che ho fornito in argomento non è già presente 
# estraggo, installo e configuro
# se già presente configuro e basta (futile ma è un opzione di rollback)
if [[ ! -d "/opt/java-jdk/$JDKDIR" ]]
then
	sudo tar -C /opt/java-jdk -zxf $1
	sudo update-alternatives --install /usr/bin/java java /opt/java-jdk/$JDKDIR/bin/java 1
	sudo update-alternatives --install /usr/bin/javac javac /opt/java-jdk/$JDKDIR/bin/javac 1
	sudo update-alternatives --set  java /opt/java-jdk/$JDKDIR/bin/java
	sudo update-alternatives --set  javac /opt/java-jdk/$JDKDIR/bin/javac
else
	sudo update-alternatives --set  java /opt/java-jdk/$JDKDIR/bin/java
	sudo update-alternatives --set  javac /opt/java-jdk/$JDKDIR/bin/javac
fi
echo "Installazione e setup conclusi"

# variabili ambiente
JAVA_HOME=`readlink -f /usr/bin/java | sed "s:/bin/java::"`

if [ -f "/etc/profile.d/jdk.sh" ] || [ -f "/etc/profile.d/jdk.csh" ] ; then
        read -p "Sovrascrivo il file /etc/profile.d/jdk.sh? " YN
        if [ "$YN" != "${YN#[YySs]}" ] ; then
                echo "Ok"
                echo "export JAVA_HOME=$JAVA_HOME
export J2SDKDIR=$JAVA_HOME
export J2REDIR=$JAVA_HOME
export DERBY_HOME=$JAVA_HOME/db
export PATH=\$PATH:$JAVA_HOME/bin:$DERBY_HOME/bin" > jdk.sh
                echo "setenv JAVA_HOME $JAVA_HOME
setenv DERBY_HOME $JAVA_HOME/db
setenv J2SDKDIR $JAVA_HOME
setenv J2REDIR $JAVA_HOME
setenv PATH $"{"PATH}:$JAVA_HOME/bin:$DERBY_HOME/bin" > jdk.csh
                sudo mv jdk.sh /etc/profile.d/jdk.sh
                sudo mv jdk.csh /etc/profile.d/jdk.csh
                echo "if you want the correct enviroment variable in the current shell you have to run:
source /etc/profile.d/jdk.sh"
        else
                echo "Concludo con la sola installazione
Se servono variabili ambiente provvedi tu!"
        fi
fi
echo "Verifico installazione"
java --version
