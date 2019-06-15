program Intro1;
{Introductional part of the program with features described in specification}
uses wingraph, wincrt;

procedure Initialise();
{Initialises the Graphics Window}
var
  colourDepth, resolution, errcode: smallint;
  begin
  //Open the Graphics Window
  colourDepth :=SVGA;
  resolution  := m640x480;
  InitGraph(colourDepth,resolution,'Minezweeper');
  SetBkColor(FloralWhite);
  ClearDevice();

  //Check for errors
  errcode:=GraphResult;
  if (errcode <> grOK) then
  begin
     WriteLn('Error when initialising the graphics window, code: ',
     						errcode, '. Message: ', GraphErrorMsg(errcode));
     ReadLn();
     Halt(1);
     end;

  end;

procedure Finalise();
{Closes the Graphics window on request}
begin
	repeat until CloseGraphRequest;
    CloseGraph();
end;

procedure LoadFromFile(fileName:string; title: boolean);
{Loads text from a given file until the end of it occurs
 and displays it on Graphics window}
var myFile : Text;
  	texttmp: string;
    i: integer;
begin
i:= 50;
setcolor(red);
Assign(myFile, fileName);
Reset(myFile);
SetTextStyle(CourierNewFont,0,1);
Repeat
  ReadLn(myFile, texttmp);
  if title=true then
  	begin
			OutTextXY(125,i,texttmp);
  		i:= i + TextHeight(texttmp);
      if i = 50 + TextHeight(texttmp) then
      	setcolor(Orange)
      else if i = 50 + (TextHeight(texttmp)*2) then
        setcolor(Green)
      else if i = 50 + (TextHeight(texttmp)*3) then
        setcolor(Blue)
      else setcolor(Purple);
  	end;
until Eof(myfile);
close(myfile);
end;
procedure AnimateTitle();
const  width = 500;
       height = 50;
       Pi18 = Pi/18;
var anim  : AnimatType;
    i: integer;
begin
  GetAnim(100,30,125+width-1,50+height-1,Transparent,anim);
  PutAnim(110,40,anim,CopyPut);
  Delay(500);
  i:=0;
  UpdateGraph(UpdateOff); //used to reduce flickering
  repeat
    Delay(25);
    PutAnim(110+Round(10*Sin(i*Pi18)),40+Round(10*Cos(i*Pi18)),anim,BkgPut);
    Inc(i);
    PutAnim(110+Round(10*Sin(i*Pi18)),40+Round(10*Cos(i*Pi18)),anim,TransPut);
    UpdateGraph(UpdateNow);
  until CloseGraphRequest ;
  FreeAnim(anim);
  Finalise();
end;

procedure MenuButtons();
{draws 3D menu buttons}
begin
SetColor(Black);
SetFillStyle(SolidFill, Black);
Bar3D( 220,150, 420, 190, 6, true);
end;

procedure Main();
begin
Initialise();
LoadFromFile('MINEZWEEPER-uvod.txt', true);
MenuButtons();
AnimateTitle();
end;

begin
  Main();
end.


