#!/usr/bin/env bash
#
# boletim_aluno_grafico.sh
#
# ----------------------------------------------------------------------------------- #
# Informação do(s) Autor(es):
#
# E-mail:     luciobrito2012@gmail.com
# Autor:      Luciano Brito
# Telefone:   +55 61 995175170
# Manutenção: Luciano Brito
#
# ----------------------------------------------------------------------------------- #
#  Descrição: Sistema que faz o gerenciamento de usuários em modo texto, como:
#		inclusão, alterar, exclusão e consultar.
#
#  Exemplos:
#      	$ ./boletim_aluno_grafico.sh.sh
#      
# ----------------------------------------------------------------------------------- #
# Histórico:
#
#	v1.0 16/10/2019, Luciano:
#		- Tratamento de erros com relação aos arquivos de banco de dados.
#
#	v2.0 18/10/2019, Luciano:
#		- Removido funções OrdenaNotas e OrdenaAlunos
#		- Adicionado um arquivo temporário de banco de dados "banco_de_dados_lista.txt"
#			que carregará as informações as informações contidas nas outras duas tabelas
#			exibindo o histórico do aluno, bem como sua média final.
#
#	v3.0 18/10/2019, Luciano:
#		- Adicionado recursos gráficos do dialog em todo o código.
#		- Adicionado funções de retorno de comando na função ExcluiAluno e ValidaExixtenciaAluno
#		- Melhorado a disposição do código dentro do arquivo shell.
#		- Adicionado diversos dispositivos de prevenção de falhas no código.
#		- Adicionado função gráfica genérica "--yesno" chamada "SimNao". 
#		- Adicionado função gráfica genérica "--msgbox" chamada "Mensagem".
#		- Migrado todos os diálogos --msgbox para a função genérica "Mensagem".
#
#	v4.0 22/10/2019, Luciano
#		- Deslocado a opção "inserir aluno" para dentro da função "InsereAluno" 
#		- Criado a função de teste "ValidaExistenciaCadastro" para validar a existencia de registro
#		- Criado as funções "AlterarAluno" e "Alteracao" para realizar alteração dos registros
#		- Adicionado dispositivos de seguraça em todas as funções para evitar perda de dados e manipulação errada.
#		- Aprimorado a comunicação com o usuário.
#
#
#
#
# ----------------------------------------------------------------------------------- #
# Testado em:
#   bash 4.4.19
# ----------------------------------------------------------------------------------- #




# ------------------------------- VARIÁVEIS ----------------------------------------- #
ARQUIVO_BANCO_DE_DADOS_ALUNOS="banco_de_dados_alunos.txt"
ARQUIVO_BANCO_DE_DADOS_NOTAS="banco_de_dados_notas.txt"
ARQUIVO_BANCO_DE_DADOS_LISTA="banco_de_dados_lista.txt"
SEP=:
TEMP_ALUNOS=temp_alunos.$$
TEMP_NOTAS=temp_notas.$$
TEMP_LISTA=temp_lista.$$
VERMELHO="\033[31;1m"
AMARELO="\033[33;1mA"
VERDE="\033[32;1m"

# ----------------------------------------------------------------------------------- #

# ------------------------------- TESTES -------------------------------------------- #
[ ! -x "$(which dialog)" ] && sudo apt install dialog -y 1> /dev/null 2>&1

if [ ! -e "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" ]; then
	touch banco_de_dados_alunos.txt && \
	echo -e "# Banco de Dados de Alunos\n# PADRAO: id:nome:serie:turma:turno" > "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" && \
	chmod +rw "$ARQUIVO_BANCO_DE_DADOS_ALUNOS"
fi

if [ ! -e "$ARQUIVO_BANCO_DE_DADOS_NOTAS" ]; then
	touch banco_de_dados_notas.txt && \
	echo -e "# Banco de Dados de Notas\n# PADRAO: id:nota1:nota2:nota3:nota4" > "$ARQUIVO_BANCO_DE_DADOS_NOTAS" && \
	chmod +rw "$ARQUIVO_BANCO_DE_DADOS_NOTAS"
fi

if [ ! -e "$ARQUIVO_BANCO_DE_DADOS_LISTA" ]; then
	touch banco_de_dados_lista.txt
	echo -e "" > "$ARQUIVO_BANCO_DE_DADOS_LISTA" && \
	chmod +rw "$ARQUIVO_BANCO_DE_DADOS_LISTA"
