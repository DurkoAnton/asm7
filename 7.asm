.model small
.stack 100h       

ZSEG SEGMENT
    
ZSEG ENDS  

.data
string db 250 dup (?)   
strSize db ?   
flagIteration db 0
overlay_seg dw ?
overlay_off dw ? 
code_seg dw ?   
flagNegWrite db ? 
flagNegNumber db ?
flagNegZero  db ?  
beginNum dw ?       
beginExp dw ?
pathToTheAdd db "add.exe",0  
pathToTheSub db "sub.exe",0
pathToTheMul db "mul.exe",0
pathToTheDiv db "div.exe",0   
errorMessage db "Error commmand line argument$" 
errorChangeMemory db "error change memory$"  
errorAllocMemory db "error alloc memory$"
overflowMessage db "overflow$"

number dw ?
countMul db ?  
countAdd db ?
countSub db ?
countDiv db ? 
posDot dw ?
k dw 10 
block dw 0 

.code  
start:    
    mov ax, @data    
    mov ds,ax   
    
    mov code_seg,cs
    mov bx,ZSEG
    mov ax,es
    sub bx,ax
    mov ah,4ah
    int 21h  
    jc errorSetMemoryForProgramm
    jmp setMemoryForOverlay
    
    errorSetMemoryForProgramm:
    mov ah,9
    lea dx,errorChangeMemory
    int 21h
    mov ah,4ch
    int 21h
    
    setMemoryForOverlay:  
    mov bx,100h
    mov ah,48h
    int 21h        
    jc errorGetMemoryForOverlay
    jmp offsetOverlay
    
    errorGetMemoryForOverlay:
    mov ah,9
    lea dx,errorAllocMemory
    int 21h
    mov ah,4ch
    int 21h
    
    offsetOverlay:  
    mov overlay_seg,ax 
    mov ax,code_seg
    mov bx,overlay_seg  
    sub bx,ax
    mov cl,4        
    shl bx,cl
    mov overlay_off,bx   
    xor ch,ch
    mov cl,strSize   
   
    xor ch, ch            
	mov cl, es:[80h]   
	
	mov strSize,cl 
	dec strSize 
	mov bl,strSize  
	mov si, 82h 
	mov di, offset string      
         
    missSpace:
    cmp BYTE PTR es:[si], ' '
    jne readString
    inc si
    jmp missSpace       

    errorCommand:
    lea dx,errorMessage
    mov ah,9
    int 21h
    mov ah,4ch
    int 21h   
                  
    readString:    
    
    cmp BYTE PTR es:[si], 0Dh 
    jne  compareSymbol
    jmp checkEnd    
   
    compareSymbol: 
    mov al,es:[si]
    cmp al,'+'
    je addPlus  
    cmp al,'-'
    je addMinus  
     cmp al,'*'
    je addMul  
     cmp al,'/'
    je addDiv 
    cmp al,'0'
    jl errorCommand 
    cmp al,'9'
    jg errorCommand 
    
    readNumber:   
    mov al, es:[si]
    mov [di], al      
          
    inc di    
    inc si
    
    loop readString 
    jmp checkCountSign  
    
    addPlus: 
    cmp si,82h
    jle errorCommand  
    call checkPreviousSymbol
    add countAdd,1  
    loop readString 
   
    addMinus:  
    cmp si,82h
    jle errorCommand 
    call checkPreviousSymbol
    add countSub,1  
    loop readString 
    
    addMul:        
    cmp si,82h
    jle errorCommand 
    call checkPreviousSymbol
    add countMul,1 
    loop readString     

    addDiv:    
    cmp si,82h
    je errorCommandInEnd 
    call checkPreviousSymbol
    add countDiv,1   
    loop readString  

    checkEnd:
    cmp BYTE PTR es:[si-1], '0'
    jl errorCommandInEnd
    jmp checkCountSign
      
     errorCommandInEnd:
    lea dx,errorMessage
    mov ah,9
    int 21h
    mov ah,4ch
    int 21h  
    
     
   checkCountSign:       
   mov al,countDiv 
   add al,countMul
   add al,countAdd
   add al,countSub
   cmp al,0
   je errorCommandInEnd             
   
   call checkPreviousSymbol     

   xor di,di 
   xor si,si 
   xor ah,ah   
   
   checkDiv: 

   xor ch,ch 
   mov cl,countDiv 
   cmp cl,0 
   jg operationDiv
   jmp  checkMul
   
   operationDiv:
   xor di,di
   mov si,di  
   mov flagNegWrite,0
   mov beginNum, di       
   
   doDiv:  
   
   cmp string[di],'.'
   je setbeginNumDotDiv 
   
   cmp flagIteration,1
   jne findOnlyDiv
   
   cmp string[di],'*'
   je findBeginNumberDiv 
   cmp string[di],'-'
   je findBeginNumberDiv 
   cmp string[di],'+'
   je findBeginNumberDiv 
   
   findOnlyDiv: 
   
   cmp string[di],'/'
   je findBeginNumberDiv   
   
   xor ch,ch
   mov cl,strSize
   cmp di, cx
   jge findBeginNumberDiv
   inc di
   jmp doDiv   
   
   setbeginNumDotDiv:    
   
   mov posDot,di
   inc di
   jmp doDiv 

  findBeginNumberDiv: 
  
    dec di   
    cmp string[di],'+'   
    je transferNumberDiv           
    cmp string[di],'*'
    je transferNumberDiv 
    cmp string[di],'/'  
    je transferNumberDiv 
    cmp string[di],'-'  
    je transferNumberDiv  
    cmp string[di],' '  
    je transferNumberDiv
    cmp di,0
    jl transferNumberDiv
   jmp findBeginNumberDiv
   
  transferNumberDiv:  
  inc di   
  mov si,di
  mov beginNum,di   
  cmp flagIteration,0
  jne notSetNewBeginDiv
  mov beginExp,di  
   
  notSetNewBeginDiv:
  mov di,posDot
  
  call transferToNumber 
  mov ax,number
   
   missSignAndSpacesDiv:
   inc di 
   cmp string[di],' '  
   je missSignAndSpacesDiv
   mov si,di 
        
   findEndNumberDiv:
  
   cmp string[di],'0'
   jl transferFractionalPartDiv  
   cmp  di,word ptr strSize
   jge transferFractionalPartDiv
   inc di
   jmp findEndNumberDiv
                                     
   transferFractionalPartDiv:       
   
   call transferToNumber 
   mov bx,number     
  
   push ax   
   push bx 
    
   inc di
   inc flagIteration 
   cmp flagIteration,1
   jne callOverlayDiv
   jmp doDiv
   
   callOverlayDiv:  
   cmp ax,0
   je errorDivZero
   mov flagIteration,0  
   jmp  overlayDiv 
   writeNewNumberInStringDiv: 
   
   mov si,beginExp 
   dec di  
   call writeNumberInString   
   dec countDiv
   cmp countDiv,0  
   jle checkMul
   jmp operationDiv  
 
 errorDivZero: 
 lea dx,errorMessage
 mov ah,9
 int 21h
 mov ah,4ch
 int 21h   
 
