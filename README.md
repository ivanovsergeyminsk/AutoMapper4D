# AutoMapper4D

Попытка реализовать упрощенный аналог фреймвока Automapper(C#) для Delphi.

В коде используется дополнитеный фреймворк: [Spring4D](https://bitbucket.org/sglienke/spring4d).
***

## Пример использования:

Настройка:
> ```pascal 
> Mapper.Configure(procedure (const cfg: TConfigurationProvider)
>                   begin
>                     cfg.CreateMap<TPerson, TPersonDTO>();
>                   end); 
> ```
Применение:
> ```pascal 
> FPersonDTO := Mapper.Map<TPersonDTO>(FPerson);
> ``` 
***
Классы объектов с которыми будем взаимодействовать:
> #### Классы сущностей:
> ```pascal
>  TAddress = class
>    private
>      FStreet: string;
>      FNumHouse: integer;
>    public
>    property Street: string read FStreet;
>    property NumHouse: integer read FNumHouse;
>
>    constructor Create(const AStreet: string; const ANumHouse: integer);
>  end;
>
>  TPerson = class
>  private
>    FLastName: string;
>    FFirstName: string;
>    FMiddleName: Nullable<string>;
>    FAge: Nullable<integer>;
>    FAddress: TAddress;
>  public
>    property LastName: string read FLastName;
>    property FirstName: string read FFirstName;
>    property MiddleName: Nullable<string> read FMiddleName;
>    property Age: Nullable<integer> read FAge;
>    property Address: TAddress read FAddress;
>    constructor Create(ALastName, AFirstName: string; AMiddleName: Nullable<string>; AAge: Nullable<integer>; AAddress: TAddress);
>  end;
> ```  

> #### Классы DTO:
> ```pascal 
>  TAddressDTO = class
>  private
>    FStreet: string;
>    FNumHouse: integer;
>    procedure SetNumHouse(const Value: integer);
>    procedure SetStreet(const Value: string);
>  public
>    property Street: string read FStreet write SetStreet;
>    property NumHouse: integer read FNumHouse write SetNumHouse;
>  end;
>
>  TPersonDTO = class
>  private
>    FAge: Nullable<integer>;
>    FLastName: string;
>    FMiddleName: Nullable<string>;
>    FAddress: TAddressDTO;
>    FFirstName: string;
>    procedure SetAddress(const Value: TAddressDTO);
>    procedure SetAge(const Value: Nullable<integer>);
>    procedure SetFirstName(const Value: string);
>    procedure SetLastName(const Value: string);
>    procedure SetMiddleName(const Value: Nullable<string>);
>  public
>    property LastName: string read FLastName write SetLastName;
>    property FirstName: string read FFirstName write SetFirstName;
>    property MiddleName: Nullable<string> read FMiddleName write SetMiddleName;
>    property Age: Nullable<integer> read FAge write SetAge;
>    property Address: TAddressDTO read FAddress write SetAddress;
>  end;
>
>  TUserDTO = class
>  private
>    FFullName: string;
>    FAddress: string;
>    procedure SetAddress(const Value: string);
>    procedure SetFullName(const Value: string);
>  public
>    property FullName: string read FFullName write SetFullName;
>    property Address: string read FAddress write SetAddress;
>  end;
>
>  TSimplePersonDTO = class
>  private
>    FMiddle_Name: string;
>    FFirst_Name: string;
>    FLast_Name: string;
>    procedure SetFirst_Name(const Value: string);
>    procedure SetLast_Name(const Value: string);
>    procedure SetMiddle_Name(const Value: string);
>  public
>    property Last_Name: string read FLast_Name write SetLast_Name;
>    property First_Name: string read FFirst_Name write SetFirst_Name;
>    property Middle_Name: string read FMiddle_Name write SetMiddle_Name;
>  end;
> ```

Сначала, в исходном коде, где выполняется инициализация Вашей программы, прописываем конфигурацию для маппера:
```pascal
 uses
 //...
 AutoMapper.Mapper;
 //...
 
  Mapper.Configure(procedure (const cfg: TConfigurationProvider)
                  begin
                        //Автоматический маппинг по public и published полям и свойствам.
                    cfg.CreateMap<TAddress, TAddressDTO>
                       .CreateMap<TPerson, TSimplePersonDTO>();
                       //Пользовательский маппинг с формативанием.                                 
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
                        //Маппинг с вложенным объектом.                              
                       .CreateMap<TPerson, TPersonDTO>(procedure (const s: TPerson; out d: TPersonDTO)
                                                        begin
                                                          d.LastName    := s.LastName;
                                                          d.FirstName   := s.FirstName;
                                                          d.MiddleName  := s.MiddleName;
                                                          d.Age         := s.Age;
                                                          d.Address     := mapper.Map<TAddressDTO>(s.Address);
                                                        end
                                                       )                                                      
                        //Маппинг, если объекту назначения требуются параметры в конструкторе
                       .CreateMap<TAddressDTO, TAddress>(procedure (const FAddressDTO: TAddressDTO; out FAddress: TAddress)
                                                          begin
                                                            FAddress := TAddress.Create(FAddressDTO.Street,
                                                                                        FAddressDTO.NumHouse);
                                                          end
                                                        )
                        //Маппинг с вложенным объектом, если объекту назначения требуются параметры в конструкторе.                 
                       .CreateMap<TPersonDTO, TPerson>(procedure (const FPersonDTO: TPersonDTO; out FPerson: TPerson)
                                                        begin
                                                          FPerson := TPerson.Create(FPersonDTO.LastName,
                                                                                    FPersonDTO.FirstName,
                                                                                    FPersonDTO.MiddleName,
                                                                                    FPersonDTO.Age,
                                                                                    mapper.Map<TAddress>(FPersonDTO.Address));
                                                        end
                                                      )
                  end);
  ```
  
 Теперь в любом месте программы можем выполнять маппинг:
 ```pascal
 uses
 //...
 AutoMapper.Mapper;
 //...
 
 var
  FPerson, FDestPerson: TPerson;
  FUserDTO:   TUserDTO;
  FPersonDTO: TPersonDTO;
begin
  //...
  FPersonDTO  := Mapper.Map<TPerson, TPersonDTO>(FPerson);
  FUserDTO    := Mapper.Map<TUserDTO>(FPerson); // Без указания типа исходного объектра
  FDestPerson := Mapper.Map<TPerson>(FPersonDTO);
  //...
end;
```
