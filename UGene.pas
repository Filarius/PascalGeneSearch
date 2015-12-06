unit UGene;

interface

uses
  System.SysUtils, System.Classes;
type
  PPerson = ^TPerson;
  TPerson = record
    value:real;
    data:Pointer;
  end;

  TGeneProcInitPerson = procedure (var data:Pointer);
  TGeneProcFreePerson = procedure (var data:Pointer);
  TGeneProcMutate = procedure (data:Pointer; mutagen:Real);
  TGeneProcEvaluate = procedure (data:Pointer; var result:Real);
  TGeneProcMating = procedure (dataleft,dataright:Pointer;var datanew:Pointer);

  TGeneTemplate = class
    protected
      FInitPerson:TGeneProcInitPerson;
      FFreePerson:TGeneProcFreePerson;
      FMutate:TGeneProcMutate;
      FEvaluate:TGeneProcEvaluate;
      FMating:TGeneProcMating;
      FPopulation:TList;
      FPopulationLimit:Integer;
      FPopulationMutation:real;
      FPopulationMutagen:real;
      FPopulationMatingRate:real;
      FPersonBest:PPerson;

      function GetPerson(Index:Integer):Pointer;
      function GetValue(Index:Integer):Real;
      procedure PopulationMutate;
      procedure PopulationMating;
      procedure PopulationEvaluate;
      procedure PopulationSort;
      procedure PopulationTruncate;
    public
      constructor Create;
      destructor Destroy;

      function GetBestPerson:Pointer;
      procedure PopulationInit;
      procedure DoStep;

      property InitPerson:TGeneProcInitPerson
        read FInitPerson write FInitPerson;
      property FreePerson:TGeneProcFreePerson
        read FFreePerson write FFreePerson;
      property Mutate:TGeneProcMutate
        read FMutate write FMutate;
      property Evaluate:TGeneProcEvaluate
        read FEvaluate write FEvaluate;
      property Mating:TGeneProcMating
        read FMating write FMating;

      property PopulationLimit:Integer
        read FPopulationLimit write FPopulationLimit;
      property PopulationMutation:real
        read FPopulationMutation write FPopulationMutation;
      property PopulationMutagen:real
        read FPopulationMutagen write FPopulationMutagen;
      property PopulationMatingRate:real
        read FPopulationMatingRate write FPopulationMatingRate;
      property BestPerson:Pointer
        read GetBestPerson;
      property Items[Index:Integer]:Pointer
        read GetPerson;
      property Values[Index:Integer]:Real
        read GetValue;

  end;

implementation

constructor TGeneTemplate.Create;
begin
  inherited Create;
  FPopulation:=TList.Create;
  FPopulationLimit:=0;
  FPopulationMutation:=-1;
  FPopulationMutagen:=0;
  FPopulationMatingRate:=-1;

  FPersonBest:=nil;
end;

destructor TGeneTemplate.Destroy;
var i:Integer;
    person:PPerson;
begin
  for i := 0 to FPopulation.Count-1 do
  begin
    person:=FPopulation.Items[i];
    FreePerson(person^.data);
    Dispose(person);
  end;
  FPopulation.Destroy;
  inherited Destroy;
end;

function TGeneTemplate.GetPerson(Index:Integer):Pointer;
begin
  Result:=PPerson(FPopulation.Items[Index])^.data;
end;

function TGeneTemplate.GetValue(Index:Integer):Real;
begin
  Result:=PPerson(FPopulation.Items[Index])^.value;
end;

procedure TGeneTemplate.PopulationMutate;
var i:integer;
    person:PPerson;
begin

  if FPopulationMutation<0 then Exit;
  for i := 0 to FPopulation.Count-1 do
    if random()<FPopulationMutation then
      begin
        person:=FPopulation.Items[i];
        FMutate(person^.data,FPopulationMutagen);
        person^.value:=-1;
      end;
end;

procedure TGeneTemplate.PopulationInit;
var person:PPerson;
    i:integer;
begin
  if FPopulationLimit=0 then
    raise Exception.Create('Population limit not initializated');
  if FPopulation.Count>0 then
    FPopulation.Clear;
  FPopulation.Capacity:=FPopulationLimit;
  for i := 1 to FPopulationLimit do
  begin
    new(person);
    person^.value:=-1;
    InitPerson(person^.data);
    FPopulation.Add(person);
  end;
end;



procedure TGeneTemplate.PopulationMating;
var i,j,count:integer;
    personleft,personright,personnew:PPerson;

begin
  count:=FPopulation.Count;
  if FPopulationMatingRate<0 then Exit;
  for i := 0 to count-2 do
    for j := i+1 to count-1 do
      if random()<FPopulationMatingRate then
        begin
          personleft:=FPopulation.Items[i];
          personright:=FPopulation.Items[j];
          new(personnew);
          personnew^.value:=-1;
          FMating(personleft^.data,personright^.data,personnew^.data);
          FPopulation.Add(personnew);
        end;
end;

procedure TGeneTemplate.PopulationEvaluate;
var
 i:integer;
 person:PPerson;
 value:real;
begin
  for i := 0 to FPopulation.Count-1 do
  begin
    person:=FPopulation.Items[i];
    if person^.value < 0 then
    begin
      FEvaluate(person^.data,person^.value);
      if not(person^.value > 0) then
        raise Exception.Create('Evaluation function is not positive');
//      person^.value:=value;
    end;
  end;
end;

  function CompareFunc(personleft,personright:Pointer):Integer;
  var left,right:PPerson;
  begin
    left:=personleft;
    right:=personright;
    if left = nil then
      Result:=-1
//    else if PPerson(personleft)^.value > PPerson(personright)^.value then
    else if left^.value < right^.value then
      Result:=1
    else if left^.value > right^.value then
      Result:=-1
    else
      Result:=0;
  end;

procedure TGeneTemplate.PopulationSort;
var
  ListSortCompare:TListSortCompare;

begin
  ListSortCompare:=@CompareFunc;
  FPopulation.Sort(
    ListSortCompare
  );
   { function (personleft,personright:pointer):Integer
    begin
      if PPerson(personleft)^.value > PPerson(personright)^.value then
        Result:=1
      else
        Result:=-1;
    end       }


  FPersonBest:=FPopulation.Items[0];
end;

procedure TGeneTemplate.PopulationTruncate;
var i:integer;
    person:PPerson;
begin
  if FPopulationLimit >= FPopulation.Count then
    Exit;
  for i := FPopulationLimit to FPopulation.Count-1 do
  begin
    person:=FPopulation.Items[i];
    FreePerson(person^.data);
    Dispose(person);
  end;
  FPopulation.Count:=FPopulationLimit;
end;

function TGeneTemplate.GetBestPerson:Pointer;
begin
  if FPersonBest = nil then
    Result:=nil
  else
    Result:=FPersonBest^.data;
end;

procedure TGeneTemplate.DoStep;
begin
  PopulationMating;
  PopulationMutate;
  PopulationEvaluate;
  PopulationSort;
  PopulationTruncate;
end;

end.