checkMul:
   xor ch,ch     
   mov flagNegWrite,0
   
   mov cl,countMul  
   cmp cl,0   
   jg operationMul
   jmp checkCycle    
   
   operationMul:
   xor di,di
   mov si,di 
   mov beginNum, di       
   doMul:
   cmp string[di],'.'
   je setbeginNumDotMul 
   
   cmp flagIteration,1
   jne findOnlyMul
   
   cmp string[di],'/'
   je findBeginNumberMul 
   cmp string[di],'-'
   je findBeginNumberMul
   cmp string[di],'+'
   je findBeginNumberMul  
   
   findOnlyMul: 
   cmp string[di],'*'
   je findBeginNumberMul   
   
   xor ch,ch
   mov cl,strSize
   cmp di, cx
   jge findBeginNumberMul
   inc di
   jmp doMul  
   
   setbeginNumDotMul:
  
    mov posDot,di
    inc di
    jmp doMul 
   findBeginNumberMul:
   
    dec di     
    cmp string[di],'+'   
    je  transferNumberMul
    cmp string[di],'*'
    je  transferNumberMul 
    cmp string[di],'/'  
    je  transferNumberMul
    cmp string[di],'-'  
    je  transferNumberMul              
    cmp string[di],' '  
    je  transferNumberMul
    cmp di,0
    jl  transferNumberMul 
   jmp findBeginNumberMul
   
  transferNumberMul:  
  inc di
  mov si,di  
  mov beginNum,di         
  
  cmp flagIteration,0
  jne notSetNewBeginMul
  mov beginExp,di        
  
  notSetNewBeginMul:                                             
  mov di,posDot
  call transferToNumber 
  mov ax,number
   
  missSignAndSpacesMul:
   inc di      
   cmp string[di],' '  
   je missSignAndSpacesMul
   mov si,di    
    
  findEndNumberMul:
  
   cmp string[di],'0'
   jl transferFractionalPartMul    
   cmp  di,word ptr strSize
   jge transferFractionalPartMul  
   inc di
   jmp findEndNumberMul
                                     
  transferFractionalPartMul:   
  
   call transferToNumber 
   mov bx,number 
    
   push ax
   push bx
   inc di
   inc flagIteration 
   cmp flagIteration,1
   jne callOverlayMul
   jmp doMul
 
    callOverlayMul: 
    mov flagIteration,0 
    jmp  overlayMul  

   writeNewNumberInStringMul:     
   mov si,beginExp         
   dec di
   call writeNumberInString    
   dec countMul
   cmp countMul,0
   jle  checkCycle     
   jmp operationMul  


    checkCycle:
    xor di,di
    
    xor ch,ch
    mov cl,strSize 
    
    cycle:   
    cmp string[di],'-'
    je operationSub  
        
    cmp string[di],'+' 
    jne nextSymbol
    jmp operationAdd 
     
    nextSymbol:
    inc di
    loop cycle  
    jmp endProg   
    
    nextSymbolCheck:      
    xor ch,ch
    mov cl,strSize
    xor di,di    
    jmp cycle 
    
    endProg:
    call outputResult
    mov ah,4ch
    int 21h           

  checkSub:
   xor ch,ch  
   mov flagIteration,0    
   mov flagNegWrite,0  
   
   mov cl,countSub 
   cmp cl,0 
   jg operationSub
   jmp  checkAdd
   
   operationSub:
   xor di,di
   mov si,di 
   mov beginNum, di 
   mov flagNegNumber,0  
   mov flagNegZero,0      
   mov beginExp, di    
    
   doSub:     
    cmp string[di],'.'
   je setbeginNumDotSub
   
   cmp flagIteration,1
   jne findOnlySub
   
   cmp string[di],'/'
   je  findBeginNumberSub 
   cmp string[di],'*'
   je  findBeginNumberSub
   cmp string[di],'+'
   je  findBeginNumberSub
   cmp string[di],'^'
   je setNeg 
   
   findOnlySub:    
   cmp string[di],'^'
   je setNeg 
   cmp string[di],'-'
   je  findBeginNumberSub                   
   xor ch,ch
   mov cl,strSize
   cmp di, cx
   jg findBeginNumberSub   
       
    inc di
    jmp doSub  
    
    setbeginNumDotSub:
    
    mov posDot,di
    inc di  
    jmp doSub  
      
    findBeginNumberSub:
    dec di
    cmp string[di],'+'   
    je transferNumberSub           
    cmp string[di],'*'
    je transferNumberSub 
    cmp string[di],'/'  
    je transferNumberSub 
    cmp string[di],'-'  
    je transferNumberSub   

    cmp string[di],' '  
    je transferNumberSub
    cmp di,0
    jl transferNumberSub 
    jmp  findBeginNumberSub
    
    setNeg: 
    
    mov flagNegNumber,1
    mov flagNegZero,1   
    inc di  
    jmp doSub
    transferNumberSub:   
    
    inc di          
    cmp string[di],'^'
    jne notNegNumSub
    mov beginExp,di
    inc di
    jmp saveBeginNumberSub
    notNegNumSub:
    cmp flagIteration,0
    jne   saveBeginNumberSub
    mov beginExp,di
    saveBeginNumberSub:
    mov beginNum,di
    mov si,di   
    
    mov di,posDot
    call transferToNumber 
    mov ax,number
    
    missSignAndSpacesSub:
    inc di 
    cmp string[di],' '  
    je  missSignAndSpacesSub
    mov si,di     
    findEndNumberSub:
    
    cmp string[di],'0'
    jl  transferFractionalPartSub   
    cmp  di,word ptr strSize
    jge  transferFractionalPartSub
    inc di
    jmp findEndNumberSub
                                 
    transferFractionalPartSub:
    call transferToNumber    
    
    mov bx,number     
    cmp flagNegNumber,0
    je setbeginNumNumbersSub 
    mov flagNegNumber,0
    neg ax
    setbeginNumNumbersSub:
    push ax   
    push bx   
    inc di                         
    inc flagIteration 
    cmp flagIteration,1
    jne  callOverlaySub  
    jmp doSub
    callOverlaySub: 
    
    mov flagIteration,0
  
    dec di  
     
    xor ah,ah  
    mov al,flagNegZero
    mov si,ax
    jmp  overlaySub  
    writeNewNumberInStringSub:  
                                                                                     
    mov flagNegNumber,0   
    mov flagNegZero,0 
    cmp dx,-1 
    je setNegNumbersSub 
    cmp ax,0
    jge writeNumberSub
    setNegNumbersSub:
    neg ax
    mov flagNegWrite,1
    
    writeNumberSub:
    mov si,beginExp      
    call writeNumberInString         
    jmp nextSymbolCheck         