else
	echo -e "" > "$ARQUIVO_BANCO_DE_DADOS_LISTA"
fi


[ ! -r "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" ] && echo "ERRO! Sem permissão de leitura em $ARQUIVO_BANCO_DE_DADOS_ALUNOS."	&& exit 1
[ ! -w "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" ] && echo "ERRO! Sem permissão de escrita em $ARQUIVO_BANCO_DE_DADOS_ALUNOS."	&& exit 1

[ ! -r "$ARQUIVO_BANCO_DE_DADOS_NOTAS" ] && echo "ERRO! Sem permissão de leitura em $ARQUIVO_BANCO_DE_DADOS_NOTAS."	&& exit 1
[ ! -w "$ARQUIVO_BANCO_DE_DADOS_NOTAS" ] && echo "ERRO! Sem permissão de escrita em $ARQUIVO_BANCO_DE_DADOS_NOTAS."	&& exit 1

[ ! -r "$ARQUIVO_BANCO_DE_DADOS_LISTA" ] && echo "ERRO! Sem permissão de leitura em $ARQUIVO_BANCO_DE_DADOS_LISTA."	&& exit 1
[ ! -w "$ARQUIVO_BANCO_DE_DADOS_LISTA" ] && echo "ERRO! Sem permissão de escrita em $ARQUIVO_BANCO_DE_DADOS_LISTA."	&& exit 1
# ----------------------------------------------------------------------------------- #

# ------------------------------- FUNÇÕES ------------------------------------------- #
ValidaExistenciaAluno() {
	grep -i -q "$1$SEP$2" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS"

	[ $? -eq 0 ] && return 0
}


ValidaExistenciaNota() {
	grep -i -q "$1$SEP$2$SEP$3$SEP$4$SEP$5" "$ARQUIVO_BANCO_DE_DADOS_NOTAS"
}


ValidaExistenciaCadastro() {

	local lista_alunos="$(egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" | sort -h )"
	if [ "$lista_alunos" ]; then
		return 0
	else
		return 1
	fi
}


ListaAlunos() {

	ValidaExistenciaCadastro
	if [ $? -eq 0 ]; then
	echo -e "" > "$ARQUIVO_BANCO_DE_DADOS_LISTA"
		local lista_alunos="$(egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" | sort -h )"
		if [ "$lista_alunos" ]; then
			egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" | sort -h > "$TEMP_ALUNOS"
			while read -r linha_arquivo_alunos; do
				id_aluno=$(echo $linha_arquivo_alunos 	| cut -d $SEP -f 1)
				nome=$(echo $linha_arquivo_alunos 		| cut -d $SEP -f 2)
				serie=$(echo $linha_arquivo_alunos 		| cut -d $SEP -f 3)
				turma=$(echo $linha_arquivo_alunos 		| cut -d $SEP -f 4)
				turno=$(echo $linha_arquivo_alunos 		| cut -d $SEP -f 5)
			
				ListaNotas "$id_aluno" "$nome" "$serie" "$turma" "$turno"
			done < $TEMP_ALUNOS
			return 0
		fi
	else
		Mensagem "ERRO!" "Não existe alunos cadastrados no sistema!"
		return 1		
	fi
 }


