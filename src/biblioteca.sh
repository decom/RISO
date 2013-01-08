#!/bin/bash

#biblioteca com as funções
# help - creditos - atualiza - configurações 


#Help, i need somebody, HELP!
helpi() {
        zenity \
        --info \
        --title 'Help' \
        --text='                                       \n
                Envie um e-mail com suas duvidas e sugestões \n
                para: "riso@comp.eng.br" e reponderei o   \n
                mais rápido possível.'
}

#Pessoas que fizeram acontecer
creditos() {

        zenity \
        --info \
        --title 'Creditos' \
        --text='                                       \n
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
        	zenity --title="Atenção" \
       	        --warning --text="\n  Programa atualizado com sucesso.\n" \
		
		bash /usr/riso/riso
		exit
	else
        	zenity --title="Atenção" \
       	        --warning --text="Esta versão já é a mais recente"\

		log "ERRO: Esta já é a versão mais nova."
	fi
}

#Define configurações do riso
configuracoes() {

    zenity --title="AVISO" --question --text="Alterar esse arquivo é potencialmente perigoso, se não souber o 
que esta fazendo pare agora.\nDeseja continuar?"

    if [ "$?" -eq "0" ]; then
		log "Iniciando configuração manual do arquivo de configuração."
		nano $riso_conf
		log "Finalizada a edição manual do arquivo de configuração."		
	fi

}
