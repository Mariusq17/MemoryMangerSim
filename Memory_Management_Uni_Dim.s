.section .note.GNU-stack,"",@progbits

.data
    matrix: .space 4194304
    vector: .space 2048
    m: .long 512
    n: .long 1024
    N: .long 1048576
    lastPoz: .long 0
    numarPtCitire: .long 0
    formatAfisarePerechiIndiciAddOP: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatAfisarePerechiIndiciGetOP: .asciz "((%d, %d), (%d, %d))\n"
    formatAfisareValoarePerechePoz: .asciz "%d: ((%d, %d), (%d, %d))\n"
    formatAfisareNum: .asciz "%d "
    formatAfisareNum2: .asciz "%d\n"
    newLine: .asciz "\n"
    formatInput: .asciz "%d"
    numarOpAdd: .long 0
    numarOpDel: .long 0
    numarOpGet: .long 0
    formatAdd: .asciz "Operatia Add cu numarul %d\n"
    formatDel: .asciz "Operatia Del cu numarul %d, id: %d\n"
    formatGet: .asciz "Operatia Get cu numarul %d\n"
.text
init:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi #matricea
    
    xor %ecx, %ecx
    pushl %ecx #i = 0
    pushl %ecx #j = 0
    loopInit1:
        movl -4(%ebp), %eax
        cmp %eax, 12(%ebp) #i == n ?
        je exitInit

        movl $0, -8(%ebp) #j = 0 la fiecare pas i
    loopInit2:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopInit2

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl $0, (%edi, %eax, 4) #matrix[i * n + j] = 0

        addl $1, -8(%ebp) #j++

        jmp loopInit2
    exitLoopInit2:
        addl $1, -4(%ebp) #i++
        jmp loopInit1
    exitInit:
    addl $8, %esp #scot indicii de pe stiva
    popl %ebp
    ret

