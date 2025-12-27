unit imOrm4D.Attributes;

interface

uses
  System.SysUtils,
  System.Rtti;

type
  TableAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  ColumnAttribute = class(TCustomAttribute)
  private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  DisplayWidthAttribute = class(TCustomAttribute)
  private
    FWidth: Integer;
  public
    constructor Create(AWidth: Integer);
    property Width: Integer read FWidth;
  end;

  PrimaryKeyAttribute = class(TCustomAttribute)
  end;

  AutoIncAttribute = class(TCustomAttribute)
  end;

  IgnoreMappingAttribute = class(TCustomAttribute)
  end;

  function GetTableName(AType: TRttiType): string;
  function GetColumnName(AProp: TRttiProperty): string;
  function IsIgnored(AProp: TRttiProperty): Boolean;

implementation

{ TableAttribute }

constructor TableAttribute.Create(const AName: string);
begin
  FName:= AName;
end;

{ ColumnAttribute }

constructor ColumnAttribute.Create(const AName: string);
begin
  FName:= AName;
end;

function GetTableName(AType: TRttiType): string;
var
  Attr: TCustomAttribute;
begin
  Result:= AType.Name;

  for Attr in AType.GetAttributes do
    if Attr is TableAttribute then
      Exit(TableAttribute(Attr).Name);
end;

function GetColumnName(AProp: TRttiProperty): string;
var
  Attr: TCustomAttribute;
begin
  Result:= AProp.Name;

  for Attr in AProp.GetAttributes do
    if Attr is ColumnAttribute then
      Exit(ColumnAttribute(Attr).Name);
end;

function IsIgnored(AProp: TRttiProperty): Boolean;
var
  Attr: TCustomAttribute;
begin
  Result:= False;
  for Attr in AProp.GetAttributes do
    if Attr is IgnoreMappingAttribute then
      Exit(True);
end;

{ DisplayWidthAttribute }

constructor DisplayWidthAttribute.Create(AWidth: Integer);
begin
  FWidth:= AWidth;
end;

end.
