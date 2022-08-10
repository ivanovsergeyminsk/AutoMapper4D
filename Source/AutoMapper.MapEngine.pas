unit AutoMapper.MapEngine;

interface
uses
    AutoMapper.CfgMapper
  , AutoMapper.TypePair
  , AutoMapper.MapItem
  , AutoMapper.MappingExpression
  , AutoMapper.Exceptions
  ;

type
  TMapEngine = class
  private
    FCfgMapper: TCfgMapper;

    function CreateInstance<TDestination>: TDestination;
    function GetExpression<TSource, TDestination>: TMapExpression<TSource, TDestination>; overload;
  public
    constructor Create(const ACfgMapper: TCfgMapper);
    destructor Destroy; override;

    function Map<TSource; TDestination>(const source: TSource): TDestination; overload;
    function Map<TSource; TDestination>(const source: TSource; const MapExpression: TMapExpression<TSource, TDestination>): TDestination; overload;
    function Map<TDestination>(const source: TObject): TDestination; overload;
    function Map<TDestination>(const source: TObject; const MapExpression: TMapExpression<TObject, TDestination>): TDestination; overload;
  end;

implementation

uses
    System.Rtti
  , System.TypInfo
  , System.SysUtils
  ;

{ TMapEngine }

constructor TMapEngine.Create(const ACfgMapper: TCfgMapper);
begin
  FCfgMapper := ACfgMapper;
end;

function TMapEngine.CreateInstance<TDestination>: TDestination;
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  RttiInstance: TRttiInstanceType;
  DestObj: TObject absolute result;
begin
  Ctx := TRttiContext.Create;
  RttiType := Ctx.GetType(TypeInfo(TDestination));
  RttiInstance := RttiType.AsInstance;

  DestObj := RttiInstance.MetaclassType.Create;

  Ctx.Free;
end;

destructor TMapEngine.Destroy;
begin
  FCfgMapper := nil;

  inherited;
end;


function TMapEngine.GetExpression<TSource, TDestination>: TMapExpression<TSource, TDestination>;
var
  Map: TMap;
  ExpValue: TValue;
  Exp: TMapExpression<TSource, TDestination>;

  TypePair: TTypePair;
begin
  TypePair := TTypePair.New<TSource, TDestination>;

  if not FCfgMapper.TryGetMap(TypePair, Map) then
  begin
    if not (TMapperSetting.Automap in FCfgMapper.Settings) then
      raise TGetMapItemException.Create(Format(CS_GET_MAPITEM_NOT_FOUND, [TypePair.SourceType,
                                                                          TypePair.DestinationType]));

    FCfgMapper.CreateMap<TSource, TDestination>();
    FCfgMapper.TryGetMap(TTypePair.New<TSource, TDestination>, Map);
  end;

  Map.Exp.ExtractRawData(@Exp);

  Result := Exp;
end;

function TMapEngine.Map<TDestination>(const source: TObject): TDestination;
var
  Ctx: TRttiContext;
  TypePair: TTypePair;

  Map: TMap;
  Exp: TMapExpression<TObject, TDestination>;
  Destination: TDestination;
begin
  Ctx := TRttiContext.Create;

  TypePair := TypePair.Create(Ctx.GetType(source.ClassType).QualifiedName, Ctx.GetType(TypeInfo(TDestination)).QualifiedName);

  if not FCfgMapper.TryGetMap(TypePair, Map) then
    raise TGetMapItemException.Create(Format(CS_GET_MAPITEM_NOT_FOUND, [TypePair.SourceType,
                                                                        TypePair.DestinationType]));
  if Ctx.GetType(TypeInfo(TDestination)).IsInstance then
    Destination := CreateInstance<TDestination>();

  Map.Exp.ExtractRawData(@Exp);
  Exp(source, Destination);

  Result := Destination;
end;

function TMapEngine.Map<TDestination>(const source: TObject;
  const MapExpression: TMapExpression<TObject, TDestination>): TDestination;
var
  Ctx: TRttiContext;

  Destination: TDestination;
begin
  Ctx := TRttiContext.Create;
  if Ctx.GetType(TypeInfo(TDestination)).IsInstance then
    Destination := CreateInstance<TDestination>();

  MapExpression(source, Destination);

  Result := Destination;
end;

function TMapEngine.Map<TSource, TDestination>(const source: TSource;
  const MapExpression: TMapExpression<TSource, TDestination>): TDestination;
var
  Ctx: TRttiContext;

  Destination: TDestination;
begin
  Ctx := TRttiContext.Create;
  if Ctx.GetType(TypeInfo(TDestination)).IsInstance then
    Destination := CreateInstance<TDestination>();

  MapExpression(source, Destination);

  Result := Destination;
end;

function TMapEngine.Map<TSource, TDestination>(const source: TSource): TDestination;
var
  Ctx: TRttiContext;

  Destination: TDestination;
  Exp: TMapExpression<TSource, TDestination>;
begin
  Exp := GetExpression<TSource, TDestination>();

  Ctx := TRttiContext.Create;
  if Ctx.GetType(TypeInfo(TDestination)).IsInstance then
    Destination := CreateInstance<TDestination>();

  Exp(source, Destination);

  Result := Destination;
end;

end.