ListaNotas() {
	local id_notas="$1"
	local nome="$2"
	local serie="$3"
	local turma="$4"
	local turno="$5"

	egrep -v "^#|^$" "$ARQUIVO_BANCO_DE_DADOS_NOTAS" | sort -h > "$TEMP_NOTAS"

	while read -r linha_arquivo_notas; do
		
		if [ "$(echo $linha_arquivo_notas | cut -d $SEP -f 1)" = "$id_notas" ]; then
			
			nota1=$(echo "$linha_arquivo_notas" | cut -d $SEP -f 2)
			nota2=$(echo "$linha_arquivo_notas" | cut -d $SEP -f 3)
			nota3=$(echo "$linha_arquivo_notas" | cut -d $SEP -f 4)
			nota4=$(echo "$linha_arquivo_notas" | cut -d $SEP -f 5)

			echo "Matricula: $id_notas" >> "$TEMP_LISTA"
			echo "Nome: $nome" >> "$TEMP_LISTA"
			echo "Serie: $serie" >> "$TEMP_LISTA"
			echo "Turma: $turma" >> "$TEMP_LISTA"
			echo "Turno: $turno" >> "$TEMP_LISTA"
			echo "Nota 1: $nota1" >> "$TEMP_LISTA"
			echo "Nota 2: $nota2" >> "$TEMP_LISTA"
			echo "Nota 3: $nota3" >> "$TEMP_LISTA"
			echo "Nota 4: $nota4" >> "$TEMP_LISTA"

			media=$((($nota1+$nota2+$nota3+$nota4)/4))

			echo "Media Final: $media" >> "$TEMP_LISTA"

			if [ $media -lt 50 ]; then
				echo "Aluno Reprovado!" >> "$TEMP_LISTA"
			elif [ $media -ge 50 ]; then
				if [ $media -lt 60 ]; then
					echo "Aluno de Recuperação!" >> "$TEMP_LISTA"
				else
					echo "Aluno Aprovado!" >> "$TEMP_LISTA"
				fi
			fi
			echo "-----------------------------------------" >> "$TEMP_LISTA"
		else
			continue
		fi
	done < $TEMP_NOTAS

	local lista=$(cat "$TEMP_LISTA")

	cat "$TEMP_LISTA" >> "$ARQUIVO_BANCO_DE_DADOS_LISTA"
	dialog --title "Lista de Alunos Matriculados" --msgbox "$lista" 16 45

	#dialog --title "Lista de Alunos Matriculados:" --msgbox "$lista" 15 45
	#dialog --title "Lista de Alunos Matriculados:" --textbox "$TEMP_LISTA" 15 45

	rm -f "$TEMP_ALUNOS"
	rm -f "$TEMP_LISTA"
	rm -f "$TEMP_NOTAS"
}


InsereAluno() {
	ultimo_id="$(egrep -v "^#|^$" $ARQUIVO_BANCO_DE_DADOS_ALUNOS | sort -h | tail -n 1 | cut -d $SEP -f 1)"
	proximo_id=$(($ultimo_id+1))

	nome=$(dialog --title "Cadastro de Alunos" --stdout --inputbox "\n\nDigite o nome do aluno:" 15 55)
	nome="$(printf $nome | tr [A-Z] [a-z])"
	[ ! "$nome" ] && Main
	[ $nome -eq 0 ] && Main

	# Existe Aluno cadastrado?
	if [ "$(ValidaExistenciaAluno "$ultimo_id" "$nome")" ]; then
		Mensagem "ERRO FATAL!" "Aluno já cadastrado no sistema!"
		exit 1
	else
		serie=$(dialog --title "Cadastro de Alunos" --stdout --inputbox "\n\nDigite a série do aluno:" 15 55)
		serie="$(printf $serie | tr [A-Z] [a-z])"
		[ ! "$serie" ] && Main
		[ $serie -eq 0 ] && Main

		turma=$(dialog --title "Cadastro de Alunos" --stdout --inputbox "\n\nDigite a turma do aluno:" 15 55)
		turma="$(printf $turma | tr [A-Z] [a-z])"
		[ ! "$turma" ] && Main
		[ $turma -eq 0 ] && Main



		turno=$(dialog --title "Cadastro de Alunos" --stdout --inputbox "\n\nDigite o turno do aluno:" 15 55)
		turno="$(printf $turno | tr [A-Z] [a-z])"
		[ ! "$turno" ] && Main
		[ $turno -eq 0 ] && Main

		echo "$proximo_id$SEP$nome$SEP$serie$SEP$turma$SEP$turno" >> "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" && \
		InsereNotas "$proximo_id"
	fi

	ListaAlunos
}


InsereNotas() {
	local id_notas[0]=$1

	for (( i = 1; i < 5; i++ )); do
		id_notas[$i]=$(dialog --title "Cadastro de Notas" --stdout --inputbox "\n\nDigite $iª nota do aluno:" 15 55)

		[ $? -ne 0 ] && break && Main
		[ ! "${id_notas[$i]}" ] && exit 1
	done
	
	# Nota já cadastrada?
	if [ "$(ValidaExistenciaNota ${id_notas[@]})" ] ; then
		Mensagem "ERRO!" "Nota já lançada no sistema!"
		Main
	else
		echo "${id_notas[0]}$SEP${id_notas[1]}$SEP${id_notas[2]}$SEP${id_notas[3]}$SEP${id_notas[4]}" >> "$ARQUIVO_BANCO_DE_DADOS_NOTAS" && \
		Mensagem "SUCESSO!" "Aluno e notas cadastrados com sucesso!"
	fi
}


