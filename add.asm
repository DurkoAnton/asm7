dat segment

dat ends  

cod segment para public 'code'

overlay proc far

assume cs:cod,ds:dat 

jmp startPlus   

setOverflow:
mov cx,-1
retf   

checkNegativeNumbers:
cmp bx,dx
jg firstFractionalPartMore
sub dx,bx
mov bx,dx           
add ax,cx
jmp exit

firstFractionalPartMore:

add dx,10
sub dx,bx 
mov bx,dx
add ax,cx  
jo setOverflow
dec ax 
cmp ax,-1
jne exit
mov ax,0
mov dx,-1   
jmp exit  

checkZero:
cmp si,1
jne positiveNumbers    
cmp bx,dx
jg firstFractionalPartMore_
sub dx,bx 
mov bx,dx

mov ax,cx 
jmp exit
firstFractionalPartMore_:
add dx,10
sub dx,bx 
mov bx,dx
dec cx
mov ax,cx  
jmp exit 
 
startPlus: 
cmp ax,0
je checkZero
jl checkNegativeNumbers  

positiveNumbers:
add ax,cx 
jo setOverflow 
cmp bx,dx                           
add bx,dx 
cmp bx,10
jl exit
add ax,1
sub bx,10    
        
 exit:
 retf
overlay endp  

cod ends
end