unit AutoMapper.MapEngine;

interface
uses
    AutoMapper.CfgMapper
  , AutoMapper.ClassPair
  , AutoMapper.MapItem
  , AutoMapper.MappingExpression
  ;

type
  TMapEngine = class
  private
    FCfgMapper: TCfgMapper;

    function CreateInstance<TDestination: Class>: TDestination;
    function GetExpression<TSource, TDestination>(const AClassPair: TClassPair): TMapExpression<TSource, TDestination>;
  public
    constructor Create(const ACfgMapper: TCfgMapper);
    destructor Destroy; override;

    function Map<TSource: Class; TDestination: Class>(const source: TSource): TDestination; overload;
    function Map<TSource: Class; TDestination: Class>(const source: TSource; const MapExpression: TMapExpression<TSource, TDestination>): TDestination; overload;
    function Map<TDestination: Class>(const source: TObject): TDestination; overload;
    function Map<TDestination: Class>(const source: TObject; const MapExpression: TMapExpression<TObject, TDestination>): TDestination; overload;
  end;

implementation

uses
    System.Rtti
  ;

{ TMapEngine }

constructor TMapEngine.Create(const ACfgMapper: TCfgMapper);
begin
  FCfgMapper := ACfgMapper;
end;

function TMapEngine.CreateInstance<TDestination>: TDestination;
var
  Ctx: TRttiContext;
  FRttiType: TRttiType;
  FRttiInstance: TRttiInstanceType;
  FDestValue: TValue;
  FDestObj: TObject;
begin
  Ctx := TRttiContext.Create;
  FRttiType := Ctx.GetType(TypeInfo(TDestination));
  FRttiInstance := FRttiType.AsInstance;

  FDestObj := FRttiInstance.MetaclassType.Create;

//  FDestValue := FRttiInstance.GetMethod('Create').Invoke(FRttiInstance.MetaclassType,[]);
//  FDestObj := FDestValue.AsObject;

  Result := FDestObj as TDestination;

  Ctx.Free;
end;

destructor TMapEngine.Destroy;
begin
  FCfgMapper := nil;

  inherited;
end;

function TMapEngine.GetExpression<TSource, TDestination>(const AClassPair: TClassPair): TMapExpression<TSource, TDestination>;
var
  FMapItem: TMapItem;
  FExpValue: TValue;
  FExp: TMapExpression<TSource, TDestination>;
begin
  FMapItem    := FCfgMapper.GetMapItem(AClassPair);
  FExpValue   := FMapItem.Exp;

  FExpValue.ExtractRawData(@FExp);

  Result := FExp;
end;

function TMapEngine.Map<TDestination>(const source: TObject): TDestination;
var
  FClassPair: TClassPair;
  FDestination: TDestination;
  FExp: TMapExpression<TObject, TDestination>;

  FDestObj: TObject;
begin
  FClassPair := TClassPair.Create(source.ClassType, TDestination);
  FExp := GetExpression<TObject, TDestination>(FClassPair);

  FDestination := CreateInstance<TDestination>();

  FExp(source, FDestination);

  Result := FDestination;
end;

function TMapEngine.Map<TSource, TDestination>(const source: TSource): TDestination;
var
  FClassPair: TClassPair;
  FDestination: TDestination;
  FExp: TMapExpression<TSource, TDestination>;
begin
  FClassPair  := TClassPair.Create(TSource, TDestination);
  FExp := GetExpression<TSource, TDestination>(FClassPair);

  FDestination := CreateInstance<TDestination>();

  FExp(source,FDestination);

  Result := FDestination;
end;

function TMapEngine.Map<TDestination>(const source: TObject;
  const MapExpression: TMapExpression<TObject, TDestination>): TDestination;
var
  FDestination: TDestination;

  FDestObj: TObject;
begin
  FDestination := CreateInstance<TDestination>();

  MapExpression(source, FDestination);

  Result := FDestination;
end;

function TMapEngine.Map<TSource, TDestination>(const source: TSource;
  const MapExpression: TMapExpression<TSource, TDestination>): TDestination;
var
  FDestination: TDestination;
begin
  FDestination := CreateInstance<TDestination>();

  MapExpression(source,FDestination);

  Result := FDestination;
end;

end.