showMatrix:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi #matricea
    
    xor %ecx, %ecx
    pushl %ecx #i = 0
    pushl %ecx #j = 0
    loopShowMatrix1:
        movl -4(%ebp), %eax
        #cmp %eax, 12(%ebp) #i == n ?
        cmp $1, %eax #i == n ?
        je exitShowMatrix

        movl $0, -8(%ebp) #j = 0 la fiecare pas i
    loopShowMatrix2:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopShowMatrix2

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        #afisarea elem matrix[i * n + j]
        pusha
        pushl (%edi, %eax, 4)
        push $formatAfisareNum
        call printf
        addl $8, %esp

        pushl $0
        call fflush
        addl $4, %esp
        popa

        addl $1, -8(%ebp) #j++

        jmp loopShowMatrix2

    exitLoopShowMatrix2:
        #afisarea enterului
        pusha
        push $newLine
        call printf
        addl $4, %esp

        pushl $0
        call fflush
        addl $4, %esp
        popa

        addl $1, -4(%ebp) #i++
        jmp loopShowMatrix1

    exitShowMatrix:
    pusha
    push $newLine
    call printf
    addl $4, %esp

    pushl $0
    call fflush
    addl $4, %esp
    popa
    addl $8, %esp #scot indicii de pe stiva
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

        xor %ecx, %ecx
        pushl %ecx #i -4
        pushl %ecx #j -8
        pushl %ecx #linStart -12
        pushl %ecx #colStart -16
        pushl %ecx #linFinish -20
        pushl %ecx #colFinish -24
        pushl %ecx #copie a lui j curent -28
        pushl 20(%ebp) #copie a dimensiunii -32

    loopAddOP1:
        movl -4(%ebp), %eax
        cmp %eax, 12(%ebp) #i == n ?
        je exitAddOP

        movl $0, -8(%ebp) #j = 0 la fiecare pas i
    loopAddOP2:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopAddOP2

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl $0, %ebx
        cmp %ebx, (%edi, %eax, 4)
        je checkApplyDim

        addl $1, -8(%ebp) #j++

        jmp loopAddOP2
    checkApplyDim:
        #actualizare copieJ, copieDim
        movl -8(%ebp), %eax
        movl %eax, -28(%ebp) #copieJ = j

        movl 20(%ebp), %eax
        movl %eax, -32(%ebp) #copieDim = dim

    checkApplyDimLoop:
        movl -28(%ebp), %eax
        cmp %eax, 12(%ebp)
        je checkApplyDimLoopExit #copieJ == n ?

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -28(%ebp), %eax #(%eax este pozitia (i * n + copieJ))

        movl $0, %ebx
        cmp %ebx, (%edi, %eax, 4)
        je checkApplyDimLoopIf

        movl 20(%ebp), %eax
        movl %eax, -32(%ebp) #copieDim = dim

        jmp checkApplyDimLoopPart2
    checkApplyDimLoopIf:
        subl $1, -32(%ebp) #copieDim--
    checkApplyDimLoopPart2:
        movl $0, %ebx
        cmp %ebx, -32(%ebp) #copieDim == 0 ?
        je checkApplyDimLoopExit

        addl $1, -28(%ebp) #copieJ++
        jmp checkApplyDimLoop
    checkApplyDimLoopExit:
        movl $0, %ebx
        cmp %ebx, -32(%ebp) #copieDim == 0 ?
        jne exitLoopAddOP2
        #Se duce la iteratia i+1, deoarece nu mai are rost sa treaca la urmatorul j (daca nu s-a gasit dim necesara
        #de la pozitia j pana la n, automat nu se va gasi nici de la j + 1 la n, deci sar la urmatoarea linie)

        #actualizarea indicilor: 
        movl -4(%ebp), %eax #i
        movl %eax, -12(%ebp) #linStart = i
        movl %eax, -20(%ebp) #linFinish = i
        movl -28(%ebp), %eax #copieJ
        movl %eax, -24(%ebp) #colFinish = copieJ

        movl %eax, -16(%ebp)
        movl 20(%ebp), %eax #dim
        subl %eax, -16(%ebp)
        addl $1, -16(%ebp) #colStart = copieJ - dim + 1

        movl -16(%ebp), %eax
        movl %eax, -28(%ebp) #copieJ = colStart  
    applyIDLoop:
        movl -28(%ebp), %eax
        cmp %eax, -24(%ebp) 
        jl exitAddOP #copieJ <= colFinish ?

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -28(%ebp), %eax #(%eax este pozitia (i * n + copieJ))

        movl 16(%ebp), %ebx
        movl %ebx, (%edi, %eax, 4) #matrix[i * n + copieJ] = id

        addl $1, -28(%ebp) #copieJ++

        jmp applyIDLoop
    exitLoopAddOP2:
        addl $1, -4(%ebp) #i++
        jmp loopAddOP1

    exitAddOP:
    #afisare, scos valori, ret
    #afisare pozitii dupa format:
    pusha
    pushl -24(%ebp) #colFinish
    pushl -20(%ebp) #linFinish
    pushl -16(%ebp) #colStart
    pushl -12(%ebp) #linFinish
    pushl 16(%ebp) #id
    push $formatAfisarePerechiIndiciAddOP
    call printf
    addl $24, %esp

    pushl $0
    call fflush
    addl $4, %esp
    popa

    #stergere variabile locale
    addl $32, %esp
    popl %ebp
    ret