exitFromProgram: 
   call outputResult
   mov ah,4ch
   int 21h
   
    checkAdd:
   xor ch,ch     
   mov flagIteration,0
   mov cl,countAdd 
   cmp cl,0 
   jg operationAdd
   jmp  exitFromProgram
   
  operationAdd:
    xor di,di
    mov si,di 
    mov beginNum, di 
    mov flagNegNumber,0      
    mov flagNegZero,0 
    mov flagNegWrite,0      
    mov beginExp, di 
    
  doAdd: 
   
   cmp string[di],'.'
   je setbeginNumDotAdd
    
   cmp flagIteration,1
   jne findOnlyAdd
   
   cmp string[di],'/'
   je findBeginNumberAdd
   cmp string[di],'*'
   je findBeginNumberAdd
   cmp string[di],'+'
   je findBeginNumberAdd  
   cmp string[di],'-'
   je findBeginNumberAdd  
  
 findOnlyAdd:  
    cmp string[di],'^'
    je setNegAdd 
    cmp string[di],'+'
    je findBeginNumberAdd                    
    xor ch,ch
    mov cl,strSize
    cmp di, cx
    jg findBeginNumberAdd    
    inc di
    jmp doAdd 
    
    setbeginNumDotAdd:
    
    mov posDot,di
    inc di  
    jmp doAdd  
       
    findBeginNumberAdd :
    dec di              
    cmp string[di],'+'   
    je transferNumberAdd          
    cmp string[di],'*'
    je transferNumberAdd   
    cmp string[di],'/'  
    je transferNumberAdd    
    cmp string[di],'-'  
    je transferNumberAdd  
    cmp string[di],' '  
    je transferNumberAdd 
    cmp di,0
    jl transferNumberAdd  
    jmp findBeginNumberAdd 
   
    setNegAdd:  
    mov flagNegNumber,1  
    mov flagNegZero,1 
    inc di  
    jmp doAdd
    
    transferNumberAdd:  
    inc di            
    cmp string[di],'^'
    jne notNegNumAdd
    mov beginExp,di
    inc di
    jmp saveBeginNumberAdd
    notNegNumAdd:
    cmp flagIteration,0
    jne saveBeginNumberAdd
    mov beginExp,di
    saveBeginNumberAdd:
    mov beginNum,di
    mov si,di    
    mov di,posDot
    call transferToNumber 
    mov ax,number 
   
  missSignAndSpacesAdd:
   inc di 
   cmp string[di],' '  
   je missSignAndSpacesAdd
   mov si,di     
   findEndNumberAdd:
  
   cmp string[di],'0'
   jl   transferFractionalPartAdd  
   cmp  di,word ptr strSize
   jge   transferFractionalPartAdd 
   inc di
   jmp findEndNumberAdd 
                                     
   transferFractionalPartAdd:
   call transferToNumber 
   mov bx,number  
   cmp flagNegNumber,0
   je setbeginNumNumbersAdd
   neg ax 
 setbeginNumNumbersAdd: 
    
   push ax 
   push bx 
    
   inc di
   inc flagIteration  
   mov flagNegNumber,0
   cmp flagIteration,1
   jne callOverlayAdd   
   jmp doAdd
   callOverlayAdd:
   mov flagIteration,0 
   mov flagNegNumber,0
   dec di   
   
   xor ah,ah
   mov al,flagNegZero 
   mov si,ax
   jmp  overlayAdd   
   writeNewNumberInStringAdd:
   cmp dx,-1
   jne checkAx
   neg ax
   mov flagNegWrite,1 
   jmp  writeNumberAdd 
   
   checkAx:  
   cmp ax,0
   jge writeNumberAdd
   neg ax
   mov flagNegWrite,1  
   
   writeNumberAdd:  
 
   mov si,beginExp   
   call writeNumberInString  
   mov flagNegNumber,0  
   dec countAdd
   jmp nextSymbolCheck

    exitFromProgrampl:  
    call outputResult
    mov ah,4ch
    int 21h

