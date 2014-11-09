Unit THApp;
Interface
Var
  ScrX,ScrY:Byte;
  IORes:Byte;


Procedure SetVideoPage(P:Byte);
Function Fill(S:String;L:Integer):String;
Procedure RolUp(x0,y0,x1,y1,P,Color:Byte);
Procedure RolDown(x0,y0,x1,y1,P,Color:Byte);
Procedure TextCursor(S:Boolean);
Procedure Center(PosY:Byte;S:String);
Function GetChar(X,Y:Byte):Byte;
Procedure WriteChar(X,Y:Byte;Ch:Char);
Procedure Frame(x0,y0,x1,y1,T:Byte);
Procedure Message(C0:Byte;S:String;C,B:Byte);
Procedure OkMessage(T:String);
Procedure ErrorMessage;
Procedure InitDownMenu(S:String;PosY:Word);
Procedure WriteDownMessage(S:String);
Procedure ClearDownMessage;
Procedure GetScreen;
Procedure SetScreen;
Procedure Help(H,FileOfHelp:String);
Procedure About(Nazev,Verze:String);
Procedure SmallHelp(X1,Y1,X2,Y2:Byte;S:String);
Procedure InitStandardScreen(Znak:Char;Typ,C,B:Byte);
Procedure Done;
Function TextInput(L:Byte;T,Old:String):String;


Implementation
Uses DOS,Crt,THString,CZ;
Var
  InitialMode,InitialPage:Byte;


Procedure GotoXY(x,y:Byte);
Var
  B:Byte;
begin
  B:=MEM[0:$462];
  Asm
  MOV AH,2
  MOV BH,B
  MOV DL,X
  MOV DH,Y
  INT 10h
  end;
end;



Procedure SetVideoPage(P:Byte);Assembler;
Asm
  MOV AH,5
  MOV AL,P
  INT 10h
end;



Function Fill(S:String;L:Integer):String;
Var
  F:Integer;
  FS:String;
begin
  FS:='';
  For F:=Length(S) to L do FS:=FS+#32;
  Fill:=FS;
end;



Procedure RolUp(x0,y0,x1,y1,P,Color:Byte);Assembler;
Asm
  MOV AH,6
  MOV CH,y0            {y1}
  MOV CL,x0            {x1}
  MOV DH,y1            {y2}
  MOV DL,x1            {x2}
  MOV AL,P             {Pocet}
  MOV BH,Color
  INT 10h
end;

Procedure RolDown(x0,y0,x1,y1,P,Color:Byte);Assembler;
Asm
  MOV AH,7
  MOV CH,y0
  MOV CL,x0
  MOV DH,y1
  MOV DL,x1
  MOV AL,P
  MOV BH,Color
  INT 10h
end;

Procedure TextCursor(S:Boolean);
begin
  If S=True then
  Asm
  MOV AH,1
  MOV CH,15
  MOV CL,16
  INT 10h
  end
  else
  Asm
  MOV AH,1
  MOV CH,20h
  MOV CL,20h
  INT 10h
  end;
end;


Procedure Center(PosY:Byte;S:String);
begin
  GotoXY(MemW[0:$44A] div 2-Length(S) div 2+1,PosY);Write(S);
end;


Function GetChar(X,Y:Byte):Byte;
begin
  If X>0 then Dec(X);
  If Y>0 then Dec(Y);
  GetChar:=Mem[$B800:X*2+Y*2*80];
end;



Procedure WriteChar(X,Y:Byte;Ch:Char);
begin
  If X>0 then Dec(X);
  If Y>0 then Dec(Y);
  Mem[$B800:X*2+Y*2*80]:=ord(Ch);
end;


Procedure Frame(x0,y0,x1,y1,T:Byte);
Var
  X,Y,I:Byte;
