# This is a starter file for your RISC-y Business Lab
# Please read the assingment handout for an implementation specification.

# Here's some sample code from the Venus specification.
# Place a breakpoint on the first line of the code and 
# Run the program by hitting the green play button in the top
# right corner.
# Hit the down arrow key to step through the execution.

#Instructions:
#Implement two simple counters on the Seven Segment Board. 
#Whenever Button 0 is pressed,the screen on the left increments by 1. 
#Whenever Button 1 is pressed, the screen on the right increments by 1. 
#Both counters wrap-around to 0 once they hit 9.
#Whenever the left counter is greater than the right counter, the green LED is lit.
#Whenever the right counter is greater than the left counter, the red LED is lit. 
#When the counters are equal, no LED is lit.

main:
    li x5, 0  # Initialize left counter
    li x6, 0  # Initialize right counter


    li a0, 0x120
    li a1, 0b0011111100111111
    li a2, 0b1111111111111111
    ecall
    li x19, 0x00000003
    li x13, 0x00000004
    li x14, 0x00000005
    li x15, 0x00000006
    li x16, 0x00000007
    li x17, 0x00000008
    li x30, 0x00000009
    li x29, 0x0000000A




loop:
    # Read button inputs
    li a0, 0x122
    ecall
    mv x31, a0
    li x7, 0x00000001
    li x28, 0x00000002
    beq x31, x7, left_press
    beq x31, x28, right_press
    j loop


left_press:
    beq x6, x0, zeroL
    beq x6, x7, oneL
    beq x6, x28, twoL
    beq x6, x19, threeL
    beq x6, x13, fourL
    beq x6, x14, fiveL
    beq x6, x15, sixL
    beq x6, x16, sevenL
    beq x6, x17, eightL
    beq x6, x30, nineL
    
zeroL:
    li a0, 0x120
    li a1, 0b1111111100111111
    beq x0, x0, left_counter

oneL:
    li a0, 0x120
    li a1, 0b1111111100000110
    beq x0, x0, left_counter

twoL:
    li a0, 0x120
    li a1, 0b1111111101011011
    beq x0, x0, left_counter

threeL:
    li a0, 0x120
    li a1, 0b1111111101001111
    beq x0, x0, left_counter

fourL:
    li a0, 0x120
    li a1, 0b1111111101100110
    beq x0, x0, left_counter

fiveL:
    li a0, 0x120
    li a1, 0b1111111101101101
    beq x0, x0, left_counter

sixL:
    li a0, 0x120
    li a1, 0b1111111101111101
    beq x0, x0, left_counter

sevenL:
    li a0, 0x120
    li a1, 0b1111111100000111
    beq x0, x0, left_counter

eightL:
    li a0, 0x120
    li a1, 0b1111111101111111
    beq x0, x0, left_counter

nineL:
    li a0, 0x120
    li a1, 0b1111111101100111
    beq x0, x0, left_counter

left_counter:
   addi x5, x5, 1
   beq x5, x7, l_one
   beq x5, x28, l_two
   beq x5, x19, l_three
   beq x5, x13, l_four
   beq x5, x14, l_five
   beq x5, x15, l_six
   beq x5, x16, l_seven
   beq x5, x17, l_eight
   beq x5, x30, l_nine
   li x5, 0
   li a0, 0x120
   li a2, 0b0011111111111111
   ecall 
   beq x0, x0, R1

l_one:
   li a0, 0x120
   li a2, 0b0000011011111111
   ecall
   beq x0, x0, R1

l_two:
   li a0, 0x120
    li a2, 0b0101101111111111
    ecall
    beq x0, x0, R1

l_three:
   li a0, 0x120
    li a2, 0b0100111111111111
    ecall
    beq x0, x0, R1

l_four:
   li a0, 0x120
    li a2, 0b0110011011111111
    ecall
    beq x0, x0, R1

l_five:
   li a0, 0x120
    li a2, 0b0110110111111111
    ecall
    beq x0, x0, R1

l_six:
   li a0, 0x120
    li a2, 0b0111110111111111
    ecall
    beq x0, x0, R1

