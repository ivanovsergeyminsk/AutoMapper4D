unit AutoMapper.MappingExpression;

interface

type
  TMapExpression<TSource, TDestination> = reference to procedure (const source: TSource; out dest: TDestination);

  TMapExpCollections = class
  strict private
    class var FMapExpProperties: TMapExpression<TObject, TObject>;
    class var FMapExpFields:     TMapExpression<TObject, TObject>;
    class var FMapExpPropsFields: TMapExpression<TObject, TObject>;

    class procedure _MapExpProperties(const source: TObject; out dest: TObject); static;
    class procedure _MapExpFields(const source: TObject; out dest: TObject); static;
    class procedure _MapExpPropsFields(const source: TObject; out dest: TObject); static;
  private
    class function GetMapExpProperties:   TMapExpression<TObject, TObject>; static;
    class function GetMapExpFields:       TMapExpression<TObject, TObject>; static;
    class function GetMapExpPropsFields:  TMapExpression<TObject, TObject>; static;
  public
    class property MapExpProperties:  TMapExpression<TObject, TObject> read GetMapExpProperties;
    class property MapExpFields:      TMapExpression<TObject, TObject> read GetMapExpFields;
    class property MapExpPropsFields: TMapExpression<TObject, TObject> read GetMapExpPropsFields;
  end;

implementation

uses
    System.Rtti
  , System.TypInfo
  , System.SysUtils
  ;

{ TMapExpCollections }

class function TMapExpCollections.GetMapExpFields: TMapExpression<TObject, TObject>;
begin
  if not Assigned(FMapExpFields) then
    FMapExpFields := _MapExpFields;

  result := FMapExpFields;
end;

class function TMapExpCollections.GetMapExpProperties: TMapExpression<TObject, TObject>;
begin
  if not Assigned(FMapExpProperties) then
    FMapExpProperties := _MapExpProperties;

  Result := FMapExpProperties;
end;

class function TMapExpCollections.GetMapExpPropsFields: TMapExpression<TObject, TObject>;
begin
  if not Assigned(FMapExpPropsFields) then
    FMapExpPropsFields := _MapExpPropsFields;

  Result := FMapExpPropsFields;
end;

class procedure TMapExpCollections._MapExpFields(const source: TObject; out dest: TObject);
var
  Ctx: TRttiContext;
  FDestRttiType, FSourceRttiType: TRttiType;

  FDestRttiField, FSourceRttiField: TRttiField;
  FBufValue, FSourceValue, FDestValue: TValue;
begin
  Ctx := TRttiContext.Create;
  FSourceRttiType := Ctx.GetType(source.ClassType);
  FDestRttiType   := Ctx.GetType(dest.ClassType);

  for FDestRttiField in FDestRttiType.GetFields do
    for FSourceRttiField in FSourceRttiType.GetFields do
      begin
        if (FDestRttiField.Visibility    in [mvPublic, mvPublished]) and
           (FSourceRttiField.Visibility  in [mvPublic, mvPublished]) and
           (FDestRttiField.Name.ToLower = FSourceRttiField.Name.ToLower)
        then
          begin
            FSourceValue  := FSourceRttiType.GetField(FSourceRttiField.Name).GetValue(source);
            FDestValue    := FDestRttiType.GetField(FDestRttiField.Name).GetValue(dest);

            if FSourceValue.TryCast(FDestValue.TypeInfo, FBufValue) then
              FDestRttiType.GetField(FDestRttiField.Name).SetValue(dest, FBufValue);
          end;
      end;

  Ctx.Free;
end;

class procedure TMapExpCollections._MapExpProperties(const source: TObject; out dest: TObject);
var
  Ctx: TRttiContext;
  FDestRttiType, FSourceRttiType: TRttiType;

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

class procedure TMapExpCollections._MapExpPropsFields(const source: TObject; out dest: TObject);
var
  Ctx: TRttiContext;
  FDestRttiType, FSourceRttiType, FPropType: TRttiType;

  FDestRttiField, FSourceRttiField: TRttiField;
  FDestRttiProp, FSourceRttiProp: TRttiProperty;

  FBufValue, FSourceValue, FDestValue: TValue;