begin
  If (T and 128)<>128 then
  begin
    GotoXY(x0,y0);
    Case T of 0:Write('É');1:Write('Ú');2:Write('Ö');3:Write('Õ');end;
    GotoXY(x1,y0);
    Case T of 0:Write('»');1:Write('¿');2:Write('·');3:Write('¸');end;
    GotoXY(x0,y1);
    Case T of 0:Write('È');1:Write('À');2:Write('Ó');3:Write('Ô');end;
    GotoXY(x1,y1);
    Case T of 0:Write('¼');1:Write('Ù');2:Write('½');3:Write('¾');end;
    For x:=x0+1 to x1-1 do
    begin
     GotoXY(x,y0);
     Case T of 0:Write('Í');1:Write('Ä');2:Write('Ä');3:Write('Í');end;
     GotoXY(x,y1);
     Case T of 0:Write('Í');1:Write('Ä');2:Write('Ä');3:Write('Í');end;
    end;
    For y:=y0+1 to y1-1 do
    begin
      GotoXY(x0,y);
      Case T of 0:Write('º');1:Write('³');2:Write('º');3:Write('³');end;
      GotoXY(x1,y);
      Case T of 0:Write('º');1:Write('³');2:Write('º');3:Write('³');end;
    end;
  end
  else
  begin
    For x:=x0 to x1 do
    For y:=y0 to y1 do
    begin
      GotoXY(x,y);
      If T and 63=0 then
      begin
        If (x=x0)and(y=y0) then Write('É')else
        If (x=x1)and(y=y0) then Write('»')else
        If (x=x0)and(y=y1) then Write('È')else
        If (x=x1)and(y=y1) then Write('¼')else
        If (x<x1)and(x>x0)and(y=y0) then Write('Í')else
        If (x<x1)and(x>x0)and(y=y1) then Write('Í')else
        If (y<y1)and(y>y0)and(x=x0) then Write('º')else
        If (y<y1)and(y>y0)and(x=x1) then Write('º')else
        Write(' ');
      end;
      If T and 1=1 then
      begin
        If (x=x0)and(y=y0) then Write('Ú')else
        If (x=x1)and(y=y0) then Write('¿')else
        If (x=x0)and(y=y1) then Write('À')else
        If (x=x1)and(y=y1) then Write('Ù')else
        If (x<x1)and(x>x0)and(y=y0) then Write('Ä')else
        If (x<x1)and(x>x0)and(y=y1) then Write('Ä')else
        If (y<y1)and(y>y0)and(x=x0) then Write('³')else
        If (y<y1)and(y>y0)and(x=x1) then Write('³')else
        Write(' ');
      end;
      If T and 2=2 then
      begin
        If (x=x0)and(y=y0) then Write('Ö')else
        If (x=x1)and(y=y0) then Write('·')else
        If (x=x0)and(y=y1) then Write('Ó')else
        If (x=x1)and(y=y1) then Write('½')else
        If (x<x1)and(x>x0)and(y=y0) then Write('Ä')else
        If (x<x1)and(x>x0)and(y=y1) then Write('Ä')else
        If (y<y1)and(y>y0)and(x=x0) then Write('º')else
        If (y<y1)and(y>y0)and(x=x1) then Write('º')else
        Write(' ');
      end;
      If T and 4=4 then
      begin
        If (x=x0)and(y=y0) then Write('Õ')else
        If (x=x1)and(y=y0) then Write('¸')else
        If (x=x0)and(y=y1) then Write('Ô')else
        If (x=x1)and(y=y1) then Write('¾')else
        If (x<x1)and(x>x0)and(y=y0) then Write('Í')else
        If (x<x1)and(x>x0)and(y=y1) then Write('Í')else
        If (y<y1)and(y>y0)and(x=x0) then Write('³')else
        If (y<y1)and(y>y0)and(x=x1) then Write('³')else
        Write(' ');
      end;
      If T and 8=8 then
      begin
        If (x=x0)and(y=y0) then Write(' ')else
        If (x=x1)and(y=y0) then Write(' ')else
        If (x=x0)and(y=y1) then Write(' ')else
        If (x=x1)and(y=y1) then Write(' ')else
        If (x<x1)and(x>x0)and(y=y0) then Write(' ')else
        If (x<x1)and(x>x0)and(y=y1) then Write(' ')else
        If (y<y1)and(y>y0)and(x=x0) then Write(' ')else
        If (y<y1)and(y>y0)and(x=x1) then Write(' ')else
        Write(' ');
      end;
    end;
  end;

  If T and 64=64 then
  begin
    For I:=Y0+1 to Y1+1 do
    begin
      If I<25 then
      begin
        Mem[$B800:((X1+1)*2)+(I*2*80)+1]:=Mem[$B800:((X1+1)*2)+(I*2*80)+1] and 7
        {(Mem[$B800:((X1+1)*2)+(I*2*80)+1]and (16+32+64)) shr 1};
        Mem[$B800:((X1+2)*2)+(I*2*80)+1]:=Mem[$B800:((X1+2)*2)+(I*2*80)+1] and 7
        {(Mem[$B800:((X1+2)*2)+(I*2*80)+1]and (16+32+64)) shr 1};

      end;
    end;

    For I:=X0+2 to X1 do
    begin
      If Y1<25 then
        Mem[$B800:(I*2)+((Y1+1)*2*80)+1]:=Mem[$B800:(I*2)+((Y1+1)*2*80)+1] and 7;
        {(Mem[$B800:(I*2)+((Y1+1)*2*80)+1]and (16+32+64)) shr 1;}
    end;
  end;
