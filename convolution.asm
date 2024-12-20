.data
    input_file:     .asciiz "/Users/phamnguyenviettri/CompAr/Assignment/submit/2252845_PhamNguyenVietTri/Test_cases/test_10.txt"
    output_file:    .asciiz "/Users/phamnguyenviettri/CompAr/Assignment/submit/2252845_PhamNguyenVietTri/output_matrix.txt"
    buffer:         .space 4096      
    buffer_size:    .word 4096
    read_bytes:     .word 0          
    temp_string:    .space 32     # Buffer string conversion
    fraction_buffer: .space 8     # Buffer fractional part

    float_ten:      .float 10.0   
    float_0_5:      .float 0.5   
    float_10000:    .float 10000.0
    N:      .word 0      
    M:      .word 0      
    p:      .word 0      
    s:      .word 0      

    newline:    .asciiz "\n"
    space:      .asciiz " "
    
    
    outputSize:  .word 0      

    

    .align 2
    image:    .space 256   
    .align 2
    kernel:   .space 64   

    .align 2
    float_0:     .float 0.0
    float_1:      .float 1.0
    float_point_one: .float 0.1
    
    .align 2
    padded_image:   .space 3600   
    .align 2
    out:  .space 400   
    
    sizeError_message: .asciiz "Error: not match size.\n"
    error_N:        .asciiz "Error: Invalid parameters.\n"

.text
.globl main

main:

    li $v0, 13                   # Syscall for open file
    la $a0, input_file          
    li $a1, 0                    
    li $a2, 0                    
    syscall
    move $s0, $v0                # save file input.txt


    bltz $s0, error_file    


    li $v0, 14                   # Syscall for read file
    move $a0, $s0                
    la $a1, buffer              
    lw $a2, buffer_size          
    syscall
    sw $v0, read_bytes           


    la $t0, buffer
    lw $t1, read_bytes
    add $t0, $t0, $t1           
    sb $zero, 0($t0)             


    li $v0, 16                   # Syscall for close file
    move $a0, $s0
    syscall
#############
callFUNCTION:
############
    jal input_Process
    jal calculate_output_size
    jal check_kernel_size
    jal convolution
    
    lw $a1, outputSize      
    la $a0, out
    jal print_matrix
   

    j exit_program
    

error_file:
    li $v0, 4
    la $a0, file_error_msg
    syscall

   j exit_program

input_Process:
    addi $sp, $sp, -8      
    sw $ra, 4($sp)         
    sw $t0, 0($sp)          

    la $t0, buffer         

readN:
    move $a0, $t0
    jal read_integer
    sw $v0, N               
    move $t0, $v1           # update position read

# Check N: 3 <= N <= 7
checkconditionN:
    lw $t1, N
    li $t2, 3
    blt $t1, $t2, error_N_constraint
    li $t2, 7
    bgt $t1, $t2, error_N_constraint
    
    
readM:
    move $a0, $t0
    jal read_integer
    sw $v0, M               
    move $t0, $v1
    # Check M: 2 <= M <= 4
checkconditionM:
    lw $t1, M
    li $t2, 2
    blt $t1, $t2, error_N_constraint
    li $t2, 4
    bgt $t1, $t2, error_N_constraint

readP:
    move $a0, $t0
    jal read_integer
    sw $v0, p               # save P
    move $t0, $v1
    # Check p: 0 <= p <= 4
checkconditionP:
    lw $t1, p
    li $t2, 0
    blt $t1, $t2, error_N_constraint
    li $t2, 4
    bgt $t1, $t2, error_N_constraint
readS:
    move $a0, $t0
    jal read_integer
    sw $v0, s               # saveS
    move $t0, $v1
checkconditionS:
    lw $t1, s
    li $t2, 1
    blt $t1, $t2, error_N_constraint
    li $t2, 3
    bgt $t1, $t2, error_N_constraint
read_image:
    lw $t1, N               
    mul $t2, $t1, $t1      
    la $a1, image   
    move $a0, $t0          
    move $a2, $t2           
    jal read_float_array
    move $t0, $v0          

read_kernel:
    lw $t1, M               
    mul $t2, $t1, $t1       
    la $a1, kernel   
    move $a0, $t0          
    move $a2, $t2          
    jal read_float_array
    move $t0, $v0          

    lw $ra, 4($sp)          
    lw $t0, 0($sp)         
    addi $sp, $sp, 8       

    jr $ra
