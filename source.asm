%include "io.inc"

%define MAX_INPUT_SIZE 4096

section .data
        semn: db 0  ; variabila de semn

section .bss
	expr: resb MAX_INPUT_SIZE

section .text
global CMAIN
CMAIN:
         mov ebp, esp; for correct debugging
	push ebp
	mov ebp, esp

	GET_STRING expr, MAX_INPUT_SIZE
        xor ecx,ecx ; este folosit drept index in stringul citit
        xor eax,eax ; in el se formeaza numarul format din cifrele citite de la tastatura, respectiv se 
                                                                            ;retine rezultatul operatiei
loop:   
        xor ebx,ebx
        
        cmp byte[expr+ecx],0 ; daca byte-ul e null trece la afisare
        je afisare
        
        cmp byte[expr+ecx],'-' ; daca este minus trece la operatia de scadere
        je  subtract
        
        cmp byte[expr+ecx],48 ; daca este o cifra trece la operatia de adaugare a cifrei la numarul in curs de
        jge form_number                                                                              ;formare 
        
        cmp byte[expr+ecx],' ' ; daca este un spatiu adauga numarul format in stack sau numarul obtinut din 
        je  stack_push                                                             ;operatia anterioara
        
        cmp byte[expr+ecx],'+' ; daca este un plus trece la operatia de adunare
        je plus
        
        cmp byte[expr+ecx],'/' ; daca este un impartit trece la opearatia de imartire
        je divide
        
        cmp byte[expr+ecx],'*' ; daca este inmultit trece la operatia de inmultire
        je mult

                
afisare:
        PRINT_DEC 4,eax
	xor eax, eax
	pop ebp
        ret
        leave

subtract:
        cmp byte[expr+ecx+1],48 ; daca byte-ul urmator este o cifra inseamna, ca minusul este de semn
        jge sign
        
        pop ebx ; altfel extrage numerele din stiva si retine rezultatul in eax si apoi trece la urmatorul byte
        pop eax
        sub eax,ebx
        
        inc ecx
        jmp loop


plus:   ; extrag numerele din stiva si retine rezultatul in eax si apoi trece la urmatorul byte
        pop ebx
        pop eax
        add eax,ebx
        
        inc ecx
        jmp loop


divide: ; extrage numerele din stiva si retine rezultatul in eax si apoi trece la urmatorul byte
        pop ebx
        pop eax
        cdq
        idiv ebx
        
        inc ecx
        jmp loop


mult:   ; extrage numerele din stiva si retine rezultatul in eax si apoi trece la urmatorul byte
        pop ebx
        pop eax
        imul ebx
        
        inc ecx
        jmp loop

                
sign:   ;se seteaza variabila semn pe 1 si se trece la urmatorul byte
        mov byte[semn],1
            
        inc ecx
        jmp loop


form_number:    ;se adauga la numarul in curs de formare cifra respectiva si se trece la urmatorul byte
        mov bl,byte[expr+ecx]
        sub bl,48    ; cifra respectiva
        
        imul eax,10 
        add eax,ebx
         
        inc ecx
        jmp loop


stack_push: ; adaug in stiva numarul nou format sau nr obtinut in urma operatiei si trece la urmatorul byte
        cmp byte[semn],1 ;verifica daca am bit de semn inainte de a adauga numarul nou format in stiva 
        jne else_if
        
        imul eax,-1
        mov byte[semn],0
    else_if:
        push eax
        xor eax,eax
        
        inc ecx
        jmp loop