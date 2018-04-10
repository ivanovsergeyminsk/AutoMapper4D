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
```pascal
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

    constructor Create(ALastName, AFirstName: string; 
                       AMiddleName: Nullable<string>; AAge: Nullable<integer>); overload;
  end;
```  
```pascal
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
```
```pascal 
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
```

Сначала, в исходном коде, где выполняется инициализация Вашей программы, прописываем конфигурацию для маппера:
```pascal
 uses
 //...
 AutoMapper.Mapper;
 //...
 
 Mapper.Configure(procedure (const cfg: TConfigurationProvider)
                  begin
                        //пользовательский маппинг.
                    cfg.CreateMap<TPerson, TUserDTO>(procedure (const FPerson: TPerson; out FUserDTO: TUserDTO)
                                                        begin
                                                          FUserDTO.FullName := FPerson.LastName    +' '+
                                                                               FPerson.FirstName   +' '+
                                                                               FPerson.MiddleName;

                                                          FUserDTO.Age      := FPerson.Age;
                                                        end
                                                      )
                        //пользовательский мапинг, если объекту назначения требуются параметры для конструктора.
                       .CreateMap<TPersonDTO, TPerson>(procedure (const FPersonDTO: TPersonDTO; out FPerson: TPerson 
                                                        begin
                                                          FPerson := TPerson.Create(FPersonDTO.LastName,
                                                                                    FPersonDTO.FirstName,
                                                                                    FPersonDTO.MiddleName,
                                                                                    FPersonDTO.Age)
                                                        end
                                                       )
                        //автоматический маппинг по public и published полям и свойствам.
                       .CreateMap<TPerson, TPersonDTO>(); 
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
  FPerson := TPerson.Create('Иванов', 'Сергей', 'Николаевич', 26);

  FPersonDTO  := Mapper.Map<TPerson, TPersonDTO>(FPerson);
  FUserDTO    := Mapper.Map<TUserDTO>(FPerson); // Без указания типа исходного объектра
  FDestPerson := Mapper.Map<TPerson>(FPersonDTO);
end;
```