##############################
#print_matrix
print_matrix:
    # $a0: Address
    # $a1: Size of the matrix
    addi $sp, $sp, -24       
    sw   $ra, 20($sp)        
    sw   $s0, 16($sp)         
    sw   $s1, 12($sp)         
    sw   $s2, 8($sp)          
    sw   $s3, 4($sp)          
    sw   $s4, 0($sp)          

    move $s0, $a0            #add
    move $s1, $a1             #size
    mul  $s2, $s1, $s1        

    # Open file out.txt 
    la   $a0, output_file     
    li   $a1, 1              
    li   $a2, 0               
    li   $v0, 13             
    syscall
    move $s3, $v0            

    bltz $s3, error_file_output 


#loop for print matrix
    li   $t0, 0              

print_matrix_loop:
    beq  $t0, $s2, print_matrix_end  

    l.s  $f12, 0($s0)         # Load float from the array into $f12

    # Convert the float to string
    jal float_to_string       # Result stored in ####temp_string####

    # Write the string to the file
    move $a0, $s3           
    la   $a1, temp_string     

    # length of the string in temp_string
    la   $t1, temp_string
    move $t2, $zero
find_length:
    lb $t3, 0($t1)
    beqz $t3, length_found
    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j find_length
length_found:
    move $a2, $t2            
    li   $v0, 15              # write to file
    syscall

    # Write a space or newline character
    addi $t0, $t0, 1         
    addi $s0, $s0, 4        

    div $t0, $s1
    mfhi $t4                  # Remainder
    bne $t4, $zero, write_space
    # At end of row, write newline
    move $a0, $s3
    la $a1, newline          
    li $a2, 1                
    li $v0, 15                # write to file
    syscall
    j print_matrix_loop
write_space:
    # Write space
    move $a0, $s3
    la $a1, space             # Space character
    li $a2, 1                 # Length of space
    li $v0, 15                #  write to file
    syscall

    j print_matrix_loop

print_matrix_end:
    # Close the file
    move $a0, $s3            
    li   $v0, 16            
    syscall

    lw   $s4, 0($sp)
    lw   $s3, 4($sp)
    lw   $s2, 8($sp)
    lw   $s1, 12($sp)
    lw   $s0, 16($sp)
    lw   $ra, 20($sp)
    addi $sp, $sp, 24        

    jr   $ra                 

error_file_output:

    li $v0, 4                    #  print string
    la $a0, file_error_msg
    syscall
    jr $ra                     

#float_to_string
##############################
float_to_string:
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $s0, 20($sp)
    sw $s1, 16($sp)
    sw $s2, 12($sp)
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)


    la $s0, temp_string          # $s0 = buffer pointer for temp_string

    # Check if the float is negative
    mfc1 $t1, $f12               # float bits from reg f12
    li $t2, 0x80000000		#sign bits
    and $t3, $t1, $t2            # Check the sign bit
    beqz $t3, positive_float
    # Float is negative
    li $t0, '-'                  # Load '-'
    sb $t0, 0($s0)               # Store '-'
    addi $s0, $s0, 1      
          
    mfc1 $t1, $f12               #  float from reg$f12
    li $t2, 0x7FFFFFFF          
    and $t1, $t1, $t2            #delete sign bit AND
    mtc1 $t1, $f12               # move fixed value to $f12

positive_float:
    # Extract int
    trunc.w.s $f0, $f12          # $f0 = integer part as float -> extract to take int part ###### KO lam tron
    mfc1 $t1, $f0                # $t1 = integer part as int

    #integer part to string
    move $a0, $s0
    move $a1, $t1
    jal int_to_string

    # Move $s0 to the end of the integer string
    # Find the end of the integer string
    move $s0, $a0                # $a0 was updated in int_to_string
find_int_end:
    lb $t3, 0($s0)
    beqz $t3, int_end_found
    addi $s0, $s0, 1
    j find_int_end