end;




Procedure Message(C0:Byte;S:String;C,B:Byte);
Var
  x0,x1,y0,y1:Integer;
begin
  If B<>255 then TextBackground(B);

  x0:=(MemW[0:$44A] div 2)-(Length(S) div 2);
  x1:=(MemW[0:$44A] div 2)+(Length(S) div 2);
  y0:=(Mem[0:$484] div 2)-1;
  y1:=y0+2;
  If C0<>255 then TextColor(C0);
  If Y0<0 then Y0:=0;
  Frame(x0-5,y0,x1+5,y1,128+64);
  If C<>255 then TextColor(C);
  GotoXY(((x1-x0) div 2-Length(S) div 2+1)+x0,(y1-y0)div 2+y0);Write(S);
end;




Procedure OkMessage(T:String);
begin
  TextColor(14);TextBackground(4);
  Frame((MemW[0:$44A] div 2-Length(T) div 2-5),10,
        (MemW[0:$44A] div 2+Length(T) div 2+5),12,129+64);
  TextColor(10);
  Center(11,T);
  GetKey;
end;



Procedure ErrorMessage;
Var
  Znak,Attr:Array[0..79,10..14] of Byte;
  S:String[80];
Procedure GetScreen;
Var
  ScrX,ScrY,A,B:Byte;
begin
  For ScrY:=10 to 14 do For ScrX:=0 to 79 do
  begin
    Asm
    MOV AH,2
    MOV DL,ScrX
    MOV DH,ScrY
    INT 10h
    MOV AH,8
    MOV BH,0
    INT 10h
    MOV A,AL
    MOV B,AH
    end;
    Znak[ScrX,ScrY]:=A;Attr[ScrX,ScrY]:=B;
  end;
end;
Procedure SetScreen;
Var
  ScrX,ScrY,A,B:Byte;
begin
  For ScrY:=10 to 14 do For ScrX:=0 to 79 do
  begin
    A:=Znak[ScrX,ScrY];B:=Attr[ScrX,ScrY];
    Asm
    MOV AH,2
    MOV DL,ScrX
    MOV DH,ScrY
    INT 10h
    MOV AH,9
    MOV CX,1
    MOV BH,0
    MOV AL,A
    MOV BL,B
    INT 10h
    end;
  end;
end;

