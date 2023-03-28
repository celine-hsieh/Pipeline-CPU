.data
num_test: .word 3 
TEST1_SIZE: .word 34
TEST2_SIZE: .word 19
TEST3_SIZE: .word 29
test1: .word 3,41,18,8,40,6,45,1,18,10,24,46,37,23,43,12,3,37,0,15,11,49,47,27,23,30,16,10,45,39,1,23,40,38
test2: .word -3,-23,-22,-6,-21,-19,-1,0,-2,-47,-17,-46,-6,-30,-50,-13,-47,-9,-50
test3: .word -46,0,-29,-2,23,-46,46,9,-18,-23,35,-37,3,-24,-18,22,0,15,-43,-16,-17,-42,-49,-29,19,-44,0,-18,23


.text
.globl main

main:
    ###########################################################################################
    # < Function >
    #   main procedure
    # 
    # < Parameters >
    #   NULL  
    #   
    # < Return Value >
    #   NULL
    ###########################################################################################
    # < Local Variable >
    #   s0 : int* answer   #0x9000
    #   s1 : int* size     #0x8004
    #   s2 : num_test      #3
    #   s3 : int* test     #0x8010
    #   s4 : i 
    #   s5 : j         
    #   t0 : test_size
    #   t1 : test_size - 1
    #   t2 : test
    #   t3 : answer
    ###########################################################################################

    ## Save ra & Callee Saved
    addi    sp, sp, -28                 # allocate stack space 
                                        # sp = @sp - 28

    sw      ra, 24(sp)                  # @ra -> MEM[@sp - 4]
    sw      s5, 20(sp)                  # @s5 -> MEM[@sp - 8]
    sw      s4, 16(sp)                  # @s4 -> MEM[@sp - 12]
    sw      s3, 12(sp)                  # @s3 -> MEM[@sp - 16]
    sw      s2, 8(sp)                   # @s2 -> MEM[@sp - 20]
    sw      s1, 4(sp)                   # @s1 -> MEM[@sp - 24]
    sw      s0, 0(sp)                   # @s0 -> MEM[@sp - 28]

    la      s1, TEST1_SIZE              # s1 = 0x8004   #TEST1_SIZE address
    li      s0, 0x9000                  # s0 = 0x9000   #answer
    la      s2, num_test                # s2 = 0x8000   #num_test
    lw      s2, 0(s2)                   # @s2 -> MEM[s2]
    la      s3, test1                   # s3 = 0x8004 + num_test*4   #0x8010

    li      s4, 0                       # s4 = 0            #i=0
    bge     s4, s2, main_endLoop        # if(i >= num_test) go to main_endLoop

main_loop:

    lw      t0, 0(s1)                   # @t0 -> MEM[s1]    # test_size = *size
    addi    t1, t0, -1                  # t2 = t0 - 1       # test_size-1
    bge     s4, s2, main_endLoop        # if(i >= num_test) go to main_endLoop
    
    ################################# Call Function Procedure ##################################
    # Caller Saved

    addi    sp, sp, -16                 # allocate stack space 
                                        # sp = @sp - 16
    sw      t0, 12(sp)                  # @t0 -> MEM[@sp - 4]                                    
    sw      t1, 8(sp)                   # @t1 -> MEM[@sp - 8]
    sw      t2, 4(sp)                   # @t2 -> MEM[@sp - 12]
    sw      t3, 0(sp)                   # @t3 -> MEM[@sp - 16]

    # Pass Arguments
    mv      a0, t1                      # a0 = t1           # test_size - 1
    mv      a1, s3                      # a1 = s3           # @test
    mv      a2, x0                      # a2 = x0           # start

    # Jump to Callee
    jal     ra, FUNC_MERGESORT          # ra = Addr(lw   t0, 4(sp))  #FC4
    ############################################################################################

    ## Retrieve Caller Saved
    lw      t0, 12(sp)                  # t0 = @t0  
    lw      t1, 8(sp)                   # t1 = @t1
    lw      t2, 4(sp)                   # t2 = @t2
    lw      t3, 0(sp)                   # t3 = @t3
    addi    sp, sp, 16                  # allocate stack space 
       
    li      s5, 0                       # s5 = 0           #j=0

main_loop_2:
    # store answer
    lw      t0, 0(s1)                   # @t0 -> MEM[s1]    # test_size = *size
    bge     s5, t0, main_endLoop_2      # if(j >= test_size) go to main_endLoop_2 
    lw      t2, 0(s3)                   # @t2 -> MEM[s1]    # test = *test
    addi    s3, s3, 4                   # s3 = s3 + 4       # *test++
    sw      t2, 0(s0)                   # mem[0x01000000] = s4 (*answer = test)
    addi    s0, s0, 4                   # s0 = s0 + 4       # *answer++
    addi    s5, s5, 1                   # s5 = s5 + 1       #j++
    jal     x0, main_loop_2             # x0 = 0, pc = main_loop_2 

