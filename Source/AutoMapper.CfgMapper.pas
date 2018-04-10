unit AutoMapper.CfgMapper;

interface

uses
  AutoMapper.MapItem,
  AutoMapper.ClassPair,
  AutoMapper.MappingExpression,
  Spring,
  Spring.Collections
  ;

type

  TCfgMapper = class
  private
    FMapItems: IDictionary<TClassPair, TMapItem>;

    function ExpToValue<TSource: Class; TDestination: Class>(const AExp: TMapExpression<TSource, TDestination>): TValue; overload;
  public
    constructor Create;
    destructor Destroy; override;

    function GetMapItem(const AClassPair: TClassPair): TMapItem;
//    procedure CreateMap<TSource, TDestination>(); overload;
    procedure CreateMap<TSource: Class; TDestination: Class>(const MappingExpression: TMapExpression<TSource, TDestination>); overload;
    procedure CreateMap<TSource: Class; TDestination: Class>; overload;
  end;

implementation

uses
  AutoMapper.Exceptions, System.SysUtils;


{ TMapperList }

constructor TCfgMapper.Create;
begin
  FMapItems   := TCollections.CreateDictionary<TClassPair, TMapItem>;
end;

procedure TCfgMapper.CreateMap<TSource, TDestination>(const MappingExpression: TMapExpression<TSource, TDestination>);
var
  FMapItem: TMapItem;
  FClassPair: TClassPair;
  FExp: TValue;
begin
  FExp := ExpToValue<TSource, TDestination>(MappingExpression);
  FClassPair := TClassPair.Create(TSource, TDestination);
  FMapItem := TMapItem.Create(FClassPair, FExp);

  FMapItems.Add(FClassPair, FMapItem);
end;

procedure TCfgMapper.CreateMap<TSource, TDestination>;
Var
  FMapItem: TMapItem;
  FClassPair: TClassPair;
  FExpValue: TValue;
  FExp: TMapExpression<TObject, TObject>;
begin
  FExp := TMapExpCollections.MapExpPropsFields;
  TValue.Make(@FExp,
               TypeInfo(TMapExpression<TObject, TObject>),
               FExpValue);

  FClassPair := TClassPair.Create(TSource, TDestination);
  FMapItem := TMapItem.Create(FClassPair, FExpValue);

  FMapItems.Add(FClassPair, FMapItem);
end;

function TCfgMapper.ExpToValue<TSource, TDestination>(
  const AExp: TMapExpression<TSource, TDestination>): TValue;
var
  FValue: TValue;
begin
  TValue.Make(@AExp, TypeInfo(TMapExpression<TSource, TDestination>), FValue);

  Result := FValue;
end;

function TCfgMapper.GetMapItem(const AClassPair: TClassPair): TMapItem;
var
  FMapItem: TMapItem;
begin
  if not FMapItems.TryGetValue(AClassPair, FMapItem) then
    raise TGetMapItemException.Create(Format(CS_GET_MAPITEM_NOT_FOUND, [AClassPair.SourceClass.ClassName,
                                                                        AClassPair.DestinationClass.ClassName]));

  Result := FMapItem;
end;

destructor TCfgMapper.Destroy;
begin
  FMapItems.Clear;
  FMapItems := nil;

  inherited;
end;

end.