int_end_found:

    # Append '.'
    li $t0, '.'
    sb $t0, 0($s0)
    addi $s0, $s0, 1

    # Compute fractional part
    cvt.s.w $f1, $f0             # $f1 = integer part as float
    sub.s $f2, $f12, $f1         # $f2 = fractional part = initial float  - int part
    l.s $f6, float_10000         # $f6 = 10000.0 -> 4 digits fraction
    mul.s $f2, $f2, $f6          # $f2 = fractional part * 10000.0

    trunc.w.s $f2, $f2           # Truncate to integer
    mfc1 $t6, $f2                # $t6 = fractional digits as integer




    # ############################# xu ly FRACTION 4 digits 
    li $t7, 1000                
    li $t5, 4                   

fractional_digits_loop:
    div $t6, $t7
    mflo $t8                     # Digit
    mfhi $t6                     # Rem

    #  digit -> ASCII
    addi $t8, $t8, '0'

    # Store digit to buffer
    sb $t8, 0($s0)
    addi $s0, $s0, 1

    #  $t7 = $t7 / 10
    li $t9, 10
    div $t7, $t9
    mflo $t7

    subi $t5, $t5, 1
    bgtz $t5, fractional_digits_loop

    # Null-terminate the string
    sb $zero, 0($s0)

    lw $t2, 0($sp)
    lw $t1, 4($sp)
    lw $t0, 8($sp)
    lw $s2, 12($sp)
    lw $s1, 16($sp)
    lw $s0, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28
    jr $ra
#  int_to_string
##############################
int_to_string:
###############################
    #   $a0  buffer address 
    #   $a1 - int Val
    addi $sp, $sp, -12
    sw $ra, 8($sp)
    sw $s0, 4($sp)
    sw $s1, 0($sp)

    move $s0, $a0    # buffer pointer

    beqz $a1, int_zero_case
    bltz $a1, int_negative

    # + int
    move $t0, $a1
    # Store
    addi $sp, $sp, -40
    move $t1, $sp   # Stack pointer for digits

    # Extrac
int_to_string_loop:
    li $t2, 10
    div $t0, $t2
    mfhi $t3        # Rem
    mflo $t0        # Quot
    addi $t3, $t3, '0' #convert int to ASCII
    sb $t3, 0($t1)
    addi $t1, $t1, 1
    bnez $t0, int_to_string_loop

#reverse order stack
    sub $t4, $t1, $sp   # Nofdigits
    subi $t1, $t1, 1    
copy_digits_loop:
    lb $t3, 0($t1)
    sb $t3, 0($s0)
    addi $s0, $s0, 1
    subi $t1, $t1, 1
    subi $t4, $t4, 1
    bgtz $t4, copy_digits_loop

    sb $zero, 0($s0)

    addi $sp, $sp, 40
    lw $s1, 0($sp)
    lw $s0, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12

   

    jr $ra

int_zero_case:
    # Handle zero
    li $t3, '0'              # Load ASCII value of '0' into $t3
    sw $t3, 0($s0)           # Store 
    li $t4, 0                # null teminate
    sw $t4, 4($s0)           # Store 

    lw $s1, 0($sp)          
    lw $s0, 4($sp)           
    lw $ra, 8($sp)           
    addi $sp, $sp, 12        
    jr $ra                   

int_negative:
    # Negative integer
    neg $a1, $a1             
    li $t3, '-'              
    sb $t3, 0($s0)         
    addi $s0, $s0, 1         
    move $t0, $a1            


    move $t2, $s0            # Lưu vị trí bắt đầu của phần chữ số vào $t2
extract_neg_digits_loop:
    li $t3, 10               
    div $t0, $t3             
    mfhi $t4                 # rem, lasst digit
    addi $t4, $t4, '0'       #ascii
    sb $t4, 0($s0)           # save $s0
    addi $s0, $s0, 1         # 
    mflo $t0                 # take int part
    bnez $t0, extract_neg_digits_loop

#reverse, skip -
reverse_neg_digits_loop:
    subi $s0, $s0, 1        #s0 is behind 0
    move $t3, $s0           #last dig
    move $t4, $t2            # save reverse
reverse_copy_loop:
    lb $t5, 0($t3)           
    sb $t5, 0($t4)          #write/save
    addi $t4, $t4, 1         
    subi $t3, $t3, 1         
    bgt $t3, $t2, reverse_copy_loop

    # add null terminator
    sb $zero, 0($t4)        



############doing
# read_integer
##############################
read_integer:
    # $a0: address of start string
    #   $v0: intValue
    #   $v1: nextAdd of INT

    move $t0, $a0       
    li $v0, 0          
    li $t1, 0           

