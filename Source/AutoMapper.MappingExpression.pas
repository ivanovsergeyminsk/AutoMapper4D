unit AutoMapper.MappingExpression;

interface

uses
  Spring;

type
  TMapExpCollections = class
  strict private
    class var FMapExpProperties: TAction<TObject, TObject>;

    class procedure _MapExpProperties(const source: TObject; const dest: TObject); static;
  private
    class function GetMapExpProperties: TAction<TObject, TObject>; static;
  public
    class property MapExpProperties: TAction<TObject, TObject> read GetMapExpProperties;
  end;

implementation

uses
  System.Rtti, System.TypInfo, System.SysUtils;

{ TMapExpCollections }

class function TMapExpCollections.GetMapExpProperties: TAction<TObject, TObject>;
begin
  if not Assigned(FMapExpProperties) then
    FMapExpProperties := _MapExpProperties;

  Result := FMapExpProperties;
end;

class procedure TMapExpCollections._MapExpProperties(const source: TObject; const dest: TObject);
var
  Ctx: TRttiContext;
  FDestRttiType, FSourceRttiType, FPropType: TRttiType;

  FDestRttiProp, FSourceRttiProp: TRttiProperty;
  FBufValue, FSourceValue, FDestValue: TValue;
begin
  Ctx := TRttiContext.Create;
  FSourceRttiType := Ctx.GetType(source.ClassType);
  FDestRttiType   := Ctx.GetType(dest.ClassType);

  for FDestRttiProp in FDestRttiType.GetProperties do
    for FSourceRttiProp in FSourceRttiType.GetProperties do
      begin
        if (FDestRttiProp.Visibility    in [mvPublic, mvPublished]) and
           (FSourceRttiProp.Visibility  in [mvPublic, mvPublished]) and
           (FDestRttiProp.Name.ToLower = FSourceRttiProp.Name.ToLower)
        then
          begin
            FSourceValue  := FSourceRttiType.GetProperty(FSourceRttiProp.Name).GetValue(source);
            FDestValue    := FDestRttiType.GetProperty(FDestRttiProp.Name).GetValue(dest);

            if FSourceValue.TryCast(FDestValue.TypeInfo, FBufValue) then
              FDestRttiType.GetProperty(FDestRttiProp.Name).SetValue(dest, FBufValue);
          end;
      end;

  Ctx.Free;
end;

end.