main_endLoop_2:  
    addi    s4, s4, 1                   # s4 = s4 + 1       #i++
    addi    s1, s1, 4                   # s1 = s1 + 4       # *size++
    jal     x0, main_loop               # x0 = 0, pc = main_loop

main_endLoop:   
    ## Retrieve ra & Retrieve Callee Saved
    lw      ra, 24(sp)                  # ra = @ra
    lw      s5, 20(sp)                  # s5 = @s5
    lw      s4, 16(sp)                  # s4 = @s4
    lw      s3, 12(sp)                  # s3 = @s3
    lw      s2, 8(sp)                   # s2 = @s2
    lw      s1, 4(sp)                   # s1 = @s1
    lw      s0, 0(sp)                   # s0 = @s0
    addi    sp, sp, 28                  # Release stack space
                                        # sp = @sp
    ## Return
    ret                                 # jalr x0, ra, 0


FUNC_MERGESORT:
    ###########################################################################################
    # < Function >
    #   Recursion call mergesort
    # 
    # < Parameters >
    #   a0 : end  (test_size - 1)
    #   a1 : arr  (test)
    #   a2 : start
    #
    # < Return Value >
    #   NULL
    ###########################################################################################
    # < Local Variable >
    #   s0 : start
    #   s1 : end
    #   s2 : mid
    #   s3 : arr
    #   s4 : mid+1
    #   s5 : i
    ###########################################################################################
    addi    sp, sp, -28                 # allocate stack space    #FC8
                                        # sp = @sp - 20 
    sw      ra, 24(sp)                  # @ra -> MEM[@sp - 4]
    sw      s5, 20(sp)                  # @s5 -> MEM[@sp - 8]
    sw      s4, 16(sp)                  # @s4 -> MEM[@sp - 12]
    sw      s3, 12(sp)                  # @s3 -> MEM[@sp - 16]	
    sw      s2, 8(sp)                   # @s2 -> MEM[@sp - 20]
    sw      s1, 4(sp)                   # @s1 -> MEM[@sp - 24]
    sw      s0, 0(sp)                   # @s0 -> MEM[@sp - 28]
    
    mv      s0, a2                      # s0 = start
    mv      s1, a0                      # s1 = end
    mv      s3, a1                      # s3 = arr

mergesort_if:
    bge     s0, s1, mergesort_else      # if(start >= end) go to mergesort_else
    add     s2, s0, s1                  # mid = end + start
    srli    s2, s2, 1                   # mid = mid/2
    addi    s4, s2, 1                   # s4 = mid + 1 
    
first_Recursion:   
    ############################# 1st Call Function Procedure ##################################
    # Pass Arguments
    mv      a2, s0                      # a2 = s0           # start
    mv      a0, s2                      # a3 = s2           # mid
    mv      a1, s3                      # a4 = s3           # arr

    # Jump to Callee
    jal     ra, FUNC_MERGESORT          # ra = Addr(lw   t0, 8(sp))
    ############################################################################################
    
second_Recursion:
    ############################# 2nd Call Function Procedure ##################################
    # Pass Arguments
    mv      a0, s1                      # a5 = s1           # end
    mv      a2, s4                      # a6 = s4           # s2 = mid + 1
    mv      a1, s3                      # a4 = s3           # arr
    
    # Jump to Callee
    jal     ra, FUNC_MERGESORT          # ra = Addr(lw   t0, 8(sp))
    ############################################################################################
    
call_merge:
    ############################# 1st Call MERGE Function Procedure ############################
    # Pass Arguments
    mv      a0, s1                      # a5 = s1           # end
    mv      a2, s0                      # a2 = s0           # start
    mv      a1, s3                      # a4 = s3           # arr
    mv      a3, s2                      # a3 = s2           # mid                

    # Jump to Callee
    jal     ra, FUNC_MERGE              # ra = Addr(lw   t0, 8(sp))
    ############################################################################################
    
mergesort_else:
    lw      ra, 24(sp)                  # ra = @ra
    lw      s5, 20(sp)                  # s5 = @s5
    lw      s4, 16(sp)                  # s4 = @s4
    lw      s3, 12(sp)                  # s3 = @s3
    lw      s2, 8(sp)                   # s2 = @s2
    lw      s1, 4(sp)                   # s1 = @s1
    lw      s0, 0(sp)                   # s0 = @s0
    addi    sp, sp, 28                  # sp = @sp
    ret                                 # jalr x0, ra, 0



