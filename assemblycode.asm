LI R1,6     #---dhdjsha
LI R2,2    
LI R3,3     #dgjhbusjk
LI R4,1        
LI R5,1    


STORE R0,R0, 0    
STORE R0, R0, 1     
STORE R0,R0, 2     
STORE R0,R0, +3         
STORE R0,R0, +4       
STORE R0,R0, +5        
STORE R0,R0, +6      
STORE R0,R0, +7     

LI R7,3             
SLL R7,R7,R2        
STORE R7,R3, +0      
STORE R7,R3, +1   
    
BEQ R2,R0,+6      
BEQ R2,R1,+7      
BEQ R3,R0,+8       
BEQ R3,R1,+9      
ADD R2,R4,R2        
ADD R3,R5,R3       
JMP -19               

LI R4,1           
JMP -7             

LI R4,-1         
JMP -9              

LI R5,1        
JMP -9        
    
LI R5,-1          
JMP -11        