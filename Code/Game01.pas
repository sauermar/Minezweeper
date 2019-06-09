program Game01;
uses wingraph, winmouse, wincrt;

type
		STATE = (closed,opened,flaged);

var
    bitmaps: array [0..6] of pointer;
    grid: array[0..24, 0..16] of STATE;

procedure LoadStaticImage(filename:string; n, m:smallint; var bitmap: pointer);
{loads a 24 bits per pixel image from a given file,
 n stands for image width and m for height (suppose it is squared)}
var size: longint;
    f     : file;
begin
 //returns the number of bytes needed to store the image
	size:=ImageSize(1,1,n,m);
  //reserves Size bytes memory on the heap, and returns a pointer to this memory
  GetMem(bitmap,size);
  {$I-} Assign(f,filename); Reset(f,1); {$I+}
  //checks for error
   if (IOResult <> 0) or (FileSize(f) <> size) then
   begin
     writeln('Error: unable to load image file.');
     Exit;
   end;
  //load the image into reserved memory
  BlockRead(f,bitmap^,size);
  Close(f);
end;

procedure Initialise();
{Initialises the Graphics Window
 also loads images and initialises grid array}
var
  colourDepth, resolution, errcode,i,j : smallint;
  begin
  //Open the Graphics Window
  colourDepth :=SVGA;
  resolution  := m640x480;
  InitGraph(colourDepth,resolution,'Minezweeper');

  //Check for errors
  errcode:=GraphResult;
  if (errcode <> grOK) then
  begin
     WriteLn('Error when initialising the graphics window, code: ',
     						errcode, '. Message: ', GraphErrorMsg(errcode));
     ReadLn();
     Halt(1);
     end;
  LoadStaticImage('flag.bmp', 25, 25, bitmaps[0]);
  LoadStaticImage('smileyface.bmp', 45, 45, bitmaps[1]);
  LoadStaticImage('surpface.bmp', 45, 45, bitmaps[2]);
  LoadStaticImage('bombface.bmp', 45, 45, bitmaps[3]);
  LoadStaticImage('wonface.bmp', 45, 45, bitmaps[4]);
  LoadStaticImage('square02.bmp', 25, 25, bitmaps[5]);
  LoadStaticImage('grid.bmp', 625, 425, bitmaps[6]);

  //initialise 2D array (grid)
  for i:= 0 to 24 do
  begin
   for j:= 0 to 16 do
   	grid[i,j] := closed;
  end;
end;

procedure Finalise();
{Closes the Graphics window on request,
 releases the allocated memory}
var i: smallint;
begin
	repeat until CloseGraphRequest;
    for i := 0 to 5 do
    begin
      FreeMem(bitmaps[i]);
    end;
    CloseGraph();
end;
procedure GameStatus(bitmap : pointer);
{creates an emoji image for equivalent game progress}
begin
PutImage(298,2,bitmap^, NormalPut);
end;

procedure CreateGrid();
{Creates a game's grid from given image}
begin
// Draws image on Graphics Window with given coordinates
PutImage(7,50,bitmaps[6]^,NormalPut);
FreeMem(bitmaps[6]);
end;

procedure GetCoordinates(var x,y : smallint);
{gets the coordinates of the top left corner of the square,
upon which has been currently mouse button pressed}
begin
 x:=GetMouseX();
 y:=GetMouseY();
 if (x > 6) and (x < 633) then   //width of grid
   	x := (((x - 7) div 25) * 25) + 7
 else x := -1;
 if (y > 49) and (y < 476) then   //length of grid
   	y := (((y - 50)div 25) * 25) + 50
 else y := -1;
end;

procedure Flag(x,y : smallint);
{draw image of flag over a square}
begin
 PutImage(x,y,bitmaps[0]^,NormalPut);
end;

procedure UnFlag(x,y : smallint);
{draw image of square over a square}
begin
 PutImage(x,y,bitmaps[5]^,NormalPut);
end;

procedure OpenSquare(x,y: smallint);
{draw a gray rectangle over a square}
begin
  //set the border colours to dark gray
 SetColor(GrayAsparagus);
 //set the fill to solid light gray
 SetFillStyle(solidFill, Gray);
 //set the line style to solid 1px width
 SetLineStyle(SolidLn,0,NormWidth);
 //draw a rectangle
 FillRect(x,y,x+25,y+25);
end;

procedure Timer(j : integer);
{creating a timer, which will count number of minutes
 and seconds from the begining of the game}
var i : integer;
begin
 i:= 0;
 while i < 60 do //number of seconds
 begin
  	inc(i);
    SetColor(Red);
    //paint numbers to Graphics window
    OutTextXY(630,2,'imodium');
    delay(1000);  // 1000ms = 1s
 end;
 inc(j); //increase number of minutes
 Timer(j);
end;

procedure ProcessMouseEvents();
{handles mouse cliking}
var
    mouseEvent : MouseEventType;
    x,y,x1,y1 : smallint;
begin
 //remove the top mouse event off the queue
	GetMouseEvent(mouseEvent);
  GetCoordinates(x,y);
  x1:= (x - 7)div 25;
  y1:= (y - 50)div 25;
  // left button was pressed = reveal an empty square
  if mouseEvent.buttons and MouseLeftButton <> 0 then
  begin
     	GameStatus(bitmaps[2]);
      if (x <> -1) and (y <> -1) and (grid[x1,y1] = closed) then
      begin
      	OpenSquare(x,y);
        grid[x1,y1] := opened;
      end;
      Delay(125);
      GameStatus(bitmaps[1]);
  end
  //right buttonn was pressed = flag an empty square
  else if mouseEvent.buttons and MouseRightButton <> 0 then
  begin
  		if (x <> -1) and (y <> -1) and (grid[x1,y1] = closed) then
      	begin
        	Flag(x,y);
          grid[x1,y1] := flaged;
        end
      else if (x <> -1) and (y <> -1) and (grid[x1,y1] = flaged) then
      begin
      	UnFlag(x,y);
        grid[x1,y1] := closed;
      end;
  end;
end;

procedure Load();
begin
	Initialise();
  GameStatus(bitmaps[1]);
  CreateGrid();
end;

procedure Main();
var ended: boolean;
    mouseEvent : MouseEventType;
begin
 	ended := false;
  Load();
  	//until the game has ended ask for mouse events and process them
  	while not ended do
    begin
      if CloseGraphRequest then
      	ended := true;
    	if PollMouseEvent(mouseEvent) then
      begin
    		ProcessMouseEvents();
      end;
    end;
    finalise();
end;

begin
  Main();
end.
