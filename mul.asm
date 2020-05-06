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
imul cx 

jno noOverflow1
pop ax
pop dx 
jmp setOverflow    

noOverflow1: 
                  
pop dx   
add si,ax             
jo setOverflow 
pop ax           
push ax       
push dx 
imul dx 
                                     
jno noOverflow2     
 
pop dx
pop ax
push ax 
push bx 
push cx  
push dx        

xor dx,dx
mov bx,10
div bx  
mov cx,dx
pop dx  
push dx 
push ax
imul dx

jno notOverflow    
pop ax
  
xor dx,dx
div bx
pop dx
push dx
mul dx  
mov bx,1 
jmp nextAfterNotOverflow 

notOverflow: 
pop bx
mov bx,10 
nextAfterNotOverflow:
pop dx
push dx
xor dx,dx
div bx
pop dx     
mov bx,10
add si,ax 
jno continueProgram
pop cx
pop bx
pop ax
jmp setOverflow  

continueProgram:
mov ax,cx  
push dx
mul dx 
pop dx 
push dx
xor dx,dx
div bx
xor dx,dx
div bx
add si,ax 
mov ax,dx
mul bx
add di,ax 
pop dx
pop cx
pop bx
pop ax
push ax
jmp nextOperation2 

noOverflow2:  

pop dx  
      
cmp ax,100
jl nextOperation1
push dx
xor dx,dx 
push cx
mov cx,100
div cx

add si,ax  
add di,dx   
pop cx
pop dx   
jmp nextOperation2          

nextOperation1:
add di,ax    
 
nextOperation2:  
pop ax  
push dx
xor dx,dx 
mov ax,cx
imul bx 
   
jno noOverflow3
pop dx       
push ax 
push bx 
push cx  
push dx     
mov ax,cx
mov dx,bx 
push dx   
xor dx,dx 
xor cx,cx
mov bx,10
div bx  
mov cx,dx
pop dx  
push dx
push ax
imul dx  

jno notOverflow_    
pop ax
  
xor dx,dx
div bx
pop dx
push dx
mul dx  
mov bx,1 
jmp nextAfterNotOverflow_ 

notOverflow_: 
pop bx
mov bx,10 
nextAfterNotOverflow_:

pop dx
push dx
xor dx,dx
div bx
pop dx  
mov bx,10
add si,ax  
jo setOverflow1
mov ax,cx  
push dx
mul dx 
pop dx 
push dx
xor dx,dx
div bx
xor dx,dx
div bx
add si,ax  
jo setOverflow1
mov ax,dx
mul bx
add di,ax 
pop dx   
pop dx
pop cx
pop bx
pop ax
push dx
jmp nextOperation4  

setOverflow1:
mov cx,-1  
jmp exit

noOverflow3:               
cmp ax,100
jl nextOperation3
push cx
mov cx,100
div cx    
pop cx
adc si,ax   
jo setOverflow1
add di,dx
jmp nextOperation4        

nextOperation3:
add di,ax  

nextOperation4:     
mov ax,bx    
pop dx  
mul dx     
jno notOverflow4  
jmp setOverflow 

notOverflow4:
xor dx,dx
push cx
mov cx,100
div cx    
pop cx

add di,ax   
mov ax,si
cmp di,100                   
jl less100
inc ax   
mov bx,di
sub bx,100 

less100: 
mov bx,di                               
   
exit:
pop di
pop si 
retf
overlay endp  

cod ends  

end