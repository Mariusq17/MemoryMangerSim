.section .note.GNU-stack,"",@progbits

.data
    vector: .space 8196
    n: .long 1024
    numarPtCitire: .long 0
    formatPerecheGET: .asciz "(%d, %d)\n"
    formatAfisareFuncAdd: .asciz "%d: "
    formatAfisareValoarePerechePoz: .asciz "%d: (%d, %d)\n"
    formatAfisareNum: .asciz "%d, "
    formatAfisareNum2: .asciz "%d : %d\n"
    newLine: .asciz "\n"
    formatInput: .asciz "%d"
.text

init:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi
    movl $0, %ecx
loopInit:
    cmp 12(%ebp), %ecx #n == ecx
    je exitInit

    movl $0, (%edi, %ecx, 4)
    addl $1, %ecx

    jmp loopInit
exitInit:
    popl %ebp
    ret

showArray:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi
    xor %ecx, %ecx
loopShowArray:
    cmp 12(%ebp), %ecx #n == ecx
    je exitShowArray

    #afisare propriu-zisa
    pusha
    pushl (%edi, %ecx, 4)
    pushl %ecx
    push $formatAfisareNum2
    call printf
    add $12, %esp

    pushl $0
    call fflush
    addl $4, %esp
    popa
    
    addl $1, %ecx

    jmp loopShowArray
exitShowArray:
    pusha
    push $newLine
    call printf
    pop newLine

    pushl $0
    call fflush
    addl $4, %esp
    popa

    popl %ebp
    ret

showSequence:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi
    xor %ecx, %ecx

    #am nevoie de variabilele x, start si finish pe care le adaug pe stiva daca a[i] != 0
    #x = a[i], start = finish = i (initial)
    pushl (%edi, %ecx, 4) #a[i]
    pushl %ecx #start
    pushl %ecx #finish
loopShowSequence1:
    cmp 12(%ebp), %ecx #n == ecx
    je exitShowSequence

    movl $0, %ebx
    cmp (%edi, %ecx, 4), %ebx
    jne ifShowSequence

    addl $1, %ecx
    jmp loopShowSequence1
ifShowSequence:
    #am nevoie de variabilele x, start si finish pe care le adaug pe stiva daca a[i] != 0
    #x = a[i], start = finish = i (initial)
    movl (%edi, %ecx, 4), %eax
    movl %eax, -4(%ebp) #x = a[i]
    movl %ecx, -8(%ebp) #start
    movl %ecx, -12(%ebp) #finish
loopShowSequence2:
    cmp 12(%ebp), %ecx #n == ecx
    je ifShowSequencePart2

    movl -4(%ebp), %ebx
    cmp %ebx, (%edi, %ecx, 4) #x == a[i]
    jne ifShowSequencePart2

    movl %ecx, -12(%ebp) #finish = i
    addl $1, %ecx

    jmp loopShowSequence2
ifShowSequencePart2:
    #afisarea perechii de indici
    pusha
    #x, start si finish sunt deja pe stiva in ordinea care trebuie
    #mai trebuie doar sa-i afisez
    pushl -12(%ebp)
    pushl -8(%ebp)
    pushl -4(%ebp)
    push $formatAfisareValoarePerechePoz
    call printf
    addl $16, %esp

    pushl $0
    call fflush
    addl $4, %esp
    popa

    #sub $1, %ecx (normal as scade aici 1, dar sa nu omitem faptul ca, spre deosebire de codul din c++, unde
    #for ul actualizeaza la loc i ul, aici sare direct la urmatoarea iteratie)
    jmp loopShowSequence1

exitShowSequence: 
    addl $12, %esp #scot cele 3 valori de pe stiva
    popl %ebp
    ret

getOP:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi   # vectorul 
    movl $0, %ecx

    # variabilele start si finish
    pushl %ecx           # start = 0
    pushl %ecx           # finish = 0
loopGetOp1:
    cmp 12(%ebp), %ecx   # i < n ?
    je exitGetOP

    movl 16(%ebp), %eax  # extrag id 
    cmp %eax, (%edi, %ecx, 4) # a[i] != id ?
    je loopGetOp1Part2   # daca gasesc id, ies din bucla

    addl $1, %ecx        # i++
    jmp loopGetOp1
loopGetOp1Part2:
    movl %ecx, -4(%ebp)  # start = i
