unit AutoMapper.Mapper;

interface
uses
    AutoMapper.ConfigurationProvider
  , AutoMapper.MapEngine
  , AutoMapper.Exceptions
  , AutoMapper.CfgMapper
  , AutoMapper.MappingExpression
  , System.SysUtils
  ;

type
  TConfigurationProvider = AutoMapper.ConfigurationProvider.TConfigurationProvider;
  TMapperSetting  = AutoMapper.CfgMapper.TMapperSetting;
  TMapperSettings = AutoMapper.CfgMapper.TMapperSettings;


  TActionConfigurationProvider = reference to procedure(const Arg1: TConfigurationProvider);

  TMapper = class
  strict private
    class var FInstance: TMapper;
    class destructor Destroy;
  private
    FActionCfg: TActionConfigurationProvider;
    FConfiguration: TConfigurationProvider;
    FMapEngine: TMapEngine;
    FCfgMapper: TCfgMapper;
  public
    /// <summary>
    /// Execute a mapping from the source object/record to a new destination object/record.
    /// </summary>
    /// <typeparam name="TSource">Source type to use, regardless of the runtime type.</typeparam>
    /// <typeparam name="TDestination">Destination type to create.</typeparam>
    /// <param name="source">Source object/record to map from.</param>
    /// <returns>Mapped destination object/record.</returns>
    function Map<TSource; TDestination>(const source: TSource): TDestination; overload;
    /// <summary>
    /// Execute a mapping from the source object/record to a new destination object/record using a custom expression.
    /// </summary>
    /// <typeparam name="TSource">Source type to use, regardless of the runtime type.</typeparam>
    /// <typeparam name="TDestination">Destination type to create.</typeparam>
    /// <param name="source">Source object/record to map from.</param>
    /// <param name="MapExpression">Custom expression for mapping.</param>
    /// <returns>Mapped destination object/record.</returns>
    function Map<TSource; TDestination>(const source: TSource; const MapExpression: TMapExpression<TSource, TDestination>): TDestination; overload;
    /// <summary>
    /// Execute a mapping from the source object to a new destination object/record without specifying the source type.
    /// </summary>
    /// <typeparam name="TDestination">Destination type to create.</typeparam>
    /// <param name="source">Source object to map from.</param>
    /// <returns>Mapped destination object/record.</returns>
    /// <remarks>
    /// To use this method, you must explicitly configure the source-destination mapping.<br/>
    /// The source can only be a class.
    /// </remarks>
    function Map<TDestination>(const source: TObject): TDestination; overload;
    /// <summary>
    /// Execute a mapping from the source object to a new destination object/record without specifying the source type using a custom expression.
    /// </summary>
    /// <typeparam name="TDestination">Destination type to create.</typeparam>
    /// <param name="source">Source object to map from.</param>
    /// <returns>Mapped destination object/record.</returns>
    /// <remarks>
    /// To use this method, you must explicitly configure the source-destination mapping.<br/>
    /// The source can only be a class.
    /// </remarks>
    function Map<TDestination>(const source: TObject; const MapExpression: TMapExpression<TObject, TDestination>): TDestination; overload;

    ///<summary>Instance of Mapper</summary>
    class function GetInstance: TMapper;
    /// <summary>Mapper Configuration.</summary>
    /// <param name="cfg">Mapper Configuration Provider.</param>
    /// <remarks>
    /// Here you can specify automatic mapping,<br/>
    /// explicitly create a source-destination map pair<br/>
    /// and specify an expression for them.
    /// </remarks>
    class procedure Configure(const cfg: TActionConfigurationProvider);
    ///<summary>Number of configured source-destination pairs.</summary>
    class function CountMapPair: integer;
    /// <summary>Reset the mapper</summary>
    class procedure Reset;
  end;

  var
    ///<summary>Instance of Mapper</summary>
    Mapper: TMapper;

implementation

function TMapper.Map<TDestination>(const source: TObject): TDestination;
begin
  Result := FMapEngine.Map<TDestination>(source);
end;

function TMapper.Map<TSource, TDestination>(const source: TSource): TDestination;
begin
  Result :=  FMapEngine.Map<TSource, TDestination>(source);
end;

class procedure TMapper.Configure(const cfg: TActionConfigurationProvider);
begin
  if Assigned(FInstance.FActionCfg) or
     Assigned(FInstance.FConfiguration) or
     Assigned(FInstance.FMapEngine) then
    raise TMapperConfigureException.Create(CS_MAPPER_CONFIGURATION_ALLREADY);

  FInstance.FActionCfg      := cfg;
  FInstance.FCfgMapper      := TCfgMapper.Create;
  FInstance.FConfiguration  := TConfigurationProvider.Create(FInstance.FCfgMapper);
  FInstance.FActionCfg(FInstance.FConfiguration);

  FInstance.FMapEngine := TMapEngine.Create(FInstance.FCfgMapper);
end;

class procedure TMapper.Reset;
begin
  if Assigned(FInstance.FMapEngine) then
    FInstance.FMapEngine.Free;
  FInstance.FMapEngine := nil;

  if Assigned(FInstance.FConfiguration) then
    FInstance.FConfiguration.Free;
  FInstance.FConfiguration := nil;

  if Assigned(FInstance.FCfgMapper) then
    FInstance.FCfgMapper.Free;
  FInstance.FCfgMapper := nil;

  if Assigned(FInstance.FActionCfg) then
   FInstance. FActionCfg := nil;

end;

class function TMapper.GetInstance: TMapper;
begin
  If FInstance = nil Then
  begin
    FInstance := TMapper.Create;
  end;
  Result := FInstance;
end;

class function TMapper.CountMapPair: integer;
begin
  if (not Assigned(FInstance.FCfgMapper)) then
    exit(0);

  result := FInstance.FCfgMapper.Count;
end;

class destructor TMapper.Destroy;
begin
  Reset;
  if Assigned(TMapper.FInstance) then
    TMapper.FInstance.Free;
end;

function TMapper.Map<TDestination>(const source: TObject;
  const MapExpression: TMapExpression<TObject, TDestination>): TDestination;
begin
  result := FMapEngine.Map<TDestination>(source, MapExpression);
end;

function TMapper.Map<TSource, TDestination>(const source: TSource;
  const MapExpression: TMapExpression<TSource, TDestination>): TDestination;
begin
  result := FMapEngine.Map<TSource, TDestination>(source, MapExpression);
end;

initialization
  Mapper := TMapper.GetInstance;

end.
