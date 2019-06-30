program Intro1;
{Introductional part of the program with features described in specification}
uses wingraph, wincrt, winmouse, sysutils;

var
    anim  : AnimatType;
    i : integer;
    colors: array [0..4] of ^longword = ( @red,@orange,@green,@Blue,@Purple);
    word: array [0..3] of string = ( 'Start Game','Difficulty',
    																	'Instructions','Highscore');
    buttonPressed : boolean;

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
    i,j: integer;
begin
if title = true then
begin
	Randomize; //generate a new sequence of colors every time the program is run
	j:= Random(4);  //Get a random number between 0 and 4
	i:= 50; // y coordinate of displaying text
	setcolor(colors[j]^);
  SetTextStyle(CourierNewFont,0,1);
  end
else
begin
	SetTextStyle(CourierNewFont,0,2);
  setcolor(Black);
  i:= 0;
end;
Assign(myFile, fileName);
Reset(myFile);
Repeat
  ReadLn(myFile, texttmp);
  if title=true then
  	begin
      //draws loaded text on window if the title is true
			OutTextXY(125,i,texttmp);
  		i:= i + TextHeight(texttmp);
      //changing colors of every line
      if i = 50 + TextHeight(texttmp) then
      	setcolor(colors[(j+1) mod 5]^ )
      else if i = 50 + (TextHeight(texttmp)*2) then
        setcolor(colors[(j+2) mod 5]^)
      else if i = 50 + (TextHeight(texttmp)*3) then
        setcolor(colors[(j+3) mod 5]^)
      else setcolor(colors[(j+4) mod 5]^);
  	end
  else if title = false then
    begin
      //draws loaded text on window if the title is false
    i:= i + TextHeight(texttmp);
    OutTextXY(0,i+60,texttmp);
    end;
until Eof(myfile);
close(myfile);
end;
procedure AnimateTitle(var anim: AnimatType);
{creates a rotation animation of the title}
const  width = 500;
       height = 50;
begin
   //gets apropriate number of pixels from screen and saves them as anim
  GetAnim(100,30,125+width-1,50+height-1,Transparent,anim);
  //puts anim bitmap on the screen
  PutAnim(110,40,anim,CopyPut);
  Delay(500);
  UpdateGraph(UpdateOff); //used to reduce flickering
end;
procedure AnimateTitle2(anim: AnimatType; var i:integer );
{continues with the animation}
const Pi18 = Pi/18; //slowing the rotation
begin
    Delay(25);
    PutAnim(110+Round(10*Sin(i*Pi18)),40+Round(10*Cos(i*Pi18)),anim,BkgPut);
    Inc(i);
    PutAnim(110+Round(10*Sin(i*Pi18)),40+Round(10*Cos(i*Pi18)),anim,TransPut);
    UpdateGraph(UpdateNow);
end;

procedure MenuButtons();
{draws 3D menu buttons}
var i,j : integer;
begin
j:= 0;
for i:= 0 to 3 do
begin
  SetColor(colors[i]^);
  SetFillStyle(SolidFill, colors[i]^);
  Bar3D( 220,150+j, 420, 190+j, 6, true);
  SetTextStyle(MSSansSerifFont,0,24);
  SetColor(Black);
  OutTextXY(320 - (TextWidth(word[i]) div 2) ,
  					(170+j) - 12 ,word[i]);
  j:= j + 65;
end;
end;

function ProcessMouseEvents(var buttonPressed : boolean):integer;
{Processes when clicked on a mouse button}
var mouseEvent: MouseEventType;
    x,y,i,j: integer;
begin
// remove the top mouse event of the queue
	GetMouseEvent(mouseEvent);
  if mouseEvent.buttons and MouseLeftButton <> 0 then
  begin
    // gets mouse's coordinates
  	x:=GetMouseX();
 		y:=GetMouseY();
    j:= 0;
    for i := 0 to 3 do
    begin
      if (x >= 220) and (x <= 420) then
      begin
    		if (y >= 150+j) and (y <= 190+j) then   // if the right button was clicked
        begin                                  // in the area of menu button
          buttonPressed := true;
          ProcessMouseEvents := j;
          exit;
        end
      	else
        begin
          j:= j + 65;
          buttonPressed := false;
        end;
      end;
    end;
  end;
