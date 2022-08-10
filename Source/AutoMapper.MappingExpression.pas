unit AutoMapper.MappingExpression;

interface

uses
    System.Rtti
  ;

type
  TMapExpression<TSource, TDestination> = reference to procedure (const source: TSource; out dest: TDestination);

  TExpressionType = (None, ObjectToObject, ObjectToRecord, RecordToObject, RecordToRecord);

  TMapExpCollections = class
  public
    class procedure MapExpObjectToObject<TSource, TDestination>(const source: TSource; out dest: TDestination); static;
    class procedure MapExpObjectToRecord<TSource, TDestination>(const source: TSource; out dest: TDestination); static;
    class procedure MapExpRecordToObject<TSource, TDestination>(const source: TSource; out dest: TDestination); static;
    class procedure MapExpRecordToRecord<TSource, TDestination>(const source: TSource; out dest: TDestination); static;

    class function GetExpressionType<TSource, TDestination>: TExpressionType; static;
  end;

implementation

uses
    System.TypInfo
  , System.SysUtils
  ;

{ TMapExpCollections }

class function TMapExpCollections.GetExpressionType<TSource, TDestination>: TExpressionType;
var
  Ctx: TRttiContext;
  SourceType, DestType: TRttiType;
begin
  Ctx := TRttiContext.Create;
  SourceType := Ctx.GetType(TypeInfo(TSource));
  DestType   := Ctx.GetType(TypeInfo(TDestination));

  if SourceType.IsInstance and DestType.IsInstance then
    Exit(TExpressionType.ObjectToObject);

  if SourceType.IsInstance and DestType.IsRecord then
    Exit(TExpressionType.ObjectToRecord);

  if SourceType.IsRecord and DestType.IsInstance then
    Exit(TExpressionType.RecordToObject);

  if SourceType.IsRecord and DestType.IsRecord then
    Exit(TExpressionType.RecordToRecord);

  result := TExpressionType.None;
end;

class procedure TMapExpCollections.MapExpObjectToObject<TSource, TDestination>(
  const source: TSource; out dest: TDestination);
var
  LSource : TObject absolute source;
  LDest   : TObject absolute dest;

  Ctx: TRttiContext;
  DestRttiType, SourceRttiType, PropType: TRttiType;

  DestRttiField, SourceRttiField: TRttiField;
  DestRttiProp, SourceRttiProp: TRttiProperty;
  BufValue, SourceValue, DestValue: TValue;

  isFound: boolean;
