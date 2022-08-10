unit Test.Automapper;

interface

uses
    DUnitX.TestFramework
  , AutoMapper.Mapper
  , Test.Models
  , Test.ModelsDTO
  ;

type
  [TestFixture]
  TestTMapper = class
  strict private
    const
      CS_LAST_NAME          = 'Иванов';
      CS_FIRST_NAME         = 'Сергей';
      CS_MIDDLE_NAME        = 'Николаеивч';
      CS_AGE                =  26;
      CS_STREET             = 'Гагарина';
      CS_NUM_HOUSE          =  34;
      CS_FULL_NAME          = CS_LAST_NAME+' '+CS_FIRST_NAME+' '+CS_MIDDLE_NAME+', возраст: 26';
      CS_FULL_ADDRESS       = 'ул. '+CS_STREET+' д. 34';
      CS_OVERRIDE_FULL_NAME = 'Петрович Петр Игнатьевич';
      СS_OVERRIDE_ADDRESS   = 'ул. Некрасова';
      CS_POST               = 'Генеральный менеджер по клинигу';
      CS_STATUS             = 12;
  strict private
    FAddress    : TAddress;
    FPerson     : TPerson;

    procedure Configure;
    procedure ConfigureWithRecords;
    procedure ConfigureWithAutomap;
  private
    procedure CreateAddressDTO(var FAddressDTO: TAddressDTO);
    procedure CreatePersonDTO(FAddressDTO: TAddressDTO; var FPersonDTO: TPersonDTO);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestConfigure;

    [Test]
    procedure TestMap_ObjectToObject;
    [Test]
    procedure TestMap_ObjectToRecord;
    [Test]
    procedure TestMap_RecordToObject;
    [Test]
    procedure TestMap_RecordToRecord;
    [Test]
    procedure TestMap_Automap;

    [Test]
    procedure TestMap_DefaultExpression;
    [Test]
    procedure TestMap_CustomExpression;
    [Test]
    procedure TestMap_WithConstructor;
    [Test]
    procedure TestMap_WithNestedObject;
    [Test]
    procedure TestMap_WithConstructorAndNestedObject;
    [Test]
    procedure TestMap_WithOverrideExpression;
  end;

implementation

uses
    System.SysUtils
  ;


procedure TestTMapper.Configure;
begin
  Mapper.Reset;
  Mapper.Configure(procedure (const cfg: TConfigurationProvider)
                  begin
                    cfg
                        //Default expression
                       .CreateMap<TPerson, TSimplePersonDTO>()
                        //Custom Expression
                       .CreateMap<TPerson, TUserDTO>(procedure (const FPerson: TPerson; out FUserDTO: TUserDTO)
                                                        begin
                                                          FUserDTO.FullName := FPerson.LastName    +' '+
                                                                               FPerson.FirstName   +' '+
                                                                               FPerson.MiddleName  +', возраст: '+
                                                                               FPerson.Age.ToString;
                                                          FUserDTO.Address  := 'ул. '+ FPerson.Address.Street
                                                                              +' д. '+ FPerson.Address.NumHouse.ToString;
                                                        end
                                                      )
                        //With constructor
                       .CreateMap<TAddressDTO, TAddress>(procedure (const FAddressDTO: TAddressDTO; out FAddress: TAddress)
                                                          begin
                                                            FAddress := TAddress.Create(FAddressDTO.Street,
                                                                                        FAddressDTO.NumHouse);
                                                          end
                                                        )
                        //With nested object
                       .CreateMap<TPerson, TPersonDTO>(procedure (const s: TPerson; out d: TPersonDTO)
                                                        begin
                                                          d.LastName    := s.LastName;
                                                          d.FirstName   := s.FirstName;
                                                          d.MiddleName  := s.MiddleName;
                                                          d.Age         := s.Age;
                                                          d.Address     := mapper.Map<TAddressDTO>(s.Address);
                                                          d.Post        := s.Post;
                                                        end
                                                       )
                        //With constructor and nested object
                       .CreateMap<TPersonDTO, TPerson>(procedure (const FPersonDTO: TPersonDTO; out FPerson: TPerson)
                                                        begin
                                                          FPerson := TPerson.Create(FPersonDTO.LastName,
                                                                                    FPersonDTO.FirstName,
                                                                                    FPersonDTO.MiddleName,
                                                                                    FPersonDTO.Age,
                                                                                    mapper.Map<TAddress>(FPersonDTO.Address),
                                                                                    FPersonDTO.Post);
                                                        end
                                                      )
                       .CreateMap<TAddress, TAddressDTO>

                  end);
end;

