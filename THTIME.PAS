Unit THTime;
{$C FIXED PRELOAD PERMANENT}
{$G+}
Interface
Var
  Time_ON:Boolean;

Procedure Time(B:Boolean);


Implementation
{$M $900,0,0}
Uses DOS;
Var
  OldInterrupt1C:Pointer;



Procedure Time(B:Boolean);
{$F+,S-,W-,R-}
Procedure Hodiny;Assembler;
Asm
 pushf
 pusha
 push es
 mov ax,0B7FFh
 mov es,ax
 mov cl,4
 mov si,158
 mov ax,703Ah
 mov [es:si+4],ax
 mov [es:si+10],ax
 @1:
 mov al,cl
 out 70h,al
 in  al,71h
 mov ah,al
 shr al,4
 and ax,0F0Fh
 or  ax,3030h
 mov [es:si],al
 mov al,70h
 mov [es:si+1],al
 mov [es:si+2],ah
 mov [es:si+3],al
 add si,6
 sub cl,2
 jnc @1
 pop es
 popa
 popf
end;
{$F-,S+}

begin
  If (B=True) and (Time_ON=False) then
  begin
    GetIntVec($1C,OldInterrupt1C);
    SetIntVec($1C,Addr(Hodiny));
    Time_ON:=True;
  end;
  If (B=False) and (Time_ON=True) then
  begin
    SetIntVec($1C,OldInterrupt1C);
    Time_ON:=False;
  end;
end;

end.