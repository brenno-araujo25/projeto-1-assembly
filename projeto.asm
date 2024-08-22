# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organização de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Araújo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vitória Félix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Projeto
# Descrição: Sistema de cadastro de pessoas e automóveis para um condomínio
# operado através de um terminal, funcionando como um interpretador de 
# comandos de texto.
# --------------------------------------------------------------------------

.data
	# Dados dos apartamentos
	apartamentos: .space 2880        # 24 apartamentos, cada um com espaço para 6 nomes de 20 caracteres (24*6*20)
	numMoradores: .space 24          # contador de moradores para cada apartamento
	veiculos: .space 576             # 24 apartamentos, cada um com espaço para 1 carro ou 2 motos,
					 # armazenando 5 espaços para modelo e 7 para placa (24*2*(5 + 7))
	numVeiculos: .space 24		 # contador de veículos para cada apartamento
	
	# Arquivo para persistência
	filename: .asciiz "dados.txt"
	file_descriptor: .word 0
	
	# Mensagens
	msg_ap_invalido: .asciiz "Falha: AP invalido\n"
	msg_max_moradores: .asciiz "Falha: AP com numero max de moradores\n"
	msg_morador_adicionado: .asciiz "Morador adicionado com sucesso\n"
	msg_morador_removido: .asciiz "Morador removido com sucesso\n"
	msg_morador_nao_encontrado: .asciiz "Falha: morador nao encontrado\n"
	msg_total_veiculos_atingido: .asciiz "Falha: máxmimo de veículos atingidos\n"
	msg_tipo_invalido: .asciiz "Falha: tipo de veículo inválido\n"
	msg_veiculo_nao_encontrado: .asciiz "Falha: veículo não encontrado\n"
	msg_veiculo_excluido: .asciiz "Veiculo excluido com sucesso\n"
	msg_comando_invalido: .asciiz "Comando invalido\n"
	msg_moradores: .asciiz "Moradores:\n"
	msg_ap_vazio: .asciiz "Apartamento vazio\n"
	msg_morador: .asciiz "Morador_"
	msg_espaco_apos_morador: .asciiz " "
	msg_formatado_sucesso: .asciiz "Todos os dados foram apagados. Lembre-se de salvar para persistir as alterações.\n"
	
	# Buffers
	input_buffer: .space 100	# buffer para armazenar o comando do usuário
	opcao1: .space 20		# buffer para armazenar a opcao1
	opcao2: .space 20		# buffer para armazenar a opcao2
	opcao3: .space 20		# buffer para armazenar a opcao3
	opcao4: .space 20		# buffer para armazenar a opcao4
		
	# Strings para comparar e encontrar o comando digitado
	str_add_morador: .ascii "addMorador"
	str_rmv_morador: .ascii "rmvMorador"
	str_add_auto: .ascii "addAuto"
	str_rmv_auto: .ascii "rmvAuto"
	str_limpar_ap: .ascii "limparAp"
	str_info_ap: .ascii "infoAp"
	str_formatar: .ascii "formatar"
	str_salvar: .ascii "salvar\n"
	
	# Banner com as iniciais do grupo
	banner: .asciiz "BCJL-shell>> "

.text
.globl main

main:

loop:
    	# imprime o banner
    	la $a0, banner
    	li $v0, 4
    	syscall

    	# lê a entrada do usuário
    	li $v0, 8                  	# syscall para leitura de string
    	la $a0, input_buffer      	# buffer para entrada do usuário
    	li $a1, 100                	# tamanho máximo
    	syscall

    	# parseia o comando
    	la $a0, input_buffer       	# buffer com o comando
    	jal parseCommand		# identifica qual comando foi digitado
	
    	# checa se o comando é válido
    	beq $v0, -1, invalid_command	# se retornou -1, o comando não foi reconhecido

    	# dependendo do comando, chama addMorador, rmvMorador, etc.
    	beq $v0, 0, call_add_morador
    	beq $v0, 1, call_rmv_morador
	beq $v0, 2, call_add_auto
	beq $v0, 3, call_rmv_auto
	beq $v0, 4, call_limpar_ap
	beq $v0, 5, call_info_ap
	beq $v0, 6, call_formatar
	beq $v0, 7, call_salvar
	
    	j loop                     	# volta ao loop de leitura

call_add_morador:
	li $a1, 13			# quantidade de bytes que vão ser pulados para extrair a primeira opção
	jal extrair_opcoes
	la $a0, opcao1
	la $a1, opcao2
	jal addMorador
	j loop

call_rmv_morador:
	li $a1, 13			# quantidade de bytes que vão ser pulados para extrair a primeira opção
	jal extrair_opcoes
	la $a0, opcao1
	la $a1, opcao2
	jal rmvMorador
	j loop
	
call_add_auto:
	jal extrair_opcoes2		# função que extrai 4 opções do comando do usuário
	la $a0, opcao1
	la $a1, opcao2
	la $a2, opcao3
	la $a3, opcao4
	jal addAuto
	j loop

call_rmv_auto:
	li $a1, 10			# quantidade de bytes que vão ser pulados para extrair a primeira opção
	jal extrair_opcoes		
	la $a0, opcao1
	la $a1, opcao2
	jal rmvAuto
	j loop
	
call_limpar_ap:
	li $a1, 11
	jal extrair_opcoes3		# função que extrai apenas 1 opção
	la $a0, opcao1
	jal limparAp
	j loop
	
call_info_ap:
	li $a1, 9
	jal extrair_opcoes3		# função que extrai apenas 1 opção
	la $a0, opcao1
	jal infoAp
	j loop

call_formatar:
	jal formatar
	j loop

call_salvar:
	jal saveData
	j loop

