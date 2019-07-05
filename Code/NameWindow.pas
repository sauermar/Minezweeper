program NameWindow;
{$APPTYPE GUI}
uses  wingraph, wincrt;
{used for inicializing small graphics window for inserting
	a nickname at the end of the game}
var  colourDepth, resolution, errcode: smallint;
  	 name : shortstring;
     namefile: Textfile;
begin
//initialise graphics window with custom width and height
  colourDepth :=SVGA;
  SetWindowSize(300,100);
  resolution := mCustom;
  InitGraph(colourDepth,resolution,'NickName');
   //Check for errors
  errcode:=GraphResult;
  if (errcode <> grOK) then
  begin
     WriteLn('Error when initialising the graphics window, code: ',
     						errcode, '. Message: ', GraphErrorMsg(errcode));
     ReadLn();
     Halt(1);
  end;

//text-output/input onto graphics window
SetTextStyle(ArialFont,0,20);
WriteBuf('New HighScore!');
WriteBuf(#13);
WriteBuf('Press Enter to confirm');
WriteBuf(#13#13);
WriteBuf('Nickname: ');
ReadBuf(name,0);

//passes the name argument by textFile
Assign(namefile,'name.txt');
Rewrite(namefile);
writeln(namefile, name);
Close(namefile);

//finalise
CloseGraph();
end.

