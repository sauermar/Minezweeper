program Intro1;
 uses wingraph;

var mess   : string;
    gd,gm  : smallint;
    errcode: smallint;

begin
{inicializace grafickeho okna z konzole}
  gd:=Detect;
  InitGraph(gd,gm,'');
  errcode:=GraphResult;
  if (errcode = grOK) then
  begin
    Bar(11,20,250,30);   // 3.sirka, 2.?
    mess:='';
    {funkce pro vykresleni textu : doprostred}
    OutTextXY((GetMaxX-TextWidth (mess)) div 2,
    					(GetMaxY-TextHeight(mess)) div 6,mess); //posunutí nahoru
    repeat until CloseGraphRequest;
    CloseGraph;
  end;
end.