invalid_command:
    	# exibe mensagem de comando inválido
    	la $a0, msg_comando_invalido
    	li $v0, 4
    	syscall
    	j loop

# Função para adicionar um morador
# Parâmetros:
# $a0 = número do apartamento
# $a1 = nome do morador
addMorador:
    	# Verifica se o apartamento é válido
    	# Se o número de moradores for 6, exibe mensagem de erro
	addi $sp, $sp, -4		# reserva 1 espaço na pilha
	sw $ra, 0($sp)			# armazena o $ra
	
	jal readInt			# converte opcao1 ($a0) para inteiro
	
	lw $ra, 0($sp)			# recupera o valor do $ra
	addi $sp, $sp, 4		# restaura a pilha
	
	move $a0, $v0			# $a0 = opcao1 convertida para inteiro
	
	blt $a0, 0, num_ap_invalido	# caso opcao1 < 0
	bgt $a0, 23, num_ap_invalido	# caso opcao1 > 23
	
	la $t0, numMoradores
	la $t1, apartamentos
	
	add $t2, $t0, $a0		# $t2 = endereço do número de moradores do ap em $a0
	lb $t3, 0($t2)			# $t3 = carrega o número de moradores
	
	beq $t3, 6, ap_cheio		# se o número de moradores == 6
	
	mul $t4, $a0, 120		# $t4 = deslocamento do ap em $a0
	add $t4, $t4, $t1		# $t4 = endereço base do ap a0
	
	mul $t5, $t3, 20		# $t5 = deslocamento até o próximo espaco vazio
	add $t4, $t4, $t5		# $t4 = espaço vazio onde o nome será adicionado
	
	li $t6, 0			# $t6 = contador de caracteres
copiarNome:
	lb $t7, 0($a1)			# $t7 = carrega o byte do nome
	sb $t7, 0($t4)			# armazena o byte na posicao correta em $t4
	beq $t7, $zero, fimCopia	# se $t7 for '\0' encerra
	addi $a1, $a1, 1		# incrementa o endereço do nome do morador
	addi $t4, $t4, 1		# incrementa o endereço da posição que o nome está sendo armazenado
	addi $t6, $t6, 1		# incrementa o contador de caracteres
	blt $t6, 20, copiarNome		# se $t6 < 20, continua copiando

fimCopia:
	addi $t3, $t3, 1		# $t3 = novo número de moradores
	sb $t3, 0($t2)			# armazena o novo numero de moradores 
	
	jr $ra				# retorna a função
	
ap_cheio:
	# caso o apartamento esteja cheio, imprime a mensagem na tela
	li $v0, 4
	la $a0, msg_max_moradores
	syscall
	jr $ra

num_ap_invalido:
	# caso o número do apartamento seja inválido, imprime a mensagem
	li $v0, 4
	la $a0, msg_ap_invalido
	syscall
	jr $ra

# Função para remover um morador
# Parâmetros:
# $a0 = número do apartamento
# $a1 = nome do morador
rmvMorador:
    	# Lógica para remover um morador
    	# Verifica se o morador existe
    	# Remove o morador e atualiza o estado do apartamento
    	
    	# armazena o $ra na pilha para não sobrescrever
    	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal readInt			# converte $a0 para inteiro
    	move $a0, $v0
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	
    	la $t0, numMoradores		# $t0 = endereço base do número de moradores
    	la $t1, apartamentos		# $t1 = endereço base dos apartamentos
    	
    	add $t2, $t0, $a0		# $t2 = endereço do numero de moradores do apartamento
    	lb $t3, 0($t2)			# $t3 = numero de moradores
    	
    	beq $t3, $zero, moradorNaoEnc	# se o apartamento estiver vazio
    	
    	mul $t4, $a0, 120		# $t4 = deslocamento pra chegar no apartamento
    	add $t4, $t4, $t1		# $t4 = endereço base do apartemento em $a0
    	
    	li $t5, 0			# $t5 = offset para o morador atual
buscarMorador:
	# comparar o nome atual com o nome a ser removido usando strncmp
	# $a1 = nome
	add $a0, $t4, $t5		# $a0 = endereco do nome atual
	li $a2, 20			# $a2 = quantidade de caracteres que serão comparados
	
	addi $sp, $sp, -24		# strncmp utiliza $t0 até $t4, então eu salvo na pilha para não sobrescrever
	sw $ra, 20($sp)
	sw $t0, 16($sp)
	sw $t1, 12($sp)
	sw $t2, 8($sp)
	sw $t3, 4($sp)
	sw $t4, 0($sp)
	jal strncmp			# chama a função strncmp
	lw $ra, 20($sp)
	lw $t0, 16($sp)
	lw $t1, 12($sp)
	lw $t2, 8($sp)
	lw $t3, 4($sp)
	lw $t4, 0($sp)
	addi $sp, $sp, 24
	
	beq $v0, $zero, nomeCorresponde	# se o retorno for 0, esse é o morador que será removido

proximoMorador:
	addi $t5, $t5, 20		# $t5 = offset para o próximo morador (pula para o proximo morador)
	subi $t3, $t3, 1		# decrementa o numero de moradores verificados
	bnez $t3, buscarMorador		# se ainda tiver moradores, continua buscando

moradorNaoEnc:
	# caso o morador não tenha sido encontrado, exibe a mensagem
	li $v0, 4
	la $a0, msg_morador_nao_encontrado
	syscall
	jr $ra

