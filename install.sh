#!/bin/bash

# --------------------------------------------------------------------------
# Arquivo de instalação do riso e do risos
# --------------------------------------------------------------------------

dep_cli="avahi-utils rtorrent screen ntfs-3g ssh"
dep_ser="avahi-utils avahi-daemon bittorrent rtorrent screen ntfs-3g grub2 ssh coreutils mkisofs genisoimage findutils bash passwd sed squashfs-tools casper rsync mount eject libdebian-installer4 os-prober ubiquity user-setup discover laptop-detect syslinux xterm util-linux xresprobe cdrecord"

menu() {
    apt-get update
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
		"RISOS") instala_risos;;
		"RISO") instala_riso;;
		"RISOS RISO") instala_riso; instala_risos;;
	esac
}

instala_riso() {
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

instala_risos() {
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
    
    echo "Gerando chaves rsa..."
    ssh-keygen -t 'rsa' -f '/root/.ssh/id_rsa' -N ''
    su -c "cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys2"
    
    echo "Criando variáveis de configuração..."
    
    #Pega partições
    partrec=`df -T | awk 'NR==2{print $1}'`
    partwindows=`os-prober | grep Windows | cut -d':' -f1`
    partlinux=`os-prober | grep linux | cut -d':' -f1`
    partswap=`blkid | grep swap | grep -v ram | cut -d':' -f1`
    
    #Pega sistema de arquivo das partiçoes.
    sa_partrec=`df -T | awk 'NR==2{print $2}'`
    sa_partlinux=`blkid ${partlinux} | cut -d'"' -f4`
    sa_partwindows=`blkid ${partwindows} | cut -d'"' -f4`
    
    #Prepara grub2
    sed s/'GRUB_DISTRIBUTOR=*'/''/g -i /etc/default/grub
    echo 'GRUB_DISTRIBUTOR=Recuperacao' >> /etc/default/grub
    sed s/'#GRUB_DISABLE_LINUX_UUID=true'/'GRUB_DISABLE_LINUX_UUID=true'/g -i /etc/default/grub
    sed s/'#GRUB_DISABLE_LINUX_RECOVERY="true"'/'GRUB_DISABLE_LINUX_RECOVERY="true"'/g -i /etc/default/grub
    rm -f /etc/grub.d/20_memtest86+
    mv /etc/grub.d/10_linux /etc/grub.d/50_linux
    update-grub
  
    #Cria riso.service
    echo "Criando arquivo de configuração..."
    echo '<?xml version="1.0" standalone="no"?><!--*-nxml-*-->' > /etc/avahi/services/riso.service
    echo '<!DOCTYPE service-group SYSTEM "avahi-service.dtd">' >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '<!--riso.service -->' >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '<!--' >> /etc/avahi/services/riso.service
    echo '  Arquivo com as variáveis de configuração do riso.' >> /etc/avahi/services/riso.service
    echo '  Essas variáveis são usadas para efetuar a comunicação do servidor riso(risos) com os cliente(riso).' >> /etc/avahi/services/riso.service
    echo '  Para mais informações sobre o processo ver http://avahi.org' >> /etc/avahi/services/riso.service
    echo '-->' >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '<service-group>' >> /etc/avahi/services/riso.service
    echo '  <name>Servidor RISO DECOM</name>' >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '  <service>' >> /etc/avahi/services/riso.service
    echo '    <!--Nome do serviço-->' >> /etc/avahi/services/riso.service
    echo "    <type>_DECOM_RISO._tcp</type>" >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '    <!--Campo não é usado-->' >> /etc/avahi/services/riso.service
    echo '    <port>1234</port>' >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '    <!--Ip do servidor-->' >> /etc/avahi/services/riso.service # modifiçaco para guarda o ip do servidor
    echo "    <txt-record>Servidor=$servidor</txt-record>" >> /etc/avahi/services/riso.service #
    echo '' >> /etc/avahi/services/riso.service #
    echo '    <!--Variáveis com sistema de arquivo das partições-->' >> /etc/avahi/services/riso.service
    echo "    <txt-record>sa_partrec=${sa_partrec}</txt-record>" >> /etc/avahi/services/riso.service
    echo "    <txt-record>sa_partlinux=${sa_partlinux}</txt-record>" >> /etc/avahi/services/riso.service
    echo "    <txt-record>sa_partwindows=${sa_partwindows}</txt-record>" >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '    <!--Variáveis com tamanho das imagens geradas no servidor-->' >> /etc/avahi/services/riso.service
    echo '    <txt-record>tamlinux=123456789</txt-record>' >> /etc/avahi/services/riso.service
    echo '    <txt-record>tamwindows=123456789</txt-record>' >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '    <!--Localização dos sistemas operacionais no HD-->' >> /etc/avahi/services/riso.service
    echo "    <txt-record>partswap=${partswap}</txt-record>" >> /etc/avahi/services/riso.service
    echo "    <txt-record>partrec=${partrec}</txt-record>" >> /etc/avahi/services/riso.service
    echo "    <txt-record>partlinux=${partlinux}</txt-record>" >> /etc/avahi/services/riso.service
    echo "    <txt-record>partwindows=${partwindows}</txt-record>" >> /etc/avahi/services/riso.service
    echo '' >> /etc/avahi/services/riso.service
    echo '  </service>' >> /etc/avahi/services/riso.service
    echo '</service-group>' >> /etc/avahi/services/riso.service
    
    
    #Se estiver usando windows 7. Muda arquivo de boot para não usar mais UUID.
    windows7=`os-prober | grep "Windows 7"`
    if [ ! -z "$windows7" ]; then
        echo "Configurando Windows 7..."
	    umount /mnt 2> /dev/null
	    mount ${partwindows} /mnt
	    cp ./conf/BCD /mnt/Boot/BCD
	    umount /mnt 2> /dev/null
    fi

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
