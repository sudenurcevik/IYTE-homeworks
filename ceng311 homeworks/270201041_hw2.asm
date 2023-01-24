##############################################################
#Dynamic array
##############################################################
#   4 Bytes - Capacity
#	4 Bytes - Size
#   4 Bytes - Address of the Elements
##############################################################

##############################################################
#Song
##############################################################
#   4 Bytes - Address of the Name (name itself is 64 bytes)
#   4 Bytes - Duration
##############################################################


# Sude Nur Çevik
# 270201041


.data
space: .asciiz " "
newLine: .asciiz "\n"
tab: .asciiz "\t"
menu: .asciiz "\n● To add a song to the list-> \t enter 1\n● To delete a song from the list-> \t enter 2\n● To list all the songs-> \t\t enter 3\n● To exit-> \t\t\t enter 4\n"
menuWarn: .asciiz "Please enter a valid input!\n"
name: .asciiz "Enter the name of the song: "
duration: .asciiz "Enter the duration: "
name2: .asciiz "Song name: "
duration2: .asciiz "Song duration: "
emptyList: .asciiz "List is empty!\n"
noSong: .asciiz "\nSong not found!\n"
songAdded: .asciiz "\nSong added.\n"
songDeleted: .asciiz "\nSong deleted.\n"

copmStr: .space 64

sReg: .word 3, 7, 1, 2, 9, 4, 6, 5
songListAddress: .word 0 #the address of the song list stored here!

.text 
main:

	jal initDynamicArray
	sw $v0, songListAddress
	
	la $t0, sReg
	lw $s0, 0($t0)
	lw $s1, 4($t0)
	lw $s2, 8($t0)
	lw $s3, 12($t0)
	lw $s4, 16($t0)
	lw $s5, 20($t0)
	lw $s6, 24($t0)
	lw $s7, 28($t0)

menuStart:
	la $a0, menu    
    li $v0, 4
    syscall

	li $v0,  5
    syscall
	li $t0, 1
	beq $v0, $t0, addSong
	li $t0, 2
	beq $v0, $t0, deleteSong
	li $t0, 3
	beq $v0, $t0, listSongs
	li $t0, 4
	beq $v0, $t0, terminate
	
	la $a0, menuWarn    
    li $v0, 4
    syscall
	b menuStart
	
addSong:
	jal createSong
	lw $a0, songListAddress
	move $a1, $v0
	jal putElement
	b menuStart
	
deleteSong:
	lw $a0, songListAddress
	jal findSong
	lw $a0, songListAddress
	move $a1, $v0
	jal removeElement
	b menuStart
	
listSongs:
	lw $a0, songListAddress
	jal listElements
	b menuStart
	
terminate:
	la $a0, newLine		
	li $v0, 4
	syscall
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	move $a0, $s1
	syscall
	move $a0, $s2
	syscall
	move $a0, $s3
	syscall
	move $a0, $s4
	syscall
	move $a0, $s5
	syscall
	move $a0, $s6
	syscall
	move $a0, $s7
	syscall
	
	li $v0, 10
	syscall


initDynamicArray:
	
	li $a0, 12 # create dynamic array
	li $v0, 9
	syscall

	move $t0, $v0 # save $v0

	li $t1, 2 # set capacity
	sw $t1, 0($t0)

	li $t1, 0 # set size
	sw $t1, 4($t0)

	li $a0, 8 # create address list of elements
	li $v0, 9
	syscall

	sw $v0, 8($t0) # assign address of elements to dynamic array

	move $v0, $t0 # change registers to return form

	jr $ra

putElement:

	move $t0, $a0 # store dynamic array address

	lw $t3, 8($t0) # store address of element addresses


	# putting address of the element to address array
	lw $t2, 4($t0) 
	mul $t1, $t2, 4  
	add $t1, $t1, $t3
	sw $a1, 0($t1)   # assinging element address to necessary place

	# increase size
	lw $t1, 4($t0)
	addi $t1, $t1, 1
	sw $t1, 4($t0)
	
	# capacity check
	lw $t1, 0($t0)
	lw $t2, 4($t0)

	# print song added
	li $v0, 4
	la $a0, songAdded
	syscall

	# double capacity condition
	blt $t2, $t1, putElementEnd

	######## double dynamic array ########

	# set new capacity
	lw $t1, 0($t0)
	mul $t1, $t1, 2
	sw $t1, 0($t0)

	# create new dynamic array
	mul $t1, $t1, 4
	move $a0, $t1
	li $v0, 9
	syscall

	# store old address list
	lw $t1, 8($t0)
	# store new address list
	move $t2, $v0
	# store current size of array
	lw $t3, 4($t0)
	# counter register in loop
	li $t4, 0

	# assign values
	copyLoopStart1:

		mul $t7, $t4, 4
		add $t5, $t1, $t7
		add $t6, $t2, $t7

		lw $t8, 0($t5)
		sw $t8, 0($t6)

		addi $t4, $t4, 1
		bne $t4, $t3, copyLoopStart1

	sw $2, 8($t0)

	putElementEnd:
	
		jr $ra

