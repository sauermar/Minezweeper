program Game01;
{$APPTYPE GUI}
uses wingraph, winmouse, wincrt, sysutils;

type
		STATE = (opened,closed,flaged);

var

    bitmaps: array [0..11] of pointer;
    ended, startTime, first, ex: boolean;
    rows, cols, count, c : smallint;
    timeCount : integer;
    mines, seconds: string;
    grid: array[0..24, 0..16] of STATE; // player's visible grid
    grid2 : array [0..24, 0..16] of boolean; // game grid for mines
    grid3 : array [0..24, 0..16] of integer; // numbers around mines

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
  colourDepth, resolution, errcode,i,j: smallint;
  myFile : Text;
  texttmp, timestring: string;
begin
  // Reads number of rows and cols from the resolution of Menu application
 Assign(myFile, 'MenuResolution.txt');
 Reset(myFile);
 ReadLn(myFile, texttmp);
 Val(texttmp,cols);
 ReadLn(myFile, texttmp);
 Val(texttmp,rows);
 close(myfile);

  //Open the Graphics Window
  colourDepth :=SVGA;

  //gets the apropriate resolution and counting number of mines
  case cols of
        24:
          begin
          resolution  := m640x480;
          count := 89;
          c := 298;
          end;
        15:
          begin
            SetWindowSize(415,455);
         		resolution  := mCustom;
            count := 39;
            c := 185;
        	end;
        9: begin
            SetWindowSize(265,305);
         		resolution  := mCustom;
            count := 9;
            c := 110;
        	end;
  end;

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
  LoadStaticImage('mine.bmp', 25, 25, bitmaps[6]);
  LoadStaticImage('mineA.bmp', 25, 25, bitmaps[7]);
  LoadStaticImage('menu.bmp', 40, 30, bitmaps[8]);
  LoadStaticImage('grid.bmp', 625, 425, bitmaps[9]);
  LoadStaticImage('grid16x16.bmp', 399, 400, bitmaps[10]);
  LoadStaticImage('grid10x10.bmp', 250, 250, bitmaps[11]);


  //initialise 2D array (grid)
  for i:= 0 to cols do
  begin
   for j:= 0 to rows do
   begin
   	grid[i,j] := closed;
    grid2[i,j] := false;
   end;
  end;
  for i := cols+1 to 24 do
  begin
  	for j := rows+1 to 16 do
    begin
     	grid[i,j] := opened;
      grid2[i,j] := false;
    end;
  end;

  timeCount := -1;
 	timestring := Timetostr(Time);
 	seconds := timestring[7] + timestring[8];

  first := true;
  ex := false;
end;

procedure Finalise();
{Closes the Graphics window on request,
 releases the allocated memory}
var i: smallint;
begin
	repeat until CloseGraphRequest;
    for i := 0 to 8 do
    begin
      FreeMem(bitmaps[i]);
    end;
    CloseGraph();
end;

procedure Menu();
{creates an image for going back to menu option}
begin
PutImage(c-40,9,bitmaps[8]^, NormalPut);
end;

procedure GameStatus(bitmap : pointer);
{creates an emoji image for equivalent game progress}
begin
//constant for first x coordinate of the gameStatus icon
PutImage(c,2,bitmap^, NormalPut);
end;

procedure PressMenu();
{creates pressed Menu icon}
begin
 SetColor(GrayAsparagus);
 SetFillStyle(solidFill, Gray);
 SetLineStyle(SolidLn,0,NormWidth);
 FillRect(c-40,9,c,39);
 Delay(40);
end;

procedure PressGameStatus();
{creates pressed gameStatus icon}
begin
 SetColor(GrayAsparagus);
 SetFillStyle(solidFill, Gray);
 SetLineStyle(SolidLn,0,NormWidth);
 FillRect(c,2,c+45,47);
 Delay(40);
end;

procedure DistributeMines(count1:smallint);
{for random distribution of mines over the specified game grid}
var i, j, k, count2: smallint;
begin
  count2 := -1;
  Randomize; { This way we generate a new sequence every time
                 the program is run}
  for k := 0 to count1 do
  begin
    i := random (cols);
    j := random (rows);
    if not grid2[i,j] then
    begin
		  grid2[i,j] := true; // Place Mine
    end
	  else inc(count2); // if colision occurs, then try again
  end;

  if count2 <> -1 then
  	DistributeMines(count2);
