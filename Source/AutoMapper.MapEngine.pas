unit AutoMapper.MapEngine;

interface
uses
  AutoMapper.CfgMapper,
  AutoMapper.ClassPair,
  AutoMapper.MapItem, Spring
  ;

type
  TMapEngine = class
  private
    FCfgMapper: TCfgMapper;

    function CreateInstance<TDestination: Class>: TDestination;
    function GetExpression<TSource: Class; TDestionation: Class>(const AClassPair: TClassPair): TAction<TSource, TDestionation>;
  public
    constructor Create(const ACfgMapper: TCfgMapper);
    destructor Destroy; override;

    function Map<TSource: Class; TDestination: Class>(const source: TSource): TDestination;

  end;

implementation

uses
  System.Rtti;

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

  FDestValue := FRttiInstance.GetMethod('Create').Invoke(FRttiInstance.MetaclassType,[]);
  FDestObj := FDestValue.AsObject;

  Result := FDestObj as TDestination;
end;

destructor TMapEngine.Destroy;
begin
  FCfgMapper := nil;

  inherited;
end;

function TMapEngine.GetExpression<TSource, TDestionation>(const AClassPair: TClassPair): TAction<TSource, TDestionation>;
var
  FMapItem: TMapItem;
  FExpValue: TValue;
  FExp: TAction<TSource, TDestionation>;
begin
  FMapItem    := FCfgMapper.GetMapItem(AClassPair);
  FExpValue   := FMapItem.Exp;

  FExpValue.ExtractRawData(@FExp);

  Result := FExp;
end;

function TMapEngine.Map<TSource, TDestination>(const source: TSource): TDestination;
var
  FClassPair: TClassPair;
  FDestination: TDestination;
  FExp: TAction<TSource, TDestination>;
begin
  FDestination := CreateInstance<TDestination>();

  FClassPair  := TClassPair.Create(TSource, TDestination);
  FExp := GetExpression<TSource, TDestination>(FClassPair);

  FExp(source,FDestination);

  Result := FDestination;
end;

end.