deleteOP:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi #matricea
    
    xor %ecx, %ecx
    pushl %ecx #i = 0
    pushl %ecx #j = 0
    loopDeleteOP1:
        movl -4(%ebp), %eax
        cmp %eax, 12(%ebp) #i == n ?
        je exitDeleteOP

        movl $0, -8(%ebp) #j = 0 la fiecare pas i
    loopDeleteOP2:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopDeleteOP2

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl 16(%ebp), %ebx
        cmp %ebx, (%edi, %eax, 4) #matrix[i * n + j] == id
        jne notEqualDelete
        movl $0, (%edi, %eax, 4) #matrix[i * n + j] = 0

        notEqualDelete:
        addl $1, -8(%ebp) #j++

        jmp loopDeleteOP2
    exitLoopDeleteOP2:
        addl $1, -4(%ebp) #i++
        jmp loopDeleteOP1
    exitDeleteOP:
        addl $8, %esp
        popl %ebp
        ret

getOP:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi #matricea
    
    xor %ecx, %ecx
    pushl %ecx #i -4
    pushl %ecx #j -8
    pushl %ecx #linStart -12
    pushl %ecx #colStart -16
    pushl %ecx #linFinish -20
    pushl %ecx #colFinish -24
    loopGetOP1:
        movl -4(%ebp), %eax
        cmp %eax, 12(%ebp) #i == n ?
        je exitGetOP

        movl $0, -8(%ebp) #j = 0 la fiecare pas i
    loopGetOP2:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopGetOP2

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl 16(%ebp), %ebx
        cmp %ebx, (%edi, %eax, 4) #matrix[i * n + j] == id
        jne notEqualGetOP
        
        #daca este egal:
        
        movl -4(%ebp), %ebx
        movl %ebx, -12(%ebp) #linStart = i
        movl %ebx, -20(%ebp) #linFinish = i

        movl -8(%ebp), %ebx
        movl %ebx, -16(%ebp) #colStart = j
        loopGetOPEqual:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopGetOPEqual

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl 16(%ebp), %ebx
        cmp %ebx, (%edi, %eax, 4) #matrix[i * n + j] == id ?
        jne exitLoopGetOPEqual

        addl $1, -8(%ebp) #j++

        jmp loopGetOPEqual
        exitLoopGetOPEqual:
        movl -8(%ebp), %ebx
        subl $1, %ebx
        movl %ebx, -24(%ebp) #colFinish = j - 1
        jmp exitGetOP

        notEqualGetOP:
        addl $1, -8(%ebp) #j++

        jmp loopGetOP2
    exitLoopGetOP2:
        addl $1, -4(%ebp) #i++
        jmp loopGetOP1
    exitGetOP:
        #afisare, scos valori, ret
        #afisare pozitii dupa format:
        pusha
        pushl -24(%ebp) #colFinish
        pushl -20(%ebp) #linFinish
        pushl -16(%ebp) #colStart
        pushl -12(%ebp) #linFinish
        push $formatAfisarePerechiIndiciGetOP
        call printf
        addl $20, %esp

        pushl $0
        call fflush
        addl $4, %esp
        popa

        addl $24, %esp
        popl %ebp
        ret