procedure TestTMapper.ConfigureWithAutomap;
begin
  Mapper.Reset;
  Mapper.Configure(procedure (const cfg: TConfigurationProvider)
                  begin
                    cfg
                       .Settings([TMapperSetting.Automap])
                  end);
end;

procedure TestTMapper.ConfigureWithRecords;
begin
  Mapper.Reset;
  Mapper.Configure(procedure (const cfg: TConfigurationProvider)
                  begin
                    cfg
                       .CreateMap<TAddress, TAddressRecord>()
                       .CreateMap<TAddressRecord, TAddressWriteble>()
                       .CreateMap<TAddressRecord, TNewAddressRecord>()
                       .CreateMap<TAddress, TAddressDTO>()

                  end);
end;

procedure TestTMapper.CreateAddressDTO(var FAddressDTO: TAddressDTO);
begin
  FAddressDTO := TAddressDTO.Create;
  FAddressDTO.Street   := CS_STREET;
  FAddressDTO.NumHouse := CS_NUM_HOUSE;
end;

procedure TestTMapper.CreatePersonDTO(FAddressDTO: TAddressDTO;
  var FPersonDTO: TPersonDTO);
begin
  FPersonDTO := TPersonDTO.Create;
  FPersonDTO.LastName   := CS_LAST_NAME;
  FPersonDTO.FirstName  := CS_FIRST_NAME;
  FPersonDTO.MiddleName := CS_MIDDLE_NAME;
  FPersonDTO.Age        := CS_AGE;
  FPersonDTO.Address    := FAddressDTO;
end;

procedure TestTMapper.Setup;
begin
  FAddress := TAddress.Create(CS_STREET, CS_NUM_HOUSE);
  FPerson  := TPerson.Create(CS_LAST_NAME, CS_FIRST_NAME, CS_MIDDLE_NAME, CS_AGE, FAddress, CS_POST);
  FPerson.Status := CS_STATUS;
end;

procedure TestTMapper.TearDown;
begin
  FPerson.Free;
  FAddress.Free;
end;

procedure TestTMapper.TestConfigure;
begin
  Configure;

  Assert.AreEqual(6, Mapper.CountMapPair);
end;

procedure TestTMapper.TestMap_Automap;
var
  FAddress: TAddress;
  FAddressRecord: TAddressRecord;
begin
  ConfigureWithAutomap;

  FAddress := TAddress.Create(CS_STREET, CS_NUM_HOUSE);

  FAddressRecord := mapper.Map<TAddress, TAddressRecord>(FAddress);

  Assert.AreEqual(CS_STREET,    FAddressRecord.Street);
  Assert.AreEqual(CS_NUM_HOUSE, FAddressRecord.NumHouse);
end;

procedure TestTMapper.TestMap_CustomExpression;
var
  FUserDTO: TUserDTO;
begin
  Configure;

  FUserDTO := mapper.Map<TUserDTO>(FPerson);

  Assert.AreEqual(CS_FULL_NAME,    FUserDTO.FullName);
  Assert.AreEqual(CS_FULL_ADDRESS, FUserDTO.Address);
end;

procedure TestTMapper.TestMap_DefaultExpression;
var
  FSimplePersonDTO: TSimplePersonDTO;
begin
  Configure;

  FSimplePersonDTO := mapper.Map<TSimplePersonDTO>(FPerson);

  Assert.AreEqual(CS_LAST_NAME,   FSimplePersonDTO.Last_Name);
  Assert.AreEqual(CS_LAST_NAME,   FSimplePersonDTO.Last_Name);
  Assert.AreEqual(CS_FIRST_NAME,  FSimplePersonDTO.First_Name);
  Assert.AreEqual(CS_POST,        FSimplePersonDTO.Post);
  Assert.AreEqual(CS_STATUS,      FSimplePersonDTO.Status.Value);
  { TODO : Добавить возможность устанавливать кастомное приведение типов. }
//  CheckEquals(CS_MIDDLE_NAME, FSimplePersonDTO.Middle_Name, 'Так как в объекте ресурса MiddleName: Nullable<string>, а в объекте назначения Middle_Mame: string - автоматическое приведение типов стандртными средствами не возможно.');
end;

procedure TestTMapper.TestMap_ObjectToObject;
var
  FAddress: TAddress;
  FAddressDTO: TAddressDTO;
begin
  ConfigureWithRecords;

  FAddress := TAddress.Create(CS_STREET, CS_NUM_HOUSE);

  FAddressDTO := mapper.Map<TAddress, TAddressDTO>(FAddress);

  Assert.AreEqual(CS_STREET,    FAddressDTO.Street);
  Assert.AreEqual(CS_NUM_HOUSE, FAddressDTO.NumHouse);
end;

