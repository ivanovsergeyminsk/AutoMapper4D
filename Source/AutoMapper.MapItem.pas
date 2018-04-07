unit AutoMapper.MapItem;

interface
uses
  AutoMapper.ClassPair,
  Spring;

type

  TMapItem = class(TObject)
  private
    FClassPair: TClassPair;
    FExp: TValue;
    function GetClassPair: TClassPair;
  public
    property ClassPair: TClassPair read GetClassPair;
    property Exp: TValue read FExp;

    constructor Create(const AClassPair:TClassPair; const AExp: TValue); overload;
  end;

implementation

{ TMapItem }

constructor TMapItem.Create(const AClassPair: TClassPair;
  const AExp: TValue);
begin
  FClassPair := AClassPair;
  FExp := AExp;
end;

function TMapItem.GetClassPair: TClassPair;
begin
  Result := FClassPair;
end;

end.
