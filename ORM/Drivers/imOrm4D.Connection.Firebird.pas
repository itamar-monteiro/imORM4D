unit imOrm4D.Connection.Firebird;

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
  TFirebirdConnection = class(TFireDACBaseConnection)
  private
    FServer: string;
    FDatabase: string;
    FUser: string;
    FPassword: string;
    FPort: Integer;
  protected
    procedure ConfigureConnection; override;
    constructor Create(const AServer, ADatabase, AUser, APassword: string; APort: Integer = 3050); reintroduce;
  public
    function GetDialect: TDatabaseDriver; override;
    class function New(const AServer, ADatabase, AUser, APassword: string; APort: Integer): TFirebirdConnection;
  end;

implementation

uses
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef;

constructor TFirebirdConnection.Create(const AServer, ADatabase, AUser, APassword: string; APort: Integer);
begin
  inherited Create;
  FServer  := AServer;
  FDatabase:= ADatabase;
  FUser    := AUser;
  FPassword:= APassword;
  FPort    := APort;
end;

function TFirebirdConnection.GetDialect: TDatabaseDriver;
begin
  Result:= ddFirebird;
end;

class function TFirebirdConnection.New(const AServer, ADatabase, AUser, APassword: string; APort: Integer): TFirebirdConnection;
begin
  Result:= Self.Create(AServer, ADatabase, AUser, APassword, APort);
end;

procedure TFirebirdConnection.ConfigureConnection;
begin
  FConn.DriverName := 'FB';
  FConn.Params.Values['Server']   := FServer;
  FConn.Params.Values['Database'] := FDatabase;
  FConn.Params.Values['User_Name']:= FUser;
  FConn.Params.Values['Password'] := FPassword;
  FConn.Params.Values['Port']     := FPort.ToString;
end;

end.