defragmentationAddOP: 
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi   # vectorul 

    xor %edx, %edx
    movl 20(%ebp), %eax #mut dim in eax
    movl $8, %ebx
    div %ebx

    cmp $0, %edx #daca dim % 8 == 0
    je defragmentationAddOPSeImparte
    
    addl $1, %eax #daca nu se imparte, mai adaug 1
    defragmentationAddOPSeImparte:
        movl %eax, 20(%ebp) #actualizez dimensiunea corect

        #calculare i si j based on lastPoz
        xor %edx, %edx
        movl lastPoz, %eax
        movl 12(%ebp), %ebx
        divl %ebx

        xor %ecx, %ecx
        pushl %eax #i -4 lastPoz / n
        pushl %edx #j -8 lastPoz % n
        pushl %ecx #linStart -12
        pushl %ecx #colStart -16
        pushl %ecx #linFinish -20
        pushl %ecx #colFinish -24
        pushl %ecx #copie a lui j curent -28
        pushl 20(%ebp) #copie a dimensiunii -32
    loopDefragmentationAddOP1:
        movl -4(%ebp), %eax
        cmp %eax, 12(%ebp) #i == n ?
        je exitDefragmentationAddOP

        movl $0, -8(%ebp) #j = 0 la fiecare pas i
    loopDefragmentationAddOP2:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopDefragmentationAddOP2

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl $0, %ebx
        cmp %ebx, (%edi, %eax, 4)
        je checkApplyDimDefragmentationAddOP

        addl $1, -8(%ebp) #j++

        jmp loopDefragmentationAddOP2
    checkApplyDimDefragmentationAddOP:
        #actualizare copieJ, copieDim
        movl -8(%ebp), %eax
        movl %eax, -28(%ebp) #copieJ = j

        movl 20(%ebp), %eax
        movl %eax, -32(%ebp) #copieDim = dim

    checkApplyDimDefragmentationAddOPLoop:
        movl -28(%ebp), %eax
        cmp %eax, 12(%ebp)
        je checkApplyDimDefragmentationAddOPLoopExit #copieJ == n ?

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -28(%ebp), %eax #(%eax este pozitia (i * n + copieJ))

        movl $0, %ebx
        cmp %ebx, (%edi, %eax, 4)
        je checkApplyDimDefragmentationAddOPLoopIf

        movl 20(%ebp), %eax
        movl %eax, -32(%ebp) #copieDim = dim

        jmp checkApplyDimDefragmentationAddOPLoopPart2
    checkApplyDimDefragmentationAddOPLoopIf:
        subl $1, -32(%ebp) #copieDim--
    checkApplyDimDefragmentationAddOPLoopPart2:
        movl $0, %ebx
        cmp %ebx, -32(%ebp) #copieDim == 0 ?
        je checkApplyDimDefragmentationAddOPLoopExit

        addl $1, -28(%ebp) #copieJ++
        jmp checkApplyDimDefragmentationAddOPLoop
    checkApplyDimDefragmentationAddOPLoopExit:
        movl $0, %ebx
        cmp %ebx, -32(%ebp) #copieDim == 0 ?
        jne exitLoopDefragmentationAddOP2
        #Se duce la iteratia i+1, deoarece nu mai are rost sa treaca la urmatorul j (daca nu s-a gasit dim necesara
        #de la pozitia j pana la n, automat nu se va gasi nici de la j + 1 la n, deci sar la urmatoarea linie)

        #actualizarea indicilor: 
        movl -4(%ebp), %eax #i
        movl %eax, -12(%ebp) #linStart = i
        movl %eax, -20(%ebp) #linFinish = i
        movl -28(%ebp), %eax #copieJ
        movl %eax, -24(%ebp) #colFinish = copieJ

        movl %eax, -16(%ebp)
        movl 20(%ebp), %eax #dim
        subl %eax, -16(%ebp)
        addl $1, -16(%ebp) #colStart = copieJ - dim + 1

        movl -16(%ebp), %eax
        movl %eax, -28(%ebp) #copieJ = colStart  

        #actualizare lastPoz
        xor %edx, %edx
        movl -4(%ebp), %eax
        movl 12(%ebp), %ebx
        mull %ebx
        addl -24(%ebp), %eax
        movl %eax, lastPoz #lastPoz = i (linStart || linFinish) * n + colFinish
    applyIDDefragmentationAddOPLoop:
        movl -28(%ebp), %eax
        cmp %eax, -24(%ebp) 
        jl exitDefragmentationAddOP #copieJ <= colFinish ?

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -28(%ebp), %eax #(%eax este pozitia (i * n + copieJ))

        movl 16(%ebp), %ebx
        movl %ebx, (%edi, %eax, 4) #matrix[i * n + copieJ] = id

        addl $1, -28(%ebp) #copieJ++

        jmp applyIDDefragmentationAddOPLoop
    exitLoopDefragmentationAddOP2:
        addl $1, -4(%ebp) #i++
        jmp loopDefragmentationAddOP1
    exitDefragmentationAddOP:
    #stergere variabile locale
    addl $32, %esp
    popl %ebp
    ret