overlayAdd:
    
    mov ax,seg block
    mov es,ax
    mov bx,offset block 
    mov ax,overlay_seg 
    mov [bx],ax          
    mov [bx]+2,ax 
    lea dx, pathToTheAdd
    mov ah,4bh
    mov al,3
    int 21h    
    jc exitIfErrorLoadOverlay    
    pop dx
    pop cx 
    pop bx
    pop ax
    call DWORD PTR overlay_off 
    cmp cx,-1
    je overflow    
    
    jmp writeNewNumberInStringAdd                  
                       
overlaySub:          
    mov ax,seg block
    mov es,ax
    mov bx,offset block 
      
    mov ax,overlay_seg 
    
    mov [bx],ax          
    mov [bx]+2,ax 
    lea dx, pathToTheSub
    mov ah,4bh
    mov al,3
    int 21h        
    jc exitIfErrorLoadOverlay 
    pop dx 
    pop cx  
    pop bx
    pop ax
    call DWORD PTR overlay_off   
    cmp cx,-1
    je overflow
    jmp writeNewNumberInStringSub

overflow:
                       
 mov ah,9
 lea dx,overflowMessage
 int 21h
 mov ah,4ch
 int 21h 
 
exitIfErrorLoadOverlay:   
    mov ax,4c00h
    int 21h 
                    
