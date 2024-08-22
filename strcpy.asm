# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organiza��o de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Ara�jo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vit�ria F�lix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Lista de Exerc�cios (20%)
# Quest�o 1: a. Fun��o strcpy
# Descri��o: Fun��o que copia uma string apontada pela source diretamente para o bloco de mem�ria apontado pelo destination.
# $a0 = destination
# $a1 = source
# $v0 = retorna destination
# --------------------------------------------------------------------------

.data
	source: .asciiz "hello, world"
	destination: .space 100
	
.text
.globl main

main:
	la $a0, destination	# carrega o endere�o do destino em a0
	la $a1, source		# carrega o endere�o da origem em a1
	
	jal strcpy		# chama a fun��o de c�pia
	
	move $a0, $v0		# move o retorno da fun��o para a0
	li $v0, 4		# c�digo para imprimir string
	syscall			# imprime a string copiada
	
	li $v0, 10		# encerra o programa
	syscall

strcpy:
	move $t0, $a0		# t0 = endere�o destino
	move $t1, $a1		# t1 = endere�o origem
	
loop:
	lb $t2, 0($t1)		# carrega o byte atual em t2
	sb $t2, 0($t0)		# armazena o byte no destino
	beq $t2, $0, end	# se o byte atual for nulo, encerra
	addi $t0, $t0, 1	# t0++
	addi $t1, $t1, 1	# t1++
	j loop
end:
	move $v0, $a0		# move o endere�o da string destino para v0
	jr $ra			# retorna a fun��o
