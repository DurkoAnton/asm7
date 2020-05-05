cod segment para public 'code'

overlay proc far

assume cs:cod

push si
push di
xor si,si
xor di,di

;jmp startDiv  

;setOverflow: 
;pop cx
;mov cx,-1  
;;mov ah,2
;;mov dl,'='
;;int 21h 
;retf

startDiv:    

xor dx,dx
div cx
add si,ax 
;add di,dx          
cmp dx,6534
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
;mov ax,dx
xor dx,dx
;pop bx
;push bx
;mov bx,10
div cx
;pop bx   
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