unit AutoMapper.ConfigurationProvider;

interface
uses
    AutoMapper.CfgMapper
  , AutoMapper.MappingExpression
  ;

type

  TConfigurationProvider = class
  private
    FCfgMapper: TCfgMapper;
  public
    function Settings(const Value: TMapperSettings): TConfigurationProvider;
    function CreateMap<TSource; TDestination>(const MappingExpression: TMapExpression<TSource, TDestination>): TConfigurationProvider; overload;
    function CreateMap<TSource; TDestination>(): TConfigurationProvider; overload;
    procedure Validate;

    constructor Create(const CfgMapper: TCfgMapper); virtual;
    destructor Destroy; override;
  end;

implementation

{ TConfigurationProvider }

constructor TConfigurationProvider.Create(const CfgMapper: TCfgMapper);
begin
  FCfgMapper := CfgMapper;
end;

function TConfigurationProvider.CreateMap<TSource, TDestination>(
  const MappingExpression: TMapExpression<TSource, TDestination>): TConfigurationProvider;
begin
  FCfgMapper.CreateMap<TSource, TDestination>(MappingExpression);
  result := Self;
end;

function TConfigurationProvider.CreateMap<TSource, TDestination>: TConfigurationProvider;
begin
  FCfgMapper.CreateMap<TSource, TDestination>;
  Result := Self;
end;

destructor TConfigurationProvider.Destroy;
begin
  FCfgMapper := nil;

  inherited;
end;


function TConfigurationProvider.Settings(
  const Value: TMapperSettings): TConfigurationProvider;
begin
  FCfgMapper.Settings := Value;
  result := self;
end;

procedure TConfigurationProvider.Validate;
begin

end;

end.