begin
  Ctx := TRttiContext.Create;
  SourceRttiType := Ctx.GetType(TypeInfo(TSource));
  DestRttiType   := Ctx.GetType(TypeInfo(TDestination));

  for DestRttiField in DestRttiType.GetFields do
  begin
    // DestField <- SourceField
    isFound := false;
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_', ''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(LSource);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(LDest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(LDest, BufValue);
          isFound := true;
          break;
        end;
      end
    end;

    if isFound then
      continue;

    // DestFiled <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility   in [mvPublic, mvPublished]) and
         (SourceRttiProp.IsReadable) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(LSource);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(LDest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(LDest, BufValue);
          break;
        end;
      end;
    end;
  end;

  for DestRttiProp in DestRttiType.GetProperties do
  begin
    isFound := false;
   // DestProp <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and (SourceRttiProp.IsReadable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
        begin
          SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(LSource);
          DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(LDest);

          if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
          begin
            DestRttiType.GetProperty(DestRttiProp.Name).SetValue(LDest, BufValue);
            isFound := true;
            break;
          end;
        end
    end;

    if isFound then
      Continue;

    // DestProp <- SourceField
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(LSource);
        DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(LDest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetProperty(DestRttiProp.Name).SetValue(LDest, BufValue);
          break;
        end;
      end;
    end;
  end;

  Ctx.Free;
end;

class procedure TMapExpCollections.MapExpObjectToRecord<TSource, TDestination>(
  const source: TSource; out dest: TDestination);
var
  LSource: TObject absolute source;

  Ctx: TRttiContext;
  DestRttiType, SourceRttiType, PropType: TRttiType;

  DestRttiField, SourceRttiField: TRttiField;
  DestRttiProp, SourceRttiProp: TRttiProperty;
  BufValue, SourceValue, DestValue: TValue;

  isFound: boolean;
begin
  Ctx := TRttiContext.Create;
  SourceRttiType := Ctx.GetType(TypeInfo(TSource));
  DestRttiType   := Ctx.GetType(TypeInfo(TDestination));

  for DestRttiField in DestRttiType.GetFields do
  begin
    // DestField <- SourceField
    isFound := false;
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_', ''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(LSource);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(@dest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(@dest, BufValue);
          isFound := true;
          break;
        end;
      end
    end;

    if isFound then
      continue;

    // DestFiled <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility   in [mvPublic, mvPublished]) and
         (SourceRttiProp.IsReadable) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(LSource);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(@dest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(@dest, BufValue);
          break;
        end;
      end;
    end;
  end;

  for DestRttiProp in DestRttiType.GetProperties do
  begin
    isFound := false;
   // DestProp <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and (SourceRttiProp.IsReadable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
        begin
          SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(LSource);
          DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(@dest);

          if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
          begin
            DestRttiType.GetProperty(DestRttiProp.Name).SetValue(@dest, BufValue);
            isFound := true;
            break;
          end;
        end
    end;

    if isFound then
      Continue;

    // DestProp <- SourceField
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(LSource);
        DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(@dest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetProperty(DestRttiProp.Name).SetValue(@dest, BufValue);
          break;
        end;
      end;
    end;
  end;

  Ctx.Free;
end;

class procedure TMapExpCollections.MapExpRecordToObject<TSource, TDestination>(
  const source: TSource; out dest: TDestination);
var
  LDest: TObject absolute dest;

  Ctx: TRttiContext;
  DestRttiType, SourceRttiType, PropType: TRttiType;

  DestRttiField, SourceRttiField: TRttiField;
  DestRttiProp, SourceRttiProp: TRttiProperty;
  BufValue, SourceValue, DestValue: TValue;

  isFound: boolean;
begin
  Ctx := TRttiContext.Create;
  SourceRttiType := Ctx.GetType(TypeInfo(TSource));
  DestRttiType   := Ctx.GetType(TypeInfo(TDestination));

  for DestRttiField in DestRttiType.GetFields do
  begin
    // DestField <- SourceField
    isFound := false;
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_', ''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(@source);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(LDest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(LDest, BufValue);
          isFound := true;
          break;
        end;
      end
    end;

    if isFound then
      continue;

    // DestFiled <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility   in [mvPublic, mvPublished]) and
         (SourceRttiProp.IsReadable) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(@source);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(LDest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(LDest, BufValue);
          break;
        end;
      end;
    end;
  end;

  for DestRttiProp in DestRttiType.GetProperties do
  begin
    isFound := false;
   // DestProp <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and (SourceRttiProp.IsReadable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
        begin
          SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(@source);
          DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(LDest);

          if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
          begin
            DestRttiType.GetProperty(DestRttiProp.Name).SetValue(LDest, BufValue);
            isFound := true;
            break;
          end;
        end
    end;

    if isFound then
      Continue;

    // DestProp <- SourceField
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(@source);
        DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(LDest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetProperty(DestRttiProp.Name).SetValue(LDest, BufValue);
          break;
        end;
      end;
    end;
  end;

  Ctx.Free;
end;


class procedure TMapExpCollections.MapExpRecordToRecord<TSource, TDestination>(
  const source: TSource; out dest: TDestination);
var
  Ctx: TRttiContext;
  DestRttiType, SourceRttiType, PropType: TRttiType;

  DestRttiField, SourceRttiField: TRttiField;
  DestRttiProp, SourceRttiProp: TRttiProperty;
  BufValue, SourceValue, DestValue: TValue;

  isFound: boolean;
begin
  Ctx := TRttiContext.Create;
  SourceRttiType := Ctx.GetType(TypeInfo(TSource));
  DestRttiType   := Ctx.GetType(TypeInfo(TDestination));

  for DestRttiField in DestRttiType.GetFields do
  begin
    // DestField <- SourceField
    isFound := false;
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_', ''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(@source);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(@dest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(@dest, BufValue);
          isFound := true;
          break;
        end;
      end
    end;

    if isFound then
      continue;

    // DestFiled <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiField.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility   in [mvPublic, mvPublished]) and
         (SourceRttiProp.IsReadable) and
         (DestRttiField.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(@source);
        DestValue    := DestRttiType.GetField(DestRttiField.Name).GetValue(@dest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetField(DestRttiField.Name).SetValue(@dest, BufValue);
          break;
        end;
      end;
    end;
  end;

  for DestRttiProp in DestRttiType.GetProperties do
  begin
    isFound := false;
   // DestProp <- SourceProp
    for SourceRttiProp in SourceRttiType.GetProperties do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiProp.Visibility  in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and (SourceRttiProp.IsReadable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiProp.Name.ToLower.Replace('_',''))
      then
        begin
          SourceValue  := SourceRttiType.GetProperty(SourceRttiProp.Name).GetValue(@source);
          DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(@dest);

          if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
          begin
            DestRttiType.GetProperty(DestRttiProp.Name).SetValue(@dest, BufValue);
            isFound := true;
            break;
          end;
        end
    end;

    if isFound then
      Continue;

    // DestProp <- SourceField
    for SourceRttiField in SourceRttiType.GetFields do
    begin
      if (DestRttiProp.Visibility    in [mvPublic, mvPublished]) and
         (SourceRttiField.Visibility in [mvPublic, mvPublished]) and
         (DestRttiProp.IsWritable) and
         (DestRttiProp.Name.ToLower.Replace('_','') = SourceRttiField.Name.ToLower.Replace('_',''))
      then
      begin
        SourceValue  := SourceRttiType.GetField(SourceRttiField.Name).GetValue(@source);
        DestValue    := DestRttiType.GetProperty(DestRttiProp.Name).GetValue(@dest);

        if SourceValue.TryCast(DestValue.TypeInfo, BufValue) then
        begin
          DestRttiType.GetProperty(DestRttiProp.Name).SetValue(@dest, BufValue);
          break;
        end;
      end;
    end;
  end;

  Ctx.Free;
end;

end.
