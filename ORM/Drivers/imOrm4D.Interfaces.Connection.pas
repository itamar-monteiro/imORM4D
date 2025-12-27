unit imOrm4D.Interfaces.Connection;

interface

uses
  System.SysUtils,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.DApt,
  FireDAC.Stan.Intf,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  imOrm4D.Connection.Drivers;

type
  IDatabaseConnection = interface
    ['{376F0B9C-01BB-4A5A-8B9B-24B2C49D0230}']
    function GetConnection: TFDConnection;
    function GetDialect: TDatabaseDriver;
    procedure Connect;
    procedure Disconnect;
    function InTransaction: Boolean;
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
  end;

implementation

end.

