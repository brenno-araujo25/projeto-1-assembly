# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organiza��o de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Ara�jo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vit�ria F�lix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Lista de Exerc�cios (20%)
# Quest�o 1: e. Fun��o strcat
# Descri��o: Fun��o de concatena��o de strings. Acrescenta uma c�pia da
# string apontada por source � string apontada por destination.
# $a0 = destination
# $a1 = source
# $v0 = retorna destination
# --------------------------------------------------------------------------

.data
	source: .asciiz "world!"
	destination: .asciiz "hello, "

.text
.globl main

main:
	la $a0, destination		# carrega o endere�o do destino em a0
	la $a1, source			# carrega o endere�o da origem em a1
	
	jal strcat
	
	move $a0, $v0			# move o retorno da fun��o para a0
	li $v0, 4			# c�digo para imprimir string
	syscall				# imprime o resultado da fun��o
	
	li $v0, 10			# encerra o programa
	syscall
	
strcat:
	move $t0, $a0			# move o endere�o do destino para t0
	move $t1, $a1			# move o endere�o da origem para t1

find_end:
	lb $t2, 0($t0)			# carrega o byte atual do destino em t2
	beq $t2, $0, copy		# se t2 == 0 encontrou o final da string
	addi $t0, $t0, 1		# incrementa o endere�o se n�o encontrou o final
	j find_end			# repete o la�o
	
copy:
	lb $t2, 0($t1)			# carrega o byte atual da origem em t2
	sb $t2, 0($t0)			# armazena o byte da origem no final do destino
	beq $t2, $0, end		# se t2 == 0 termina a c�pia
	addi $t0, $t0, 1		# incrementa o endere�o do destino
	addi $t1, $t1, 1		# incrementa o endere�o da origem
	j copy				# repete o la�o

end:
	move $v0, $a0			# move o endere�o do destino para $v0
	jr $ra				# retorna a fun��o
