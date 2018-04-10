program AutoMapperTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  AutoMapper.ConfigurationProvider in '..\Source\AutoMapper.ConfigurationProvider.pas',
  AutoMapper.MappingExpression in '..\Source\AutoMapper.MappingExpression.pas',
  AutoMapper.Mapper in '..\Source\AutoMapper.Mapper.pas',
  AutoMapper.CfgMapper in '..\Source\AutoMapper.CfgMapper.pas',
  AutoMapper.MapItem in '..\Source\AutoMapper.MapItem.pas',
  AutoMapper.ClassPair in '..\Source\AutoMapper.ClassPair.pas',
  AutoMapper.Exceptions in '..\Source\AutoMapper.Exceptions.pas',
  AutoMapper.MapEngine in '..\Source\AutoMapper.MapEngine.pas',
  Test.Models in 'Test.Models.pas',
  TestAutoMapper in 'TestAutoMapper.pas',
  Test.ModelsDTO in 'Test.ModelsDTO.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