initVector:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi
    movl $0, %ecx
    loopInitVector:
        cmp 12(%ebp), %ecx #m == ecx
        je exitInitVector

        movl $0, (%edi, %ecx, 4)
        addl $1, %ecx

        jmp loopInitVector
    exitInitVector:
        popl %ebp
        ret
defragmentationOP:
    pushl %ebp
    movl %esp, %ebp

    #initializarea vectorului auxiliar (pentru id si nr blocuri)
    pushl 20(%ebp) #m
    pushl 16(%ebp) #vectorul
    call initVector
    addl $8, %esp

    movl 8(%ebp), %edi #matricea
    
    xor %ecx, %ecx
    pushl %ecx #i = 0
    pushl %ecx #j = 0
    pushl %ecx #k = 0
    pushl %ecx #cnt = 0
    #reinitializare lastPoz cu 0
    movl $0, lastPoz
    loopDefragmentationOP1:
        movl -4(%ebp), %eax
        cmp %eax, 12(%ebp) #i == n ?
        je exitLoopDefragmentationOP1

        movl $0, -8(%ebp) #j = 0 la fiecare pas i
    loopDefragmentationOP2:
        movl -8(%ebp), %eax
        cmp %eax, 12(%ebp) #j == n ?
        je exitLoopDefragmentationOP2

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl $0, %ebx
        cmp %ebx, (%edi, %eax, 4) #matrix[i * n + j] == 0
        je equalDefragmentationOP

        
        
        movl -8(%ebp), %ebx
        movl %ebx, -12(%ebp) #k = j

        movl (%edi, %eax, 4), %ebx #matrix[i * n + j]
        movl -16(%ebp), %edx #cnt
        movl 16(%ebp), %ecx #ecx este vectorul
        movl %ebx, (%ecx, %edx, 4)
        addl $1, %edx 
        movl %edx, -16(%ebp) #fr[cnt++] = matrix[i * n + j]

    loopAddFreqDefragmentationOP:
        movl -12(%ebp), %ebx #k < n ?
        cmp %ebx, 12(%ebp)
        je endLoopAddFreqDefragmentationOP

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -12(%ebp), %eax
        movl %eax, %ecx #(%ecx este pozitia (i * n + k))

        movl 12(%ebp), %eax #n
        movl -4(%ebp), %ebx #i
        mull %ebx
        addl -8(%ebp), %eax #(%eax este pozitia (i * n + j))

        movl (%edi, %ecx, 4), %edx #(%edx = matrix[i * n + k])
        cmp %edx, (%edi, %eax, 4) #matrix[i * n + k] == matrix[i * n + j]
        jne endLoopAddFreqDefragmentationOP

        movl -16(%ebp), %ebx
        movl 16(%ebp), %ecx #ecx este vectorul
        addl $1, (%ecx, %ebx, 4) #vector[cnt]++

        addl $1, -12(%ebp) #k++

        jmp loopAddFreqDefragmentationOP
    endLoopAddFreqDefragmentationOP:
        addl $1, -16(%ebp) #cnt++
        
        movl -12(%ebp), %ebx
        subl $1, %ebx
        movl %ebx, -8(%ebp) #j = k - 1
    equalDefragmentationOP:
        addl $1, -8(%ebp) #j++

        jmp loopDefragmentationOP2
    exitLoopDefragmentationOP2:
        addl $1, -4(%ebp) #i++
        jmp loopDefragmentationOP1
    exitLoopDefragmentationOP1:
        #reinitializarea matricei
        pushl n
        pushl $matrix
        call init
        addl $8, %esp

        movl $0, -4(%ebp) #i = 0
    reAddLoopDefragmentationOP:
        movl -4(%ebp), %eax
        cmp %eax, -16(%ebp) #i < cnt ?
        je exitDefragmentationOP
        
        movl -4(%ebp), %edx
        addl $1, %edx
        movl 16(%ebp), %ecx #%ecx este vectorul
        movl (%ecx, %edx, 4), %eax
        xor %edx, %edx
        movl $8, %ebx
        mull %ebx #(%eax = fr[i + 1] * 8)

        pushl %eax #fr[i + 1] * 8
        movl 16(%ebp), %ecx #%ecx este vectorul
        movl -4(%ebp), %edx
        pushl (%ecx, %edx, 4) #fr[i]
        pushl n
        pushl $matrix
        call defragmentationAddOP
        addl $16, %esp

        addl $2, -4(%ebp) #i += 2

        jmp reAddLoopDefragmentationOP
    exitDefragmentationOP:
        addl $16, %esp #scot varibilele locale de pe stiva
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
        cmp 16(%ebp), %ecx #N == ecx (N = numarul total de elemente al matricei)
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
        cmp 16(%ebp), %ecx #N == ecx (N = numarul total de elemente al matricei)
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
        #trebuie calculat linStart, colStart, linFinish, colFinish

        #colFinish = finish % n
        xor %edx, %edx
        movl -12(%ebp), %eax
        movl 12(%ebp), %ebx #n (n = numarul de elemente de pe o linie / coloana)
        div %ebx 
        pushl %edx #colFinish

        #linStart = linFinish = (start - (start % n)) / n
        xor %edx, %edx
        movl -8(%ebp), %eax #start
        movl 12(%ebp), %ebx #n (n = numarul de elemente de pe o linie / coloana)
        divl %ebx
        movl -8(%ebp), %eax #start
        subl %edx, %eax #%eax = start - (start % n)

        xor %edx, %edx
        movl 12(%ebp), %ebx #n (n = numarul de elemente de pe o linie / coloana)
        div %ebx 
        movl %eax, %edx #%edx = (start - (start % n)) / n

        pushl %edx #linFinish

        #colStart = start % n
        xor %edx, %edx
        movl -8(%ebp), %eax
        movl 12(%ebp), %ebx #n (n = numarul de elemente de pe o linie / coloana)
        div %ebx 
        pushl %edx #colStart

        #linStart = linFinish = (start - (start % n)) / n
        xor %edx, %edx
        movl -8(%ebp), %eax #start
        movl 12(%ebp), %ebx #n (n = numarul de elemente de pe o linie / coloana)
        divl %ebx
        movl -8(%ebp), %eax #start
        subl %edx, %eax #%eax = start - (start % n)

        xor %edx, %edx
        movl 12(%ebp), %ebx #n (n = numarul de elemente de pe o linie / coloana)
        div %ebx 
        movl %eax, %edx #%edx = (start - (start % n)) / n

        pushl %edx #linStart

        pushl -4(%ebp) #x
        push $formatAfisareValoarePerechePoz
        call printf
        addl $24, %esp

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
controlPanel:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %edi   # matricea 
    #adaugarea de variabile locale (op, task, N, id, dim)
    pushl $0    #op -4
    pushl $0    #task -8
    pushl $0    #N -12
    pushl $0    #id -16
    pushl $0    #dim -20

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
        pushl N
        pushl n
        pushl $matrix
        call showSequence
        add $12, %esp
        popa

        jmp endSwitchCP
    switchCPCaseDefault:
        pusha
        pushl m
        pushl $vector
        pushl 12(%ebp)
        pushl 8(%ebp)
        call defragmentationOP
        add $16, %esp
        popa
        pusha
        pushl N
        pushl n
        pushl $matrix
        call showSequence
        add $12, %esp
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
    pushl $matrix
    call init
    addl $8, %esp

    pushl n
    pushl $matrix
    call controlPanel
    add $8, %esp
	# Iesire (sys_exit)
sys_exit:
    pushl $0
    call fflush
    popl %eax
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80
