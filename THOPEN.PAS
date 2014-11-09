Unit THOpen;
Interface
Type
     TTHConfig=Record
                 Locks0:Byte;
                 EXT:String[3];
                 DisplayTime:Boolean;
                 PuvAdr:String[80];
               end;

Var
  IORs:Byte;
  Cfg:TTHConfig;


Function ChooseFile(FileType:String):String;


Implementation
Uses CRT,DOS,CZ,THApp,THString;
Type
     TSoubor=Record
                Soubor:String[12];
                Attr:Byte;
                Size:LongInt;
                Date:LongInt;
                Dataer:Boolean;
                {Array[0..1018]}
              end;
     TPolozka=Record
                Nazev:String[20];
                Cislo:LongInt;
                Soubor:String[80];
                Pocet:LongInt;
              end;

Var
  NO_Pocet:LongInt;
  F:File of Byte;
  Soubor:Array[0..1018] of TSoubor;
  I:Integer;
  ScrX,ScrY,A,B:Byte;
  Zn,At:Array[0..79,0..24,0..1] of byte;
  Polozka:TPolozka;



Procedure GetScreen;
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
    Zn[ScrX,ScrY,0]:=A;
    At[ScrX,ScrY,0]:=B;
  end;
end;

Procedure SetScreen;
begin
  For ScrY:=0 to 24 do
  For ScrX:=0 to 79 do
  begin
    A:=Zn[ScrX,ScrY,0];
    B:=At[ScrX,ScrY,0];
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




{Procedure GotoXY(x,y:Byte);
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
end;}




{Procedure TextCursor(S:Boolean);
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


Function LeadingZero(w : Word) : String;
var
  s : String;
begin
  Str(w:0,s);
  if Length(s) = 1 then
    s := '0' + s;
  LeadingZero := s;
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



Procedure Center(PosY:Byte;S:String);
begin
  GotoXY(MemW[0:$44A] div 2-Length(S) div 2,PosY);Write(S);
end;



Function UpString(S:String):String;
Var
  I:Integer;
  SUp:String;
begin
  SUp:=S;
  For I:=1 to Length(S) do
  begin
    SUp[I]:=UpCase(S[I]);
  end;
  UpString:=SUp;
end;



Procedure InitDownMenu(S:String;PosY:Word);
Var
  I:Integer;
  Active:Boolean;
begin
  Active:=False;
  Textbackground(7);
  Window(1,PosY,80,PosY);ClrScr;Window(1,1,80,25);
  GotoXY(1,PosY);
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


 }
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
      If T and 3=3 then
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
      If T and 63=63 then
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
    For I:=Y0 to Y1 do
    begin
      If I<24 then
      begin
        Mem[$B800:((X1)*2)+(I*2*80)+1]:=Mem[$B800:((X1)*2)+(I*2*80)+1] and 7;
        Mem[$B800:((X1+1)*2)+(I*2*80)+1]:=Mem[$B800:((X1+1)*2)+(I*2*80)+1] and 7;
      end;
    end;

    For I:=X0+2 to X1 do
    begin
      If Y1<24 then
      Mem[$B800:(I*2)+((Y1)*2*80)+1]:=Mem[$B800:(I*2)+((Y1)*2*80)+1] and 7;
    end;
  end;
end;


