unit imOrm4D.Connection.BaseConnection;

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
  imOrm4D.Interfaces.Connection,
  imOrm4D.Connection.Drivers;

type
  TFireDACBaseConnection = class(TInterfacedObject, IDatabaseConnection)
  private
    FGUI: TFDGUIxWaitCursor;
  protected
    FConn: TFDConnection;
    constructor Create; virtual;
    procedure ConfigureConnection; virtual; abstract;
  public
    destructor Destroy; override;
    function GetConnection: TFDConnection;
    function GetDatabaseDriver: TDatabaseDriver; virtual;
    procedure Connect;
    procedure Disconnect;
    function InTransaction: Boolean;
    procedure BeginTransaction;
    procedure Commit;
    procedure Rollback;
    class function New: TFireDACBaseConnection;
  end;

implementation

{ TFireDACBaseConnection }
destructor TFireDACBaseConnection.Destroy;
begin
  FConn.Free;
  FGUI.Free;
  inherited;
end;

procedure TFireDACBaseConnection.Connect;
begin
  ConfigureConnection;
  if not FConn.Connected then
    FConn.Connected := True;
end;

constructor TFireDACBaseConnection.Create;
begin
  inherited Create;
  FConn:= TFDConnection.Create(nil);
  FGUI := TFDGUIxWaitCursor.Create(nil);
  FGUI.Provider:= 'Forms';
end;

procedure TFireDACBaseConnection.Disconnect;
begin
  if FConn.Connected then
    FConn.Connected:= False;
end;

function TFireDACBaseConnection.GetConnection: TFDConnection;
begin
  Result:= FConn;
end;

function TFireDACBaseConnection.GetDatabaseDriver: TDatabaseDriver;
begin
  raise Exception.Create('Driver não implementado');
end;

function TFireDACBaseConnection.InTransaction: Boolean;
begin
  Result:= FConn.InTransaction;
end;

class function TFireDACBaseConnection.New: TFireDACBaseConnection;
begin
  Result:= Self.Create;
end;

procedure TFireDACBaseConnection.BeginTransaction;
begin
  if not FConn.InTransaction then
    FConn.StartTransaction;
end;

procedure TFireDACBaseConnection.Commit;
begin
  if FConn.InTransaction then
    FConn.Commit;
end;

procedure TFireDACBaseConnection.Rollback;
begin
  if FConn.InTransaction then
    FConn.Rollback;
end;

end.

