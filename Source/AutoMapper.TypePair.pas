unit AutoMapper.TypePair;

interface

type
  TTypePair = record
    class operator Equal(a: TTypePair; b: TTypePair) : Boolean;
    class operator NotEqual(a: TTypePair; b: TTypePair) : Boolean;
  private
    FSourceType       : string;
    FDestinationType  : string;
  public
    constructor Create(const ASourceType, ADestinationType: string);
    property SourceType: string read FSourceType;
    property DestinationType: string read FDestinationType;

    function Equals(const other: TTypePair): boolean; overload;
    function GetHashCode: integer; overload;

    class function New<TSource, TDestination>: TTypePair; static;
  end;

  THashCodeCombiner = class
    class function Combine<T1, T2>(const obj1: T1; const obj2: T2): integer; overload;
    class function Combine<T1: Class; T2: Class>: integer; overload;
    class function CombineCodes(const h1, h2: integer): integer;
  end;

implementation

uses
    AutoMapper.Exceptions
  , System.SysUtils
  , System.Rtti
  ;

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

{ TTypePair }

constructor TTypePair.Create(const ASourceType, ADestinationType: string);
begin
  if ASourceType = ADestinationType then
    raise TTypePairCreateException.Create('SourceType equals DestinationType');

  if ASourceType.IsEmpty then
    raise TTypePairCreateException.Create('SourceType is nil');

  if ADestinationType.IsEmpty then
    raise TTypePairCreateException.Create('DestinationType is nil');

  FSourceType       := ASourceType;
  FDestinationType  := ADestinationType;
end;

class operator TTypePair.Equal(a, b: TTypePair): Boolean;
begin
  result := a.Equals(b);
end;

function TTypePair.Equals(const other: TTypePair): boolean;
begin
  Result := (FSourceType = other.FSourceType) and (FDestinationType = other.FDestinationType);
end;

function TTypePair.GetHashCode: integer;
begin
  Result := THashCodeCombiner.CombineCodes(FSourceType.GetHashCode, FDestinationType.GetHashCode);
end;

class function TTypePair.New<TSource, TDestination>: TTypePair;
var
  Ctx: TRttiContext;
  SourceType, DestType: TRttiType;
begin
  Ctx := TRttiContext.Create;
  SourceType := Ctx.GetType(TypeInfo(TSource));
  DestType   := Ctx.GetType(TypeInfo(TDestination));

  Result := TTypePair.Create(SourceType.QualifiedName, DestType.QualifiedName);
end;

class operator TTypePair.NotEqual(a, b: TTypePair): Boolean;
begin
  result := not a.Equals(b);
end;

end.