nomeCorresponde:
	# remove deslocando os nomes seguintes
	add $t7, $t4, $t5		# $t7 = inicio do nome encontrado
	addi $t7, $t7, 20		# $t7 = inicio do proximo nome
	
	# calcula o numero de bytes a serem removidos
	beq $t3, $zero, atualizarNumMoradores
	sub $t3, $t3, 1			# $t3 = numero de moradores restantes
	mul $t3, $t3, 20		# $t3 = mul pelo tamanho de cada morador
	
	# memcpy para mover os nomes seguintes
	add $a0, $t4, $t5		# $a0 = destino (endereço do começo do nome que será removido)
	move $a1, $t7			# $a1 = fonte (inicio do proximo morador)
	move $a2, $t3			# $a2 = numero de bytes a serem movidos
	
	addi $sp, $sp, -16
	sw $ra, 12($sp)
	sw $t1, 8($sp)
	sw $t2, 4($sp)
	sw $t3, 0($sp)
	jal memcpy			# t0, t1, t2 e t3 são usados em memcpy (salvo na pilha para não sobrescrever)
	lw $ra, 12($sp)
	lw $t1, 8($sp)
	lw $t2, 4($sp)
	lw $t3, 0($sp)
	addi $sp, $sp, 16

limparEspaco:
	# preencher com \0 os bytes onde o último morador estava
	add $a0, $t4, $t5		# $a0 = endereco do espaco a ser limpo
	add $a0, $a0, $t3		# $a0 = avancar para o espaco vazio
	li $t8, 20			# $t8 = quantidade de espaços que serão preenchidos

zerarLoop:
	beq $t8, $zero, atualizarNumMoradores
	sb $zero, 0($a0)		# armazena \0 no endereço em $a0
	addi $a0, $a0, 1		# $a0++
	subi $t8, $t8, 1		# $t8--
	j zerarLoop			# continua preenchendo com \0

atualizarNumMoradores:
	lb $t3, 0($t2)			# $t3 = recarrega o num moradores
	subi $t3, $t3, 1		# decrementa o num
	sb $t3, 0($t2)			# armazena o novo num
	
	jr $ra				# retorna a função, após remover morador

# Função para adicionar veículo
# Parâmetros:
# $a0 = número do apartamento
# $a1 = tipo do automóvel ('c' ou 'm')
# $a2 = endereço do modelo do automóvel
# $a3 = endereço da placa
addAuto:
	# validar o número do apartamento
	add $sp, $sp, -4
	sw $ra, 0($sp)
	jal readInt
	lw $ra, 0($sp)
	add $sp, $sp, 4
	move $a0, $v0
	blt $a0, $zero, ap_invalido	# se $a0 < 0
	bgt $a0, 23, ap_invalido	# se $a0 > 23
	
	# validar o tipo do automovel
	lb $a1, 0($a1)
	beq $a1, 'c', processar_carro
	beq $a1, 'm', processar_moto
	j tipo_invalido
	
processar_carro:
	la $t0, numVeiculos		# $t0 = base de numVeiculos
	la $t1, veiculos		# $t1 = base de veiculos
	
	# calcular o deslocamento do apartamento em numVeiculos
	mul $t2, $a0, 2			# $t2 = deslocamento para o numero de veiculos do apartamento
	add $t2, $t2, $t0		# $t2 = endereco do numero de carros do apartamento
	lb $t3, 0($t2)			# $t3 = número de carros do apartamento
	
	# checar se a quantidade total de veículos foi atingida (se ja tiver 1 carro ou uma moto nao pode adicionar 1 carro)
	bge $t3, 1, total_veiculos	# $t3 >= 1
	
	addi $t3, $t3, 2		# $t3 += 2
	sb $t3, 0($t2)			# armazena o novo número de veículos
	
	mul $t2, $a0, 24		# 20 bytes por carro
	add $t2, $t1, $t2		# $t2 = endereco para o novo carro
	
	# copiar modelo e placa
	move $a0, $t2			# $a0 = edereço para arnazenar o carro
	move $a1, $a2			# $a1 = modelo do carro
	
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $t2, 0($sp)
	jal strcpy			# copia o modelo do carro para o local especificado em $a0
	lw $ra, 4($sp)
	lw $t2, 0($sp)
	addi $sp, $sp, 8
	
	addi $a0, $t2, 5		# pula para o espaço da placa
	move $a1, $a3
	
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $t2, 0($sp)
	jal strcpy			# copia a placa do carro para o novo espaço em $a0
	lw $ra, 4($sp)
	lw $t2, 0($sp)
	addi $sp, $sp, 8
	
	jr $ra
	
processar_moto:
	la $t0, numVeiculos		# $t0 = base de numVeiculos
	la $t1, veiculos		# $t1 = base de veiculos
	
	# calcular o deslocamento do apartamento em numVeiculos
	mul $t2, $a0, 2			# $t2 = deslocamento para o numero de veiculos do apartamento
	add $t2, $t2, $t0		# $t2 = endereco do numero de carros do apartamento
	lb $t3, 0($t2)			# $t3 = número de carros do apartamento
	
	bge $t3, 2, total_veiculos	# se o número de carros for >= 2
	
	addi $t3, $t3, 1		# $t3++
	sb $t3, 0($t2)			# armazena o novo número de veículos
	
	mul $t2, $a0, 24		# 20 bytes por veiculos
	add $t2, $t1, $t2		# $t2 = endereco para a nova moto
	
	# se já tiver uma moto, pula o espaço dela para nao armazenar por cima
	blt $t3, 2, nao_pular_moto_existente
	addi $t2, $t2, 12		# adiciona 12 bytes (tamanho da moto já adicionada)
