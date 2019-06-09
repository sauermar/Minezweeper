program test;
uses wingraph;
begin
gd:=Detect;
InitGraph(gd,gm,'');
<your code here>
repeat until CloseGraphRequest; //this waits for close button to be clicked
CloseGraph;
end.

