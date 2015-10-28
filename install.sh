#!/bin/bash

# --------------------------------------------------------------------------
# Arquivo de instalação do riso e do risos
# --------------------------------------------------------------------------

dep_cli="avahi-utils rtorrent screen ntfs-3g ssh"
dep_ser="avahi-utils avahi-daemon bittorrent rtorrent screen ntfs-3g grub2 ssh coreutils genisoimage findutils bash passwd sed squashfs-tools rsync mount eject libdebian-installer4 os-prober user-setup discover laptop-detect syslinux xterm util-linux apache2"

menu() {
    apt-get update
    apt-get autoremove -y
    apt-get install -y dialog
	opcao=$( dialog --stdout \
	--title	'Instalação do RISO' \
	--ok-label 'Confirmar'   \
	--checklist 'Deseja instalar:' \
	0 0 0 \
	RISOS '' ON  \
	RISO '' ON )

	# De acordo com a opção escolhida, executa funcoes
	case $opcao in
		"RISOS") instalar_risos;;
		"RISO") instalar_riso;;
		"RISOS RISO") instalar_riso; instalar_risos;;
	esac
}

instalar_riso() {
    echo "Instalando Cliente (RISO)..."
    
    echo "Baixando dependências..."
    for i in $dep_cli
    do
    	apt-get install -y $i
    	if [ "$?" != "0" ]; then
    		 echo "Falha ao instalar RISO - Erro ao baixar a dependência: $i"
    		 return 1
    	fi
    done
    
    echo "Criando árvore de diretórios..."
    mkdir -p /usr/riso
    mkdir -p /usr/riso/imagens
    
    echo "Criando arquivo de inicialização..."
    echo '#!/bin/bash' > /usr/bin/riso
    echo '/usr/riso/riso $@' >> /usr/bin/riso
    chmod +x /usr/bin/riso
    
    echo "Movendo script..."
    cp ./src/riso /usr/riso/riso
    cp ./src/quitRTorrent.sh /usr/riso/quitRTorrent.sh
    chmod +x /usr/riso/quitRTorrent.sh
    chmod +x /usr/riso/riso
    cp ./conf/riso.conf /usr/riso/riso.conf
    cp ./conf/.rtorrent.rc /root    

    echo "Sistema instalado com sucesso."
    echo "Tente digitar 'riso' para iniciar."
}

instalar_risos() {
    echo "Instalando Servidor (RISOS)..."
    servidor=`ip route | grep src | cut -d ' ' -f12`  
        
    echo "Liberando login como root..."
    echo -n "root:" > /etc/shadow.tmp
    pass=`cat /etc/shadow | grep \`who | awk 'NR==1{print $1}'\` | cut -d':' -f2`
    echo -n "${pass}:" >> /etc/shadow.tmp
    cat /etc/shadow | grep root | cut -d':' -f3,4,5,6,7,8,9 >> /etc/shadow.tmp
    cat /etc/shadow | grep -v root >> /etc/shadow.tmp
    mv /etc/shadow.tmp /etc/shadow
    
    echo "Baixando dependências..."
    for i in $dep_ser
    do
    	apt-get install -y $i
    	if [ "$?" != "0" ]; then
    		 echo "Falha ao instalar RISOS - Erro ao baixar a dependência: $i"
    		 return 1
    	fi
    done
    
    echo "Criando árvore de diretórios..."
    mkdir -p /usr/riso
    mkdir -p /usr/riso/imagens
    
    echo "Criando arquivo de inicialização..."
    echo '#!/bin/bash' > /usr/bin/risos
    echo '/usr/riso/risos $@' >> /usr/bin/risos
    chmod +x /usr/bin/risos
    
    echo "Movendo script..."
    cp ./src/risos /usr/riso/risos
    chmod +x /usr/riso/risos
    cp ./conf/BCD /usr/riso/
    	
    echo "Gerando chaves rsa..."
    ssh-keygen -t 'rsa' -f '/root/.ssh/id_rsa' -N ''
    su -c "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys2"
    
    echo "Criando variáveis de configuração..."
    
    #Prepara grub2
    sed /'GRUB_DISTRIBUTOR='/d -i /etc/default/grub
    echo 'GRUB_DISTRIBUTOR=Recuperacao' >> /etc/default/grub
    sed /'GRUB_TIMEOUT='/d -i /etc/default/grub
    echo 'GRUB_TIMEOUT=120' >> /etc/default/grub
    sed s/'#GRUB_DISABLE_LINUX_UUID=false'/'GRUB_DISABLE_LINUX_UUID=true'/g -i /etc/default/grub
    sed s/'#GRUB_DISABLE_LINUX_RECOVERY="false"'/'GRUB_DISABLE_LINUX_RECOVERY="true"'/g -i /etc/default/grub
    rm -f /etc/grub.d/20_memtest86+
    
    if [ -e /etc/grub.d/10_linux ]; then
        mv /etc/grub.d/10_linux /etc/grub.d/50_linux
    fi
    
    update-grub
    
    echo "Configurando serviço..."
    cp ./src/RISOServiceRemoval /etc/init.d/
    chmod 755 /etc/init.d/RISOServiceRemoval
    update-rc.d RISOServiceRemoval defaults 2> /dev/null 

    echo "Sistema instalado com sucesso"
    echo "Tente risos para iniciar"
}

#Verifica se usuário é o root antes de executar.
if [ $(id -u) -ne "0" ];then
	echo "Este script deve ser executado com o usuario root"
	echo "\"Great scripts come with great responsabilities...\" - Uncle Juan"
	exit 1
else
	menu
fi