overlayMul:
                       
    mov ax,seg block
    mov es,ax
    mov bx,offset block 
    mov ax,overlay_seg 
    mov [bx],ax          
    mov [bx]+2,ax 
    lea dx, pathToTheMul
    mov ah,4bh
    mov al,3    
    
    int 21h  
    jc exitIfErrorLoadOverlay     
    pop dx       
    pop cx 
    pop bx
    pop ax
    call DWORD PTR overlay_off  
    
    cmp cx,-1
    je overflow
    jmp writeNewNumberInStringMul 
                   
                   
overlayDiv:               
    
    mov ax,seg block
    mov es,ax
    mov bx,offset block 
    mov ax,overlay_seg 
    mov [bx],ax          
    mov [bx]+2,ax 
    lea dx, pathToTheDiv
    mov ah,4bh
    mov al,3
    int 21h            
    jc exitIfErrorLoadOverlay
  
    pop dx
    pop cx
    pop bx
    pop ax 
    call DWORD PTR overlay_off 
    cmp cx,-1
    je overflow   
    jmp writeNewNumberInStringDiv 
                                
errorPreviousSymbol:
    lea dx,errorMessage
    mov ah,9
    int 21h
    mov ah,4ch
    int 21h   
    
transferToNumber proc           
    push bx
    push cx
    push si
    push ax
    push di
    
    mov number,0
    xor bh,bh    
    xor ch,ch
    xor ah,ah 
    xor dx,dx
    
    mov bl,1 
    dec di
    xor ah,ah
    transform:
    mov al,string[di]
    
    sub al,'0'
    mul bx  
    jo errorPreviousSymbol 
    add number,ax
    jo errorPreviousSymbol  
    mov ax,bx
    imul k  
    mov bx,ax
    dec di 
    cmp di,si
    jl exitFromTransform   
    xor ax,ax
    jmp transform
    
    exitFromTransform:
    pop di
    pop ax
    pop si
    pop cx
    pop bx    
    ret    