FUNC_MERGE:
    ###########################################################################################
    # < Function >
    #   merge
    # 
    # < Parameters >
    #   a2 : start
    #   a3 : mid
    #   a1 : arr
    #   a0 : end
    #
    # < Return Value >
    #   NULL
    ###########################################################################################
    # < Local Variable >
    #   t0 : temp_size
    #   t1 : temp[left_index]      arr
    #   t2 : temp[right_index]      start
    #   t3 : mid
    #   t4 : end
    #   t5 : -1
    #   t6 : temp_size * 4
    #   s0 : i
    #   s1 : i*4 (allocate int temp[i] stack space)
    #   s2 : i + start
    #   s3 : address of (i + start) * 4
    #   s4 : address of temp[i]
    #   s5 : left_index
    #   s6 : left_max
    #   s7 : right_index
    #   s8 : right_max
    #   s9 : arr_index
    ###########################################################################################
    addi    sp, sp, -28                 # allocate stack space    #FC8
                                        # sp = @sp - 28
    sw      s10, 24(sp)                 # @s10 -> MEM[@sp - 4] 
    sw      ra, 20(sp)                  # @ra -> MEM[@sp - 8]
    sw      s4, 16(sp)                  # @s4 -> MEM[@sp - 12]
    sw      s3, 12(sp)                  # @s3 -> MEM[@sp - 16]	
    sw      s2, 8(sp)                   # @s2 -> MEM[@sp - 20]
    sw      s1, 4(sp)                   # @s1 -> MEM[@sp - 24]
    sw      s0, 0(sp)                   # @s0 -> MEM[@sp - 28]
    

    sub     t0, a0, a2                  # t0 = end - start  # temp_size
    addi    t0, t0, 1                   # t0 = t0 + 1

 
    li      s0, 0                       # s0 = 0            #i=0
    
    slli    t6, t0, 2                   # t6 = t0 * 4
    sub     sp, sp, t6                  # allocate temp[temp_size] stack space    # sp = @sp - t6
    mv      s4, sp                      # s4 = sp

merge_forLoop:
    bge     s0, t0, merge_endForLoop    # if(i >= temp_size) go to merge_endForLoop
    add     s2, s0, a2                  # s2 = i + start  
    slli    s3, s2, 2                   # s3 = (i + start) * 4
    add     s3, a1, s3                  # s3 = arr[i + start]   # &arr[i + start]
    lw      s2, 0(s3)

    slli    s1, s0, 2                   # s1 = i * 4
    add     s10, s4, s1                 # s10 = s4 + s1      # address of temp[i]
    sw      s2, 0(s10)                  # @s3 -> MEM[@s10 - 4]  temp[i] = arr[i + start]

    addi    s0, s0, 1                   # s0 = s0 + 1       #i++
    jal     x0, merge_forLoop           # x0 = 0, pc = merge_forLoop

merge_endForLoop:
  
    addi    sp, sp, -20                  # allocate stack space    # sp = @sp - 20
    sw      s5, 16(sp)                   # @s5 -> MEM[@sp - 4] 
    sw      s6, 12(sp)                   # @s6 -> MEM[@sp - 8] 
    sw      s7, 8(sp)                    # @s7 -> MEM[@sp - 12]
    sw      s8, 4(sp)                    # @s8 -> MEM[@sp - 16]
    sw      s9, 0(sp)                    # @s9 -> MEM[@sp - 20]

    li      s5, 0                        # s5 = 0                #left_index
    sub     s6, a3, a2                   # s6 = mid-start        #left_max
    addi    s7, s6, 1                    # s7 = mid-start+1      #right_index
    sub     s8, a0, a2                   # s8 = end-start        #right_max
    mv      s9, a2                       # s9 = start            #arr_index

merge_while_1:
    blt     s6, s5, merge_while_3        # if(left_max < left_index) go to merge_while_3
    blt     s8, s7, merge_while_2        # if(right_max < right_index) go to merge_while_2 
    
