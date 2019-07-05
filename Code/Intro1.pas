program Intro1;
{$APPTYPE GUI}
{Introductional part of the program with features described in specification}
uses wingraph, wincrt, winmouse, sysutils;

var
    anim  : AnimatType;
    i : integer;
    colors: array [0..4] of ^longword = ( @red,@orange,@green,@Blue,@Purple);
    word: array [0..3] of string = ( 'Start Game','Difficulty',
    																	'Instructions','Highscore');
    word1: array [0..2] of string = ( 'Beginner','Intermediate','Expert');
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
    i,j,m: integer;
begin
if title = true then
	begin
		Randomize; //generate a new sequence of colors every time the program is run
		j:= Random(4);  //Get a random number between 0 and 4
		i:= 50; // y coordinate of displaying text
		setcolor(colors[j]^);
  	SetTextStyle(CourierNewFont,0,1);
  end
else if fileName = 'Instructions.txt' then
	begin
		SetTextStyle(CourierNewFont,0,2);
  	setcolor(Black);
  	i:= 0;
    m:= 10;
	end
else
	begin
  	SetTextStyle(CourierNewFont,0,30);
  	setcolor(Black);
  	i:= 30;
    m:= 230;
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
    OutTextXY(m,i+50,texttmp);
    end;
until Eof(myfile);
close(myfile);
end;

procedure RewriteMenuResolution(j : integer);
{used for writing in text file with difficulty settings
, which is afterwards read by game}
const
  C_FNAME = 'MenuResolution.txt';

var
  tf: TextFile;

begin
  // Set the name of the file that will be created
  AssignFile(tf, C_FNAME);

  {$I+}

  // Embed the file creation in a try/except block to handle errors gracefully
  try
    // Create the file, write some text and close it.
    rewrite(tf);
    case j of
    0 :
      begin
        writeln(tf, '9');
    		writeln(tf, '9');
      end;
    65:
      begin
        writeln(tf, '15');
    		writeln(tf, '15');
      end;
    130:
      begin
        writeln(tf, '24');
    		writeln(tf, '16');
      end;

    end;

	CloseFile(tf);

  except
    // If there was an error the reason can be found here
    on E: EInOutError do
      writeln('File handling error occurred. Details: ', E.ClassName, '/', E.Message);
  end;
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

procedure PressButton(j:integer; menu:boolean);
{clears the pressed button and draws new rectangle over it}
var k: integer;
begin
k:= j div 65;
if menu then
	begin
    SetFillStyle(SolidFill, colors[k]^);
    SetColor(colors[k]^);
	end
else
	begin
	  SetFillStyle(SolidFill, Black);
	  SetColor(Black);
	end;

ClearButton(j);
FillRect(226,144+j,426,184+j);

if menu then
	begin
    SetTextStyle(MSSansSerifFont,0,24);
    SetColor(Black);
    OutTextXY(326 - (TextWidth(word[k]) div 2) ,
 					  (164+j) - 12 ,word[k]);
	end
else
	begin
  	SetTextStyle(MSSansSerifFont,0,24);
  	SetColor(White);
  	OutTextXY(320 - (TextWidth(word1[k]) div 2) ,
  					(170+j) - 12 ,word1[k]);
    delay(100);
	end;
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
UpdateGraph(UpdateOn);
end;

procedure DrawBack();
var size: longint;
    f     : file;
    bitmap : pointer;
begin
 //returns the number of bytes needed to store the image
	size:=ImageSize(1,1,69,45);
 //reserves Size bytes memory on the heap, and returns a pointer to this memory
  GetMem(bitmap,size);
  {$I-} Assign(f,'back.bmp'); Reset(f,1); {$I+}
 //checks for error
  if (IOResult <> 0) or (FileSize(f) <> size) then
   begin
     writeln('Error: unable to load image file.');
     Exit;
   end;
  //load the image into reserved memory
  BlockRead(f,bitmap^,size);
  Close(f);
  // Draws an image onto the window
  //x,y are coordinates of the left upper corner
  PutImage(0,0,bitmap^, NormalPut);
end;

procedure BackToMainMenuGraphics();
begin
SetBkColor(FloralWhite);
ClearDevice();
MenuButtons();
end;

procedure Back();
{for returning to main menu screen}
var back: boolean;
    mouseEvent: MouseEventType;
    x,y : smallint;
begin
back := false;
while not back do
  begin
    if closeGraphRequest then
    	closegraph();
    if (PollMouseEvent(mouseEvent)) then
    begin
      GetMouseEvent(mouseEvent);
  			if mouseEvent.buttons and MouseLeftButton <> 0 then
  			begin
    		// gets mouse's coordinates
  			x:=GetMouseX();
 				y:=GetMouseY();
        if (x >-1) and (x < 70) then
        	if (y > -1) and (y < 46) then
          begin
        		back := true;
        		BackToMainMenuGraphics()
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
  DrawBack();
  UpdateGraph(UpdateOn);
  Back();
end;

procedure HighScore();
{used for displaying highest scores in different difficulties of teh game}
begin
 SetBkColor(FloralWhite);
 ClearDevice();
 LoadFromFile('Highscore.txt', false);
 DrawBack();
 UpdateGraph(UpdateOn);
 Back();
end;

procedure  Difficulty();
var i,j : smallint;
    mouseEvent: MouseEventType;
    diffset : boolean = false;
begin
	SetBkColor(FloralWhite);
  ClearDevice();
  j:= 0;
  //creates buttons with difficulty options
	for i:= 0 to 2 do
	begin
  	SetColor(Black);
  	SetFillStyle(SolidFill, Black);
  	Bar3D( 220,150+j, 420, 190+j, 6, true);
  	SetTextStyle(MSSansSerifFont,0,24);
  	SetColor(White);
  	OutTextXY(320 - (TextWidth(word1[i]) div 2) ,
  					(170+j) - 12 ,word1[i]);
  	j:= j + 65;
	end;
  SetTextStyle(MSSansSerifFont,0,30);
  SetColor(Black);
  OutTextXY(235,60,'Difficulty settings');

  UpdateGraph(UpdateOn); //used for updating graphics

  //cycle for pressing one of the difficulty buttons
  //and setuping the difficulty through text file
  while not diffset do
    begin
      if closegraphrequest then
      	exit();
      if PollMouseEvent(mouseEvent) then
  		begin
  			j := ProcessMouseEvents(buttonPressed);
    	end;
      if buttonPressed then
    	begin
      	PressButton(j, false);
        buttonPressed := false;
        RewriteMenuResolution(j);
        diffset := true;
        BackToMainMenuGraphics()
    	end;
    end;

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
      PressButton(j, true);
      k:= j;
      buttonStillPressed := true;
      buttonPressed := false;
    end;
  end;
  AnimateTitle2(anim, i);
  UpdateGraph(UpdateOff); // used to reduce flickering of animated title
  if ((i mod 20) = 0) and buttonStillPressed then
  begin
  	UnpressButton(k);
		buttonStillPressed := false;
    case k of
    0:
      begin
        StartGame();
        exit;
      end;
    65:
      begin
        Difficulty();
      end;
    130:
      begin
    		Instructions();
  		end;
    195: HighScore();
    end;
  end;
end;
FreeAnim(anim);
Finalise();
end;

{$R *.res}

begin
  Main();
end.


