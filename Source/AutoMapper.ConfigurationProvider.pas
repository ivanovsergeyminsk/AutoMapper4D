unit AutoMapper.ConfigurationProvider;

interface
uses
  AutoMapper.CfgMapper,
  Spring,
  AutoMapper.MappingExpression;

type
  TConfigurationProvider = class
  protected
    FCfgMapper: TCfgMapper;
  public
    function CreateMap<TSource: Class; TDestination: Class>(const MappingExpression: TMapExpression<TSource, TDestination>): TConfigurationProvider; overload;
    function CreateMap<TSource: Class; TDestination: Class>(): TConfigurationProvider; overload;
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

procedure TConfigurationProvider.Validate;
begin

end;

end.
