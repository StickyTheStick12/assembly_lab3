.data 
    buffer: .zero 1024 # array with 1024 bytes
    ind: .zero 4 # index
    formatChar: .asciz "%c\n" # format for printf
    formatDigit: .asciz "%d\n" #remove \n
    notEmpty: .zero 4 # bool 

.text
    .global main

main:
    pushq %rbp

    call getInt

    leaq formatDigit(%rip), %rdi
    movq %rax, %rsi
    movl $0, %eax
    call printf

    call getInPos

    leaq formatDigit(%rip), %rdi
    movq %rax, %rsi
    movl $0, %eax
    call printf

    pop %rbp
    ret
    

inImage:
    pushq %rbp
    movq %rsp, %rbp
    movq stdin(%rip), %rdx
    movl $1024, %esi
    leaq buffer(%rip), %rdi 
    call fgets 
    movl $0, ind(%rip) # reset index to zero
    movb $1, notEmpty(%rip) # bool = true

    pop %rbp
    ret 

getInt:
    pushq %rbp
    call CheckEmpty

    movq $0, %rax
    movq $0, %r11
    leaq buffer(%rip), %rdi
    movl ind(%rip), %r9d
    cltq
    addq %r9, %rdi
BlancCheck:
    cmpb $' ', (%rdi)
    jne SignPlus
    addq $1, ind(%rip)
    incq %rdi
    jmp BlancCheck
SignPlus:
    cmpb $'+', (%rdi)
    jne SignMinus
    addq $1, ind(%rip)
    incq %rdi
    jmp Number
SignMinus:
    cmpb $'-', (%rdi)
    jne Number;
    movq $1, %r11
    addq $1, ind(%rip)
    incq %rdi
Number:
    cmpb $'0', (%rdi)
    jl NAN
    cmpb $'9', (%rdi)
    jg NAN
    movzbq (%rdi), %r10
    subq $'0', %r10
    imulq $10, %rax
    addq %r10, %rax
    addq $1, ind(%rip)
    incq %rdi
    jmp Number
NAN:
    cmpq $1, %r11
    jne End
    negq %rax
End:
    popq %rbp
    ret

getChar:
    push %rbp

    call CheckEmpty

    movl ind(%rip), %eax
    cltq 
    leaq buffer(%rip), %rdi
    movzbl (%rdi, %rax), %eax

    addq $1, ind(%rip)

    pop %rbp
    ret

getInPos:
    push %rbp
    movl ind(%rip), %eax
    pop %rbp
    ret

setInPos:
    push %rbp
    cmpl $1023, %edi
    jg GreaterThanMax
    cmpl $0, %edi
    jl LessThanZero

    movl %edi, ind(%rip)
    pop %rbp
    ret

LessThanZero:
    movl $0, ind(%rip)
    pop %rbp
    ret

GreaterThanMax:
    movl $1023, ind(%rip)
    pop %rbp
    ret

getText:
    # rdi buffer to save to
    # rsi n(amount to read max)
    # rax is amount read + index to rdi to place
    # rcx buffer*
    # r9 value of buffer[ind] and ind

    push %rbp, %rsi#we have to save rsi 
    call CheckEmpty
    subq $1, %rsi
    leaq buffer(%rip), %rcx
    movq $0, %rax

loop:
    cmpq %rax, %rsi 
    je END

    movl ind(%rip), %r9d
    cltq
    cmpq $1023, %r9
    je END

    addq %r9, %rcx

    cmpq $'\0', (%rcx) 
    je END

    movq (%rcx), (%rdi)

    addl $1, ind(%rip)
    addq $1, %rax
    incq %rdi
    jmp loop

END:
    pop %rbp, %rsi
    ret


CheckEmpty:
    push %rbp
    # check if bool is false
    movl notEmpty(%rip), %eax 
    cmpl $0, %eax
    je getImage

    # check if we reached the end of the array
    movl ind(%rip), %eax
    cmpl $1023, %eax
    je getImage

    # check if the current value pointed at by index is null terminator
    movl ind(%rip), %eax
    cltq
    leaq buffer(%rip), %rdx
    movzbl (%rdx, %rax), %eax
    cmpl $'\0', %eax
    je getImage

    pop %rbp
    ret

getImage:
    call inImage
    pop %rbp
    ret


outImage:
    push %rbp

oLoop:
    movq ind(%rip), %rax
    cltq
    cmpq $1023, %rax
    je END

    leaq buffer(%rip), %rdi
    movzbq (%rdi, %rax), %rax

    cmpq $'\0', %rax
    je END

    addq $1, ind(%rip)

    leaq formatChar(%rip), %rdi
    movl %eax, %esi
    movl $0, %eax
    call printf

    jmp oLoop