{
Procedure InputLine(x,y,Delka:Byte;old:String);
Var
  p:String;
  fill,Poz:Integer;
  V:Char;
begin
   Vstup:=old;
   Poz:=Length(Old);
   TextBackground(1);
   GotoXY(x,y);For fill:=0 to Delka do Write(' ');
   TextBackground(1);
   GotoXY(x,y);Write(Old);
   TextCursor(True);
   Poz:=Length(Old);
   Repeat
     GotoXY(x+Poz,y);
     GetKey;
     If (Scan=82)and(Ascii=224)then Ascii:=0;
     If (Scan=75)and(Ascii=224)then
     begin If Poz>0 then Dec(Poz);Ascii:=0;end;
     If (Scan=77)and(Ascii=224)then
     begin If Poz<Length(Vstup) then Inc(Poz);Ascii:=0;end;
     If (Scan=83)and(Ascii=224)then
     begin Delete(Vstup,Poz+1,1);Ascii:=0;end;
     If ((Scan=71)or(Scan=73)or(Scan=72))and(Ascii=224)then
     begin Poz:=0;Ascii:=0;end;
     If ((Scan=79)or(Scan=81)or(Scan=80))and(Ascii=224)then
     begin Poz:=Length(Vstup);Ascii:=0;end;
     p:='';
     If ((Ascii>=46)and(Ascii<=57))or((Ascii>=65)and(Ascii<=122))or(Ascii=92)or
        (Ascii=58)or(Ascii=32)or((ASCII>=128)and(ASCII<=255))or
        (ASCII=ord('+'))or(ASCII=ord('-'))or(ASCII=ord('*'))or(ASCII=ord('{'))or
        (ASCII=ord('}{'))or(ASCII=ord('+'))or(ASCII=ord('='))or(ASCII=ord(';'))or
        (ASCII=ord('?'))or(ASCII=ord('~'))or(ASCII=ord(','))or(ASCII=ord('<'))or
        (ASCII=ord('>'))or(ASCII=39)or(ASCII=34)and((Scan<>72)and(Scan<>80))then
     begin
       If Length(Vstup)<Delka then
       begin V:=Chr(Ascii);Poz:=Poz+1;end;
     end
     else V:=#0;
     If (Length(Vstup)>0)and(Scan=14)and(Poz>0) then
     begin Delete(Vstup,Poz,1);Dec(Poz);end;
     If (V<>#0)and(Length(Vstup)<Delka) then Insert(V,Vstup,Poz);
     For fill:=1 to (Delka-Length(Vstup)) do p:=p+' ';
     TextBackground(1);GotoXY(x,y);Write(Vstup+p);
   until (Scan=28)or(Scan=1);
   TextCursor(False);
   TextColor(8);TextBackground(1);
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
  Frame(x0-10,y0,x1+10,y1,128+64);
  If C<>255 then TextColor(C);
  GotoXY(((x1-x0) div 2-Length(S) div 2+1)+x0,(y1-y0)div 2+y0);Write(S);
end;


Procedure OkMessage(S:String);
begin
  TextColor(14);TextBackground(4);
  Frame((MemW[0:$44A] div 2-Length(S) div 2-5),10,
        (MemW[0:$44A] div 2+Length(S) div 2+5),12,129+64);
  TextColor(10);
  Center(11,S);
  GetKey;
end;


Procedure ErrorMessage;
Var
  Znak,Attr:Array[0..79,9..13] of Byte;
  S:String[80];
Procedure GetScreen;
Var
  ScrX,ScrY,A,B:Byte;
begin
  For ScrY:=9 to 13 do For ScrX:=0 to 79 do
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
  For ScrY:=9 to 13 do For ScrX:=0 to 79 do
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
  IORs:=IOResult;
  If MaxAvail>MemAvail then
  begin
    GetScreen;
    Message(15,'Nedostatek pameti !',15,4);GetKey;Scan:=0;
    SetScreen;
  end;
  If IORs<>0 then
  begin
    GetScreen;
    Case IORs of
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
      162:S:='Chyba hardwaru';
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
      else S:='Neznama chyba !';
    end;
    Message(15,S,15,4);
    GetKey;
    Scan:=0;
    SetScreen;
  end;
end;}



Function ChooseFile(FileType:String):String;
Var
  Path,PSoubor,S:String[80];
  N: NameStr;
  E: ExtStr;
  P: PathStr;
  D: DirStr;
  Pol:Byte;
  Pozice:LongInt;
  DirInfo: SearchRec;
  Dir,XSoubor:String[80];
  DT:DateTime;

Procedure Reload;
begin
  For I:=0 to 1000 do
  begin
    Soubor[I].Soubor:='';
    Soubor[I].Attr:=0;
    Soubor[I].Date:=0;
  end;
  I:=0;
  GetDir(0,Dir);
  If Length(Dir)<>3 then
  begin Soubor[0].Soubor:='..';Soubor[0].Attr:=$10;end else I:=-1;

  FindFirst('*.*',$3F,DirInfo);
  while DosError=0 do
  begin
    If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
    begin
      Inc(I);
      Soubor[I].Soubor:=DirInfo.Name;
      Soubor[I].Attr:=DirInfo.Attr;
      Soubor[I].Size:=DirInfo.Size;
      Soubor[I].Date:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;

  FindFirst(FileType,$3F,DirInfo);
  while DosError=0 do
  begin
    If DirInfo.Attr and $10<>$10 then
    begin
      Inc(I);
      Soubor[I].Soubor:=DirInfo.Name;
      Soubor[I].Attr:=DirInfo.Attr;
      Soubor[I].Size:=DirInfo.Size;
      Soubor[I].Date:=DirInfo.Time;
    end;
    FindNext(DirInfo);
  end;
  NO_Pocet:=I;

  GetDir(0,Dir);
  NO_Pocet:=I;
end;

Procedure DeleteFile;
Var
  Znak,Attr:Array[0..79,9..13] of byte;
Procedure GetScreen;
begin
  For ScrY:=9 to 13 do
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
    Znak[ScrX,ScrY]:=A;
    Attr[ScrX,ScrY]:=B;
  end;
end;
Procedure SetScreen;
begin
  For ScrY:=9 to 13 do
  For ScrX:=0 to 79 do
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
begin
  GetScreen;
  If Soubor[Pol+Polozka.Cislo].Soubor='..' then Exit;
  Sound(100);Delay(100);NoSound;
  If (Soubor[Pol+Polozka.Cislo].Attr and $10)=$10 then
  begin
    OkMessage('Opravdu chcete adres © "'+Soubor[Pol+Polozka.Cislo].Soubor+'" odstranit ?');
    If (Scan=28)or(UpCase(chr(ASCII))='A') then
    begin
      {$I-}RMDir(Soubor[Pol+Polozka.Cislo].Soubor);{$I+}
      If IOResult<>0 then
      begin
        Message(15,'Adres © nen¡ pr zdn˜ !!!',15,4);GetKey;Scan:=0;
      end
      else
      begin
        If Pozice>0 then Dec(Pozice);
        If Pol>0 then Dec(Pol);
      end;
    end;
    Repeat until Port[$60]>128;Scan:=0;
  end
  else
  begin
    OkMessage('Opravdu chcete soubor "'+Soubor[Pol+Polozka.Cislo].Soubor+'" odstranit ?');
    If (Scan=28)or(UpCase(chr(ASCII))='A') then
    begin
      Assign(F,Soubor[Pol+Polozka.Cislo].Soubor);
      {$I-}Reset(F);Close(F);{$I+}ErrorMessage;
      {$I-}Erase(F);{$I+}ErrorMessage;
      If IORs=0 then
      begin
        If Pozice>0 then Dec(Pozice);
        If Pol>0 then Dec(Pol);
      end;
    end;
    Repeat until Port[$60]>128;Scan:=0;
  end;
  SetScreen;
  Reload;
end;



Procedure NewDir;
Var
  Path,PSoubor:String;
  N: NameStr;
  E: ExtStr;
  P: PathStr;
  D: DirStr;
  Pol:Byte;
  Pozice:LongInt;
  Znak,Attr:Array[0..79,9..14] of byte;
Procedure GetScreen;
begin
  For ScrY:=9 to 14 do
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
    Znak[ScrX,ScrY]:=A;
    Attr[ScrX,ScrY]:=B;
  end;
end;
Procedure SetScreen;
begin
  For ScrY:=9 to 14 do
  For ScrX:=0 to 79 do
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
begin
  GetScreen;
  PSoubor:='';
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(31,10,49,13,129+64);
  TextColor(0);
  GotoXY(32,11);Write('Zalo‘it adres ©');
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(31,11,16,'');
  until (Vstup<>'')or(Scan=1);
  Vstup:=FExpand(Vstup);
  If Length(Vstup)+2>=70 then
  begin
    Message(15,'Cesta obsahuje p©¡li¨ mnoho znak– !!!',15,4);
    GetKey;
    SetScreen;
    Scan:=0;
    Exit;
  end;
  FSplit(Vstup,D,N,E);
  SetScreen;
  If Scan=28 then
  begin
    GetScreen;
    {$I-}MkDir(Vstup);{$I+}
    IORs:=IOResult;
    If IORs<>0 then
    begin
      Message(15,'Soubor nebo adres © '+UpString(N+E)+' ji‘ exituje !!!',15,4);
      GetKey;
      SetScreen;
      NewDir;
    end;
    SetScreen;
    Pozice:=0;Pol:=0;
  end;
  Scan:=0;Ascii:=0;
  Reload;
end;


Procedure RenameFile;
Var
  PSoubor:String[80];
  Znak,Attr:Array[0..79,9..14] of byte;
Procedure GetScreen;
begin
  For ScrY:=9 to 14 do
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
    Znak[ScrX,ScrY]:=A;
    Attr[ScrX,ScrY]:=B;
  end;
end;
Procedure SetScreen;
begin
  For ScrY:=9 to 14 do
  For ScrX:=0 to 79 do
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

begin
  GetScreen;
  PSoubor:='';
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(24,10,56,13,129+64);
  TextColor(0);
  GotoXY(26,11);Write('P©ejmenovat "',Soubor[Pol+Polozka.Cislo].Soubor,'" na');
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(24,11,30,'');
  until (Vstup<>'')or(Scan=1);
  Vstup:=FExpand(Vstup);
  FSplit(Vstup,D,N,E);
  If E<>Copy(FileType,2,Length(FileType)) then E:=Copy(FileType,2,Length(FileType));
  Vstup:=N+E;

  SetScreen;
  If Scan=28 then
  begin
    GetScreen;
    PSoubor:=Vstup;
    Assign(F,PSoubor);
    {$I-}Reset(F);{$I+}
    If (IOResult<>0){or(PSoubor=Soubor.Soubor[Pol+Polozka.Cislo])} then
    begin
      Assign(F,Soubor[Pol+Polozka.Cislo].Soubor);
      {$I-}Rename(F,PSoubor);{$I+}ErrorMessage;
    end
    else
    If Vstup<>Soubor[Pol+Polozka.Cislo].Soubor then
    begin
      {$I-}Close(F);{$I+}ErrorMessage;
      OKMessage('Soubor '+UpString(PSoubor)+' ji‘ exituje, P©epsat ?');
      If (Scan=28)or(UpCase(chr(ASCII))='A') then
      begin
        Assign(F,Vstup);
        {$I-}Erase(F);{$I+}ErrorMessage;
        Assign(F,Soubor[Pol+Polozka.Cislo].Soubor);
        {$I-}Rename(F,Vstup);{$I+}ErrorMessage;
      end
      else
      begin
        SetScreen;RenameFile;
      end;
    end;
    SetScreen;
    GetScreen;
    If IORs=0 then
    begin
      If IORs=0 then Message(0,'Soubor '+Soubor[Pol+Polozka.Cislo].Soubor+' byl p©ejmenov n na '+UpString(PSoubor),0,7);
      GetKey;
      Assign(F,PSoubor);{$I-}Reset(F);{$I+}ErrorMessage;
    end;
    SetScreen;
    Pozice:=0;Pol:=0;
  end;
  Reload;
  Scan:=0;Ascii:=0;
end;



Function SaveToFile:String;
Var
  PSoubor:String;
  N: NameStr;
  E: ExtStr;
  D: DirStr;
  Znak,Attr:Array[0..79,9..14] of byte;
Procedure GetScreen;
begin
  For ScrY:=9 to 14 do
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
    Znak[ScrX,ScrY]:=A;
    Attr[ScrX,ScrY]:=B;
  end;
end;
Procedure SetScreen;
begin
  For ScrY:=9 to 14 do
  For ScrX:=0 to 79 do
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

begin
  GetScreen;
  Scan:=0;Ascii:=0;
  TextColor(0);TextBackground(7);
  Frame(22,10,54,13,129+64);
  TextColor(0);
  GotoXY(23,11);Write('Nov˜ soubor');
  TextCursor(True);
  Repeat
    TextColor(15);TextBackground(1);
    InputLine(22,11,30,'');
  until (Vstup<>'')or(Scan=1);
  TextCursor(False);
  Vstup:=FExpand(Vstup);
  FSplit(Vstup,D,N,E);
  If E<>'.'+Copy(FileType,3,3) then E:='.'+Copy(FileType,3,3);
  Vstup:=D+N+E;
  SetScreen;
  If Scan=28 then
  begin
    GetScreen;
    PSoubor:=Vstup;
    Assign(F,PSoubor);
    {$I-}Reset(F);Close(F);{$I+}
    If IOResult<>0 then
    begin
      {$I-}Rewrite(F);{$I+}ErrorMessage;
      {$I-}Close(F);{$I+}ErrorMessage;
    end
    else
    begin
      OKMessage('Soubor '+UpString(PSoubor)+' ji‘ exituje, P©epsat ?');
      If (Scan=28)or(UpCase(chr(ASCII))='A')or(UpCase(chr(ASCII))='Y')or
         (UpCase(chr(Ascii))='P') then
         begin
           {$I-}Rewrite(F);Close(F);{$I+}ErrorMessage;
         end
      else
      begin
        SetScreen;Scan:=0;SaveToFile:=PSoubor;
      end;
    end;
    SetScreen;
    SaveToFile:=PSoubor;
  end;
  Scan:=0;Ascii:=0;
end;




{Choose File}
begin
  GetDir(0,Path);
  Repeat
    GetScreen;
    InitDownMenu(' ~F2~ New  ~F6~ Rename  ~F7~ MkDir  ~F8~ Delete  ~Alt+F1~ Disk  ~ENTER~ ViewFile',25);
    Scan:=0;Ascii:=0;
    TextColor(0);TextBackground(7);

    Reload;
    Pozice:=0;Pol:=0;
    GetDir(0,Dir);
    NO_Pocet:=I;
    TextColor(15);TextBackground(1);
    Frame(21,2,62,24,129+64);
    TextColor(15);
    GotoXY(23,3);Write(' Jm‚no   Ext  Velikost   Datum    €as ');
    Pozice:=0;Pol:=0;XSoubor:='';
    Repeat
      For I:=0 to 18 do
      begin
        If Pol=I then Textbackground(8) else Textbackground(1);

        If Soubor[I+Pozice].Attr and $10=$10 then TextColor(14)
        else TextColor(10);
        P:=Soubor[I+Pozice].Soubor;FSplit(P,D,N,E);

        GotoXY(22,I+5);
        If E='..' then
        begin
          TextColor(15);Write(' ..           <ADRESž>                 ');
        end
        else
        If N<>'' then
        begin

{  faReadOnly    $01
   faHidden      $02
   faSysFile     $04
   faVolumeID    $08
   faDirectory   $10
   faArchive     $20
   faAnyFile     $3F
}
          Write(' '+N+Fill(N,8));
          If Soubor[I+Pozice].Attr and 1=1 then
          begin GotoXY(31,I+5);Write('ù');end;

          If Soubor[I+Pozice].Attr and 2=2 then
          begin GotoXY(31,I+5);Write('°');end;

          If Soubor[I+Pozice].Attr and 4=4 then
          begin GotoXY(31,I+5);Write('÷');end;

          Write(Copy(E,2,3)+Fill(E,4));
          TextColor(11);
          GotoXY(36,I+5);Write('                          ');


          If (Soubor[I+Pozice].Attr and $10<>$10) then
          begin
            Str(Soubor[I+Pozice].Size,S);
            GotoXY(45-Length(S),I+5);Write(S,' ');
            UnPackTime(Soubor[I+Pozice].Date,DT);
            GotoXY(47,I+5);Write(LeadingZero(DT.Day),'.',LeadingZero(DT.Month),
              '.',Copy(LeadingZero(DT.Year),3,2),' ',LeadingZero(DT.Hour),':',
              LeadingZero(DT.Min));
          end
          else
          begin
            TextColor(15);GotoXY(36,I+5);Write('<ADRESž>');
          end;
        end
        else Write(' '+N+Fill(N,38));
        If Copy(P,2,1)=':' then
        begin
          GotoXY(22,I+5);TextColor(12);Write('   -< '+P+' >-                          ');
        end;
      end;
      If NO_Pocet<0 then NO_Pocet:=0;
      I:=NO_Pocet;
      TextColor(15);TextBackground(1);Center(3,'                ');
      GotoXY(39,4);Write(Pozice+Pol+1,'/',I+1,'    ');
      Scan:=0;
      GetKey;
      If (Scan=71)and(ASCII=224) then{HOME}
      begin Pol:=0;Pozice:=0;end;

      If (Scan=79)and(ASCII=224) then{END}
      begin
        If I>18 then Pol:=18
        else Pol:=I;
        Pozice:=I-Pol;
      end;

      If (Scan=73)and(ASCII=224) then{PGUP}
      begin
        If Pozice-18>=0 then Pozice:=Pozice-18;
      end;

      If (Scan=81)and(ASCII=224) then{PGDOWN}
      begin If Pozice+18<NO_Pocet then Pozice:=Pozice+18;end;

      If (I>0)and(Scan=72)and(Pol=0)and(Pozice>0)then {UP}
      begin Pozice:=Pozice-1;Pol:=0;end;
      If (I>0)and(Scan=72)and(Pol>0) then Pol:=Pol-1;

      If (I>0)and(Scan=80) then Pol:=Pol+1;           {DOWN}
      If (I>0)and(Scan=80)and(Pol>18)then
      begin Pozice:=Pozice+1;pol:=18;end;

      If (I>18)and((Pozice+Pol)>I) then
      begin Pol:=18;Pozice:=I-Pol;end;

      If (I<=18)and((Pozice+Pol)>I) then
      begin Pol:=I-Pozice;Pozice:=I-Pol;end;

      If ((Ascii>=48)and(Ascii<=57))or
         ((UpCase(chr(Ascii))>#64)and(UpCase(chr(Ascii))<#90))or
         (Scan=14)or(chr(Ascii)='.') then
      begin
        If Scan=14 then
        begin
          XSoubor:=Copy(XSoubor,1,Length(XSoubor)-1);
          GotoXY(22+Length(XSoubor),24);Write('ÄÄÄ');
        end
        else
        begin
          If Length(XSoubor)<12 then XSoubor:=XSoubor+chr(Ascii);
        end;
        GotoXY(22,24);
        If XSoubor[0]=#0 then Write('ÄÄÄ') else Write('['+XSoubor+']');
      end;

      If Soubor[Pol+Polozka.Cislo].Attr and $10<>$10 then
      begin
        If Scan=64 then RenameFile; {F6}
      end;
      If Scan=60 then
      begin
        SaveToFile;  {F2}
        Reload;
      end;
      If Scan=66 then DeleteFile;  {F8}
      If Scan=65 then NewDir;      {F7}
      If Scan=104 then              {Alt+F1}
      begin
        If Copy(Soubor[NO_Pocet].Soubor,2,1)<>':'then
        begin
          For I:=0 to 25 do
          begin
            B:=I;
            asm
            MOV AH,44h
            MOV AL,0Fh
            MOV BL,B
            INC BL
            INT 21h
            end;
            {$I-}
             FindFirst(chr(I+65)+':\*.*',$3F,DirInfo);
            {$I+}
            If DosError=0 then
            begin
              If Soubor[NO_Pocet].Soubor='' then
              begin
                Soubor[NO_Pocet].Soubor:=chr(I+65)+':';
                Soubor[NO_Pocet].Attr:=$10;
                Inc(NO_Pocet);
              end
              else
              begin
                Inc(NO_Pocet);
                Soubor[NO_Pocet].Soubor:=chr(I+65)+':';
                Soubor[NO_Pocet].Attr:=$10;
              end;
            end;
            If (Soubor[NO_Pocet].Soubor='')and(NO_Pocet>0)then
              Dec(NO_Pocet);
          end;
        end;
      end;

      If Scan=28 then
      begin
        If XSoubor[0]<>#0 then
        begin
          PSoubor:=XSoubor;
          Soubor[Pol+Pozice].Soubor:=XSoubor;
          Break;
        end;

        Dir:=Soubor[Pol+Pozice].Soubor;

        If (Soubor[Pol+Pozice].Attr and $10=$10)then
        begin
          For I:=0 to 1000 do
          begin
            Soubor[I].Soubor:='';
            Soubor[I].Attr:=0;
            Soubor[I].Date:=0;
          end;
          I:=0;
          Scan:=0;
          If (dir<>'..')and(dir[2]=':') then
          begin
            B:=ord(Dir[1])-65;
            asm
            MOV AH,44h
            MOV AL,0Fh
            MOV BL,B
            INC BL
            INT 21h
            end;
          end;
          ChDir(Dir);
          GetDir(0,Dir);

          If Length(Dir)<>3 then
          begin Soubor[0].Soubor:='..';Soubor[0].Attr:=$10;end else I:=-1;

          FindFirst('*.*',$3F,DirInfo);
          while DosError=0 do
          begin
            If (DirInfo.Attr and $10=$10)and(copy(DirInfo.Name,1,1)<>'.') then
            begin
              Inc(I);
              Soubor[I].Soubor:=DirInfo.Name;
              Soubor[I].Attr:=DirInfo.Attr;
              Soubor[I].Size:=DirInfo.Size;
              Soubor[I].Date:=DirInfo.Time;
            end;
            FindNext(DirInfo);
          end;

          FindFirst(FileType,$3F,DirInfo);
          while DosError=0 do
          begin
            If (DirInfo.Attr and $10<>$10)and(DirInfo.Attr and 8<>8) then
            begin
              Inc(I);
              Soubor[I].Soubor:=DirInfo.Name;
              Soubor[I].Attr:=DirInfo.Attr;
              Soubor[I].Size:=DirInfo.Size;
              Soubor[I].Date:=DirInfo.Time;
            end;
            FindNext(DirInfo);
          end;
          Pol:=0;Pozice:=0;
          NO_Pocet:=I;
        end;
      end;
      If (Scan=28)and(Soubor[Pol+Pozice].Soubor='')then Scan:=0;
    until (Scan=1)or(Scan=28);
    XSoubor:=FExpand(Soubor[Pol+Pozice].Soubor);
    Repeat until Port[$60]>128;
  until (Scan=1)or(Scan=28);
  SetScreen;
  TextColor(8);TextBackground(1);
  ChooseFile:=XSoubor;
end;

Begin
end.