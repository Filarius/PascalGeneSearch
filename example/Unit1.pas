unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ugene, Vcl.StdCtrls, Vcl.ExtCtrls;

type

  TMyData = array [1..100,1..100] of boolean;
  PMyData = ^TMyData;
  TForm1 = class(TForm)
    BtnInit: TButton;
    BtnStep: TButton;
    BtnFree: TButton;
    Memo1: TMemo;
    Image1: TImage;
    Timer1: TTimer;
    BtnRadiation: TButton;
    procedure BtnInitClick(Sender: TObject);
    procedure BtnStepClick(Sender: TObject);
    procedure BtnFreeClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure BtnRadiationClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Gene: TGeneTemplate;
implementation

{$R *.dfm}

procedure InitPerson(var data:Pointer);
var i,j:Word;
var mydata:PMyData;
begin
 mydata:=data;
 new(mydata);
 data:= mydata;
 for i := 1 to 100 do
   for j := 1 to 100 do
    mydata^[i,j]:=(Random(2)=0);
end;

procedure FreePerson(var data:Pointer);
var mydata:PMyData;
begin
  mydata:=data;
  Dispose(mydata);
  data:=nil;
end;

procedure Mutate(data:Pointer; mutagen:real);
var i,j:word;
    mydata:PMyData;
begin
  for i := 1 to 100 do
    for j := 1 to 100 do
      if random()<mutagen then
      begin
        mydata:=data;
        mydata^[i,j]:=not mydata^[i,j];
      end;
end;

procedure Evaluate(data:Pointer; var result:real);
var
  sum:Real;
  flag:Boolean;
  i,j:word;
begin
  // solution must be 50*100 of black and 50*100 of white
  sum:=0;
  for i := 1 to 100 do
    for j := 1 to 100 do
     // if (PMyData(data)^[i,j] = ((abs(i-50)<25))and(abs(j-50)<25)) then
      if (PMyData(data)^[i,j] = (i<50)) then
        sum:=sum+1;
  result:=sum;
end;

procedure Mating(dataleft,dataright:Pointer;var datanew:Pointer);
var
  i,j:word;
begin
  New(PMyData(datanew));
  for i := 1 to 100 do
    for j := 1 to 100 do
      if Random(2) = 0 then
        PMyData(datanew)^[i,j]:=PMyData(dataleft)^[i,j]
      else
        PMyData(datanew)^[i,j]:=PMyData(dataright)^[i,j]
end;

procedure TForm1.BtnFreeClick(Sender: TObject);
begin
Timer1.Enabled:=false;
Gene.Destroy;
end;

procedure TForm1.BtnInitClick(Sender: TObject);
begin
  Randomize;
  Image1.Canvas.Pen.Color:=clWhite;

  Gene:=TGeneTemplate.Create;
  Gene.InitPerson:=InitPerson;
  Gene.FreePerson:=FreePerson;
  Gene.Mutate:=Mutate;
  Gene.Mating:=Mating;
  Gene.Evaluate:=Evaluate;
  Gene.PopulationLimit:=50;
  Gene.PopulationMutation:=0.9;
  Gene.PopulationMutagen:=0.3;
  Gene.PopulationMatingRate:=0.1;
  Gene.PopulationInit;
end;

procedure TForm1.BtnStepClick(Sender: TObject);
var
  ptr:Pointer;
  i:Integer;
  j: Integer;
begin
Timer1.Enabled:= not Timer1.Enabled;
  {Gene.DoStep;
  ptr:=Gene.GetBestPerson;
  if ptr=nil then
    Memo1.Text:='NO'
  else begin
    Memo1.Clear;

    Memo1.Lines.Add('list of solutions');
    for i := 0 to 4 do
      Memo1.Lines.Add(IntToStr(i)+
                      '__'+
                      FloatToStr(Gene.Values[i])
      );
  end;

  Image1.Canvas.Rectangle(Canvas.ClipRect);

  for i := 1 to 100 do
    for j := 1 to 100 do
      if PMyData(ptr)^[i,j] then
        Image1.Canvas.Pixels[i,j]:=clblack
      else
        Image1.Canvas.Pixels[i,j]:=clWhite;   }

end;

procedure TForm1.BtnRadiationClick(Sender: TObject);
var
  i,j,k:Integer;
  mydata:PMyData;
begin
  for k := 0 to Gene.PopulationLimit-1 do
  begin
    mydata:=Gene.Items[k];
    for i := 1 to 100 do
      for j := 1 to 100 do
        if random()<0.05 then
          begin
            mydata^[i,j]:=not mydata^[i,j];
          end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  ptr:Pointer;
  i:Integer;
  j: Integer;
begin
Gene.DoStep;
  ptr:=Gene.GetBestPerson;
  if ptr=nil then
    Memo1.Text:='NO'
  else begin
    Memo1.Clear;

    Memo1.Lines.Add('price of best solutions');
    for i := 0 to 4 do
      Memo1.Lines.Add(IntToStr(i)+
                      '__'+
                      FloatToStr(Gene.Values[i])
      );
  end;

  Image1.Canvas.Rectangle(Canvas.ClipRect);

  for i := 1 to 100 do
    for j := 1 to 100 do
      if PMyData(ptr)^[i,j] then
        Image1.Canvas.Pixels[i,j]:=clblack
      else
        Image1.Canvas.Pixels[i,j]:=clWhite;
end;

end.