nao_pular_moto_existente:
	move $a0, $t2			# $a0 = edereço para arnazenar a moto
	move $a1, $a2			# $a1 = modelo da moto
	
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $t2, 0($sp)
	jal strcpy			# copia o modelo da moto para o endereço correto
	lw $ra, 4($sp)
	lw $t2, 0($sp)
	addi $sp, $sp, 8
	
	addi $a0, $t2, 5		# pula para o espaço da placa
	move $a1, $a3
	
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $t2, 0($sp)
	jal strcpy			# copia a placa para o endereço correto
	lw $ra, 4($sp)
	lw $t2, 0($sp)
	addi $sp, $sp, 8
	jr $ra

total_veiculos:
	# exibe a mensagem caso o número total de veículos tenha sido atingido
	li $v0, 4				# syscall para umprimir string
	la $a0, msg_total_veiculos_atingido	
	syscall
	jr $ra

ap_invalido:
	# exibe a mensagem caso o número do apartamento seja inválido
	li $v0, 4
	la $a0, msg_ap_invalido
	syscall
	jr $ra

tipo_invalido:
	# exibe a mensagem caso o tipo de automóvel informado não seja 'c' ou 'm'
	li $v0, 4
	la $a0, msg_tipo_invalido
	syscall
	jr $ra

# Funcao para remover automovel
# Parametros:
# $a0 = numero do apartamento
# $a1 = placa do automovel
rmvAuto:
	add $sp, $sp, -4
	sw $ra, 0($sp)
	jal readInt			# converte o número do apartamento para inteiro
	lw $ra, 0($sp)
	add $sp, $sp, 4
	move $a0, $v0
	blt $a0, $zero, ap_invalido	# se $a0 < 0
	bgt $a0, 23, ap_invalido	# se $a0 > 23
	move $t9, $a0
	
	la $t0, numVeiculos		# $t0 = base de numVeiculos
	la $t1, veiculos		# $t1 = base de veiculos
	
	# calcular o deslocamento do apartamento em numVeiculos
	mul $t2, $a0, 2			# $t2 = deslocamento para o numero de veiculos do apartamento
	add $t2, $t2, $t0		# $t2 = endereco do numero de carros do apartamento
	lb $t3, 0($t2)			# $t3 = número de carros do apartamento
	
	mul $t2, $a0, 24		# 24 bytes por carro
	add $t2, $t1, $t2		# $t2 = endereco para o novo carro
	add $t2, $t2, 5			# pula o modelo do veiculo
	
	li $t6, 0
	move $t7, $a1			# $t7 = endereço da placa
comparar_placa:
	lb $t4, 0($t2)			# $t4 = byte atual da placa armazenada
	lb $t5, 0($t7)			# $t5 = byte atual da placa fornecida
	bne $t4, $t5, proximo_veiculo	# se forem diferentes, testa o proximo espaco de placa
	addi $t2, $t2, 1
	addi $t7, $t7, 1
	addi $t6, $t6, 1
	beq $t6, 7, apagar_veiculo
	j comparar_placa
	
proximo_veiculo:
	# pula o restante da placa e mais 5 bytes para chegar na placa do proximo veiculo
	li $t8, 7
	sub $t6, $t8, $t6
	add $t6, $t6, 5
	add $t2, $t2, $t6
	li $t6, 0
	move $t7, $a1
comparar_placa_2:
	lb $t4, 0($t2)				# $t4 = byte atual da placa armazenada
	lb $t5, 0($t7)				# $t5 = byte atual da placa fornecida
	bne $t4, $t5, nenhum_veiculo_encontrado	# se forem diferentes, testa o proximo espaco de placa
	addi $t2, $t2, 1
	addi $t7, $t7, 1
	addi $t6, $t6, 1
	beq $t6, 7, apagar_veiculo
	j comparar_placa_2
	
apagar_veiculo:
	# $t2 tem o inicio do proximo veiculo
	move $t8, $t2
	subi $t4, $t2, 12		# volta ate o inicio do veiculo
	
	move $a0, $t4			# destino
	move $a1, $t2			# origem
	li $a2, 12			# quantidade de bytes que um veiculo ocupa
	
	addi $sp, $sp, -20
	sw $ra, 16($sp)
	sw $t0, 12($sp)
	sw $t1, 8($sp)
	sw $t2, 4($sp)
	sw $t3, 0($sp)
	jal memcpy			# t0, t1, t2 e t3 são usados em memcpy (salvo na pilha para não sobrescrever)
	lw $ra, 16($sp)
	lw $t0, 12($sp)
	lw $t1, 8($sp)
	lw $t2, 4($sp)
	lw $t3, 0($sp)
	addi $sp, $sp, 20
	
	# atualizar numero de veículos
	la $t0, numVeiculos		# $t0 = base de numVeiculos
	
	# calcular o deslocamento do apartamento em numVeiculos
	# $t9 == $a0
	mul $t2, $t9, 2			# $t2 = deslocamento para o numero de veiculos do apartamento
	add $t2, $t2, $t0		# $t2 = endereco do numero de carros do apartamento
	lb $t3, 0($t2)			# $t3 = número de carros do apartamento
	addi $t3, $t3, -2
	sb $t3, 0($t2)

zerar_ultimo_veiculo:
	# preencher com \0 os bytes onde o último veiculo estava
	# $t8 = endereço do espaço a ser apagado
	li $t9, 12			# $t8 = quantidade de espaços que serão preenchidos

zerar_ultimo_veiculo_loop:
	beq $t9, $zero, finaliza_zerar_veiculo
	sb $zero, 0($t8)		# armazena \0 no endereço em $t8
	addi $t8, $t8, 1		# $t8++
	subi $t9, $t9, 1		# $t9--
	j zerar_ultimo_veiculo_loop			# continua preenchendo com \0

finaliza_zerar_veiculo:

	jr $ra
	
nenhum_veiculo_encontrado:
	li $v0, 4
	la $a0, msg_veiculo_nao_encontrado
	syscall
	jr $ra

