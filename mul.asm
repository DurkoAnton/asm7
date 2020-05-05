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
push ax       
push dx 
imul dx 
  
jno noOverflow2
;pop dx  
pop dx
pop ax
push ax 
push bx
push dx
mov ax,dx
xor dx,dx
mov bx,10
div ax,bx 
pop dx
pop bx  
mov dx,ax
pop ax
imul dx

jmp setOverflow 

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
push dx
xor dx,dx 
mov ax,cx
mul bx 
   
jno noOverflow3
pop dx 
jmp setOverflow  

noOverflow3:               
cmp ax,100
jl nextOperation3
push cx
mov cx,100
div cx    
;mov dx,ax  
;mov ah,2
;add dx,'-'
;int 21h 
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
;mov dx,ax  
;mov ah,2
;add dx,'0'
;int 21h 
jo setOverflow 

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