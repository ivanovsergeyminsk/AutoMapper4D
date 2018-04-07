unit AutoMapper.ClassPair;

interface
type
  TClassPair = record
  class operator Equal(a: TClassPair; b: TClassPair) : Boolean;
  class operator NotEqual(a: TClassPair; b: TClassPair) : Boolean;
  private
    FSourceClass: TClass;
    FDestinationClass: TClass;


  public
    constructor Create(const ASourceClass, ADestinationClass: TClass);
    property SourceClass: TClass read FSourceClass;
    property DestinationClass: TClass read FDestinationClass;

    function Equals(const other: TClassPair): Boolean; overload;
    function GetHashCode: integer; overload;
  end;



  THashCodeCombiner = class
  class function Combine<T1, T2>(const obj1: T1; const obj2: T2): integer; overload;
  class function Combine<T1: Class; T2: Class>: integer; overload;
  class function CombineCodes(const h1, h2: integer): integer;

  end;

implementation

uses
  System.Rtti, AutoMapper.Exceptions;

{ TClassPair }

constructor TClassPair.Create(const ASourceClass, ADestinationClass: TClass);
begin
  if not Assigned(ASourceClass) then
    raise TClassPairCreateExcetion.Create(CS_CLASSPAIR_CREATE_SOURCECLASS_NIL);

  if not Assigned(ADestinationClass) then
    raise TClassPairCreateExcetion.Create(CS_CLASSPAIR_CREATE_DESTCLASS_NIL);

  FSourceClass      := ASourceClass;
  FDestinationClass := ADestinationClass;
end;

class operator TClassPair.Equal(a, b: TClassPair): Boolean;
begin
  Result := a.Equals(b);
end;

function TClassPair.GetHashCode: integer;
begin
  Result := THashCodeCombiner.Combine(SourceClass, DestinationClass);
end;

function TClassPair.Equals(const other: TClassPair): Boolean;
begin
  Result := (SourceClass = other.SourceClass) and (DestinationClass = other.DestinationClass);
end;

class operator TClassPair.NotEqual(a, b: TClassPair): Boolean;
begin
  Result := not a.Equals(b);
end;

{ THashCodeCombiner }

class function THashCodeCombiner.Combine<T1, T2>(const obj1: T1; const obj2: T2): integer;
var
  Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;

  Result := CombineCodes(Ctx.GetType(@obj1).GetHashCode, Ctx.GetType(@obj2).GetHashCode);

  Ctx.Free;
end;

class function THashCodeCombiner.Combine<T1, T2>: integer;
var
  Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;

  Result := CombineCodes(Ctx.GetType(T1).GetHashCode, Ctx.GetType(T2).GetHashCode);

  Ctx.Free;
end;

class function THashCodeCombiner.CombineCodes(const h1, h2: integer): integer;
begin
  Result := ((h1 shl 5) + h1) xor h2;
end;

end.
