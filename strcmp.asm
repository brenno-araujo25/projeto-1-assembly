# --------------------------------------------------------------------------
# Disciplina: Arquitetura e Organização de Computadores
# Semestre Letivo: 2024.1
# Alunos: Brenno Araújo Caldeira Silva
# 	  Camila de Almeida Silva
# 	  Jeane Vitória Félix da Silva
# 	  Lucas Matias da Silva
# Atividade: 1 VA - Lista de Exercícios (20%)
# Questão 1: c. Função strcmp
# Descrição: Função que compara a string apontada por str1 com a string apontada por str2.
# $a0 = str1
# $a1 = str2
# $v0 = retorna 0 caso as duas strings sejam iguais, um inteiro negativo caso
# o primeiro caractere diferente tenha um valor decimal menor em str1 do que em str2
# ou um inteiro positivo caso o primeiro caractere diferente tem um valor decimal maior em str1 do que em str2.
# --------------------------------------------------------------------------

.data
    str1: .asciiz "hello"
    str2: .asciiz "hello"

.text
.globl main

main:
	la $a0, str1		# carrega o endereço de str1 em a0
	la $a1, str2		# carrega o endereço de str2 em a1
	
	jal strcmp
	
	move $a0, $v0		# move o retorno da função para a0
	li $v0, 1		# código para imprimir inteiro
	syscall
	
	li $v0, 10		# encerra o programa
	syscall
	
strcmp:
	move $t0, $a0		# move o endereço de str1 para t0
	move $t1, $a1		# move o endereço de str2 para t1
	
loop:
	lb $t2, 0($t0)		# t2 = byte atual de str1
	lb $t3, 0($t1)		# t3 = byte atual de str2
	beq $t2, $0, end	# se str1 terminou, encerra
	beq $t3, $0, end	# se str2 terminou, encerra
	bne $t2, $t3, char_diff	# se os bytes atuais forem diferentes vai para char_diff
	
	addi $t0, $t0, 1	# incrementa o endereço de str1
	addi $t1, $t1, 1	# incrementa o endereço de str2
	j loop			# repete o loop

char_diff:
	sub $v0, $t2, $t3	# retorna a diferença dos bytes atuais
	jr $ra			# retorna a função

end:
	sub $v0, $t2, $t3	# retorna a diferença
	jr $ra
