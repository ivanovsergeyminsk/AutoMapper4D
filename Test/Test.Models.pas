unit Test.Models;

interface
uses
  Spring,
  System.Variants;
type
  TAddress = class
    private
      FStreet: string;
      FNumHouse: integer;
    public
    property Street: string read FStreet;
    property NumHouse: integer read FNumHouse;

    constructor Create(const AStreet: string; const ANumHouse: integer);
  end;

  {$M+}
  TPerson = class
  private
    FLastName: string;
    FFirstName: string;
    FMiddleName: Nullable<string>;
    FAge: Nullable<integer>;
    FAddress: TAddress;
    FPost: string;
  public
    Status: Nullable<integer>;
  published
    property LastName: string read FLastName;
    property FirstName: string read FFirstName;
    property MiddleName: Nullable<string> read FMiddleName;
    property Age: Nullable<integer> read FAge;
    property Address: TAddress read FAddress;
    property Post: string read FPost;
    constructor Create(ALastName, AFirstName: string; AMiddleName: Nullable<string>; AAge: Nullable<integer>; AAddress: TAddress; APost: string); overload;
  end;



implementation

{ TPerson }

constructor TPerson.Create(ALastName, AFirstName: string;
  AMiddleName: Nullable<string>; AAge: Nullable<integer>; AAddress: TAddress; APost: string);
begin
  FLastName   := ALastName;
  FFirstName  := AFirstName;
  FMiddleName := AMiddleName;
  FAge        := AAge;
  FAddress    := AAddress;
  FPost       := APost;
end;

{ TAddress }

constructor TAddress.Create(const AStreet: string; const ANumHouse: integer);
begin
  FStreet := AStreet;
  FNumHouse := ANumHouse;
end;

end.
