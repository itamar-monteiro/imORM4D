unit imOrm4D.Interfaces.Repository;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Comp.Client,
  imOrm4D.Attributes,
  imOrm4D.Interfaces.Connection,
  imOrm4D.Interfaces.Select;

type
  IRepository<T> = interface
    ['{8C3C6E2B-2D7B-4DDE-8AEE-28D4CFF1B4B3}']
    function Insert(const AEntity: T): IRepository<T>; overload;
    function Insert(const AEntity: T; out InsertedId: Integer): IRepository<T>; overload;
    function Update(const AEntity: T): IRepository<T>;
    function Delete(const AEntity: T): IRepository<T>;
    function GetById(const AId: Variant): T;
    function GetAll: TList<T>;
    function Select: ISelect<IRepository<T>>;
    function DataSource(ADataSource: TDataSource): IRepository<T>;
    function List: IRepository<T>;
    function LastID(const ATable, AField: string): Integer;
    function StartTransaction: IRepository<T>;
    function Commit: IRepository<T>;
    function Rollback: IRepository<T>;
  end;

  implementation

end.