read_int_skip_space:
    lb $t2, 0($t0)
    beq $t2, $zero, read_int_done  
    li $t3, 32                     #space
    li $t4, 10                     #newLine
    beq $t2, $t3, read_int_advance
    beq $t2, $t4, read_int_advance
    j read_int_start

read_int_advance:
    addi $t0, $t0, 1
    j read_int_skip_space

read_int_start:
    # check - 
    li $t3, 45                     # '-'
    beq $t2, $t3, read_int_negative
    j read_int_process

read_int_negative:
    li $t1, 1                      
    addi $t0, $t0, 1               # '-'
    lb $t2, 0($t0)                 

read_int_process:
    li $t3, 48                     # '0'
    li $t4, 57                     # '9'

read_int_loop:
    blt $t2, $t3, read_int_end     #  < '0', end
    bgt $t2, $t4, read_int_end     # > '9'end
    sub $t5, $t2, $t3              
    mul $v0, $v0, 10
    add $v0, $v0, $t5
    addi $t0, $t0, 1
    lb $t2, 0($t0)
    j read_int_loop

read_int_end:
#negative - 
    beq $t1, $zero, read_int_done
    neg $v0, $v0

read_int_done:
    move $v1, $t0                
    jr $ra
    
    
    
##############################
#  size cuar output
##############################
calculate_output_size:

    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $t0, 8($sp)
    sw $t1, 4($sp)
    sw $t2, 0($sp)


    lw $t0, N        # $t0 = N
    lw $t1, M        # $t1 = M
    lw $t2, p        # $t2 = P
    lw $t3, s        # $t3 = S


    beq $t3, $zero, division_by_zero_error

    addi $t2, $t2, 0      
    add $t2, $t2, $t2    
    add $t4, $t0, $t2    
    sub $t4, $t4, $t1    
    div $t4, $t3         
    mflo $t5             

    # outputSize = ((N + 2 * P - M) / S) + 1
    addi $t5, $t5, 1      # $t5 = outputSize
    sw $t5, outputSize


    lw $ra, 12($sp)
    lw $t0, 8($sp)
    lw $t1, 4($sp)
    lw $t2, 0($sp)
    addi $sp, $sp, 16

    jr $ra

division_by_zero_error:
    li $v0, 4
    la $a0, div_zero_msg
    syscall

    j exit_program

##############################
read_float:
    addi $sp, $sp, -28
    sw $ra, 24($sp)
    sw $t0, 20($sp)
    sw $t1, 16($sp)
    sw $t2, 12($sp)
    sw $t3, 8($sp)
    sw $t4, 4($sp)
    sw $t5, 0($sp)

    move $t0, $a0      
    li $t1, 0           
    li $t6, 0           


    la $t5, float_0
    l.s $f0, 0($t5)     # $f0 = 0.0
    la $t5, float_ten
    l.s $f10, 0($t5)   
    la $t5, float_1
    l.s $f11, 0($t5)    
    la $t5, float_point_one
    l.s $f12, 0($t5)    


    mov.s $f14, $f11    # $f14 = 1.0 

    # skip space and newline
read_float_skip_space:
    lb   $t2, 0($t0)                    
    beq  $t2, $zero, read_float_end     

    # Check if the character is a space (' '), line feed ('\n'), or carriage return ('\r')
    li   $t3, 32                        #  space
    li   $t4, 10                        #  line
    li   $t5, 13                        # carriage return


    beq  $t2, $t3, read_float_advance    
    beq  $t2, $t4, read_float_advance    
    beq  $t2, $t5, read_float_advance    

    j    read_float_start               

read_float_advance:
    addi $t0, $t0, 1                     
    j    read_float_skip_space             

read_float_start:
    li   $t3, 45                           # '-'
    beq  $t2, $t3, read_float_negative    
    j    read_float_loop                   # proceed to parse the float

read_float_negative:
    li   $t1, 1                            # 
    addi $t0, $t0, 1                       # Move '-' character
    lb   $t2, 0($t0)                       # Load '-'
    j    read_float_start                  # Continue parsing from the new character