end;

procedure CreateGrid();
{Creates a game's grid from given image}
var i : smallint;
begin
// Draws image on Graphics Window with given coordinates
case cols of
     24 : PutImage(7,50,bitmaps[9]^,NormalPut);
     15 : PutImage(7,50,bitmaps[10]^,NormalPut);
     9 : PutImage(7,50,bitmaps[11]^,NormalPut);
end;
for i := 9 to 11 do
	FreeMem(bitmaps[i]);
end;

procedure GetCoordinates(var x,y : smallint; maxX,maxY: smallint);
{gets the coordinates of the top left corner of the square,
upon which has been currently mouse button pressed}
begin
 x:=GetMouseX();
 y:=GetMouseY();
 if (x > 6) and (x < maxX) then   //width of grid
   	x := (((x - 7) div 25) * 25) + 7
 else x := -1;
 if (y > 49) and (y < maxY) then   //length of grid
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

Procedure NumbersAroundTiles();
{creates a 2D array of integers, depending on the location of mines}
var i,j,numberOfMines : smallint;
begin
 for i := 0 to cols do
 begin
  for j := 0 to rows do
  begin
   	numberOfMines := 0;
   	if not grid2[i,j] then
    begin
      if ((i-1) >= 0) and ((j-1) >= 0) then
	      if grid2[i-1,j-1] then
  	    	inc(numberOfMines);
      if ((j-1) >= 0) then
	      if grid2[i,j-1] then
  	    	inc(numberOfMines);
      if ((j-1) >= 0) and ((i+1) <= cols) then
      	if grid2[i+1,j-1] then
	      	inc(numberOfMines);
      if ((i-1) >= 0) then
      	if grid2[i-1,j] then
      		inc(numberOfMines);
      if ((i+1) <= cols) then
      	if grid2[i+1,j] then
      		inc(numberOfMines);
      if ((i-1) >= 0) and ((j+1) <= rows) then
      	if grid2[i-1,j+1] then
      		inc(numberOfMines);
      if ((j+1) <= rows) then
	      if grid2[i,j+1] then
  	    	inc(numberOfMines);
      if ((i+1) <= cols)and ((j+1) <= rows) then
	      if grid2[i+1,j+1] then
  	    	inc(numberOfMines);
      grid3[i,j] := numberOfMines;
    end
    else grid3[i,j] := -1;
  end;
 end;
end;

procedure Timer(seconds : string);
{initialise and overwrites timer on the right upper corner}
var x : smallint;
begin
case cols of
     24: x := 566;
     15: x := 341;
     9: x := 191;
     end;
  SetFillStyle(solidFill, White);
  SetLineStyle(NullLn,NormWidth,0);
  FillRect(x,10,x+67,36);
  SetTextStyle(ArialFont,0,40);
	SetColor(Red);

  if timeCount < 10 then
  	OutTextXY(x+5, 4,'00' + seconds)
  else if timeCount < 100 then
  	OutTextXY(x+5, 4,'0' + seconds)
    	else
      OutTextXY(x+5, 4, seconds);
end;

procedure ChangeTimer( seconds1 : string);
var
    timestring, help : string;
    number1,number2 : smallint;
begin
 timestring := Timetostr(Time);
 seconds := timestring[7] + timestring[8];
 Val(seconds,number1);
 Val(seconds1,number2);
 if number2 <> number1 then
 	begin
  	inc(timeCount);
    help := inttostr(timeCount);
   	Timer(help);
	end;
end;

procedure MineCounter();
{initialise mine counter on the left upper corner}
begin
  SetFillStyle(solidFill, White);
  FillRect(7,10,67,36);
  SetTextStyle(ArialFont,0,40);
	SetColor(Red);
  str(count+1, mines);
	OutTextXY(25, 4, mines);
end;

procedure ChangeMineNumber(subtract: boolean);
{subtracts flaged squares from the amount of mines}
begin
  if not subtract then
  	begin
			dec(count);
      str(count+1, mines);
      SetFillStyle(solidFill, White);
      SetLineStyle(NullLn,NormWidth,0);
  		FillRect(7,10,67,36);
      SetTextStyle(ArialFont,0,40);
      SetColor(Red);
      OutTextXY(25, 4, mines);
    end
  else
  begin
  	inc(count);
    str(count+1, mines);
    SetFillStyle(solidFill, White);
    SetLineStyle(NullLn,NormWidth,0);
  	FillRect(7,10,67,36);
    SetTextStyle(ArialFont,0,40);
    SetColor(Red);
    OutTextXY(25, 4, mines);
  end;
end;

procedure MineActivated(x,y : smallint);
{graphics after uncovering a mine}
var i,j : smallint;
begin
  GameStatus(bitmaps[3]);
  for i:= 0 to cols do
  begin
   for j := 0 to rows do
   begin
    if (grid2[i,j]) then
   		PutImage((i*25)+7,(j*25)+50,bitmaps[6]^,NormalPut);
   end;
  end;
  PutImage(x,y,bitmaps[7]^,NormalPut);
end;

procedure DisplaySquare(x,y,x1,y1 : smallint);
{Displays the number of mines around a square
or displays an area without any mines}
var number:string;
begin
  if grid3[x1,y1] <> 0 then
    begin
      SetTextStyle(TimesNewRomanFont,0,35);
      case grid3[x1,y1] of
           1:SetColor(MediumBlue);
           2:SetColor(ForestGreen);
           3:SetColor(Scarlet);
           4:SetColor(DarkBlue);
           5:SetColor(Cinnamon);
           6:SetColor(DarkCyan);
           7:SetColor(Black);
           8:SetColor(Lavender);
    	end;
      str(grid3[x1,y1],number);
      OutTextXY(x+5, y-5 , number);
    end
  else
  begin
  	if ((x1-1) >= 0) and ((y1-1) >= 0) and (grid[x1-1,y1-1] = closed) then
      begin
         x := ((x1-1)*25)+7;
         y := ((y1-1)*25)+50;
         OpenSquare(x,y);
    	 	 grid[x1-1,y1-1] := opened;
         DisplaySquare(x,y,x1-1,y1-1);
      end;
    if ((y1-1) >= 0) and (grid[x1,y1-1] = closed) then
      begin
        x := (x1*25)+7;
        y := ((y1-1)*25)+50;
        OpenSquare(x,y);
    	 	grid[x1,y1-1] := opened;
        DisplaySquare(x,y,x1,y1-1);
      end;
    if ((y1-1) >= 0) and ((x1+1) <= cols) and (grid[x1+1,y1-1] = closed) then
       begin
       	x := ((x1+1)*25)+7;
        y := ((y1-1)*25)+50;
        OpenSquare(x,y);
    	 	grid[x1+1,y1-1] := opened;
        DisplaySquare(x,y,x1+1,y1-1);
       end;
    if ((x1-1) >= 0) and (grid[x1-1,y1] = closed) then
       begin
        x := ((x1-1)*25)+7;
        y := (y1*25)+50;
        OpenSquare(x,y);
    	 	grid[x1-1,y1] := opened;
        DisplaySquare(x,y,x1-1,y1);
       end;
    if ((x1+1) <= cols) and (grid[x1+1,y1] = closed) then
       begin
       	x := ((x1+1)*25)+7;
        y := (y1*25)+50;
        OpenSquare(x,y);
    	 	grid[x1+1,y1] := opened;
        DisplaySquare(x,y,x1+1,y1);
       end;
    if ((x1-1) >= 0) and ((y1+1) <= rows) and (grid[x1-1,y1+1] = closed) then
       begin
       	x := ((x1-1)*25)+7;
        y := ((y1+1)*25)+50;
        OpenSquare(x,y);
    	 	grid[x1-1,y1+1] := opened;
        DisplaySquare(x,y,x1-1,y1+1);
       end;
    if ((y1+1) <= rows) and (grid[x1,y1+1] = closed) then
        begin
        x := (x1*25)+7;
        y := ((y1+1)*25)+50;
        OpenSquare(x,y);
    	 	grid[x1,y1+1] := opened;
        DisplaySquare(x,y,x1,y1+1);
        end;
    if ((x1+1) <= cols)and ((y1+1) <= rows) and (grid[x1+1,y1+1] = closed) then
       begin
       	x := ((x1+1)*25)+7;
        y := ((y1+1)*25)+50;
        OpenSquare(x,y);
    	 	grid[x1+1,y1+1] := opened;
        DisplaySquare(x,y,x1+1,y1+1);
       end;
  end;
end;

function IsGameWon(): boolean;
{returns true if every mine was flaged, else returns false}
var i,j: smallint;
    win: boolean;
begin
win := true;
for i := 0 to cols do
begin
	for j := 0 to rows do
	begin
    if (grid2[i,j]) and (grid[i,j] <> flaged) then
				win:= false;
  end;
end;
IsGameWon:= win;
end;

procedure UpdateHighScore(j : smallint; score: string);
var oldfile, newfile, namefile: TextFile;
    line: string[100]; // long enough to hold the longest line in the file
    i: word; // counter for the lines
    name : shortstring;
begin
name := '';

executeprocess('NameWindow.exe',['']);
AssignFile(namefile, 'name.txt');
Reset(namefile);
Readln(namefile, name);
CloseFile(namefile);

Erase(namefile);

AssignFile(oldfile, 'Highscore.txt');
AssignFile(newfile, 'Highscore(1).txt'); // create new file

Reset(oldfile);
Rewrite(newfile); // open the new file for writing

i := 0;

while not eof(oldfile) do begin
    readln(oldfile, line);
    if (i = j+1) then
        writeln(newfile, name + ': ' + score)
    else
        writeln(newfile, line);
    i := i + 1;
end;

Close(oldfile);
Close(newfile);

Erase(oldfile);
Rename(newfile, 'Highscore.txt');

end;

function GetHighScore(i : smallint): string;
var tf:TextFile;
    j,k : smallint;
    texttmp, high : string;
begin
  AssignFile(tf, 'Highscore.txt');
  Reset (tf);
  for j := 0 to i do
    readln(tf);

  readln(tf,texttmp);
  high := '';
  for j := 0 to length(texttmp) do
  begin
    if texttmp[j] = ':' then
      begin
       for k := j+2 to length(texttmp) do
        high := high + texttmp[k];
       break;
      end;
  end;

  CloseFile(tf);

  GetHighScore := high;
end;

procedure ProcessWonGame();
{creates the winning screen}
var mess, mess1, score, highsc , mess2: string;
    i, best : smallint;
begin
  GameStatus(bitmaps[4]);
  case cols of
       9: i := 0;
       15 : i := 2;
       24 : i:= 4;
       end;
  highsc := GetHighScore(i);
  str(Timecount,score);

  Val(highsc,best);
  if best > timecount then
    begin
     highsc := score;
     UpdateHighScore(i, score);
    end;

  SetFillStyle(XHatchFill, grayAsparagus);
  FillRect(7,50,(25*(cols+1))+7,(25*(rows+1))+50);

  SetTextStyle(ArialFont,0,40);
	SetColor(Yellow);

	mess:='You Won';
  mess1 := 'Score: ' + score ;
  mess2 := 'Best: ' + highsc;
  OutTextXY(c-55 ,c-40,mess);
  OutTextXY(c-55 ,c,mess1);
	OutTextXY(c-55 ,c+40,mess2);



end;

procedure ProcessMouseEvents();
{handles mouse clicking}
var
    mouseEvent : MouseEventType;
    x,y,x1,y1,i : smallint;
    won : boolean;
begin
 //remove the top mouse event of the queue
	GetMouseEvent(mouseEvent);
  case cols of
       24:GetCoordinates(x,y,633,476);
       15:GetCoordinates(x,y,408,451);
        9:GetCoordinates(x,y,258,301);
  end;
  x1:= (x - 7)div 25;
  y1:= (y - 50)div 25;
  // left button was pressed = reveal an empty square
  if mouseEvent.buttons and MouseLeftButton <> 0 then
  begin
   //creates surprise face on GameStatus icon
      GameStatus(bitmaps[2]);
      if (x <> -1) and (y <> -1) and (grid[x1,y1] = closed) then
      begin
        //when first square opens start the timer
        	if first then
      		begin
      			startTime := true;
        		first := false;
      		end;
          //if mine was detected under opened square
      	if (grid2[x1,y1]) then
      	begin
          ended := true;
          MineActivated(x,y);
          exit;
      	end;
        //if mine don't occur, then open square normally
        	OpenSquare(x,y);
     	 		grid[x1,y1] := opened;
          DisplaySquare(x,y,x1,y1);
      end
      else
      //if it's clicked on GameStatus icon, restarts game
      begin
      	x:=GetMouseX();
				y:=GetMouseY();
        if ((x >= c) and (x <= c+45)) and ((y > 1) and (y < 48)) then
          	begin
              PressGameStatus();
              for i := 0 to 8 do
              begin
                FreeMem(bitmaps[i]);
              end;
              ex:= true;
              Closegraph();
              executeprocess('Game01.exe',['']);
            end
        // or when it's clicked on Menu button, it goes back to menu
      	else if ((x > c-41) and (x < c)) and ((y > 8) and (y < 40)) then
         begin
            PressMenu();
            for i := 0 to 8 do
      	   begin
        	   FreeMem(bitmaps[i]);
      	   end;
            ex := true;
      	   Closegraph();
      	   executeprocess('Intro1.exe',['']);
         end;
      end;
      Delay(125);
      GameStatus(bitmaps[1]);
  end
  //right button was pressed
  else if mouseEvent.buttons and MouseRightButton <> 0 then
  begin
    // flag unreveiled square
  		if (x <> -1) and (y <> -1) and (grid[x1,y1] = closed) then
      	begin
        	Flag(x,y);
          grid[x1,y1] := flaged;
          ChangeMineNumber(false);
          //checkes if all mines were flaged
          if (count+1) = 0 then
            begin
            won := IsGameWon();
            if won then
              begin
                ProcessWonGame();
                ended := true;
              end;
            end;
        end
      //unflag unreveiled square
      else if (x <> -1) and (y <> -1) and (grid[x1,y1] = flaged) then
      begin
      	UnFlag(x,y);
        grid[x1,y1] := closed;
        ChangeMineNumber(true);
      end;
  end;
end;

procedure ProcessMouseEventsAfterTheGameHasEnded();
{enables to start a new game after lost or won one
 by clicking on the gameStatus icon}
var mouseEvent : MouseEventType;
    x,y,i : smallint;
begin
  GetMouseEvent(mouseEvent);
  if mouseEvent.buttons and MouseLeftButton <> 0 then
  begin
    x:=GetMouseX();
		y:=GetMouseY();
    //if it's clicked on GameStatus icon, restarts game
    if ((x >= c) and (x <= c+45)) and ((y > 1) and (y < 48)) then
    begin
        PressGameStatus();
        for i := 0 to 8 do
      	begin
        	FreeMem(bitmaps[i]);
      	end;
        ex := true;
      	Closegraph();
      	executeprocess('Game01.exe',['']);
      end
    //or when it's clicked on Menu button, it goes back to menu
    else if ((x > c-41) and (x < c)) and ((y > 8) and (y < 40)) then
      begin
         PressMenu();
         for i := 0 to 8 do
      	begin
        	FreeMem(bitmaps[i]);
      	end;
         ex := true;
      	Closegraph();
      	executeprocess('Intro1.exe',['']);
      end;
  end;
end;

procedure Load();
//loads initial structures and procedures for the game
begin
	Initialise();
  GameStatus(bitmaps[1]);
  Menu();
  MineCounter();
	Timer('0');
  CreateGrid();
  DistributeMines(count);
  NumbersAroundTiles();
end;

procedure Main();
var
  mouseEvent : MouseEventType;
begin
 	ended := false;
  startTime := false;
  Load();
  	//until the game has ended ask for mouse events and process them
  	while not ended do
    begin
     if (timeCount < 1000) and startTime then
      	ChangeTimer(seconds);
      if CloseGraphRequest then
      	ended := true;
    	if PollMouseEvent(mouseEvent) then
      begin
    		ProcessMouseEvents();
        if ex then exit;
      end;
    end;
    while ended do
    begin
       if CloseGraphRequest then
      	ended := false;
       if PollMouseEvent(mouseEvent) then
      	begin
    			ProcessMouseEventsAfterTheGameHasEnded();
          if ex then exit;
      	end;
    end;
    finalise();
end;

begin
  Main();
end.
