dat segment
dat ends  

cod segment para public 'code'

overlay proc far

assume cs:cod,ds:dat 
 
jmp startSub  

checkNegativeNumbers:
sub ax,cx
add bx,dx 
cmp bx,10
jl  exit
sub bx,10
dec ax
jmp exit           

checkZero:
cmp si,1
jne subPositiveNumbers  

mov ax,cx
neg ax
add bx,dx
cmp bx,10
jl exit
dec ax
sub bx,10
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
add dx,10
sub dx,bx   
mov bx,dx
sub ax,cx
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
cmp ax,0
jne exit
mov dx,-1
jmp exit
firstNumberMore_:
add bx,10
sub bx,dx
sub ax,cx
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