# Função para limpar apartamento inteiro
# Parâmetros:
# $a0 = número do apartamento
limparAp:
	addi $sp, $sp, -4
    	sw $ra, 0($sp)
    	jal readInt			# converte $a0 para inteiro
    	move $a0, $v0			# $a0 = número do apartamento
    	lw $ra, 0($sp)
    	addi $sp, $sp, 4
    	
    	blt $a0, 0, ap_invalido
    	bgt $a0, 23, ap_invalido
    	
    	la $t0, numMoradores		# $t0 = endereço base do número de moradores
    	la $t1, apartamentos		# $t1 = endereço base dos apartamentos
    	
    	add $t2, $t0, $a0		# $t2 = endereço do numero de moradores do apartamento
    	sb $zero, 0($t2)		# armazena 0 no byte atual do endereço de numMoradores
    	
 	mul $t3, $a0, 120		# $t3 = offset para deslocar até o apartamento desejado
 	add $t1, $t1, $t3		# $t1 = endereço base do apartamento que deve ser esvaziado
 	
 	li $t4, 120
loop_esvaziar_ap:
	 beq $t4, $zero, finalizar
	 sb $zero, 0($t1)
	 addi $t1, $t1, 1
	 addi $t4, $t4, -1
	 j loop_esvaziar_ap
finalizar:
	jr $ra

# Função para vizualizar todos os moradores do apartamento
# Parâmetros:
# $a0 = número do apartamento
infoAp:
	addi $sp, $sp, -4		# reserva 1 espaço na pilha
	sw $ra, 0($sp)			# armazena o $ra
	
	jal readInt			# converte opcao1 ($a0) para inteiro
	move $a0, $v0	
	lw $ra, 0($sp)			# recupera o valor do ra
	addi $sp, $sp, 4		# restaura a pilha
	
	# checa se o número do apartamento é válido
	blt $a0, $zero, ap_invalido
    	bgt $a0, 23, ap_invalido
    	
    	la $t0, numMoradores
    	la $t1, apartamentos
    	
    	# verifica o número de moradores do apartamento
    	add $t2, $t0, $a0
    	lb $t3, 0($t2)
    	beq $t3, $zero, ap_vazio
    	
    	# calcula o endereço base do apartamento
    	mul $t4, $a0, 120		# $t4 = offset para se deslocar até o apartamento
    	add $t1, $t1, $t4		# $t1 = endereço base do apartamento
    	
	la $a0, msg_moradores
	li $v0, 4
	syscall				# exibe a mensagem 'Moradores:'
	
	li $t5, 0 			# $t5 = contador de moradores
loop_exibir_moradores:
	beq $t5, $t3, fim_exibicao	# se o contador é igual ao numero de moradores, encerra a exibição
	la $a0, msg_morador
	li $v0, 4
	syscall				# exibe 'Morador_'
	
	addi $t6, $t5, 1
	move $a0, $t6
	li $v0, 1
	syscall				# exibe o número do morador
	
	la $a0, msg_espaco_apos_morador	# imprime um espaço
	li $v0, 4
	syscall
	
	move $a0, $t1			# $a0 aponta para o nome do morador atual
	li $v0, 4
	syscall
	
	addi $t1, $t1, 20		# avança para o próximo morador
	addi $t5, $t5, 1		# incrementa o contador de moradores
	j loop_exibir_moradores

fim_exibicao:
	jr $ra
	
ap_vazio:
	la $a0, msg_ap_vazio
	li $v0, 4
	syscall
	jr $ra

# Função para formatar
formatar:
    	# zerando a área de apartamentos
    	la $t0, apartamentos        # endereço base dos apartamentos
    	li $t1, 0                   # valor para zerar (0)
    	li $t2, 2880                # tamanho total dos apartamentos

zerar_apartamentos:
    	sb $t1, 0($t0)              # zera um byte
    	addi $t0, $t0, 1            # avança o ponteiro
    	subi $t2, $t2, 1            # decrementa o contador
    	bnez $t2, zerar_apartamentos # se não chegou ao final, continue

    	# zerando numMoradores
    	la $t0, numMoradores           # endereço base de numMoradores
    	li $t1, 0                   # valor para zerar (0)
    	li $t2, 24                  # número de moradores

zerar_num_moradores:
    	sb $t1, 0($t0)              # zera um byte
    	addi $t0, $t0, 1            # avança o ponteiro
    	subi $t2, $t2, 1            # decrementa o contador
    	bnez $t2, zerar_num_moradores   # se não chegou ao final, continue

    	# zerando a área de veículos
    	la $t0, veiculos            # endereço base dos veículos
    	li $t1, 0                   # valor para zerar (0)
    	li $t2, 576                 # tamanho total dos veículos

zerar_veiculos:
    	sb $t1, 0($t0)              # zera um byte
    	addi $t0, $t0, 1            # avança o ponteiro
    	subi $t2, $t2, 1            # decrementa o contador
   	bnez $t2, zerar_veiculos    # se não chegou ao final, continue
	
	la $t0, numVeiculos		# $t0 = endereço base de numVeiculos
	li $t2, 24			# $t2 = contador

zerar_num_veiculos:
	sb $zero, 0($t0)		# armazena 0 na posição atual de numVeiculos
	addi $t0, $t0, 1		# incrementa o endereço de numVeiculos
	subi $t2, $t2, 1		# decrementa o contador
	bnez $t2, zerar_num_veiculos	# se o contador nao for igual a 0, continua
	
    	# exibe mensagem de sucesso
    	la $a0, msg_formatado_sucesso
    	li $v0, 4
    	syscall

    	jr $ra                     # retorna a função

