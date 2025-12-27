unit imOrm4D.Attributes.Helper;

interface

uses
  System.SysUtils,
  System.Rtti;

type
  TAttributeHelper = class
  public
    class function HasAttribute<T: TCustomAttribute>(AProp: TRttiProperty): Boolean;
  end;

implementation

{ TAttributeHelper }

class function TAttributeHelper.HasAttribute<T>(AProp: TRttiProperty): Boolean;
var
  Attr: TCustomAttribute;
begin
  Result := False;
  for Attr in AProp.GetAttributes do
    if Attr is T then
      Exit(True);

end;

end.
