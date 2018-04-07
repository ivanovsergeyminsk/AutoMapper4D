unit AutoMapper.ConfigurationProvider;

interface
uses
  AutoMapper.CfgMapper,
  Spring;
type
  TConfigurationProvider = class
  protected
    FCfgMapper: TCfgMapper;
    constructor Create(const CfgMapper: TCfgMapper); virtual;
    destructor Destroy; override;
  public
    function CreateMap<TSource: Class; TDestination: Class>(const MappingExpression: TAction<TSource, TDestination>): TConfigurationProvider; overload;

    procedure Validate;
  end;

  TConfigurationProvderRunTime = class(TConfigurationProvider)
  public
    constructor Create(const CfgMapper: TCfgMapper); overload;
  end;

implementation

{ TConfigurationProvider }

constructor TConfigurationProvider.Create(const CfgMapper: TCfgMapper);
begin
  FCfgMapper := CfgMapper;
end;

function TConfigurationProvider.CreateMap<TSource, TDestination>(
  const MappingExpression: TAction<TSource, TDestination>): TConfigurationProvider;
begin
  FCfgMapper.CreateMap<TSource, TDestination>(MappingExpression);
  result := Self;
end;

destructor TConfigurationProvider.Destroy;
begin
  FCfgMapper := nil;

  inherited;
end;

procedure TConfigurationProvider.Validate;
begin

end;

{ TConfigurationProvderRunTime }

constructor TConfigurationProvderRunTime.Create(const CfgMapper: TCfgMapper);
begin
  inherited Create(CfgMapper);
end;

end.