AlterarAluno() {
	ValidaExistenciaCadastro
	if [ $? -eq 0 ]; then
		while : ; do
			acao=$(dialog 	--title "Alteração de Cadastro" \
							--stdout \
							--menu 	"O que você deseja alterar?\n\nEscolha uma das opções abaixo:" \
							0 0 0 \
							nome 	"Altera o nome do aluno" \
							serie 	"Altera a serie do aluno" \
							turma 	"Altera a turma do aluno" \
							turno 	"Altera o turno do aluno" \
							notas 	"Altera notas do aluno" \
							voltar 	"...Voltar ao menu principal") 

			[ $? -ne 0 ] && SaiDoProrgama

			case $acao in
				nome) Alteracao  "B1" "nome"  ;;
				serie) Alteracao "B1" "serie" ;;
				turma) Alteracao "B1" "turma" ;;
				turno) Alteracao "B1" "turno" ;;
				notas) Alteracao "B2" "nota"  ;;
				voltar) Main ;;
			esac
		done
	else
		Mensagem "ERRO!" "Não existe alunos cadastrados no sistema!"
		return 1
	fi
}


Alteracao() {

	local registro="$1"
	local opcao="$2"
	local name="$(dialog --title "Menu de Alteração" --stdout --inputbox "\n\nDigite o nome do aluno:" 15 55)"
	name="$(printf $name | tr [A-Z] [a-z])"
	[ $name -eq 0 ] && Main
	[ ! "$name" ] && Main

	local indice="$(egrep -i "$SEP$name$SEP" $ARQUIVO_BANCO_DE_DADOS_ALUNOS | cut -d "$SEP" -f 1)"

	if [ "$registro" = "B1" ]; then
		old_data=$(dialog --title "Menu de Alteração" --stdout --inputbox "\n\nDigite a(o) antiga(o) $opcao:" 15 55)
		new_data=$(dialog --title "Menu de Alteração" --stdout --inputbox "\n\nDigite a(o) nova(o) $opcao:" 15 55)
		old_data="$(printf $old_data | tr [A-Z] [a-z])"
		new_data="$(printf $new_data | tr [A-Z] [a-z])"
		[ $old_data -eq 0 ] && Main
		[ ! "$old_data" ] && Main
		[ $new_data -eq 0 ] && Main
		[ ! "$new_data" ] && Main
		
		grep -i -v "^$indice$SEP" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS"
		
		if [ $? -eq 0 ]; then
			grep -i -v "^$indice$SEP" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" > "$TEMP_LISTA"
			grep -i "^$indice$SEP" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" | sed "s/$old_data/$new_data/" >> "$TEMP_LISTA"
			cat $TEMP_LISTA | sort -h > "$ARQUIVO_BANCO_DE_DADOS_ALUNOS"
			Mensagem "Menu de Alteração" "Alteração realizada com sucesso!"
		else
			Mensagem "Menu de Alteração" "Desculpe!\nA alteração não foi realizada.\nNão encontramos $opcao $old_data em nossos registros!"
		fi
	else
		old_data=$(dialog --title "Menu de Alteração" --stdout --inputbox "\n\nDigite a(o) antiga(o) $opcao:" 15 55)
		new_data=$(dialog --title "Menu de Alteração" --stdout --inputbox "\n\nDigite a(o) nova(o) $opcao:" 15 55)
		old_data="$(printf $old_data | tr [A-Z] [a-z])"
		new_data="$(printf $new_data | tr [A-Z] [a-z])"
		[ $old_data -eq 0 ] && Main
		[ ! "$old_data" ] && Main
		[ $new_data -eq 0 ] && Main
		[ ! "$new_data" ] && Main

		grep -i -v "^$indice$SEP" "$ARQUIVO_BANCO_DE_DADOS_NOTAS"
		
		if [ $? -eq 0 ]; then	
			grep -i -v "^$indice$SEP" "$ARQUIVO_BANCO_DE_DADOS_NOTAS" > "$TEMP_LISTA"
			grep -i "^$indice$SEP" "$ARQUIVO_BANCO_DE_DADOS_NOTAS" | sed "s/$old_data/$new_data/" >> "$TEMP_LISTA"
			cat $TEMP_LISTA | sort -h > "$ARQUIVO_BANCO_DE_DADOS_NOTAS"
			Mensagem "Menu de Alteração" "Alteração realizada com sucesso!"
		else
			Mensagem "ERRO!" "Desculpe! A alteração não foi realizada.\nNão encontramos $opcao $old_data em nossos registros!"
		fi
	fi

	rm -f "$TEMP_LISTA"
}


