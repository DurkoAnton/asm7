cod segment para public 'code'

overlay proc far

assume cs:cod
 
jmp startSub  

setOverflow_:
mov cx,-1
jmp exit 

checkNegativeNumbers:
sub ax,cx   
jo  setOverflow_
add bx,dx 
cmp bx,100
jl  exit
sub bx,100
dec ax
jmp exit           

checkZero:
cmp si,1
jne subPositiveNumbers  

mov ax,cx
neg ax
add bx,dx
cmp bx,100
jl exit
dec ax
sub bx,100
jmp exit

startSub:
cmp ax,0
jl checkNegativeNumbers  
je checkZero
jg subPositiveNumbers   

exit:
retf 
                                              
subPositiveNumbers: 

cmp bx,dx
jg firstFractionalMore 
je equalFractional
jmp secondFractionalMore
             
equalFractional:       
mov bx,0  
sub ax,cx
jo setOverflow
jmp exit    

firstFractionalMore:
cmp ax,cx         
jge firstNumberMore
add dx,100
sub dx,bx   
mov bx,dx
sub ax,cx 
jo  setOverflow
inc ax
cmp ax,0
jne exit
mov dx,-1
jmp exit   

firstNumberMore:
sub bx,dx
sub ax,cx
jmp exit 

secondFractionalMore:
cmp ax,cx         
jg firstNumberMore_
sub dx,bx 
mov bx,dx
sub ax,cx  
jo  setOverflow
cmp ax,0
jne exit
mov dx,-1
jmp exit
firstNumberMore_:
add bx,100
sub bx,dx
sub ax,cx  
jo  setOverflow
dec ax   
cmp ax,-1
jne exit
mov ax,0
mov dx,-1
jmp exit
 
setOverflow:
mov cx,-1
jmp exit    

overlay endp  

cod ends
end