loopGetOp2:
    cmp 12(%ebp), %ecx   # i < n ?
    je loopGetOp2Part2

    movl 16(%ebp), %eax  # extrag id 
    cmp %eax, (%edi, %ecx, 4) # a[i] == id ?
    jne loopGetOp2Part2  # daca nu mai e egal, ies din bucla

    addl $1, %ecx        # i++
    jmp loopGetOp2
loopGetOp2Part2:
    subl $1, %ecx        # i--
    movl %ecx, -8(%ebp)  # finish = i

exitGetOP:
    # afiseaza perechea
    pusha
    pushl -8(%ebp)       # finish
    pushl -4(%ebp)       # start
    push $formatPerecheGET
    call printf
    add $12, %esp        # curata stiva dupa afisare
    
    pushl $0
    call fflush
    addl $4, %esp
    popa

    add $8, %esp         # scot de pe stiva start si finish
    popl %ebp
    ret

addOP:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi   # vectorul 

    xor %edx, %edx
    movl 20(%ebp), %eax #mut dim in eax
    movl $8, %ebx
    div %ebx

    cmp $0, %edx #daca dim % 8 == 0
    je addOPSeImparte
    
    addl $1, %eax #daca nu se imparte, mai adaug 1
addOPSeImparte:
    movl %eax, 20(%ebp) #actualizez dimensiunea corect
    pushl 20(%ebp) #creez o copie a dimensiunii

    xor %ecx, %ecx
loopAddOP1: 
    movl -4(%ebp), %eax
    cmp $0, %eax
    je loopAddOP1Part2

    cmp 12(%ebp), %ecx   # i < n ?
    je exitAddOP

    movl (%edi, %ecx, 4), %eax
    cmp $0, %eax
    jne ifLoopAddOP1

    movl -4(%ebp), %eax
    subl $1, %eax
    movl %eax, -4(%ebp) #copieDim-- + actualizare

    jmp endIfLoopAddOP1
ifLoopAddOP1:
    movl 20(%ebp), %eax
    movl %eax, -4(%ebp)
endIfLoopAddOP1:
    addl $1, %ecx
    jmp loopAddOP1
loopAddOP1Part2:
    #pe copie dim il voi folosi acum drept indice de final care este egal cu i (curent)
    #pe ecx, care este index, il voi refolosi ca indice doar ca acum incep de la indicele de final - dim
    #pentru a putea actualiza corespunzator cele dim pozitii din vector (iStart = i - dim, i)
    movl %ecx, -4(%ebp)
    subl 20(%ebp), %ecx
loopAddOP2:
    cmp -4(%ebp), %ecx   # iStart < i ?
    je exitAddOP

    movl 16(%ebp), %eax
    movl %eax, (%edi, %ecx, 4) #a[i] = id

    addl $1, %ecx

    jmp loopAddOP2
exitAddOP:
    #afisarea secventei lui id ("id: (left, right)"")
    pusha
    pushl 16(%ebp) #id
    push $formatAfisareFuncAdd
    call printf
    add $8, %esp

    pushl $0
    call fflush
    addl $4, %esp
    popa

    pusha
    pushl 16(%ebp) #id
    pushl 12(%ebp) #n
    pushl 8(%ebp)
    call getOP
    add $12, %esp
    popa

    add $4, %esp #scot variabila copieDim
    popl %ebp
    ret

deleteOP:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi   # vectorul
    xor %ecx, %ecx
    loopDeleteOP1:
        cmp 12(%ebp), %ecx 
        je exitDeleteOP

        movl (%edi, %ecx, 4), %eax
        cmp 16(%ebp), %eax
        je loopDeleteOP2

        addl $1, %ecx

        jmp loopDeleteOP1
    loopDeleteOP2: 
        cmp 12(%ebp), %ecx 
        je exitDeleteOP

        movl (%edi, %ecx, 4), %eax
        cmp 16(%ebp), %eax
        jne exitDeleteOP

        movl $0, (%edi, %ecx, 4)

        addl $1, %ecx

        jmp loopDeleteOP2
    exitDeleteOP:
        popl %ebp
        ret

defragmentationOP:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi   # vectorul 
    xor %ecx, %ecx #index
    xor %eax, %eax #lastPoz
loopDefragmentationOP1:
    cmp 12(%ebp), %ecx
    je loopDefragmentationOP2

    movl (%edi, %ecx, 4), %edx
    cmp $0, %edx #v[i] == 0
    je ifLoopDefragmentationOP1

    movl (%edi, %ecx, 4), %ebx
    movl %ebx, (%edi, %eax, 4)
    addl $1, %eax #v[lastPoz++] = v[i]