ExcluiAluno() {

	ValidaExistenciaCadastro
	if [ $? -eq 0 ]; then
		SimNao 'Exclusão de Aluno' "\nPara realizar a exclusão de um aluno será preciso informar, \
		primeiro o número de matrícula e depois o nome do aluno!\n\n \
		Você realmente deseja realizar a exclusão de aluno?"
		[ $? -ne 0 ] && Main

		ValidaExistenciaCadastro
		[ $? -ne 0 ] && Main

		local id=$(dialog --title "Exclusão de Aluno" --stdout --inputbox "\n\nInforme o número de matrícula do aluno a ser excluído:" 15 55)
		[ ! "$id" ] && Main
		
		local nome=$(dialog --title "Exclusão de Aluno" --stdout --inputbox "\n\nInforme o nome do aluno a ser excluído:" 15 55)
		[ ! "$nome" ] && Main

		ValidaExistenciaAluno "$id" "$nome"

		if [ $? -eq 0 ] ; then 
			grep -i -v "$id$SEP$nome" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS" > "$TEMP_ALUNOS"
			mv "$TEMP_ALUNOS" "$ARQUIVO_BANCO_DE_DADOS_ALUNOS"
			ExcluiRegistroDeNotas "$id" "$nome"
		else
			Mensagem "Exclusão de Aluno" "Aluno não encontrado!"
		fi
	else
		Mensagem "ERRO!" "Não existe alunos cadastrados no sistema!"
		return 1
	fi
}


ExcluiRegistroDeNotas() {
	local id="$1"
	local aluno="$2"

	grep -i -v "$id$SEP" "$ARQUIVO_BANCO_DE_DADOS_NOTAS" > "$TEMP_NOTAS"
	mv "$TEMP_NOTAS" "$ARQUIVO_BANCO_DE_DADOS_NOTAS"

	Mensagem "Exclusão de Aluno" "Registro do aluno $aluno excluído com sucesso!"
}


Mensagem() {
	dialog 	--title "$1" \
			--msgbox "\n\n$2" \
			15 55
}


SimNao() {
	dialog 	--title "$1" \
			--yesno "\n\n$2" \
			15 55
	return $?
}


SaiDoProrgama() {

	SimNao "SAIR" "Você realmente deseja sair do sistema?"

	[ $? -eq 0 ] && exit 0
}


# Menu Principal
Main() {
	while : ; do
		acao=$(dialog 	--title "Gerenciamento de Alunos 4.0" \
						--stdout \
						--menu 	"\nEscolha uma das opções abaixo:\n" \
						0 0 0 \
						listar 	"Lista todos os alunos do sistema" \
						inserir "Insere um novo aluno no sistema" \
						alterar "Altera o cadastro de aluno" \
						remover "Remove um aluno do sistema" \
						sair 	"Sai do Programa") 

		[ $? -ne 0 ] && SaiDoProrgama

		case $acao in
			listar) ListaAlunos ;;
			inserir) InsereAluno ;;
			alterar) AlterarAluno ;;
			remover) ExcluiAluno ;;
			sair) SaiDoProrgama ;;
		esac
	done
}

# ----------------------------------------------------------------------------------- #

# ------------------------------- EXECUÇÃO ------------------------------------------ #
Mensagem "Gerenciamento de Alunos 4.0" "Sistema de gerenciamento de notas de alunos em modo texto. \
 										\n\nTodos os registros serão disponibilizados para acesso \
 										no arquivo $ARQUIVO_BANCO_DE_DADOS_LISTA."
Main
exit 1
# ----------------------------------------------------------------------------------- #