begin
  IORes:=IOResult;
  {If MaxAvail>MemAvail then
  begin
    GetScreen;
    Message(15,'Nedostatek pamˆti !',15,4);GetKey;Scan:=0;
    SetScreen;
  end;}
  If IORes<>0 then
  begin
    GetScreen;
    Case IORes of
        2:S:='Soubor nebyl nalezen !';
        3:S:='Nenalezena cesta k souboru !';
        4:S:='P©¡li¨ mnoho otev©en˜ch soubor– !';
        5:S:='Soubor nen¡ p©¡stupn˜.';
        6:S:='Neplatn˜ ovlada‡ souboru.';
       15:S:='Neplatn‚ ‡¡slo disku !';
      100:S:='Chyba p©i ‡ten¡ !';
      101:S:='Chyba p©i z pisu !';
      103:S:='Soubor nebyl otev©en !';
      150:S:='Disk chr nˆn proti z pisu !';
      151:S:='›patn  d‚lka struktury po‘adavku na disk !';
      152:S:='Disk nen¡ p©ipraven !';
      152:S:='Sektor nenalezen !';
      154:S:='Chyba CRC v datech !';
      156:S:='Chyba p©i hled n¡ sektoru !';
      157:S:='Nezn m˜ typ media !';
      158:S:='Sektor nenalezen !';
      160:S:='Chyba p©i z pisu do za©¡zen¡ !';
      161:S:='Chyba p©¡ ‡ten¡ ze za©¡zen¡ !';
      162:S:='Chyba hardwaru !';
      200:S:='Dˆlen¡ nulou';
      201:S:='Chyba rozsahu';
      202:S:='P©ete‡en¡ z sobn¡ku';
      203:S:='P©ete‡en¡ haldy';
      204:S:='Neplatn  operace s ukazatelem';
      205:S:='€¡seln‚ p©ete‡en¡ p©i operaci s re ln˜mi ‡¡sly';
      206:S:='€¡seln‚ podte‡en¡ p©i operaci s re ln˜mi ‡¡sly';
      207:S:='Neplatn  operace s re ln˜mi ‡¡sly';
      208:S:='Nen¡ nainstalov na spr va ovrlej¡';
      209:S:='Chyba p©i ‡ten¡ souboru overlay';
      210:S:='Neinicializovan˜ objekt';
      211:S:='Vol n¡ abstraktn¡ metody';
      212:S:='Chyba registrace proudu';
      213:S:='Index kolekce mimo rozsah';
      214:S:='P©eplnˆn¡ kolekce';
      215:S:='Chyba aritmetick‚ho p©ete‡en¡';
      216:S:='Chyba obecn‚ ochrany';
      else S:='Nezn m  chyba !';
    end;
    Message(15,S,15,4);
    GetKey;
    Scan:=0;
    SetScreen;
  end;
end;


Procedure InitDownMenu(S:String;PosY:Word);
Var
  I:Integer;
  Active:Boolean;
begin
  Active:=False;
  Textbackground(7);
  Window(1,PosY,80,PosY);ClrScr;Window(1,1,80,25);
  GotoXY(1,PosY-1);
  For I:=1 to ord(S[0]) do
  begin
    If S[I]='~' then
    begin
      If Active=True then Active:=False else Active:=True;
      Continue;
    end;
    If Active then TextColor(4) else TextColor(0);
    Write(S[I]);
  end;
end;


Procedure GetScreen;
Var
  A,B:Byte;
  Segm,Adr:Word;
begin
  Segm:=$B800;
  {If Mem[0:$449]<=3 then Segm:=$B800;
  If Mem[0:$449]=7 then Segm:=$B000;}

  For ScrY:=0 to 24 do
  For ScrX:=0 to 79 do
  begin
    Adr:=(ScrX*2)+(ScrY*2*80);
    Mem[$B000:Adr]:=Mem[Segm:Adr];
    Mem[$B000:Adr+1]:=Mem[Segm:Adr+1];
    {Asm
    MOV AH,2
    MOV DL,ScrX
    MOV DH,ScrY
    INT 10h
    MOV AH,8
    MOV BH,0
    INT 10h
    MOV A,AL
    MOV B,AH
    end;
    Znak0[ScrX,ScrY]:=A;
    Attr0[ScrX,ScrY]:=B;}
  end;
end;


Procedure SetScreen;
Var
  A,B:Byte;
  Segm,Adr:Word;
begin
  Segm:=$B800;
  {If Mem[0:$449]<=3 then Segm:=$B800;
  If Mem[0:$449]=7 then Segm:=$B000;}

  For ScrY:=0 to 24 do
  For ScrX:=0 to 79 do
  begin
    Adr:=(ScrX*2)+(ScrY*2*80);
    Mem[Segm:Adr]:=Mem[$B000:Adr];
    Mem[Segm:Adr+1]:=Mem[$B000:Adr+1];
    {A:=Znak0[ScrX,ScrY];
    B:=Attr0[ScrX,ScrY];
    Asm
    MOV AH,2
    MOV DL,ScrX
    MOV DH,ScrY
    INT 10h
    MOV AH,9
    MOV CX,1
    MOV BH,0
    MOV AL,A
    MOV BL,B
    INT 10h
    end;}
  end;
end;



Procedure WriteDownMessage(S:String);
Var
  I:Byte;
  W:Word;
