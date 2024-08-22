# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organização de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Araújo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vitória Félix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Lista de Exercícios (20%)
# Questão 1: d. Função strncmp
# Descrição: Função que compara a string apontada por str1 com a string
# apontada por str2 especificando a quantidade máxima de bytes que devem ser comparados.
# $a0 = str1
# $a1 = str2
# $a2 = num
# $v0 = retorna 0 caso as duas strings sejam iguais, um inteiro negativo caso
# o primeiro caractere diferente tenha um valor decimal menor em str1 do que em str2
# ou um inteiro positivo caso o primeiro caractere diferente tem um valor decimal maior em str1 do que em str2.
# --------------------------------------------------------------------------

.data:
	str1: .asciiz "hello, world!"
	str2: .asciiz "hello"
	
.text
.globl main

main:
	la $a0, str1		# carrega o endereço de str1 em a0
	la $a1, str2		# carrega o endereço de str2 em a1
	li $a2, 5		# a2 = número de caracteres que serão comparados
	
	jal strncmp
	
	move $a0, $v0		# move para a0 o valor retornado pela função
	li $v0, 1		# código para imprimir inteiro
	syscall			# imprime o retorno da função
	
	li $v0, 10		# encerra o programa
	syscall
	
strncmp:
	move $t0, $a0		# t0 = endereço de str1
	move $t1, $a1		# t1 = endereço de str2
	move $t2, $a2		# t2 = numero de caracteres
	
loop:
	beq $t2, $0, end	# se t2 == 0 termina
	lb $t3, 0($t0)		# carrega o byte atual de str1 em t3
	lb $t4, 0($t1)		# carrega o byte atual de str2 em t4
	beq $t3, $0, end	# se str1 terminou, encerra
	beq $t4, $0, end	# se str2 terminou, encerra
	bne $t3, $t4, char_diff	# se os bytes são diferentes, calcula a diferença
	
	addi $t0, $t0, 1	# incrementa o endereço de str1
	addi $t1, $t1, 1	# incrementa o endereço de str2
	addi $t2, $t2, -1	# decrementa o contador
	j loop			# repete o laço

char_diff:
	sub $v0, $t3, $t4	# retorna a diferença dos bytes atuais
	jr $ra

end:
	sub $v0, $t3, $t4	# retorna a diferença dos bytes atuais
	jr $ra