read_float_loop:
    beq $t2, $zero, read_float_end  # end
    li $t3, 46                      #  '.'
    beq $t2, $t3, read_float_decimal_point

    li $t3, 48                      # '0'
    li $t4, 57                      # '9'
    blt $t2, $t3, read_float_end
    bgt $t2, $t4, read_float_end

    sub $t7, $t2, $t3             

    mtc1 $t7, $f1                  
    cvt.s.w $f1, $f1               

    beq $t6, $zero, read_float_integer_part
    #fraction part
    mul.s $f14, $f14, $f12          # f14 = f14 * 0.1 
    mul.s $f2, $f1, $f14            # f2 = digit * fraction_factor
    add.s $f0, $f0, $f2             # f0 += f2
    j read_float_next_char

read_float_integer_part:
    mul.s $f0, $f0, $f10            # f0 = f0 * 10
    add.s $f0, $f0, $f1             # f0 = f0 + digit

read_float_next_char:
    addi $t0, $t0, 1
    lb $t2, 0($t0)
    j read_float_loop

read_float_decimal_point:
    li $t6, 1                       # start decimal
    addi $t0, $t0, 1                #skip '.'
    lb $t2, 0($t0)
    j read_float_loop

read_float_end:
    beq $t1, $zero, read_float_done
    neg.s $f0, $f0

read_float_done:
    move $v1, $t0                  

    lw $ra, 24($sp)
    lw $t0, 20($sp)
    lw $t1, 16($sp)
    lw $t2, 12($sp)
    lw $t3, 8($sp)
    lw $t4, 4($sp)
    lw $t5, 0($sp)
    addi $sp, $sp, 28

    jr $ra

##############################
#  read_float_array 
read_float_array:
    addi $sp, $sp, -16         
    sw    $ra, 12($sp)         
    sw    $s0, 8($sp)          
    sw    $s1, 4($sp)          
    sw    $s2, 0($sp)         

    move  $s0, $a0             
    move  $s1, $a1             
    move  $s2, $a2              

process_loop:
    beq   $s2, $zero, finish    

    move  $a0, $s0              
    jal   read_float            

    swc1  $f0, 0($s1)          
    addi  $s1, $s1, 4          
    move  $s0, $v1              
    subi  $s2, $s2, 1           
    j     process_loop           

finish:
    move  $v0, $s0             


    lw    $ra, 12($sp)
    lw    $s0, 8($sp)
    lw    $s1, 4($sp)
    lw    $s2, 0($sp)
    addi  $sp, $sp, 16          

    jr    $ra                   
####################
# check_kernel_size
check_kernel_size:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    lw $t0, N        # Load N
    lw $t1, M        # Load M
    lw $t2, p        # Load P

    # Calculate N + 2 * P
    add $t3, $t2, $t2  # $t3 = 2 * P
    add $t3, $t3, $t0  # $t3 = N + 2 * P

    ble $t1, $t3, kernel_size_ok   # If M <= N + 2 * P, continue

   
    la   $a0, output_file    
    li   $a1, 1               
    li   $a2, 0              
    li   $v0, 13              
    syscall
    move $s0, $v0             

    bltz $s0, error_file 

    # Write the error message to the file
    move $a0, $s0            
    la   $a1, sizeError_message    

    # Calculate length of error message
    la   $t0, sizeError_message   
    move $t1, $zero                    
message_length_error:
    lb $t2, 0($t0)
    beqz $t2, error_msg_length_found
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j message_length_error
error_msg_length_found:
    move $a2, $t1            
    li   $v0, 15              # write to file
    syscall

    # Close the file
    move $a0, $s0           
    li   $v0, 16             
    syscall

    j exit_program           

kernel_size_ok:

    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra                    
    

##############################
#convolution
convolution:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)

###### load N,M,p,s
    lw $s0, N         
    lw $s1, M         
    lw $s2, p         
    lw $s3, s        
    lw $s4, outputSize

    #  padded_image_size = N + 2 * P
    add $t0, $s2, $s2  
    add $s5, $s0, $t0 

add_Padding:
    li $t1, 0           # $t1 = i

padImage_OUTER:
    bge $t1, $s0, padImage_OUTER_done  #i >= N

    li $t2, 0           # $t2 = j

