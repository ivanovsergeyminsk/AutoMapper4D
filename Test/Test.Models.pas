unit Test.Models;

interface
uses
  Spring,
  System.Variants;
type
  TPerson = class
  private
    FLastName: string;
    FFirstName: string;
    FMiddleName: Nullable<string>;
    FAge: Nullable<integer>;

  public
    property LastName: string read FLastName;
    property FirstName: string read FFirstName;
    property MiddleName: Nullable<string> read FMiddleName;
    property Age: Nullable<integer> read FAge;

    constructor Create(ALastName, AFirstName: string; AMiddleName: Nullable<string>; AAge: Nullable<integer>); overload;
  end;

  TPersonDTO = class
  private
    FAge: integer;
    FLastName: string;
    FMiddleName: Nullable<string>;
    FFirstName: string;
    procedure SetAge(const Value: integer);
    procedure SetFirstName(const Value: string);
    procedure SetLastName(const Value: string);
    procedure SetMiddleName(const Value: Nullable<string>);
  public
    property LastName: string read FLastName write SetLastName;
    property FirstName: string read FFirstName write SetFirstName;
    property MiddleName: Nullable<string> read FMiddleName write SetMiddleName;
    property Age: integer read FAge write SetAge;
  end;

  TUserDTO = class
  private
    FAge: integer;
    FFullName: string;
    procedure SetAge(const Value: integer);
    procedure SetFullName(const Value: string);
  published
    property FullName: string read FFullName write SetFullName;
    property Age: integer read FAge write SetAge;
  end;


implementation

{ TPerson }

constructor TPerson.Create(ALastName, AFirstName: string;
  AMiddleName: Nullable<string>; AAge: Nullable<integer>);
begin
  FLastName   := ALastName;
  FFirstName  := AFirstName;
  FMiddleName := AMiddleName;
  FAge        := AAge;
end;

{ TPersonDTO }

procedure TPersonDTO.SetAge(const Value: integer);
begin
  FAge := Value;
end;

procedure TPersonDTO.SetFirstName(const Value: string);
begin
  FFirstName := Value;
end;

procedure TPersonDTO.SetLastName(const Value: string);
begin
  FLastName := Value;
end;

procedure TPersonDTO.SetMiddleName(const Value: Nullable<string>);
begin
  FMiddleName := Value;
end;

{ TUserDTO }

procedure TUserDTO.SetAge(const Value: integer);
begin
  FAge := Value;
end;

procedure TUserDTO.SetFullName(const Value: string);
begin
  FFullName := Value;
end;

end.