# Função para carregar dados do arquivo
loadData:
    	# abrir o arquivo para leitura
   	li $v0, 13			# código para abrir arquivo
    	la $a0, filename		# nome do arquivo
    	li $a1, 0			# abrir no modo de leitura
    	li $a2, 0			# permissões padrão
    	syscall
    	move $t0, $v0			# salva o descritor de arquivo em t0
    
    	# ler dados dos apartamentos
    	la $a0, apartamentos		# endereço base dos apartamentos
    	li $a1, 2880			# tamanho dos dados
    	li $v0, 14			# código para leitura
    	move $a2, $t0			# descritor de arquivo
   	syscall
    
    	# ler dados dos veículos
    	la $a0, veiculos		# enedereço base dos veículos
    	li $a1, 576			# tamanho dos dados
    	li $v0, 14			# código para leitura
    	move $a2, $t0			# descritor de arquivo
    	syscall
    
    	# fechar o arquivo
    	li $v0, 16			# código para fechar arquivo
    	move $a0, $t0			# descritor de arquivo
    	syscall
    
    	jr $ra				# retorna a função

# Função para salvar dados no arquivo
saveData:
    	# abrir o arquivo para escrita
    	li $v0, 13		# syscall para abrir arquivo
    	la $a0, filename	# nome do arquivo
    	li $a1, 0x001		# modo de escrita
    	li $a2, 0x1B6		# permissões (rw-rw-rw-)
    	syscall
    	sw $v0, file_descriptor	# armazena o descritor do arquivo
    	
    	# escrever apartamentos no arquivo
    	la $t0, apartamentos	# carrega o endereço base dos apartamentos
    	li $t1, 2880		# número de bytes que serão escritos
    	
    	lw $a0, file_descriptor	# carrega o descritor do arquivo
    	move $a1, $t0		# ponteiro para o buffer (apartamentos)
    	move $a2, $t1		# tamanho dos dados
    	li $v0, 15		# syscall para escrita
    	syscall
    	
    	# escrever numMoradores no arquivo
    	la $t0, numMoradores	# carrega o endereço base dos apartamentos
    	li $t1, 24		# número de bytes que serão escritos
    	
    	lw $a0, file_descriptor	# carrega o descritor do arquivo
    	move $a1, $t0		# ponteiro para o buffer (apartamentos)
    	move $a2, $t1		# tamanho dos dados
    	li $v0, 15		# syscall para escrita
    	syscall
    	
    	# escrever Veículos no arquivo
    	la $t0, veiculos	# carrega o endereço base dos veículos
    	li $t1, 576		# número de bytes que serão escritos
    	
    	lw $a0, file_descriptor
    	move $a1, $t0
    	move $a2, $t1
    	li $v0, 15
    	syscall

	# Escrever numVeiculos no arquivo
    	la $t0, numVeiculos	# carrega o endereço base dos apartamentos
    	li $t1, 24		# número de bytes que serão escritos
    	
    	lw $a0, file_descriptor	# carrega o descritor do arquivo
    	move $a1, $t0		# ponteiro para o buffer (apartamentos)
    	move $a2, $t1		# tamanho dos dados
    	li $v0, 15		# syscall para escrita
    	syscall

	# fecha o arquivo e retorna a função
	lw $a0, file_descriptor
	li $v0, 16
	syscall
	jr $ra
	
# Função para parsear o comando
parseCommand:
    	# lógica para interpretar o comando
    	# exemplo: se o comando é "addMorador", retorna 0
    	# exemplo: se o comando é "rmvMorador", retorna 1
    	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	la $a1, str_add_morador	# endereço da string "addMorador"
    	li $a2, 10		# comparar apenas 10 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdAddMorador	# se for 0 é pq foi igual a "addMorador"
	
	# fazendo o mesmo para os outros comandos
    	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	la $a1, str_rmv_morador	# endereço da string "rmvMorador"
    	li $a2, 10		# comparar apenas 10 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdRmvMorador	# se for 0 é pq foi igual a "rmvMorador"	
	
	# checa se é addAuto
	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	
    	la $a1, str_add_auto	# endereço da string "addAuto"
    	li $a2, 7		# comparar apenas 7 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdAddAuto	# se for 0 é pq foi igual a "addAuto"	
	
	# checa se é rmvAuto
	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	
    	la $a1, str_rmv_auto	# endereço da string "rmvAuto"
    	li $a2, 7		# comparar apenas 7 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdRmvAuto	# se for 0 é pq foi igual a "rmvAuto"
	
	# checa se é limparAp
	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	
    	la $a1, str_limpar_ap	# endereço da string "limparAp"
    	li $a2, 8		# comparar apenas 8 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdLimparAp	# se for 0 é pq foi igual a "limparAp"
	
	# checa se é infoAp
	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	
    	la $a1, str_info_ap	# endereço da string "infoAp"
    	li $a2, 6		# comparar apenas 6 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdInfoAp	# se for 0 é pq foi igual a "infoAp"
	
	# checa se é 'formatar'
	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	
    	la $a1, str_formatar	# endereço da string "formatar"
    	li $a2, 8		# comparar apenas 8 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdFormatar	# se for 0 é pq foi igual a "formatar"
	
	# checa se é 'salvar'
	add $sp, $sp, -8
    	sw $a0, 4($sp)		# armazena o buffer de entrada
    	sw $ra, 0($sp)		# armazena o retorno
    	
    	
    	la $a1, str_salvar	# endereço da string "salvar"
    	li $a2, 6		# comparar apenas 6 caracteres
    	jal strncmp
	
	lw $a0, 4($sp)		# recarrega o retorno e o valor de a0
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	beq $v0, $0, cmdSalvar	# se for 0 é pq foi igual a "salvar"
	
	# se nao for igual a nenhum dos comandos, retorna -1
	li $v0, -1
    	jr $ra