padImage_INNER:
    bge $t2, $s0, padImage_INNER_done  #  j >= N out loop 

    # index image[i][j]
    mul $t3, $t1, $s0   
    add $t3, $t3, $t2  
    sll $t3, $t3, 2     # t3 = (i * N + j) * 4

    # Load image = image[i][j]
    la $t4, image
    add $t4, $t4, $t3
    l.s $f0, 0($t4)


    add $t5, $t1, $s2   # t5 = i + P
    add $t6, $t2, $s2   # t6 = j + P

    # index padded_image[padded_i][padded_j]
    mul $t7, $t5, $s5  
    add $t7, $t7, $t6  
    sll $t7, $t7, 2     # t7 = padded_index * 4

    # Store image vào padded_image[padded_i][padded_j]
    la $t8, padded_image
    add $t8, $t8, $t7
    s.s $f0, 0($t8)

    #  j
    addi $t2, $t2, 1
    j padImage_INNER

padImage_INNER_done:
    # i
    addi $t1, $t1, 1
    j padImage_OUTER

padImage_OUTER_done:


#start convolution ####################################

    li $t1, 0           # $t1 = i

convolution_outer:
    bge $t1, $s4, convolution_outer_done  #  i >= outputSize

    li $t2, 0           # $t2 = j

convolution_inner:
    bge $t2, $s4, convolution_inner_done  #  j >= outputSize

    #  sum = 0.0
    la $t9, float_0
    l.s $f4, 0($t9)     # $f4 = sum = 0.0

    li $t3, 0           

kernel_i_loop:
    bge $t3, $s1, kernel_i_done    # ki >= M

    li $t4, 0           # $t4 = kj

kernel_j_loop:
    bge $t4, $s1, kernel_j_done    #  kj >= M,out

    # index kernel[ki][kj]
    mul $t5, $t3, $s1   
    add $t5, $t5, $t4   
    sll $t5, $t5, 2     

    # Load kernel[ki][kj]
    la $t6, kernel
    add $t6, $t6, $t5
    l.s $f2, 0($t6)

    #  pi = i * S + ki
    mul $t7, $t1, $s3   
    add $t7, $t7, $t3   
    # pj = j * S + kj
    mul $t8, $t2, $s3  
    add $t8, $t8, $t4   

    #index padded_image[pi][pj]
    mul $t9, $t7, $s5   
    add $t9, $t9, $t8   
    sll $t9, $t9, 2     

    # Load padded_image[pi][pj]
    la $t0, padded_image
    add $t0, $t0, $t9
    l.s $f3, 0($t0)

    #  sum += kernel_value * padded_value
    mul.s $f5, $f2, $f3  
    add.s $f4, $f4, $f5  

    # +kj
    addi $t4, $t4, 1
    j kernel_j_loop

kernel_j_done:
    #  ki
    addi $t3, $t3, 1
    j kernel_i_loop

kernel_i_done:
    # sum -> out[i][j]
    mul $t5, $t1, $s4  
    add $t5, $t5, $t2  
    sll $t5, $t5, 2     # t5 = output_index * 4

    la $t6, out
    add $t6, $t6, $t5
    s.s $f4, 0($t6)

    addi $t2, $t2, 1
    j convolution_inner

convolution_inner_done:
    # + i
    addi $t1, $t1, 1
    j convolution_outer

convolution_outer_done:
    lw $ra, 28($sp)
    lw $s0, 24($sp)
    lw $s1, 20($sp)
    lw $s2, 16($sp)
    lw $s3, 12($sp)
    lw $s4, 8($sp)
    lw $s5, 4($sp)
    lw $s6, 0($sp)
    addi $sp, $sp, 32

    jr $ra
error_N_constraint:

    addi $sp, $sp, -16
    sw   $ra, 12($sp)
    sw   $s0, 8($sp)
    sw   $s1, 4($sp)
    sw   $s2, 0($sp)


    la   $a0, output_file    
    li   $a1, 1               
    li   $a2, 0              
    li   $v0, 13             
    syscall
    move $s0, $v0            

    bltz $s0, error_file 
    move $a0, $s0             
    la   $a1, error_N         

    la   $t0, error_N        
    move $t1, $zero           

    j message_length_error


 exit_program:
    li $v0, 10
    syscall

.data
    file_error_msg: .asciiz "Error: Cannot open input.txt\n"
    div_zero_msg: .asciiz "Error: Division by zero.\n"
space_label:    .asciiz " "        # Space 
newline_label:  .asciiz "\n"       # Newline 
