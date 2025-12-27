unit imOrm4D.Connection.Postgres;

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
  imOrm4D.Connection.BaseConnection,
  imOrm4D.Connection.Drivers;

type
  TPostgresConnection = class(TFireDACBaseConnection)
  private
    FServer: string;
    FDatabase: string;
    FUser: string;
    FPassword: string;
    FPort: Integer;
  protected
    procedure ConfigureConnection; override;
    constructor Create(const AServer, ADatabase, AUser, APassword: string; APort: Integer = 5432); reintroduce;
  public
    function GetDialect: TDatabaseDriver; override;
    class function New(const AServer, ADatabase, AUser, APassword: string; APort: Integer): TPostgresConnection;
  end;

implementation

uses
  FireDAC.Phys.PG,
  FireDAC.Phys.PGDef;

constructor TPostgresConnection.Create(const AServer, ADatabase, AUser, APassword: string; APort: Integer);
begin
  inherited Create;
  FServer  := AServer;
  FDatabase:= ADatabase;
  FUser    := AUser;
  FPassword:= APassword;
  FPort    := APort;
end;

function TPostgresConnection.GetDialect: TDatabaseDriver;
begin
  Result:= ddPostgres;
end;

class function TPostgresConnection.New(const AServer, ADatabase, AUser, APassword: string; APort: Integer): TPostgresConnection;
begin
  Result:= Self.Create(AServer, ADatabase, AUser, APassword, APort);
end;

procedure TPostgresConnection.ConfigureConnection;
begin
  FConn.DriverName := 'PG';
  FConn.Params.Values['Server']   := FServer;
  FConn.Params.Values['Database'] := FDatabase;
  FConn.Params.Values['User_Name']:= FUser;
  FConn.Params.Values['Password'] := FPassword;
  FConn.Params.Values['Port']     := FPort.ToString;
end;

end.

