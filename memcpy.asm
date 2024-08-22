# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organização de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Araújo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vitória Félix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Lista de Exercícios (20%)
# Questão 1: b. Função memcpy
# Descrição: Função que copia um total de bytes dado por num do local
# apontado pela source  diretamente para o bloco de memória apontado pelo destination
# $a0 = destination
# $a1 = source
# $a2 = num
# $v0 = retorna destination
# --------------------------------------------------------------------------

.data
	source: .asciiz "hello, world!"
	destination: .space 20

.text
.globl main

main:
	la $a0, destination		# carrega o endereço do destino para a0
	la $a1, source			# carrega o endereço da origem para a1
	li $a2, 5			# a2 = número de bytes que serão copiados
	
	jal memcpy
	
	move $a0, $v0			# carrega o endereço de retorno em a0
	li $v0, 4			# código para imprimir string
	syscall				# imprime a string copiada
	
	li $v0, 10
	syscall

memcpy:
	move $t0, $a0			# move o endereço do destino para t0
	move $t1, $a1			# move o endereço da origem para t1
	move $t2, $a2			# move a quantidade de bytes para t2

loop:
	beq $t2, $0, end		# se t2 == 0 encerra
	
	lb $t3, 0($t1)			# carrega o byte atual da origem
	sb $t3, 0($t0)			# armazena o byte no destino
	
	addi $t0, $t0, 1		# incrementa o endereço destino
	addi $t1, $t1, 1		# incrementa o edereço origem
	addi $t2, $t2, -1		# decrementa o contador de bytes
	
	j loop				# repete o laço
end:
	move $v0, $a0			# retorna o endereço de destino em v0
	jr $ra
