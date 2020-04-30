dat segment

dat ends  

cod segment para public 'code'

overlay proc far

assume cs:cod    

jmp startMul
setOverflow: 
mov cx,-1   
jmp exit

startMul:

push si
push di  
xor si,si
xor di,di
push ax
 
push dx
mul cx 
jno noOverflow1
pop ax
pop dx 
jmp setOverflow    

noOverflow1: 
pop dx   
add si,ax    
pop ax           
       
push dx 
mul dx 
jno noOverflow2
pop dx 
jmp setOverflow 

noOverflow2: 
pop dx  
      
cmp ax,10
jl nextOperation1
push dx
xor dx,dx 
push cx
mov cx,10
div cx

add si,ax  
add di,dx   
pop cx
pop dx   
jmp nextOperation2          

nextOperation1:
add di,ax    

nextOperation2:     
push dx
xor dx,dx 
mov ax,cx
mul bx    
jno noOverflow3
pop dx 
jmp setOverflow  

noOverflow3:               
cmp ax,10
jl nextOperation3
push cx
mov cx,10
div cx    
pop cx
add si,ax  
add di,dx
jmp nextOperation4        

nextOperation3:
add di,ax  

nextOperation4:     
mov ax,bx    
pop dx  
mul dx 
jo setOverflow 

xor dx,dx
push cx
mov cx,10
div cx    
pop cx

add di,ax   
mov ax,si
cmp di,10      
jl lessTen
inc ax   
mov bx,di
sub bx,10
lessTen: 
mov bx,di  
   
exit:
pop di
pop si
 retf
overlay endp  

cod ends  

end