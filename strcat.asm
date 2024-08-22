# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organização de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Araújo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vitória Félix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Lista de Exercícios (20%)
# Questão 1: e. Função strcat
# Descrição: Função de concatenação de strings. Acrescenta uma cópia da
# string apontada por source à string apontada por destination.
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
	la $a0, destination		# carrega o endereço do destino em a0
	la $a1, source			# carrega o endereço da origem em a1
	
	jal strcat
	
	move $a0, $v0			# move o retorno da função para a0
	li $v0, 4			# código para imprimir string
	syscall				# imprime o resultado da função
	
	li $v0, 10			# encerra o programa
	syscall
	
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
	beq $t2, $0, end		# se t2 == 0 termina a cópia
	addi $t0, $t0, 1		# incrementa o endereço do destino
	addi $t1, $t1, 1		# incrementa o endereço da origem
	j copy				# repete o laço

end:
	move $v0, $a0			# move o endereço do destino para $v0
	jr $ra				# retorna a função
