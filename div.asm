cod segment para public 'code'

overlay proc far

assume cs:cod

push si
push di
xor si,si
xor di,di

startDiv:    

xor dx,dx
div cx
add si,ax 
        
cmp dx,6554
jl notOverflow
mov ax,dx
push bx
mov bx,10
xor dx,dx
div bx
push ax
xor dx,dx
mov ax,cx
div bx
mov cx,ax
xor dx,dx
pop ax
pop bx
jmp startDiv 

notOverflow:
push bx
mov bx,10 
mov ax,dx
mul bx

xor dx,dx

div cx
  
push dx   
mul bx 
pop  dx   
push ax
mov ax,dx
mul bx
div cx
mov dx,ax
pop ax
add ax,dx
pop bx
add di,ax

xor dx,dx
mov ax,bx
div cx 

add di,ax

mov ax,si
mov bx,di 
pop di
pop si
retf
overlay endp

cod ends    

end 