unit imOrm4D.Connection.Driver.Helper;

interface

uses
  System.SysUtils,
  System.Math,
  imOrm4D.Connection.Drivers;

type
  TDatabaseDriverHelper = class
  public
     class function ApplyPagination(const ADbDriver: TDatabaseDriver; const ASQL: string; ALimit, AOffset: Integer): string;
  end;

implementation

{ TDatabaseDriverHelper }

class function TDatabaseDriverHelper.ApplyPagination(const ADbDriver: TDatabaseDriver; const ASQL: string; ALimit,
  AOffset: Integer): string;
begin
  Result:= ASQL;

  if (ALimit < 0) and (AOffset < 0) then
    Exit;

  case ADbDriver of
    ddPostgres, ddSQLite:
      begin
        if ALimit >= 0 then
          Result:= Result + Format(' LIMIT %d', [ALimit]);
        if AOffset >= 0 then
          Result:= Result + Format(' OFFSET %d', [AOffset]);
      end;

    ddMySQL:
      begin
        if (ALimit >= 0) and (AOffset >= 0) then
          Result:= Result + Format(' LIMIT %d, %d', [AOffset, ALimit])
        else if ALimit >= 0 then
          Result:= Result + Format(' LIMIT %d', [ALimit]);
      end;

    ddFirebird:
      begin
        if (ALimit >= 0) and (AOffset >= 0) then
          Result:= Result + Format(' ROWS %d TO %d', [AOffset + 1, AOffset + ALimit])
        else if ALimit >= 0 then
          Result:= Result + Format(' ROWS %d', [ALimit]);
      end;

    ddSQLServer, ddOracle:
      begin
        Result:= Result + Format(' OFFSET %d ROWS FETCH NEXT %d ROWS ONLY', [Max(AOffset, 0), ALimit]);
      end;
  end;
end;

end.