cmdAddMorador:
	# retornar 0 = codigo para addMorador
	li $v0, 0
	jr $ra

cmdRmvMorador:
	# retornar 1 = codigo para rmvMorador
	li $v0, 1
	jr $ra

cmdAddAuto:
	# retorna 2 = código para addAuto
	li $v0, 2
	jr $ra

cmdRmvAuto:
	# retorna 3 = código para rmvAuto
	li $v0, 3
	jr $ra

cmdLimparAp:
	# retorna 4 = código para limparAp
	li $v0, 4
	jr $ra

cmdInfoAp:
	# retorna 5 = código para infoAp
	li $v0, 5
	jr $ra

cmdFormatar:
	# retorna 6 = código para formatar todos os dados
	li $v0, 6
	jr $ra

cmdSalvar:
	# retorna 7 = código para salvar os dados em um arquivo
	li $v0, 7
	jr $ra
	
# EXTRAIR OPÇÕES DOS COMANDOS
extrair_opcoes:
	# Parâmetros:
	# $a0 = endereço do buffer de entrada
	# $a1 = quantidade de bytes para pular o comando
	add $t0, $a0, $a1		# adiciona 13 bytes para pular 'addMorador --', por exemplo
	la $t1, opcao1			# carrega o endereço do buffer da opcao1
	la $t2, opcao2			# carrega o endereço do buffer da opcao2
	
copia_opcao1:
	lb $t3, 0($t0)			# copia o byte atual em t3
	beq $t3, ' ', proxima_opcao	# se encontrar um espaço termina a cópia da primeira opcao
	sb $t3, 0($t1)			# copia o caractere para opcao1
	addi $t0, $t0, 1		# incrementa o endereço da entrada
	addi $t1, $t1, 1		# incrementa o endereço da opcao1
	j copia_opcao1
	
proxima_opcao:
	sb $zero, 0($t1)		# adiciona o terminador nulo no final de opcao1
	addi $t0, $t0, 3		# pula " --" para chegar na proxima opcao
	la $t1, opcao1			# restaura t1 para o inicio de opcao1
	
copia_opcao2:
	lb $t3, 0($t0)			# carrega o byte atual do comando
	beq $t3, $zero, fim_extracao	# se for o fim da string termina
	sb $t3, 0($t2)			# armazena o byte atual em opcao2
	addi $t2, $t2, 1		# incrementa opcao2
	addi $t0, $t0, 1		# incrementa o comando de entrada
	j copia_opcao2
fim_extracao:
	sb $zero, 0($t2)		# adiciona o terminador nulo no final de opcao2
	la $t2, opcao2			# restaura t2 para o inicio de opcao2
	# nesse momento
	# $t1 = opcao1, $t2 = opcao2	
	jr $ra



# EXTRAIR 4 OPCOES
extrair_opcoes2:
	# Parâmetros:
	# $a0 = endereço do buffer de entrada
	addi $t0, $a0, 10		# adiciona 10 bytes para pular 'addAuto --'
	la $t1, opcao1			# carrega o endereço do buffer da opcao1
	la $t2, opcao2			# carrega o endereço do buffer da opcao2
	la $t3, opcao3
	la $t4, opcao4
	
copia_opcao1_2:
	lb $t5, 0($t0)			# copia o byte atual em t3
	beq $t5, ' ', proxima_opcao_2	# se encontrar um espaço termina a cópia da primeira opcao
	sb $t5, 0($t1)			# copia o caractere para opcao1
	addi $t0, $t0, 1		# incrementa o endereço da entrada
	addi $t1, $t1, 1		# incrementa o endereço da opcao1
	j copia_opcao1_2
	
proxima_opcao_2:
	sb $zero, 0($t1)		# adiciona o terminador nulo no final de opcao1
	addi $t0, $t0, 3		# pula " --" para chegar na proxima opcao
	la $t1, opcao2			# restaura t1 para o inicio de opcao1
	
copia_opcao2_2:
	lb $t5, 0($t0)			# carrega o byte atual do comando
	beq $t5, ' ', proxima_opcao_3	# se for o fim da string termina
	sb $t5, 0($t2)			# armazena o byte atual em opcao2
	addi $t2, $t2, 1		# incrementa opcao2
	addi $t0, $t0, 1		# incrementa o comando de entrada
	j copia_opcao2_2
	
proxima_opcao_3:
	sb $zero, 0($t2)
	addi $t0, $t0, 3
	la $t2, opcao2

copia_opcao_3:
	lb $t5, 0($t0)
	beq $t5, ' ', proxima_opcao_4
	sb $t5, 0($t3)
	addi $t3, $t3, 1
	addi $t0, $t0, 1
	j copia_opcao_3

proxima_opcao_4:
	sb $0, 0($t3)
	addi $t0, $t0, 3
	la $t3, opcao3

copia_opcao_4:
	lb $t5, 0($t0)
	beq $t5, $zero, fim_extracao_2
	sb $t5, 0($t4)
	addi $t4, $t4, 1
	addi $t0, $t0, 1
	j copia_opcao_4
	
fim_extracao_2:
	sb $zero, 0($t4)		# adiciona o terminador nulo no final de opcao4
	la $t4, opcao4			# restaura t4 para o inicio de opcao4
	jr $ra

# EXTRAIR UMA ÚNICA OPCAO PARA OS COMANDOS limparAp, infoAp
extrair_opcoes3:
	# Parâmetros:
	# $a0 = endereço do buffer de entrada
	# $a1 = bytes para pular
	add $t0, $a0, $a1		# adiciona 11 bytes para pular 'limparAp --'
	la $t1, opcao1			# carrega o endereço do buffer da opcao1
	