l_seven:
   li a0, 0x120
    li a2, 0b0000011111111111
    ecall
    beq x0, x0, R1

l_eight:
   li a0, 0x120
    li a2, 0b0111111111111111
    ecall
    beq x0, x0, R1

l_nine:
   li a0, 0x120
    li a2, 0b0110011111111111
    ecall
    beq x0, x0, R1

R1:
    beq x5, x6, led_off
    bgt x5, x6, led_green
    blt x5, x6, led_red


right_press:
    beq x5, x0, zeroR
    beq x5, x7, oneR
    beq x5, x28, twoR
    beq x5, x19, threeR
    beq x5, x13, fourR
    beq x5, x14, fiveR
    beq x5, x15, sixR
    beq x5, x16, sevenR
    beq x5, x17, eightR
    beq x5, x30, nineR

zeroR:
    li a0, 0x120
    li a1, 0b0011111111111111
    beq x0, x0, right_counter

oneR:
    li a0, 0x120
    li a1, 0b0000011011111111
    beq x0, x0, right_counter

twoR:
    li a0, 0x120
    li a1, 0b0101101111111111
    beq x0, x0, right_counter

threeR:
    li a0, 0x120
    li a1, 0b0100111111111111
    beq x0, x0, right_counter

fourR:
    li a0, 0x120
    li a1, 0b0110011011111111
    beq x0, x0, right_counter

fiveR:
    li a0, 0x120
    li a1, 0b0110110111111111
    beq x0, x0, right_counter

sixR:
    li a0, 0x120
    li a1, 0b0111110111111111
    beq x0, x0, right_counter

sevenR:
    li a0, 0x120
    li a1, 0b0000011111111111
    beq x0, x0, right_counter

eightR:
    li a0, 0x120
    li a1, 0b0111111111111111
    beq x0, x0, right_counter

nineR:
    li a0, 0x120
    li a1, 0b0110011111111111
    beq x0, x0, right_counter

right_counter:
    addi x6, x6, 1
    beq x6, x7, r_one
   beq x6, x28, r_two
   beq x6, x19, r_three
   beq x6, x13, r_four
   beq x6, x14, r_five
   beq x6, x15, r_six
   beq x6, x16, r_seven
   beq x6, x17, r_eight
   beq x6, x30, r_nine
   li x6, 0
   li a0, 0x120
   li a2, 0b1111111100111111
   ecall 
   beq x0, x0, R2

r_one:
   li a0, 0x120
    li a2, 0b1111111100000110
    ecall
    beq x0, x0, R2

r_two:
   li a0, 0x120
    li a2, 0b1111111101011011
    ecall
    beq x0, x0, R2

r_three:
   li a0, 0x120
    li a2, 0b1111111101001111
    ecall
    beq x0, x0, R2

r_four:
   li a0, 0x120
    li a2, 0b1111111101100110
    ecall
    beq x0, x0, R2

r_five:
   li a0, 0x120
    li a2, 0b1111111101101101
    ecall
    beq x0, x0, R2

r_six:
   li a0, 0x120
    li a2, 0b1111111101111101
    ecall
    beq x0, x0, R2

r_seven:
   li a0, 0x120
    li a2, 0b1111111100000111
    ecall
    beq x0, x0, R2

r_eight:
   li a0, 0x120
    li a2, 0b1111111101111111
    ecall
    beq x0, x0, R2

r_nine:
   li a0, 0x120
    li a2, 0b1111111101100111
    ecall
    beq x0, x0, R2


R2:
    beq x5, x6, led_off
    bgt x5, x6, led_green
    blt x5, x6, led_red


led_off:
    li a0, 0x121
    mv x18, a1
    li a1, 0b00
    ecall
    mv a1, x18
    bge x0, x0, end

led_green:
    li a0, 0x121
    mv x18, a1
    li a1, 0b01
    ecall
    mv a1, x18
    bge x0, x0, end

led_red:
    li a0, 0x121
    mv x18, a1
    li a1, 0b10
    ecall
    mv a1, x18
    bge x0, x0, end

end:
    j loop



