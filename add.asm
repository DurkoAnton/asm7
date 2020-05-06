cod segment para public 'code'

overlay proc far

assume cs:cod

jmp startPlus   

exit_:
retf

setOverflow:
mov cx,-1      
retf   

checkNegativeNumbers:
cmp bx,dx
jg firstFractionalPartMore 

xor si,si
add si,ax
add si,cx
cmp si,0
jne modulsNumbersDiff
mov ax,0
sub dx,bx
mov bx,dx
retf
modulsNumbersDiff:
add bx,100
sub bx,dx 
       
add ax,cx   
inc ax  
checkAXForZero:
cmp ax,0
jne exit_
mov dx,-1                         
retf

firstFractionalPartMore:
                        
add dx,100
sub dx,bx 
mov bx,dx
add ax,cx  
jo setOverflow
 
cmp ax,0
jg checkNegativeZero
mov dx,100
sub dx,bx
mov bx,dx 
cmp ax,0
jne exit 
mov dx,-1   
retf 

checkNegativeZero:         
dec ax 
cmp ax,-1
jne exit
mov ax,0
mov dx,-1   
retf 

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
cmp ax,cx
jne numbersNotEqual
sub bx,dx 
dec cx
mov ax,cx
mov cx,0  
cmp ax,-1  
jne exit

mov ax,0
mov dx,-1
mov cx,0 
jmp exit 

startPlus: 
cmp ax,0
je checkZero
jg positiveNumbers
jmp checkNegativeNumbers  

numbersNotEqual:
add dx,100
sub dx,bx
mov bx,dx
dec cx
mov ax,cx
mov cx,0  
retf

positiveNumbers:
add ax,cx 
jo setOverflow_                             
add bx,dx
cmp bx,100
jl exit  
add ax,1
sub bx,100    
retf
setOverflow_: 
mov cx,-1
       
exit:
retf 

overlay endp  

cod ends
end