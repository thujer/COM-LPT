Program COM_LPT;
Uses CRT,THApp,THString,CZ,THGS;

Const
  OEM='LPT x COM Swaper';
  Ver='2.2';

Type
  TPorts=Record
           Name:String[10];
           Adress:Word;
         end;
Var
  LPT,COM,LPT0,COM0:Array[1..5] of TPorts;
  NO_LPT,NO_COM:Byte;
  L:Boolean;
  I:Integer;



Procedure Exchange;
begin
  GetScreen;
  OKMessage('Prohodit z suvky port– '+LPT[NO_LPT].Name+' a '+COM[NO_COM].Name);
  If Scan=28 then
  begin
    MemW[0:$0408+(NO_LPT-1)*2]:=COM[NO_COM].Adress;
    MemW[0:$0400+(NO_COM-1)*2]:=LPT[NO_LPT].Adress;
  end;
  SetScreen;
end;



Procedure Edit;
Var
  M:Array[0..10] of Word;
  NO_Zas:Byte;
begin
  M[0]:=0;
  M[1]:=$2F8;
  M[2]:=$3F8;
  M[3]:=$278;
  M[4]:=$378;
  M[5]:=$3BC;

  GetScreen;
  TextColor(0);TextBackground(7);
  Frame(31,10,48,17,129+64);
  GotoXY(33,11);Write(' Adresa z suvky ');
  NO_Zas:=0;
  Repeat
    For I:=0 to 5 do
    begin
       If I=NO_Zas then TextBackground(10) else TextBackground(7);
       GotoXY(33,12+I);Write('     '+HexWord(M[I])+' h     ');
    end;
    GetKey;
    If (Scan=72)and(NO_Zas>0) then Dec(NO_Zas);
    If (Scan=80)and(NO_Zas<5) then Inc(NO_Zas);
  until (Scan=1)or(Scan=28);
  If Scan=28 then
  If L then MemW[0:$0408+(NO_LPT-1)*2]:=M[NO_Zas]
  else      MemW[0:$0400+(NO_COM-1)*2]:=M[NO_Zas];
  SetScreen;
end;




Procedure ResetPorts;
begin
  GetScreen;
  OKMessage('Obnovit p–vodn¡ nastaven¡ portu ?');
  If Scan=28 then
  begin
    For I:=0 to 3 do MemW[0:$0408+I*2]:=LPT0[I+1].Adress;
    For I:=0 to 3 do MemW[0:$0400+I*2]:=COM0[I+1].Adress;
  end;
  SetScreen;
end;



Procedure LoadPorts;
begin
  LPT0[1].Name:='LPT1';LPT0[2].Name:='LPT2';
  LPT0[3].Name:='LPT3';LPT0[4].Name:='LPT4';
  COM0[1].Name:='COM1';COM0[2].Name:='COM2';
  COM0[3].Name:='COM3';COM0[4].Name:='COM4';
  For I:=0 to 3 do
  begin
    LPT0[I+1].Adress:=MemW[0:$0408+I*2];
  end;
  For I:=0 to 3 do
  begin
    COM0[I+1].Adress:=MemW[0:$0400+I*2];
  end;

  LPT[1].Name:='LPT1';LPT[2].Name:='LPT2';
  LPT[3].Name:='LPT3';LPT[4].Name:='LPT4';
  For I:=0 to 3 do
  begin
    LPT[I+1].Adress:=MemW[0:$0408+I*2];
  end;

  COM[1].Name:='COM1';COM[2].Name:='COM2';
  COM[3].Name:='COM3';COM[4].Name:='COM4';
  For I:=0 to 3 do
  begin
    COM[I+1].Adress:=MemW[0:$0400+I*2];
  end;

end;