begin
  Window(1,1,80,25);
  For I:=0 to 79 do
  begin
    W:=(I*2)+(24*2*80);
    Mem[$B800:I+10000]:=Mem[$B800:W];
    Mem[$B800:I+10080]:=Mem[$B800:W+1];
  end;
  TextColor(0);TextBackground(7);
  GotoXY(0,24);Write(' '+S+Fill(S,77));
end;



Procedure ClearDownMessage;
Var
  I:Byte;
  W:Word;
begin
  For I:=0 to 79 do
  begin
    W:=(I*2)+(24*2*80);
    Mem[$B800:W]:=Mem[$B800:I+10000];
    Mem[$B800:W+1]:=Mem[$B800:I+10080];
  end;
end;


Procedure Help(H,FileOfHelp:String);
Type
  THelp=Record
          Nazev:String[10];
          Data:Array[0..79,0..24,0..1] of Byte;
        end;
Var
  F:File of THelp;
  HLP:THelp;
  x,y,a,b:Byte;
  I:Word;
  Znak0,Attr0:Array[0..79,0..24] of byte;

Procedure GetScreen;
Var
  A,B:Byte;
begin
  For ScrY:=0 to 24 do
  For ScrX:=0 to 79 do
  begin
    Asm
    MOV AH,2
    MOV DL,ScrX
    MOV DH,ScrY
    INT 10h
    MOV AH,8
    MOV BH,0
    INT 10h
    MOV A,AL
    MOV B,AH
    end;
    Znak0[ScrX,ScrY]:=A;
    Attr0[ScrX,ScrY]:=B;
  end;
end;


Procedure SetScreen;
Var
  A,B:Byte;
begin
  Mem[$B800:0]:=219;Mem[$B800:1]:=7;
  For ScrY:=0 to 24 do
  For ScrX:=0 to 79 do
  begin
    A:=Znak0[ScrX,ScrY];
    B:=Attr0[ScrX,ScrY];
    Asm
    MOV AH,2
    MOV DL,ScrX
    MOV DH,ScrY
    INT 10h
    MOV AH,9
    MOV CX,1
    MOV BH,0
    MOV AL,A
    MOV BL,B
    INT 10h
    end;
  end;
end;

begin
  GetScreen;
  Assign(F,FileOfHelp);
  {$I-}Reset(F);{$I+}ErrorMessage;
  If IORes=0 then
  begin
    Repeat
      Read(F,HLP);
    until (HLP.Nazev=H)or(FilePos(F)>=FileSize(F));
    {$I-}Close(F);{$I+}ErrorMessage;
    For x:=0 to 79 do
    For y:=0 to 24 do
    begin
      B:=HLP.DATA[x,y,1];A:=HLP.DATA[x,y,0];
      I:=(x*2)+(y*2*80);
      Mem[$B800:I]:=A;Mem[$B800:I+1]:=B;
    end;
    GetKey;
    SetScreen;
  end;
  Repeat until Port[$60]>128;
  Scan:=0;
  If CestinaOK then SetASCIITAB(10);
end;



Procedure About(Nazev,Verze:String);
Var
  Znak,Attr:Array[26..56,7..18] of Byte;
  A,B,I:Byte;

Procedure GetScreen;
Var
  A,B:Byte;
begin
  For ScrY:=7 to 18 do
  For ScrX:=26 to 56 do
  begin
    Asm
    MOV AH,2
    MOV DL,ScrX
    MOV DH,ScrY
    INT 10h
    MOV AH,8
    MOV BH,0
    INT 10h
    MOV A,AL
    MOV B,AH
    end;
    Znak[ScrX,ScrY]:=A;
    Attr[ScrX,ScrY]:=B;
  end;
end;



