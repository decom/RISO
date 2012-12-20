#!/bin/bash

#biblioteca com as funções
# help - creditos - atualiza - configurações 


#Help, i need somebody, HELP!
helpi() {
	dialog \
	--ok-label 'OK' \
	--title 'Help' \
	--msgbox '                                       \n
		Envie um e-mail com suas duvidas e sugestões \n
		para: "riso@comp.eng.br" e reponderei o   \n
		mais rápido possível.'                    \
		0 0
}

#Pessoas que fizeram acontecer
creditos() {

	dialog \
	--ok-label 'OK' \
	--title 'Creditos' \
	--msgbox '                                       \n
		 CENTRO FEDERAL DE EDUCAÇAO TECNOLOGICA  \n
		        Engenharia da Computaçao         \n
		                                         \n
		      Cristiano Goulart Lopes Dias       \n
		    Vinicius Tinti de Paula Oliveira     \n
		       Germano Teixeira de Miranda       \n
		        Gabriel de Souza Brandao         \n
		         Marcio J. Menezes Jr.           \n
		    Gabriel Machado de Castro Fonseca    \n
		      André Luiz Silveira Herculano      \n
		                                         \n
		           www.dgo.cefetmg.br            \n
		                                         \n'\
		  0 0
		  
}

#Atualiza R.I.S.O.
atualiza() {
	log "Iniciando atualização do script."
	log "Verificando disponibilidade do servidor de atualização."
	ping -q -c 1 200.131.37.236 > /dev/null 2>&1
	if [ "$?" -eq "0" ]; then
		log "Iniciando download do script novo."
		(wget 200.131.37.236/riso/riso0.5 -O /usr/riso/riso && log "RISO atualizado com sucesso.") || log "ERRO: Não foi possível baixar o novo script."
		
		#Menssagem de atualizado com sucesso.
		dialog \
	        --ok-label 'OK' \
        	--title 'Atenção' \
        	--msgbox '\n   RISO atualizado com sucesso.\n' \
		    7 39
		
		bash /usr/riso/riso
		exit
	else
		dialog \
		--ok-label 'OK' \
		--title 'ERRO' \
		--msgbox '\n   Esta versão já é a mais recente'\
		7 40
		log "ERRO: RISO já é a versão mais nova."
	fi
}

#Define configurações do riso
configuracoes() {
    dialog                                          \
    --title 'AVISO'                              \
    --yesno '\nAlterar esse arquivo é potencialmente
             perigoso, se não souber o que esta fazendo pare agora.\n\nDeseja continuar?'    \
    0 0
    if [ "$?" -eq "0" ]; then
		log "Iniciando configuração manual do arquivo de configuração."
		nano $riso_conf
		log "Finalizada a edição manual do arquivo de configuração."		
	fi

}