Begin
  LoadPorts;
  {InitStandardScreen('°',0,1,7);}
  TextColor(0);TextBackground(7);
  Center(0,OEM);
  InitDownMenu('~TAB~ LPT/COM  ~CTRL+R~ Reset  ~F6~ Exchange  ~F2~ Change  ~~ Move',25);
  Frame(12,3,30,8,129+64);
  Frame(47,3,65,8,129+64);

  TextColor(0);TextBackground(7);
  Frame(12,3,30,8,1);
  GotoXY(15,4);Write(' Port - Z suvka');
  TextColor(8);
  Frame(47,3,65,8,1);
  GotoXY(50,4);Write(' Port - Z suvka ');

  TextColor(8);
  Frame(12,15,30,20,129+64);
  GotoXY(14,16);Write('P–vodn¡ nastaven¡');
  Frame(47,15,65,20,129+64);
  GotoXY(49,16);Write('P–vodn¡ nastaven¡');

  NO_LPT:=1;
  NO_COM:=1;
  L:=True;
  For I:=1 to 4 do
  begin
    GotoXY(49,I+16);
    Write('  '+COM0[I].Name+' : '+HexWord(COM0[I].Adress)+' h  ');
  end;
  For I:=1 to 4 do
  begin
    GotoXY(14,16+I);
    Write('  '+LPT0[I].Name+' : '+HexWord(LPT0[I].Adress)+' h  ');
  end;


  For I:=1 to 4 do
  begin
    GotoXY(49,I+4);
    Write('  '+COM[I].Name+' : '+HexWord(COM[I].Adress)+' h  ');
  end;
  Scan:=68;
  Repeat
    For I:=0 to 3 do
    begin
      LPT[I+1].Adress:=MemW[0:$0408+I*2];
    end;
    For I:=0 to 3 do
    begin
      COM[I+1].Adress:=MemW[0:$0400+I*2];
    end;


    If (Scan=15)or((L=False)and(Scan=75))or((L=True)and(Scan=77)) then
    begin
      L:=not L;

    If L then
    begin
      TextColor(0);TextBackground(7);
      Frame(12,3,30,8,1);
      GotoXY(15,4);Write(' Port - Z suvka');
      TextColor(8);
      Frame(47,3,65,8,1);
      GotoXY(50,4);Write(' Port - Z suvka ');
    end
    else
    begin
      TextColor(8);TextBackground(7);
      Frame(12,3,30,8,1);
      GotoXY(15,4);Write(' Port - Z suvka');
      TextColor(0);
      Frame(47,3,65,8,1);
      GotoXY(50,4);Write(' Port - Z suvka ');
    end;
    end;

    TextColor(0);
    If L then
    begin
      If (Scan=72)and(NO_LPT>1) then Dec(NO_LPT);
      If (Scan=80)and(NO_LPT<4) then Inc(NO_LPT);
    end
    else
    begin
      If (Scan=72)and(NO_COM>1) then Dec(NO_COM);
      If (Scan=80)and(NO_COM<4) then Inc(NO_COM);
    end;

    For I:=1 to 4 do
    begin
      If NO_COM=I then TextBackground(10) else TextBackground(7);
      GotoXY(49,4+I);
      Write('  '+COM[I].Name+' : '+HexWord(COM[I].Adress)+' h  ');
    end;

    For I:=1 to 4 do
    begin
      If NO_LPT=I then TextBackground(10) else TextBackground(7);
      GotoXY(14,4+I);
      Write('  '+LPT[I].Name+' : '+HexWord(LPT[I].Adress)+' h  ');
    end;


    If Scan=68 then About(OEM,Ver);
    GetKey;
    If Scan=64 then Exchange;  {F6}
    If Scan=60 then Edit;      {F2}
    If (Ascii=18)and(Scan=19) then ResetPorts; {CTRL+R}
  until (Scan=45)and(Ascii=0);
  {Done;}
  TextCursor(True);
  TextColor(7);TextBackground(0);
  ClrScr;
  Writeln(#10#10#13'Copyright (C) 1998  Tomas Hujer'#10);
end.