begin
  GetScreen;
  TextColor(15);TextBackground(7);
  For I:=4 downto 0 do
  begin
    Frame(27,7+I,54,17-I,129+64);
    Delay(10);
  end;
  Center(07,' About ');
  TextColor(0);
  Center(09,Nazev+' ');
  Center(11,'Verze '+Verze+' ');
  If CestinaOK then Center(13,'Copyright úôõ 1998  by')
  else Center(13,'Copyright (C) 1998  by');
  If CestinaOK then Center(15,'Tom ¨ Hujer')
  else Center(15,'Tomas Hujer');
  GetKey;
  Scan:=0;
  Repeat until Port[$60]<128;
  For I:=0 to 5 do
  begin
    TextColor(15);TextBackground(7);
    Frame(27,7+I,54,17-I,129+64);
    Delay(5);
    ScrY:=I+7;
    For ScrX:=26 to 56 do
    begin
      A:=Znak[ScrX,ScrY];
      B:=Attr[ScrX,ScrY];
      Asm
      MOV AH,2
      MOV DL,ScrX
      MOV DH,ScrY
      INT 10h
      MOV AH,9
      MOV CX,1
      MOV BH,0
      MOV AL,A
      MOV BL,B
      INT 10h
      end;
    end;
    ScrY:=18-I;
    For ScrX:=26 to 56 do
    begin
      A:=Znak[ScrX,ScrY];
      B:=Attr[ScrX,ScrY];
      Asm
      MOV AH,2
      MOV DL,ScrX
      MOV DH,ScrY
      INT 10h
      MOV AH,9
      MOV CX,1
      MOV BH,0
      MOV AL,A
      MOV BL,B
      INT 10h
      end;
    end;
  end;
  ScrY:=12;
  For ScrX:=26 to 56 do
    begin
      A:=Znak[ScrX,ScrY];
      B:=Attr[ScrX,ScrY];
      Asm
      MOV AH,2
      MOV DL,ScrX
      MOV DH,ScrY
      INT 10h
      MOV AH,9
      MOV CX,1
      MOV BH,0
      MOV AL,A
      MOV BL,B
      INT 10h
      end;
    end;
  TextColor(15);TextBackground(0);
  Repeat until Port[$60]>128;
end;





Procedure SmallHelp(X1,Y1,X2,Y2:Byte;S:String);
begin
  Window(1,1,80,25);
  Frame(X1,Y1,X2,Y2+2,136);
  Window(X1+2,Y1+2,X2,Y2+2);
  Write(S);
  Window(1,1,80,25);
end;





Procedure InitStandardScreen(Znak:Char;Typ,C,B:Byte);
Var
  x,y:Integer;
begin
  asm
  MOV AH,0
  MOV AL,3
  INT 10h

  MOV AH,5
  MOV AL,0
  INT 10h
  end;
  TextCursor(False);
  Window(1,2,80,24);TextColor(2);TextBackground(1);Window(1,1,80,25);
  Case Typ of
  0:begin
      For x:=0 to 79 do
      For y:=1 to 23 do
      begin
        TextColor(C);TextBackground(B);
        GotoXY(x,y);Write(Znak);
      end;
    end;
  1:begin
      For x:=0 to 79 do
      For y:=1 to 23 do
      begin
        TextColor(C);TextBackground(Random(B)+8);
        GotoXY(x,y);Write(Znak);
      end;
    end;
  end;
  InitDownMenu('',1);
  InitDownMenu('',25);
end;





Procedure Done;
begin
  {Asm
  MOV AH,0
  MOV AL,InitialMode
  INT 10H
  MOV AH,05
  MOV AL,InitialPage
  INT 10H
  end;}
  Mem[0:$449]:=InitialMode;
  Mem[0:$462]:=InitialPage;
  TextCursor(True);
  TextColor(7);TextBackground(0);
  ClrScr;
  Writeln(#10#10#13'Copyright (C) 1998  Tomas Hujer');
end;




Function TextInput(L:Byte;T,Old:String):String;
Var
  Position:Byte;
begin
  Position:=MemW[0:$44A] div 2-L div 2-1;
  Scan:=0;Ascii:=0;
  If L<8 then L:=8;
  TextColor(0);TextBackground(7);
  Frame(Position-1,10,Position+1+L,13,129+64);
  TextColor(0);
  GotoXY(Position,11);Write(T);
  TextCursor(True);
  Repeat
    TextColor(15);TextBackground(1);
    InputTextLine(Position,12,L,Old);
  until (Scan=1)or(Scan=28);
  TextCursor(False);
  If Scan=28 then TextInput:=Vstup else TextInput:=Old;
end;




Begin
  InitialPage:=Mem[0:$462];
  InitialMode:=Mem[0:$449];
  {Asm
  MOV AH,0Fh
  INT 10h
  MOV InitialMode,AL
  MOV InitialPage,BH
  end;}
end.