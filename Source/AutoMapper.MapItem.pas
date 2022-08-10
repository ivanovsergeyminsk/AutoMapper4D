unit AutoMapper.MapItem;

interface
uses
    AutoMapper.TypePair
  , System.Rtti
  ;

type
  TMap = class
  private
    FTypePair: TTypePair;
    FExp: TValue;
  public
    property TypePair: TTypePair read FTypePair;
    property Exp: TValue read FExp;

    constructor Create(const ATypePair: TTypePair; const AExp: TValue);
  end;

implementation

{ TMap }

constructor TMap.Create(const ATypePair: TTypePair; const AExp: TValue);
begin
  FTypePair := ATypePair;
  FExp      := AExp;
end;

end.