transferToNumber endp  

outputResult proc 
    mov ah,2
    xor si,si
    xor cx,cx
    mov cl,strSize
    output:
    mov dl,string[si]  
    cmp dl,' '
    je nextSymbolInString
    cmp dl,'^'
    jne outputSymbol
    mov dl,'-'
    outputSymbol:
    int 21h 
    nextSymbolInString:
    inc si
    loop output 
ret    
outputresult endp

checkPreviousSymbol proc

mov al,es:[si-1]
cmp al,'+'
je errorPreviousSymbol
cmp al,'-'
je errorPreviousSymbol
cmp al,'/'
je errorPreviousSymbol
cmp al,'*'
je errorPreviousSymbol

mov al,'.'
mov [di],al
inc di   
mov al,'0'
mov [di],al
inc di      
mov al, es:[si]
mov [di], al            
inc di    
inc si  
add strSize,2         
ret    
checkPreviousSymbol endp                    
               
writeNumberInString proc
    push bx
    push cx
    push si
    push di
    xor cx,cx  
    dec di 
    mov cx,ax
    mov ax,bx
    xor dx,dx   
    
    div k     
    mov bx,ax
    add dx,'0'
    mov al,ah
    xor ah,ah
    mov string[di],dl 
    xor ah,ah
    mov ax,bx   
    dec di   
      
    mov al,'.'
    mov string[di],al
    dec di  
    mov ax,cx 
    divNumberPart:
    xor dx,dx
    div k     
    mov bx,ax
    add dx,'0'
    mov al,ah
    xor ah,ah
    mov string[di],dl  
    add cx,1 
    xor ah,ah
    mov ax,bx   
    dec di   
    
    cmp bl,0
    je outNumbers
    jmp divNumberPart
    
    outNumbers:  
    cmp flagNegWrite,0
    je setSpaces
    mov string[di],'^'
    dec di      
    setSpaces:
    mov string[di],' '
    dec di      
    cmp di,si
    jl exitFromSetSpaces
    jmp setSpaces
    exitFromSetSpaces:      
    pop di
    pop si
    pop cx
    pop bx  
    ret    
writeNumberInString endp  

end start