copia_opcao1_3:
	lb $t5, 0($t0)			# copia o byte atual em t3
	beq $t5, '\n', fim_extracao_3	# se encontrar um espaço termina a cópia da primeira opcao
	beq $t5, ' ', fim_extracao_3
	sb $t5, 0($t1)			# copia o caractere para opcao1
	addi $t0, $t0, 1		# incrementa o endereço da entrada
	addi $t1, $t1, 1		# incrementa o endereço da opcao1
	j copia_opcao1_3

fim_extracao_3:
	#sb $zero, 0($t1)
	la $t1, opcao1
	jr $ra

# FUNÇÕES DA BIBLIOTECA STRING.H

# COMPARAR DETERMINADA QUANTIDADE DE CARACTERES
# $a0 = endereço de str1
# $a1 = endereço de str2
# $a2 = número de bytes que serão comparados
strncmp:
	move $t0, $a0		# t0 = endereço de str1
	move $t1, $a1		# t1 = endereço de str2
	move $t2, $a2		# t2 = numero de caracteres
	
loop_strncmp:
	beq $t2, $0, end_strncmp	# se t2 == 0 termina
	lb $t3, 0($t0)		# carrega o byte atual de str1 em t3
	lb $t4, 0($t1)		# carrega o byte atual de str2 em t4
	beq $t3, $0, end_strncmp	# se str1 terminou, encerra
	beq $t4, $0, end_strncmp	# se str2 terminou, encerra
	bne $t3, $t4, char_diff	# se os bytes são diferentes, calcula a diferença
	
	addi $t0, $t0, 1	# incrementa o endereço de str1
	addi $t1, $t1, 1	# incrementa o endereço de str2
	addi $t2, $t2, -1	# decrementa o contador
	j loop_strncmp			# repete o laço

char_diff:
	sub $v0, $t3, $t4	# retorna a diferença dos bytes atuais
	jr $ra

end_strncmp:
	sub $v0, $t3, $t4	# retorna a diferença dos bytes atuais
	jr $ra

# COPIAR DETERMINADA QUANTIDADE DE CARACTERES
# $a0 = endereço de destino
# $a1 = endereço da origem
# $a2 = quantidade de bytes a ser copiada
memcpy:
	move $t0, $a0			# move o endereço do destino para t0
	move $t1, $a1			# move o endereço da origem para t1
	move $t2, $a2			# move a quantidade de bytes para t2

loop_memcpy:
	beq $t2, $0, end_memcpy		# se t2 == 0 encerra
	
	lb $t3, 0($t1)			# carrega o byte atual da origem
	sb $t3, 0($t0)			# armazena o byte no destino
	
	addi $t0, $t0, 1		# incrementa o endereço destino
	addi $t1, $t1, 1		# incrementa o edereço origem
	addi $t2, $t2, -1		# decrementa o contador de bytes
	
	j loop_memcpy			# repete o laço
end_memcpy:
	move $v0, $a0			# retorna o endereço de destino em v0
	jr $ra

# Função para copiar uma string
# Parâmetros:
# $a0 = endereço destino
# $a1 = endereço origem
strcpy:
	move $t0, $a0		# t0 = endereço destino
	move $t1, $a1		# t1 = endereço origem
	
loop_strcpy:
	lb $t2, 0($t1)		# carrega o byte atual em t2
	sb $t2, 0($t0)		# armazena o byte no destino
	beq $t2, $0, end_strcpy	# se o byte atual for nulo, encerra
	addi $t0, $t0, 1	# t0++
	addi $t1, $t1, 1	# t1++
	j loop_strcpy
end_strcpy:
	move $v0, $a0		# move o endereço da string destino para v0
	jr $ra			# retorna a função

# Função para concatenar strings
# Parâmetros:
# $a0 = destino			resultado = destino + origem
# $a1 = origem
strcat:
	move $t0, $a0			# move o endereço do destino para t0
	move $t1, $a1			# move o endereço da origem para t1

find_end:
	lb $t2, 0($t0)			# carrega o byte atual do destino em t2
	beq $t2, $0, copy		# se t2 == 0 encontrou o final da string
	addi $t0, $t0, 1		# incrementa o endereço se não encontrou o final
	j find_end			# repete o laço
	
copy:
	lb $t2, 0($t1)			# carrega o byte atual da origem em t2
	sb $t2, 0($t0)			# armazena o byte da origem no final do destino
	beq $t2, $0, end_strcat		# se t2 == 0 termina a cópia
	addi $t0, $t0, 1		# incrementa o endereço do destino
	addi $t1, $t1, 1		# incrementa o endereço da origem
	j copy				# repete o laço

end_strcat:
	move $v0, $a0			# move o endereço do destino para $v0
	jr $ra				# retorna a função

# Função auxiliar para ler um número inteiro de uma string
# $a0 = endereço da string contendo o número
# Retorna o número inteiro em $v0
readInt:
    	li $v0, 0            # inicializa o resultado em 0
    	li $t0, 10           # base decimal
    
read_int_loop:
    	lb $t1, 0($a0)       	# lê o próximo byte da string
    	beqz $t1, end_read_int 	# se o byte for 0 (fim da string), encerra

    	# converte o caractere ASCII para o valor numérico (0-9)
    	subi $t1, $t1, '0'   # subtrai o valor ASCII de '0'

    	# atualiza o valor do número inteiro
   	mul $v0, $v0, $t0    # multiplica o resultado atual por 10
    	add $v0, $v0, $t1    # adiciona o novo dígito

    	# avança para o próximo caractere
    	addi $a0, $a0, 1
    	j read_int_loop      # repete o loop

end_read_int:
    	jr $ra               # retorna a função