begin
  Ctx := TRttiContext.Create;
  FSourceRttiType := Ctx.GetType(source.ClassType);
  FDestRttiType   := Ctx.GetType(dest.ClassType);

  for FDestRttiField in FDestRttiType.GetFields do
    for FSourceRttiField in FSourceRttiType.GetFields do
      begin
        // DestField <- SourceField
        if (FDestRttiField.Visibility    in [mvPublic, mvPublished]) and
           (FSourceRttiField.Visibility  in [mvPublic, mvPublished]) and
           (FDestRttiField.Name.ToLower.Replace('_','') = FSourceRttiField.Name.ToLower.Replace('_', ''))
        then
          begin
            FSourceValue  := FSourceRttiType.GetField(FSourceRttiField.Name).GetValue(source);
            FDestValue    := FDestRttiType.GetField(FDestRttiField.Name).GetValue(dest);

            if FSourceValue.TryCast(FDestValue.TypeInfo, FBufValue) then
              FDestRttiType.GetField(FDestRttiField.Name).SetValue(dest, FBufValue);
          end
         else
          // DestFiled <- SourceProp
          for FSourceRttiProp in FSourceRttiType.GetProperties do
            if (FDestRttiField.Visibility    in [mvPublic, mvPublished]) and
               (FSourceRttiProp.Visibility   in [mvPublic, mvPublished]) and
               (FDestRttiField.Name.ToLower.Replace('_','') = FSourceRttiProp.Name.ToLower.Replace('_',''))
            then
              begin
                FSourceValue  := FSourceRttiType.GetProperty(FSourceRttiProp.Name).GetValue(source);
                FDestValue    := FDestRttiType.GetField(FDestRttiField.Name).GetValue(dest);

                if FSourceValue.TryCast(FDestValue.TypeInfo, FBufValue) then
                  FDestRttiType.GetField(FDestRttiField.Name).SetValue(dest, FBufValue);
              end;
      end;

  for FDestRttiProp in FDestRttiType.GetProperties do
    for FSourceRttiProp in FSourceRttiType.GetProperties do
      begin
        // DestProp <- SourceProp
        if (FDestRttiProp.Visibility    in [mvPublic, mvPublished]) and
           (FSourceRttiProp.Visibility  in [mvPublic, mvPublished]) and
           (FDestRttiProp.Name.ToLower.Replace('_','') = FSourceRttiProp.Name.ToLower.Replace('_',''))
        then
          begin
            FSourceValue  := FSourceRttiType.GetProperty(FSourceRttiProp.Name).GetValue(source);
            FDestValue    := FDestRttiType.GetProperty(FDestRttiProp.Name).GetValue(dest);

            if FSourceValue.TryCast(FDestValue.TypeInfo, FBufValue) then
              FDestRttiType.GetProperty(FDestRttiProp.Name).SetValue(dest, FBufValue);
          end
        else
          // DestProp <- SourceField
          for FSourceRttiField in FSourceRttiType.GetFields do
            if (FDestRttiProp.Visibility    in [mvPublic, mvPublished]) and
               (FSourceRttiField.Visibility   in [mvPublic, mvPublished]) and
               (FDestRttiProp.Name.ToLower.Replace('_','') = FSourceRttiField.Name.ToLower.Replace('_',''))
            then
              begin
                FSourceValue  := FSourceRttiType.GetField(FSourceRttiField.Name).GetValue(source);
                FDestValue    := FDestRttiType.GetProperty(FDestRttiProp.Name).GetValue(dest);

                if FSourceValue.TryCast(FDestValue.TypeInfo, FBufValue) then
                  FDestRttiType.GetProperty(FDestRttiProp.Name).SetValue(dest, FBufValue);
              end;
      end;

  Ctx.Free;
end;

end.
