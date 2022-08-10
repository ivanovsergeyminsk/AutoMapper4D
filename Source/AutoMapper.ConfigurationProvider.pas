unit AutoMapper.ConfigurationProvider;

interface
uses
    AutoMapper.CfgMapper
  , AutoMapper.MappingExpression
  ;

type
  /// <summary>Mapper Configuration Provider.</summary>
  TConfigurationProvider = class
  private
    FCfgMapper: TCfgMapper;
  public
    /// <summary>Set Mapper settings.</summary>
    /// <param name="Value">Setting Flags.</param>
    function Settings(const Value: TMapperSettings): TConfigurationProvider;
    /// <summary>Create a map for the source-destination pair by specifying the expression.</summary>
    /// <typeparam name="TSource">Source type to use, regardless of the runtime type.</typeparam>
    /// <typeparam name="TDestination">Destination type to create.</typeparam>
    /// <param name="MappingExpression">Expression for mapping.</param>
    function CreateMap<TSource; TDestination>(const MappingExpression: TMapExpression<TSource, TDestination>): TConfigurationProvider; overload;
    /// <summary>Create a map for the source-destination pair using default expressions.</summary>
    /// <typeparam name="TSource">Source type to use, regardless of the runtime type.</typeparam>
    /// <typeparam name="TDestination">Destination type to create.</typeparam>
    function CreateMap<TSource; TDestination>(): TConfigurationProvider; overload;
    /// <summary>Not implemented</summary>
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