procedure TestTMapper.TestMap_ObjectToRecord;
var
  FAddress: TAddress;
  FAddressRecord: TAddressRecord;
begin
  ConfigureWithRecords;

  FAddress := TAddress.Create(CS_STREET, CS_NUM_HOUSE);

  FAddressRecord := mapper.Map<TAddress, TAddressRecord>(FAddress);

  Assert.AreEqual(CS_STREET,    FAddressRecord.Street);
  Assert.AreEqual(CS_NUM_HOUSE, FAddressRecord.NumHouse);
end;

procedure TestTMapper.TestMap_RecordToObject;
var
  FAddress: TAddressWriteble;
  FAddressRecord: TAddressRecord;
begin
  ConfigureWithRecords;

  FAddressRecord.Street   := CS_STREET;
  FAddressRecord.NumHouse := CS_NUM_HOUSE;

  FAddress := mapper.Map<TAddressRecord, TAddressWriteble>(FAddressRecord);

  Assert.AreEqual(CS_STREET,    FAddress.Street);
  Assert.AreEqual(CS_NUM_HOUSE, FAddress.NumHouse);
end;

procedure TestTMapper.TestMap_RecordToRecord;
var
  FNewAddressRecord: TNewAddressRecord;
  FAddressRecord: TAddressRecord;
begin
  ConfigureWithRecords;

  FAddressRecord.Street   := CS_STREET;
  FAddressRecord.NumHouse := CS_NUM_HOUSE;

  FNewAddressRecord := mapper.Map<TAddressRecord, TNewAddressRecord>(FAddressRecord);

  Assert.AreEqual(CS_STREET,    FNewAddressRecord.Street);
  Assert.AreEqual(CS_NUM_HOUSE, FNewAddressRecord.Num_House);
end;

procedure TestTMapper.TestMap_WithConstructor;
var
  FAddress:   TAddress;
  FAddressDTO: TAddressDTO;
begin
  Configure;
  CreateAddressDTO(FAddressDTO);

  FAddress := mapper.Map<TAddress>(FAddressDTO);

  Assert.AreEqual(CS_STREET,    FAddress.Street);
  Assert.AreEqual(CS_NUM_HOUSE, FAddress.NumHouse);
end;

procedure TestTMapper.TestMap_WithConstructorAndNestedObject;
var
  FPerson: TPerson;
  FPersonDTO: TPersonDTO;
  FAddressDTO: TAddressDTO;
begin
  Configure;

  CreateAddressDTO(FAddressDTO);
  CreatePersonDTO(FAddressDTO, FPersonDTO);

  FPerson := mapper.Map<TPerson>(FPersonDTO);

  Assert.AreEqual(CS_LAST_NAME,    FPerson.LastName);
  Assert.AreEqual(CS_FIRST_NAME,   FPerson.FirstName);
  Assert.AreEqual(CS_MIDDLE_NAME,  FPerson.MiddleName.Value);
  Assert.AreEqual(CS_AGE,          FPerson.Age.Value);
  Assert.AreEqual(CS_STREET,       FPerson.Address.Street);
  Assert.AreEqual(CS_NUM_HOUSE,    FPerson.Address.NumHouse);
end;

procedure TestTMapper.TestMap_WithNestedObject;
var
  FPersonDTO: TPersonDTO;
begin
  Configure;

  FPersonDTO := mapper.Map<TPersonDTO>(FPerson);

  Assert.AreEqual(CS_LAST_NAME,    FPersonDTO.LastName);
  Assert.AreEqual(CS_FIRST_NAME,   FPersonDTO.FirstName);
  Assert.AreEqual(CS_MIDDLE_NAME,  FPersonDTO.MiddleName.Value);
  Assert.AreEqual(CS_AGE,          FPersonDTO.Age.Value);
  Assert.AreEqual(CS_STREET,       FPersonDTO.Address.Street);
  Assert.AreEqual(CS_NUM_HOUSE,    FPersonDTO.Address.NumHouse);
end;

procedure TestTMapper.TestMap_WithOverrideExpression;
var
  FUserDTO: TUserDTO;
begin
  Configure;

  FUserDTO := mapper.Map<TPerson, TUserDTO>(FPerson, procedure (const s: TPerson; out d:  TUserDTO)
                                              begin
                                                d.FullName := CS_OVERRIDE_FULL_NAME;
                                                d.Address  := СS_OVERRIDE_ADDRESS;
                                              end
                                            );

  Assert.AreEqual(CS_OVERRIDE_FULL_NAME, FUserDTO.FullName);
  Assert.AreEqual(СS_OVERRIDE_ADDRESS,   FUserDTO.Address);
end;

initialization
  TDUnitX.RegisterTestFixture(TestTMapper);

end.