removeElement:
	
	move $t0, $a0 # dynamic array
	move $t1, $a1 # index

	beq $t1, -1, notFound

	lw $t2, 4($t0) # size
	lw $t3, 8($t0) # address list


	###### reduce size ########
	subu $t2, $t2, 1
	sw $t2, 4($t0) 

	########### shift elements #########
	move $t4, $t1 # counter
	shiftElements: 
		beq $t4, $t2 deleted

		mul $t5, $t4, 4
		add $t6, $t3, $t5 # target location
		lw $t7, 4($t6)
		sw $t7, 0($t6)

		addi $t4, $t4, 1
		j shiftElements


	########## capacity check ###########
	lw $t5, 0($t0)
	sll $t4, $t2, 1
	bge $t4, $t5, deleted

	########## reduce capacity ###########
	srl $t5, $t5, 1
	sw $t5, 0($t0) 

	########## new address list ##########
	mul $a0, $t5, 4
	li $v0, 9
	syscall
	move $t1, $v0

	########## copy addresses ############
	li $t4, 0 # counter
	copyLoopStart2:

		mul $t6, $t4, 4
		add $t5, $t3, $t6
		add $t6, $t1, $t6

		lw $t8, 0($t5)
		sw $t8, 0($t6)

		addi $t4, $t4, 1
		bne $t4, $t2, copyLoopStart2

	sw $t1, 8($t0)

	deleted:  #when the element is deleted
		la $a0, songDeleted
		li $v0, 4
		syscall
		jr $ra	

	notFound: #when the element is not found
		la $a0, noSong
		li $v0, 4
		syscall
		jr $ra

listElements:
	
	subu $sp, $sp, 4
	sw $ra, 0($sp)

	move $t0, $a0

	# address list
	lw $t1, 8($t0)
	# list size
	lw $t2, 4($t0)

	bgt $t2, $zero, printListContinue  #empty list check

		la $a0, emptyList  #abort that list is empty
		li $v0, 4
		syscall
		
		lw $ra, 0($sp)
		addu $sp, $sp, 4
		jr $ra

	printListContinue:  #list is not empty 

		# counter
		li $t3, 0

		printSingle:  #print single element

			sll $t4, $t3, 2
			add $a0, $t1, $t4
			jal printElement
			addi $t3, $t3, 1

			blt $t3, $t2, printSingle

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra

compareString:
	

    li $t0, 0 # counter
 	
	compareLoop: 
		bge $t0, $a2, exitCompare # i >= comparison size go to exit
        	lb $t1, ($a0)      
        	lb $t2, ($a1)
        
        	seq $t3, $t1, $t2   # t1=t2 ? 1 : 0

			#increase base addresses
        	addi $a0, $a0, 1   
        	addi $a1, $a1, 1

        	beq $t3, $zero, notEqual    
        	addi $t0, $t0, 1  # i+=1
        	j compareLoop
        	
 	notEqual:
 		move $v0, $t3   # return 0
 		jr $ra
 		
	exitCompare:
		li $v0, 1  # return 1
		jr $ra 
	
printElement:
	
	subu $sp, $sp, 4
	sw $ra, 0($sp)

	jal printSong

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra

createSong:
	
	# create song area
	li $a0, 8
	li $v0, 9
	syscall
	# save $v0
	move $t0, $v0

	# print name request
	la $a0, name
	li $v0, 4
	syscall

	# name storage
	li $a0, 64
	li $v0, 9
	syscall
	move $t2, $v0

	# get name
	move $a0, $t2
	li $a1, 64
	li $v0, 8
	syscall

	# store name in song
	sw $t2, 0($t0)

	# print duration request
	la $a0, duration
	li $v0, 4
	syscall

	# get duration
	li $v0, 6
	syscall
	# store duration in song
	swc1 $f0, 4($t0)

	# change registers to return form
	move $v0, $t0

	jr $ra

findSong:

	subu $sp, $sp, 4
	sw $ra, 0($sp)

	lw $t9, 8($a0) # address list
	lw $t8, 4($a0) # list size
	li $t7, 0 # counter

	la $a0, name
	li $v0, 4
	syscall


	la $a0, copmStr
	li $v0, 8
	syscall

	findLoop:   # it is a loop to find same string with the given one
		beq $t7, $t8, elementNotFound

		sll $t1, $t7, 2
		add $t2, $t1, $t9
		lw $t2, 0($t2)

		lw $a0, 0($t2)
		la $a1, copmStr
		li $a2, 64

		jal compareString
		beq $v0, 1, found

		addi $t7, $t7, 1
		j findLoop


	elementNotFound:
		li $v0, -1

		lw $ra, 0($sp)
		addu $sp, $sp, 4
		jr $ra
	
	found:
		move $v0, $t7

		lw $ra, 0($sp)
		addu $sp, $sp, 4
		jr $ra

printSong:

	lw $t0, 0($a0)
	
	la $a0, name2
	li $v0, 4
	syscall

	lw $a0, 0($t0)
	li $v0, 4
	syscall

	la $a0, duration2
	li $v0, 4
	syscall

	lwc1 $f12, 4($t0)
	li $v0, 2
	syscall

	la $a0, newLine
	li $v0, 4
	syscall
	syscall
	
	jr $ra

additionalSubroutines:



