unit imOrm4D.DisplayAttributes;

interface

uses
  System.SysUtils;

type
  DisplayLabelAttribute = class(TCustomAttribute)
  private
    FLabel: string;
  public
    constructor Create(const ALabel: string);
    property LabelText: string read FLabel;
  end;

  DisplayFormatAttribute = class(TCustomAttribute)
  private
    FFormat: string;
  public
    constructor Create(const AFormat: string);
    property FormatText: string read FFormat;
  end;

implementation

constructor DisplayLabelAttribute.Create(const ALabel: string);
begin
  FLabel:= ALabel;
end;

constructor DisplayFormatAttribute.Create(const AFormat: string);
begin
  FFormat:= AFormat;
end;

end.

