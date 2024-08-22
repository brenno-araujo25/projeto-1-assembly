# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organização de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Araújo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vitória Félix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Lista de Exercícios (20%)
# Questão 1: a. Função strcpy
# Descrição: Função que copia uma string apontada pela source diretamente para o bloco de memória apontado pelo destination.
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
	la $a0, destination	# carrega o endereço do destino em a0
	la $a1, source		# carrega o endereço da origem em a1
	
	jal strcpy		# chama a função de cópia
	
	move $a0, $v0		# move o retorno da função para a0
	li $v0, 4		# código para imprimir string
	syscall			# imprime a string copiada
	
	li $v0, 10		# encerra o programa
	syscall

strcpy:
	move $t0, $a0		# t0 = endereço destino
	move $t1, $a1		# t1 = endereço origem
	
loop:
	lb $t2, 0($t1)		# carrega o byte atual em t2
	sb $t2, 0($t0)		# armazena o byte no destino
	beq $t2, $0, end	# se o byte atual for nulo, encerra
	addi $t0, $t0, 1	# t0++
	addi $t1, $t1, 1	# t1++
	j loop
end:
	move $v0, $a0		# move o endereço da string destino para v0
	jr $ra			# retorna a função
