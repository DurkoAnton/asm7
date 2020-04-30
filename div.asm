dat segment
dat ends  

cod segment para public 'code'
start:
overlay proc far

assume cs:cod,ds:dat

jmp startMul
setOverflow: 
mov cx,-1   
retf

startMul:
xor dx,dx          
push cx
mov cx,10
mul cx 
jo setOverflow
add ax,bx
mov bx,10
pop cx   
div cx  
xor dx,dx
div bx
mov bx,dx
xor dx,dx 

retf
overlay endp  

cod ends
end start