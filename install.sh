#!/bin/bash

# --------------------------------------------------------------------------
# Arquivo de instalação do sistema RISO
# --------------------------------------------------------------------------

dependencias="apache2 avahi-utils avahi-daemon bash bittorrent coreutils dialog findutils grub-efi mount ntfs-3g os-prober psmisc rtorrent sed ssh util-linux"

instalar() {

    echo "Atualizando sistema operacional"
    apt-get update
    apt-get autoremove -y
    
    echo "Obtendo dependências"
    for i in $dependencias
    do
    	apt-get install -y $i
    	if [ "$?" != "0" ]; then
    		 echo "Falha ao instalar - Erro ao baixar a dependência: $i"
    		 return 1
    	fi
    done
    
    echo "Criando árvore de diretórios"
    mkdir -p /usr/riso
    mkdir -p /usr/riso/imagens

    echo "Instalando scritps"
    cp ./src/riso /usr/riso/riso
    cp ./src/quitRTorrent.sh /usr/riso/quitRTorrent.sh
    chmod +x /usr/riso/quitRTorrent.sh
    chmod +x /usr/riso/riso
    cp ./conf/.rtorrent.rc /root
    cp ./src/risos /usr/riso/risos
    chmod +x /usr/riso/risos
    cp ./conf/BCD /usr/riso/
    echo '#!/bin/bash' > /usr/bin/riso
    echo '/usr/riso/riso $@' >> /usr/bin/riso
    chmod +x /usr/bin/riso
    echo '#!/bin/bash' > /usr/bin/risos
    echo '/usr/riso/risos $@' >> /usr/bin/risos
    chmod +x /usr/bin/risos
    
    echo "Configurando sistema de boot" 
    sed /'GRUB_DISTRIBUTOR='/d -i /etc/default/grub
    echo 'GRUB_DISTRIBUTOR=Recovery' >> /etc/default/grub
    sed /'GRUB_TIMEOUT='/d -i /etc/default/grub
    echo 'GRUB_TIMEOUT=-1' >> /etc/default/grub
    sed /'GRUB_DISABLE_LINUX_UUID='/d -i /etc/default/grub
    echo 'GRUB_DISABLE_LINUX_UUID=true' >> /etc/default/grub
    sed /'GRUB_DISABLE_LINUX_RECOVERY='/d -i /etc/default/grub
    echo 'GRUB_DISABLE_LINUX_RECOVERY="true"' >> /etc/default/grub
    rm -f /etc/grub.d/20_memtest86+
    if [ -e /etc/grub.d/10_linux ]; then
        mv /etc/grub.d/10_linux /etc/grub.d/50_linux
    fi
    update-grub
    
    echo "Configurando serviços do sistema"
    cp ./src/RISOServiceRemoval /etc/init.d/
    chmod 755 /etc/init.d/RISOServiceRemoval
    update-rc.d RISOServiceRemoval defaults 2> /dev/null
    sed s/'use-ipv6=yes'/'use-ipv6=no'/g -i /etc/avahi/avahi-daemon.conf   

    echo "Sistema instalado com sucesso."
}

#Verifica se usuário é o root antes de executar.
if [ $(id -u) -ne "0" ];then
	echo "Este script deve ser executado com o usuario root"
	echo "\"Great scripts come with great responsabilities...\" - Uncle Juan"
	exit 1
else
	instalar
fi