end;

procedure ClearButton(j:integer);
{clears the viewport of the menu button}
begin
	SetBkColor(FloralWhite);
  SetViewPort(220,144+j,426,190+j, false);
  ClearViewPort();
  SetViewPort(0,0,0,0, false);
end;

procedure PressButton(j:integer);
{clears the pressed button and draws new rectangle over it}
var k: integer;
begin
k:= j div 65;
SetFillStyle(SolidFill, colors[k]^);
ClearButton(j);
SetColor(colors[k]^);
FillRect(226,144+j,426,184+j);
SetTextStyle(MSSansSerifFont,0,24);
SetColor(Black);
OutTextXY(326 - (TextWidth(word[k]) div 2) ,
 					(164+j) - 12 ,word[k]);
end;
procedure UnpressButton(j:integer);
{clears the rectangle and draws new menu button over the area}
var k:integer;
begin
k:= j div 65;
ClearButton(j);
SetColor(colors[k]^);
Bar3D( 220,150+j, 420, 190+j, 6, true);
SetTextStyle(MSSansSerifFont,0,24);
SetColor(Black);
OutTextXY(320 - (TextWidth(word[k]) div 2) ,
 					(170+j) - 12 ,word[k]);
end;

procedure Back();
{for returning to main menu screen}
var back: boolean;
    mouseEvent: MouseEventType;
    x,y : smallint;
begin
back := false;
SetFillStyle(solidFill, Amethyst);
SetLineStyle(NullLn,NormWidth,0);
FillRect(0,0,50,50);
SetTextStyle(ArialFont,0,25);
SetColor(Black);
OutTextXY(0, 0, 'BACK');
  while not back do
  begin
    if closeGraphRequest then
    	finalise();
    if (PollMouseEvent(mouseEvent)) then
    begin
      GetMouseEvent(mouseEvent);
  			if mouseEvent.buttons and MouseLeftButton <> 0 then
  			begin
    		// gets mouse's coordinates
  			x:=GetMouseX();
 				y:=GetMouseY();
        if (x > 0) and (x < 50) then
        	if (y > 0) and (y < 50) then
          begin
        		back := true;
        		SetBkColor(FloralWhite);
  					ClearDevice();
						LoadFromFile('MINEZWEEPER-uvod.txt', true);
						MenuButtons();
						AnimateTitle(anim);
          end;
        end;
    end;
  end;
end;

procedure Instructions();
{for displaying Instructions in cleared graphics window, read from file}
begin
  SetBkColor(FloralWhite);
  ClearDevice();
  LoadFromFile('Instructions.txt', false);
  UpdateGraph(UpdateOn);
  Back();
end;

procedure StartGame();
begin
  Closegraph();
  executeprocess('Game01.exe',['']);
end;

procedure Main();
var mouseEvent: MouseEventType;
    j,k : integer;
    buttonStillPressed : boolean;
begin
i:= 0;
k:=0;
buttonStillPressed := false;
Initialise();
LoadFromFile('MINEZWEEPER-uvod.txt', true);
MenuButtons();
AnimateTitle(anim);
//until the request for graphics window closing occurs
while not CloseGraphRequest do
begin
  //checks if any mouse event occured
	if PollMouseEvent(mouseEvent) then
  begin
  	j := ProcessMouseEvents(buttonPressed);
    if buttonPressed then
    begin
      PressButton(j);
      k:= j;
      buttonStillPressed := true;
      buttonPressed := false;
    end;
  end;
  AnimateTitle2(anim, i);
  if ((i mod 20) = 0) and buttonStillPressed then
  begin
  	UnpressButton(k);
		buttonStillPressed := false;
    case k of
    0: StartGame();
    //65: Difficulty();
    130: begin
      		FreeAnim(anim);
    			Instructions();
  			 end;
    //195: Highscore();
    end;
  end;
end;
FreeAnim(anim);
Finalise();
end;

begin
  Main();
end.


