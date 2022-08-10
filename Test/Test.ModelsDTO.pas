unit Test.ModelsDTO;

interface
uses
  Spring;

type
  TAddressRecord = record
    Street: string;
    NumHouse: integer;
  end;

  TNewAddressRecord = record
    Street: string;
    Num_House: integer;
  end;

  TAddressDTO = class
  private
    FStreet: string;
    FNumHouse: integer;
    procedure SetNumHouse(const Value: integer);
    procedure SetStreet(const Value: string);
  public
    property Street: string read FStreet write SetStreet;
    property NumHouse: integer read FNumHouse write SetNumHouse;
  end;

  {$M+}
  TPersonDTO = class
  private
    FAge: Nullable<integer>;
    FLastName: string;
    FMiddleName: Nullable<string>;
    FAddress: TAddressDTO;
    FFirstName: string;
    FStatus: Nullable<integer>;
    procedure SetAddress(const Value: TAddressDTO);
    procedure SetAge(const Value: Nullable<integer>);
    procedure SetFirstName(const Value: string);
    procedure SetLastName(const Value: string);
    procedure SetMiddleName(const Value: Nullable<string>);
    procedure SetStatus(const Value: Nullable<integer>);
  public
    Post: string;
  published
    property LastName: string read FLastName write SetLastName;
    property FirstName: string read FFirstName write SetFirstName;
    property MiddleName: Nullable<string> read FMiddleName write SetMiddleName;
    property Age: Nullable<integer> read FAge write SetAge;
    property Address: TAddressDTO read FAddress write SetAddress;
    property Status: Nullable<integer> read FStatus write SetStatus;
  end;

  TUserDTO = class
  private
    FFullName: string;
    FAddress: string;
    procedure SetAddress(const Value: string);
    procedure SetFullName(const Value: string);
  public
    property FullName: string read FFullName write SetFullName;
    property Address: string read FAddress write SetAddress;
  end;

  TSimplePersonDTO = class
  private
    FMiddle_Name: string;
    FFirst_Name: string;
    FLast_Name: string;
    FStatus: Nullable<integer>;
    procedure SetFirst_Name(const Value: string);
    procedure SetLast_Name(const Value: string);
    procedure SetMiddle_Name(const Value: string);
    procedure SetStatus(const Value: Nullable<integer>);
  public
    Post: string;
  published
    property Last_Name: string read FLast_Name write SetLast_Name;
    property First_Name: string read FFirst_Name write SetFirst_Name;
    property Middle_Name: string read FMiddle_Name write SetMiddle_Name;
    property Status: Nullable<integer> read FStatus write  SetStatus;
  end;

implementation

{ TUserDTO }

procedure TUserDTO.SetAddress(const Value: string);
begin
  FAddress := Value;
end;

procedure TUserDTO.SetFullName(const Value: string);
begin
  FFullName := Value;
end;

{ TPersonDTO }

procedure TPersonDTO.SetAddress(const Value: TAddressDTO);
begin
  FAddress := Value;
end;

procedure TPersonDTO.SetAge(const Value: Nullable<integer>);
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

procedure TPersonDTO.SetStatus(const Value: Nullable<integer>);
begin
  FStatus := Value;
end;

{ TAddressDTO }

procedure TAddressDTO.SetNumHouse(const Value: integer);
begin
  FNumHouse := Value;
end;

procedure TAddressDTO.SetStreet(const Value: string);
begin
  FStreet := Value;
end;

{ TSimplePersonDTO }

procedure TSimplePersonDTO.SetFirst_Name(const Value: string);
begin
  FFirst_Name := Value;
end;

procedure TSimplePersonDTO.SetLast_Name(const Value: string);
begin
  FLast_Name := Value;
end;

procedure TSimplePersonDTO.SetMiddle_Name(const Value: string);
begin
  FMiddle_Name := Value;
end;

procedure TSimplePersonDTO.SetStatus(const Value: Nullable<integer>);
begin
  FStatus := Value;
end;

end.