merge_if:
    slli    t1, s5, 2                    # t1 = left_index * 4
    add     t1, s4, t1                   # t1 = address of temp[left_index]
    lw      t1, 0(t1)                    # t1 = temp[left_index]

    slli    t2, s7, 2                    # t2 = right_index * 4
    add     t2, s4, t2                   # t2 = address of temp[right_index]
    lw      t2, 0(t2)                    # t2 = temp[right_index]
    
    blt     t2, t1, merge_else           # if(temp[right_index] < temp[left_index]) go to merge_else
    slli    t3, s9, 2                    # t3 = arr_index * 4
    add     t3, a1, t3                   # t3 = address of arr[arr_index]
    sw      t1, 0(t3)                    # mem[@t3] = t1       #(arr[arr_index] = temp[left_index])
    addi    s9, s9, 1                    # s9 = s9 + 1         #arr_index++
    addi    s5, s5, 1                    # s5 = s5 + 1         #left_index++
    jal     x0, merge_while_1            # x0 = 0, pc = merge_while_1
    
merge_else:
    slli    t1, s5, 2                    # t1 = left_index * 4
    add     t1, s4, t1                   # t1 = address of temp[left_index]
    lw      t1, 0(t1)                    # t1 = temp[left_index]

    slli    t2, s7, 2                    # t2 = right_index * 4
    add     t2, s4, t2                   # t2 = address of temp[right_index]
    lw      t2, 0(t2)                    # t2 = temp[right_index]
    
    slli    t3, s9, 2                    # t3 = arr_index * 4
    add     t3, a1, t3                   # t3 = address of arr[arr_index]
    sw      t2, 0(t3)                    # mem[@t3] = t2       #(arr[arr_index] = temp[right_index])
    addi    s9, s9, 1                    # s9 = s9 + 1         #arr_index++
    addi    s7, s7, 1                    # s5 = s5 + 1         #right_index++
    jal     x0, merge_while_1            # x0 = 0, pc = merge_while_1



merge_while_2:
    slli    t1, s5, 2                    # t1 = left_index * 4
    add     t1, s4, t1                   # t1 = address of temp[left_index]
    lw      t1, 0(t1)                    # t1 = temp[left_index]

    slli    t2, s7, 2                    # t2 = right_index * 4
    add     t2, s4, t2                   # t2 = address of temp[right_index]
    lw      t2, 0(t2)                    # t2 = temp[right_index]
    
    blt     s6, s5, merge_while_3        # if(left_max < left_index) go to merge_while_3
    slli    t3, s9, 2                    # t3 = arr_index * 4
    add     t3, a1, t3                   # t3 = address of arr[arr_index]
    sw      t1, 0(t3)                    # mem[@t3] = t1       #(arr[arr_index] = temp[left_index])
    addi    s9, s9, 1                    # s9 = s9 + 1         #arr_index++
    addi    s5, s5, 1                    # s5 = s5 + 1         #left_index++
    jal     x0, merge_while_2            # x0 = 0, pc = merge_while_2



merge_while_3:
    slli    t1, s5, 2                    # t1 = left_index * 4
    add     t1, s4, t1                   # t1 = address of temp[left_index]
    lw      t1, 0(t1)                    # t1 = temp[left_index]

    slli    t2, s7, 2                    # t2 = right_index * 4
    add     t2, s4, t2                   # t2 = address of temp[right_index]
    lw      t2, 0(t2)                    # t2 = temp[right_index]
    
    blt     s8, s7, merge_end            # if(right_max < right_index) go to merge_end
    slli    t3, s9, 2                    # t3 = arr_index * 4
    add     t3, a1, t3                   # t3 = address of arr[arr_index]
    sw      t2, 0(t3)                    # mem[@t3] = t2       #(arr[arr_index] = temp[right_index])
    addi    s9, s9, 1                    # s9 = s9 + 1         #arr_index++
    addi    s7, s7, 1                    # s5 = s5 + 1         #right_index++
    jal     x0, merge_while_3            # x0 = 0, pc = merge_while_3
    

merge_end:
    add     sp, sp, t6
    
    lw      s5, 16(sp)                   # s5 = @s5
    lw      s6, 12(sp)                   # s6 = @s6
    lw      s7, 8(sp)                    # s7 = @s7
    lw      s8, 4(sp)                    # s8 = @s8
    lw      s9, 0(sp)                    # s9 = @s9
    addi    sp, sp, 20                   # allocate stack space    # sp = @sp
    
    lw      s10, 24(sp)                  # @s0 -> MEM[@sp - 20]
    lw      ra, 20(sp)                   # ra = @ra
    lw      s4, 16(sp)                   # s4 = @s4
    lw      s3, 12(sp)                   # s3 = @s3
    lw      s2, 8(sp)                    # s2 = @s2
    lw      s1, 4(sp)                    # s1 = @s1
    lw      s0, 0(sp)                    # s0 = @s0
    addi    sp, sp, 28                   # Release stack space

    ret                                  # jalr   x0, ra, 0