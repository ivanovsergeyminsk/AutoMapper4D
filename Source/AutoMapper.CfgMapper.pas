unit AutoMapper.CfgMapper;

interface

uses
    AutoMapper.MapItem
  , AutoMapper.TypePair
  , AutoMapper.MappingExpression
  , System.Generics.Collections
  , System.Rtti
  ;

type

  TMapperSetting = (Automap);
  TMapperSettings = set of TMapperSetting;

  TCfgMapper = class
  private
    FMaps: TDictionary<TTypePair, TMap>;
    FSettings: TMapperSettings;

    function ExpressionToValue<TSource, TDestination>(const AExpression: TMapExpression<TSource, TDestination>): TValue;
  public
    constructor Create;
    destructor Destroy; override;

    function TryGetMap(const ATypePair: TTypePair; out Map: TMap): boolean;

    property Settings: TMapperSettings read FSettings write FSettings;

    procedure CreateMap<TSource; TDestination>; overload;
    procedure CreateMap<TSource; TDestination>(const MappingExpression: TMapExpression<TSource, TDestination>); overload;
  end;

implementation

uses
    AutoMapper.Exceptions
  , System.SysUtils
  ;


{ TCfgMapper }

constructor TCfgMapper.Create;
begin
  FMaps     := TObjectDictionary<TTypePair, TMap>.Create([doOwnsValues]);
  FSettings := [TMapperSetting.Automap];
end;

procedure TCfgMapper.CreateMap<TSource, TDestination>;
var
  Ctx: TRttiContext;
  SourceType, DestType: TRttiType;

  DefaultExp: TMapExpression<TSource, TDestination>;

  TypePair : TTypePair;
  ExpValue : TValue;
  Map      : TMap;
begin
  Ctx := TRttiContext.Create;
  SourceType := Ctx.GetType(TypeInfo(TSource));
  DestType   := Ctx.GetType(TypeInfo(TDestination));

  case TMapExpCollections.GetExpressionType<TSource, TDestination> of
    TExpressionType.ObjectToObject: DefaultExp := TMapExpCollections.MapExpObjectToObject<TSource, TDestination>;
    TExpressionType.ObjectToRecord: DefaultExp := TMapExpCollections.MapExpObjectToRecord<TSource, TDestination>;
    TExpressionType.RecordToObject: DefaultExp := TMapExpCollections.MapExpRecordToObject<TSource, TDestination>;
    TExpressionType.RecordToRecord: DefaultExp := TMapExpCollections.MapExpRecordToRecord<TSource, TDestination>;

  else
    raise TMapperConfigureException.Create('Pair of types not supported.');
  end;

  TypePair := TTypePair.Create(SourceType.QualifiedName, DestType.QualifiedName);
  ExpValue := ExpressionToValue<TSource, TDestination>(DefaultExp);

  Map := TMap.Create(TypePair, ExpValue);

  FMaps.Add(TypePair, Map);
end;

procedure TCfgMapper.CreateMap<TSource, TDestination>(
  const MappingExpression: TMapExpression<TSource, TDestination>);
var
  Ctx: TRttiContext;
  SourceType, DestType: TRttiType;

  Map: TMap;
  TypePair: TTypePair;
  Exp: TValue;
begin
  Ctx := TRttiContext.Create;
  SourceType := Ctx.GetType(TypeInfo(TSource));
  DestType   := Ctx.GetType(TypeInfo(TDestination));

  TypePair := TTypePair.Create(SourceType.QualifiedName, DestType.QualifiedName);
  Exp      := ExpressionToValue<TSource, TDestination>(MappingExpression);

  Map := TMap.Create(TypePair, Exp);

  FMaps.Add(TypePair, Map);
end;

function TCfgMapper.ExpressionToValue<TSource, TDestination>(
  const AExpression: TMapExpression<TSource, TDestination>): TValue;
var
  Value: TValue;
begin
  TValue.Make(@AExpression, TypeInfo(TMapExpression<TSource, TDestination>), Value);

  Result := Value;
end;

function TCfgMapper.TryGetMap(const ATypePair: TTypePair; out Map: TMap): boolean;
begin
  result := FMaps.TryGetValue(ATypePair, Map);
end;

destructor TCfgMapper.Destroy;
begin
  FMaps.Clear;
  FMaps.Free;

  inherited;
end;

end.