ifLoopDefragmentationOP1:
    addl  $1, %ecx
    jmp loopDefragmentationOP1
loopDefragmentationOP2:
    cmp 12(%ebp), %eax
    je exitDefragmentationOP

    movl $0, (%edi, %eax, 4)

    addl  $1, %eax
    jmp loopDefragmentationOP2
exitDefragmentationOP:
    popl %ebp
    ret

controlPanel:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi   # vectorul 
    #adaugarea de variabile locale (op, task, N, id, dim)
    pushl $0    #op
    pushl $0    #task
    pushl $0    #N
    pushl $0    #id
    pushl $0    #dim

    #citire op:
    pushl $numarPtCitire
    pushl $formatInput
    call scanf
    addl $8, %esp
    movl numarPtCitire, %eax
    movl %eax, -4(%ebp)


    #while op--
whileOpCP:
    movl -4(%ebp), %eax
    afis:
    cmp $0, %eax
    je exitControlPanel
    
    #citire task:
    pusha
    pushl $numarPtCitire
    pushl $formatInput
    call scanf
    addl $8, %esp
    movl numarPtCitire, %eax
    movl %eax, -8(%ebp)
    popa

    #switch task (kinda)
    movl -8(%ebp), %eax
    cmp $1, %eax
    jne switchCPCase2

    #task este egal cu 1
    
    #citire N:
    pushl $numarPtCitire
    pushl $formatInput
    call scanf
    addl $8, %esp
    movl numarPtCitire, %eax
    movl %eax, -12(%ebp)

whileNCP:
    movl -12(%ebp), %eax
    cmp $0, %eax
    je endSwitchCP

    #citire id:
    pushl $numarPtCitire
    pushl $formatInput
    call scanf
    addl $8, %esp
    movl numarPtCitire, %eax
    movl %eax, -16(%ebp)

    #citire dim:
    pushl $numarPtCitire
    pushl $formatInput
    call scanf
    addl $8, %esp
    movl numarPtCitire, %eax
    movl %eax, -20(%ebp)

    pusha
    pushl -20(%ebp) #dim
    pushl -16(%ebp) #id
    pushl 12(%ebp) #n
    pushl 8(%ebp) #vectorul
    call addOP
    add $16, %esp
    popa

    #pushl n
    #pushl $vector
    #call showArray
    #add $8, %esp

    subl $1, -12(%ebp)

    jmp whileNCP
switchCPCase2:
    movl -8(%ebp), %eax
    cmp $2, %eax
    jne switchCPCase3

    #citire id:
    pushl $numarPtCitire
    pushl $formatInput
    call scanf
    addl $8, %esp
    movl numarPtCitire, %eax
    movl %eax, -16(%ebp)

    pusha
    pushl -16(%ebp)
    pushl 12(%ebp)
    pushl 8(%ebp)
    call getOP
    add $12, %esp
    popa

    jmp endSwitchCP
switchCPCase3:
    movl -8(%ebp), %eax
    cmp $3, %eax
    jne switchCPCaseDefault

    #citire id:
    pushl $numarPtCitire
    pushl $formatInput
    call scanf
    addl $8, %esp
    movl numarPtCitire, %eax
    movl %eax, -16(%ebp)

    pusha
    pushl -16(%ebp)
    pushl 12(%ebp)
    pushl 8(%ebp)
    call deleteOP
    add $12, %esp
    popa

    pusha
    pushl n
    pushl $vector
    call showSequence
    add $8, %esp
    popa

    jmp endSwitchCP
switchCPCaseDefault:
    pusha
    pushl 12(%ebp)
    pushl 8(%ebp)
    call defragmentationOP
    add $8, %esp
    popa

    pusha
    pushl n
    pushl $vector
    call showSequence
    add $8, %esp
    popa

endSwitchCP:
    subl $1, -4(%ebp)
    jmp whileOpCP
exitControlPanel:
    addl $20, %esp
    popl %ebp
    ret


.global main
main:
    pushl n
    pushl $vector
    call init
    add $8, %esp

    pushl n
    pushl $vector
    call controlPanel
    add $8, %esp
	# Iesire (sys_exit)
sys_exit:
	movl $1, %eax         # numarul apelului de sistem exit
	movl $0, %ebx         # codul de iesire 0
	int $0x80
