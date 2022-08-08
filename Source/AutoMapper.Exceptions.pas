unit AutoMapper.Exceptions;

interface

uses
    System.SysUtils
  ;

type
  TAutoMapperException      = class(Exception);
  TMapperConfigureException = class(TAutoMapperException);
  TGetMapItemException      = class(TAutoMapperException);
  TClassPairCreateExcetion  = class(TAutoMapperException);

const
  CS_MAPPER_CONFIGURATION_ALLREADY = 'The AutoMapper configuration has already been performed.';

  CS_GET_MAPITEM_NOT_FOUND         = 'MapItem for a pair of objects "%s"->"%s" not found.';

  CS_CLASSPAIR_CREATE_SOURCECLASS_NIL = 'Argument SourceClass is nil.';
  CS_CLASSPAIR_CREATE_DESTCLASS_NIL   = 'Argument DestinationClass is nil.';

implementation

end.
