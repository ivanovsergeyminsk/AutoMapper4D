﻿unit AutoMapper.Mapper;

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
  TActionConfigurationProvider = reference to procedure(const Arg1: TConfigurationProvider);

  TMapper = class
  strict private
    class var FInstance: TMapper;
    class destructor Destroy;
  private
    ActionCfg: TActionConfigurationProvider;
    Configuration: TConfigurationProvider;
    MapEngine: TMapEngine;
    CfgMapper: TCfgMapper;
  public
    /// <summary>
    /// Execute a mapping from the source object to a new destination object.
    /// </summary>
    /// <typeparam name="TSource">Source type to use, regardless of the runtime type</typeparam>
    /// <typeparam name="TDestination">Destination type to create</typeparam>
    /// <param name="source">Source object to map from</param>
    /// <returns>Mapped destination object</returns>
    function Map<TSource; TDestination>(const source: TSource): TDestination; overload;
//    function Map<TSource; TDestination>(const source: TSource; const MapExpression: TMapExpression<TSource, TDestination>): TDestination; overload;

    class function GetInstance: TMapper;
    class procedure Configure(const cfg: TActionConfigurationProvider);
    class procedure Reset;
  end;

  var
    Mapper: TMapper;

implementation

function TMapper.Map<TSource, TDestination>(const source: TSource): TDestination;
begin
  Result :=  MapEngine.Map<TSource, TDestination>(source);
end;

//function TMapper.Map<TSource, TDestination>(const source: TSource;
//  const MapExpression: TMapExpression<TSource, TDestination>): TDestination;
//begin
//  Result :=  MapEngine.Map<TSource, TDestination>(source, MapExpression);
//end;

class procedure TMapper.Configure(const cfg: TActionConfigurationProvider);
begin
  if Assigned(FInstance.ActionCfg) or
     Assigned(FInstance.Configuration) or
     Assigned(FInstance.MapEngine) then
    raise TMapperConfigureException.Create(CS_MAPPER_CONFIGURATION_ALLREADY);

  FInstance.ActionCfg := cfg;

  FInstance.CfgMapper := TCfgMapper.Create;
  FInstance.Configuration := TConfigurationProvider.Create(FInstance.CfgMapper);
  FInstance.ActionCfg(FInstance.Configuration);

  FInstance.MapEngine := TMapEngine.Create(FInstance.CfgMapper);
end;

class procedure TMapper.Reset;
begin
  if Assigned(FInstance.MapEngine) then
    FInstance.MapEngine.Free;
  FInstance.MapEngine := nil;

  if Assigned(FInstance.Configuration) then
    FInstance.Configuration.Free;
  FInstance.Configuration := nil;

  if Assigned(FInstance.CfgMapper) then
    FInstance.CfgMapper.Free;
  FInstance.CfgMapper := nil;

  if Assigned(FInstance.ActionCfg) then
   FInstance. ActionCfg := nil;

end;

class function TMapper.GetInstance: TMapper;
begin
  If FInstance = nil Then
  begin
    FInstance := TMapper.Create;
  end;
  Result := FInstance;
end;

class destructor TMapper.Destroy;
begin
  Reset;
  if Assigned(TMapper.FInstance) then
    TMapper.FInstance.Free;
end;

initialization
  Mapper := TMapper.GetInstance;

end.
