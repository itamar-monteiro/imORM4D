unit imOrm4D.Repository;

interface

uses
  System.SysUtils,
  System.Rtti,
  System.Generics.Collections,
  Data.DB,
  FireDAC.Comp.Client,
  imOrm4D.Attributes.Helper,
  imOrm4D.Attributes,
  imOrm4D.Interfaces.Connection,
  imOrm4D.Interfaces.Select,
  imOrm4D.Interfaces.Repository,
  imOrm4D.DisplayAttributes;

type
  TRepository<T: class, constructor> = class(TInterfacedObject, IRepository<T>)
  private
    FSelect: ISelect<IRepository<T>>;
    FLastQuery: TFDQuery;
    FDataSource: TDataSource;
    FTransaction: TFDTransaction;
    function CreateEntity: T;
    function PrimaryKeyProp: TRttiProperty;
    function ColumnProps: TArray<TRttiProperty>;
    procedure MapRowToEntity(Q: TFDQuery; E: T);
  protected
    FConn: IDatabaseConnection;
    FTable: string;
    FContext: TRttiContext;
    FType: TRttiType;
  public
    function Insert(const AEntity: T): IRepository<T>; overload;
    function Insert(const AEntity: T; out InsertedId: Integer): IRepository<T>; overload;
    function Update(const AEntity: T): IRepository<T>;
    function Delete(const AEntity: T): IRepository<T>;
    function GetById(const AId: Variant): T;
    function GetAll: TList<T>;
    function Select: ISelect<IRepository<T>>;
    function List: IRepository<T>;
    function LastID(const ATable, AField: string): Integer;
    function DataSource(ADataSource: TDataSource): IRepository<T>;
    function StartTransaction: IRepository<T>;
    function Commit: IRepository<T>;
    function Rollback: IRepository<T>;
    constructor Create(const AConnection: IDatabaseConnection);
    destructor Destroy; override;
  end;

implementation

uses
  FireDAC.Stan.Param,
  System.Variants,
  System.TypInfo,
  System.StrUtils,
  System.Classes,
  imOrm4D.Select,
  imOrm4D.Connection.Driver.Helper;

function TRepository<T>.Commit: IRepository<T>;
begin
  Result:= Self;
  if not FTransaction.Active then
    raise Exception.Create('Não há transação ativa para commit.');

  FTransaction.Commit;
end;

constructor TRepository<T>.Create(const AConnection: IDatabaseConnection);
begin
  FConn   := AConnection;
  FContext:= TRttiContext.Create;
  FType   := FContext.GetType(TypeInfo(T));
  FTable  := GetTableName(FType);
  FSelect := nil;
  FLastQuery:= nil;
  // Cria a transação associada à conexão
  FTransaction:= TFDTransaction.Create(nil);
  FTransaction.Connection:= FConn.GetConnection;
end;

function TRepository<T>.CreateEntity: T;
begin
  Result:= T.Create;
end;

function TRepository<T>.Select: ISelect<IRepository<T>>;
begin
  if not Assigned(FSelect) then
    FSelect:= TSelect<IRepository<T>>.Create(Self as IRepository<T>);
  Result:= FSelect;
end;

function TRepository<T>.StartTransaction: IRepository<T>;
begin
  Result:= Self;
  if FTransaction.Active then
    Exit;

  FTransaction.StartTransaction;
end;

function TRepository<T>.PrimaryKeyProp: TRttiProperty;
var
  P: TRttiProperty;
begin
  Result:= nil;

  for P in FType.GetProperties do
    if TAttributeHelper.HasAttribute<PrimaryKeyAttribute>(P) then
      Exit(P);
end;

function TRepository<T>.Rollback: IRepository<T>;
begin
  Result:= Self;
  if not FTransaction.Active then
    raise Exception.Create('Não há transação ativa para rollback.');

  FTransaction.Rollback;
end;

function TRepository<T>.ColumnProps: TArray<TRttiProperty>;
var
  List: TList<TRttiProperty>;
  P   : TRttiProperty;
begin
  List:= TList<TRttiProperty>.Create;
  try
    for P in FType.GetProperties do
      if P.IsReadable and P.IsWritable and (not IsIgnored(P)) then
        List.Add(P);

    Result:= List.ToArray;
  finally
    List.Free;
  end;
end;

procedure TRepository<T>.MapRowToEntity(Q: TFDQuery; E: T);
var
  P: TRttiProperty;
  ColName: string;
  Field: TField;
  V: Variant;
begin
  for P in FType.GetProperties do
  begin
    // 1. Tenta pelo nome definido no atributo [Column('nome_coluna')]
    ColName:= GetColumnName(P);
    Field  := Q.FindField(ColName);

    // 2. Se não encontrou (ex: campo de JOIN com Alias), tenta pelo nome da Propriedade
    if not Assigned(Field) then
      Field:= Q.FindField(P.Name);

    if Assigned(Field) and not Field.IsNull then
    begin
      V:= Field.Value;

      if P.PropertyType.Handle = TypeInfo(Integer) then
        P.SetValue(TObject(E), TValue.From<Integer>(Integer(V)))
      else if P.PropertyType.Handle = TypeInfo(Int64) then
        P.SetValue(TObject(E), TValue.From<Int64>(Int64(V)))
      else if P.PropertyType.Handle = TypeInfo(Double) then
        P.SetValue(TObject(E), TValue.From<Double>(Double(V)))
      else if P.PropertyType.Handle = TypeInfo(Currency) then
        P.SetValue(TObject(E), TValue.From<Currency>(Currency(V)))
      else if P.PropertyType.Handle = TypeInfo(string) then
        P.SetValue(TObject(E), TValue.From<string>(VarToStr(V)))
      else if P.PropertyType.Handle = TypeInfo(TDateTime) then
        P.SetValue(TObject(E), TValue.From<TDateTime>(VarToDateTime(V)))
      else if P.PropertyType.Handle = TypeInfo(Boolean) then
        P.SetValue(TObject(E), TValue.From<Boolean>(Field.AsBoolean))
      else
        P.SetValue(TObject(E), TValue.FromVariant(V));
    end;
  end;
end;

function TRepository<T>.Update(const AEntity: T): IRepository<T>;
var
  Query: TFDQuery;
  Props: TArray<TRttiProperty>;
  P, PK: TRttiProperty;
  Sets: TStringList;
  UpdateSQL: string;
begin
  Result:= Self;
  PK    := PrimaryKeyProp;

  if not Assigned(PK) then
    raise Exception.Create('PrimaryKey não definido.');

  Query:= TFDQuery.Create(nil);
  Sets := TStringList.Create;

  try
    Query.Connection:= FConn.GetConnection;
    Query.Params.Clear;
    Props:= ColumnProps;

    for P in Props do
    begin
      if P.Name = PK.Name then
        Continue;
      Sets.Add(Format('%s = :%s', [GetColumnName(P), GetColumnName(P)]));
    end;

    UpdateSQL:= Format('UPDATE %s SET %s WHERE %s = :%s',
      [FTable,
       String.Join(', ', Sets.ToStringArray),
       GetColumnName(PK),
       GetColumnName(PK)]);

    Query.SQL.Text:= UpdateSQL;

    for P in Props do
    begin
      with Query.ParamByName(GetColumnName(P)) do
      begin
        ParamType:= ptInput;
        Value    := P.GetValue(TObject(AEntity)).AsVariant;

        if P.PropertyType.Handle = TypeInfo(Integer) then
          DataType:= ftInteger
        else if P.PropertyType.Handle = TypeInfo(Double) then
          DataType:= ftFloat
        else if P.PropertyType.Handle = TypeInfo(Currency) then
          DataType:= ftCurrency
        else if P.PropertyType.Handle = TypeInfo(string) then
          DataType:= ftString
        else if P.PropertyType.Handle = TypeInfo(TDateTime) then
          DataType:= ftDateTime
        else
          DataType:= ftVariant;
      end;
    end;

    with Query.ParamByName(GetColumnName(PK)) do
    begin
      ParamType:= ptInput;
      Value    := PK.GetValue(TObject(AEntity)).AsVariant;
      DataType := ftInteger;
    end;

    Query.ExecSQL;
  finally
    Query.Free;
    Sets.Free;
  end;
end;

function TRepository<T>.DataSource(ADataSource: TDataSource): IRepository<T>;
begin
  Result:= Self;
  FDataSource:= ADataSource;
  if Assigned(FLastQuery) and Assigned(FDataSource) then
    FDataSource.DataSet:= FLastQuery;
end;

function TRepository<T>.Delete(const AEntity: T): IRepository<T>;
var
  Query: TFDQuery;
  PK: TRttiProperty;
  ParamName: string;
begin
  Result:= Self;
  PK    := PrimaryKeyProp;

  if not Assigned(PK) then
    raise Exception.Create('PrimaryKey não definido.');

  Query:= TFDQuery.Create(nil);
  try
    Query.Connection:= FConn.GetConnection;
    ParamName:= GetColumnName(PK);

    Query.SQL.Text:= Format('DELETE FROM %s WHERE %s = :%s', [FTable, ParamName, ParamName]);

    with Query.ParamByName(ParamName) do
    begin
      ParamType:= ptInput;
      Value    := PK.GetValue(TObject(AEntity)).AsVariant;

      // Define tipo explicitamente
      if PK.PropertyType.Handle = TypeInfo(Integer) then
        DataType:= ftInteger
      else if PK.PropertyType.Handle = TypeInfo(Int64) then
        DataType:= ftLargeint
      else if PK.PropertyType.Handle = TypeInfo(string) then
        DataType:= ftString
      else if PK.PropertyType.Handle = TypeInfo(TGUID) then
        DataType:= ftGUID
      else
        DataType:= ftVariant;
    end;

    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

destructor TRepository<T>.Destroy;
begin
  if Assigned(FLastQuery) then
    FLastQuery.Free;

  if Assigned(FTransaction) then
    FreeAndNil(FTransaction);

  FSelect:= nil;
  inherited;
end;

function TRepository<T>.GetAll: TList<T>;
var
  Query: TFDQuery;
  E: T;
begin
  Result:= TList<T>.Create;
  Query := TFDQuery.Create(nil);

  try
    Query.Connection:= FConn.GetConnection;
    Query.SQL.Text  := Format('SELECT * FROM %s', [FTable]);
    Query.Open;

    while not Query.Eof do
    begin
      E:= CreateEntity;
      MapRowToEntity(Query, E);
      Result.Add(E);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TRepository<T>.GetById(const AId: Variant): T;
var
  Query: TFDQuery;
  PK: TRttiProperty;
  E: T;
  ParamName: string;
begin
  Result:= nil;
  PK    := PrimaryKeyProp;

  if not Assigned(PK) then
    raise Exception.Create('PrimaryKey não definido.');

  Query:= TFDQuery.Create(nil);
  try
    Query.Connection:= FConn.GetConnection;
    ParamName:= GetColumnName(PK);

    Query.SQL.Text:= Format('SELECT * FROM %s WHERE %s = :%s', [FTable, ParamName, ParamName]);

    with Query.ParamByName(ParamName) do
    begin
      ParamType:= ptInput;
      Value    := AId;

      // Define tipo explicitamente
      if PK.PropertyType.Handle = TypeInfo(Integer) then
        DataType:= ftInteger
      else if PK.PropertyType.Handle = TypeInfo(Int64) then
        DataType:= ftLargeint
      else if PK.PropertyType.Handle = TypeInfo(string) then
        DataType:= ftString
      else if PK.PropertyType.Handle = TypeInfo(TGUID) then
        DataType:= ftGUID
      else
        DataType:= ftVariant;
    end;

    Query.Open;

    if not Query.IsEmpty then
    begin
      E:= CreateEntity;
      MapRowToEntity(Query, E);
      Result:= E;
    end;
  finally
    Query.Free;
  end;
end;

function TRepository<T>.Insert(const AEntity: T; out InsertedId: Integer): IRepository<T>;
var
  Query: TFDQuery;
  PK: TRttiProperty;
  Cols, Placeholders: TList<string>;
  P: TRttiProperty;
  HasAutoIncPK: Boolean;
  ColName: string;
begin
  Result:= Self;
  InsertedId:= -1;
  Query:= TFDQuery.Create(nil);
  Cols := TList<string>.Create;
  Placeholders:= TList<string>.Create;
  try
    Query.Connection:= FConn.GetConnection;
    PK:= PrimaryKeyProp;
    HasAutoIncPK:= Assigned(PK) and TAttributeHelper.HasAttribute<AutoIncAttribute>(PK);

    for P in ColumnProps do
    begin
      if Assigned(PK) and (P.Name = PK.Name) and HasAutoIncPK then
        Continue;

      ColName:= GetColumnName(P);
      Cols.Add(ColName);
      Placeholders.Add(':' + ColName);
    end;

    Query.SQL.Text:= Format('INSERT INTO %s (%s) VALUES (%s)',
       [FTable, String.Join(', ', Cols.ToArray), String.Join(', ', Placeholders.ToArray)]);

    if HasAutoIncPK then
      Query.SQL.Text:= Query.SQL.Text + Format(' RETURNING %s', [GetColumnName(PK)]);

    for P in ColumnProps do
    begin
      if Assigned(PK) and (P.Name = PK.Name) and HasAutoIncPK then
        Continue;

      ColName:= GetColumnName(P);

      with Query.ParamByName(ColName) do
      begin
        ParamType:= ptInput;
        Value:= P.GetValue(TObject(AEntity)).AsVariant;

        if P.PropertyType.Handle = TypeInfo(Integer) then
          DataType:= ftInteger
        else if P.PropertyType.Handle = TypeInfo(Int64) then
          DataType:= ftLargeint
        else if P.PropertyType.Handle = TypeInfo(Double) then
          DataType:= ftFloat
        else if P.PropertyType.Handle = TypeInfo(Currency) then
          DataType:= ftCurrency
        else if P.PropertyType.Handle = TypeInfo(string) then
          DataType:= ftString
        else if P.PropertyType.Handle = TypeInfo(TDateTime) then
          DataType:= ftDateTime
        else DataType:= ftVariant;
      end;
    end;

    if HasAutoIncPK then
      begin
        Query.Open;
        if not Query.IsEmpty then
        begin
          InsertedId:= Query.Fields[0].AsInteger;
          PK.SetValue(TObject(AEntity), InsertedId);
        end;
      end
    else
      Query.ExecSQL;

  finally
    Placeholders.Free; Cols.Free; Query.Free;
  end;
end;

function TRepository<T>.Insert(const AEntity: T): IRepository<T>;
var
  Query: TFDQuery;
  PK: TRttiProperty;
  Cols, Placeholders: TList<string>;
  P: TRttiProperty;
  HasAutoIncPK: Boolean;
  ColName: string;
begin
  Result:= Self;
  Query:= TFDQuery.Create(nil);
  Cols := TList<string>.Create;
  Placeholders:= TList<string>.Create;
  try
    Query.Connection:= FConn.GetConnection;
    PK:= PrimaryKeyProp;
    HasAutoIncPK:= Assigned(PK) and TAttributeHelper.HasAttribute<AutoIncAttribute>(PK);

    for P in ColumnProps do
    begin
      if Assigned(PK) and (P.Name = PK.Name) and HasAutoIncPK then
        Continue;

      ColName:= GetColumnName(P);
      Cols.Add(ColName);
      Placeholders.Add(':' + ColName);
    end;

    Query.SQL.Text:= Format('INSERT INTO %s (%s) VALUES (%s)',
       [FTable, String.Join(', ', Cols.ToArray), String.Join(', ', Placeholders.ToArray)]);

    for P in ColumnProps do
    begin
      if Assigned(PK) and (P.Name = PK.Name) and HasAutoIncPK then
        Continue;

      ColName:= GetColumnName(P);

      with Query.ParamByName(ColName) do
      begin
        ParamType:= ptInput;
        Value:= P.GetValue(TObject(AEntity)).AsVariant;

        if P.PropertyType.Handle = TypeInfo(Integer) then
          DataType:= ftInteger
        else if P.PropertyType.Handle = TypeInfo(Int64) then
          DataType:= ftLargeint
        else if P.PropertyType.Handle = TypeInfo(Double) then
          DataType:= ftFloat
        else if P.PropertyType.Handle = TypeInfo(Currency) then
          DataType:= ftCurrency
        else if P.PropertyType.Handle = TypeInfo(string) then
          DataType:= ftString
        else if P.PropertyType.Handle = TypeInfo(TDateTime) then
          DataType:= ftDateTime
        else DataType:= ftVariant;
      end;
    end;

    Query.ExecSQL;

  finally
    Placeholders.Free; Cols.Free; Query.Free;
  end;
end;

function TRepository<T>.LastID(const ATable, AField: string): Integer;
var
  Query: TFDQuery;
begin
  Query:= TFDQuery.Create(nil);
  try
    Query.Connection:= FConn.GetConnection;
    Query.SQL.Text:= Format('SELECT coalesce(max(%s), 0) FROM %s', [AField, ATable]);
    Query.Open;
    Result:= Query.Fields[0].AsInteger;
  finally
    Query.Free;
  end;
end;

function TRepository<T>.List: IRepository<T>;
var
  Query: TFDQuery;
  SQL: string;
  Params: TArray<Variant>;
  I: Integer;
  P: TRttiProperty;
  Attr: TCustomAttribute;
  Fld: TField;
begin
  Result:= Self;

  if not Assigned(FSelect) then
    raise Exception.Create('Criteria não definido. Use .Criteria antes de .List');

  // Libera query anterior se existir
  if Assigned(FLastQuery) then
  begin
    FLastQuery.Free;
    FLastQuery:= nil;
  end;

  Query:= TFDQuery.Create(nil);
  Query.Connection:= FConn.GetConnection;
  FLastQuery:= Query;

  SQL:= FSelect.ToSQL(FTable, Params);

  if (FSelect.Limit > 0) and (FSelect.Offset > -1) then
    SQL:= TDatabaseDriverHelper.ApplyPagination(FConn.GetDatabaseDriver, SQL, FSelect.Limit, FSelect.Offset);

  FLastQuery.SQL.Text:= SQL;

  for I:= 0 to High(Params) do
  begin
    with FLastQuery.ParamByName('p' + I.ToString) do
    begin
      ParamType:= ptInput;
      Value    := Params[I];

      if VarIsNumeric(Value) then
        begin
          if VarType(Value) = varInt64 then
            DataType:= ftLargeint
          else
            DataType:= ftInteger;
        end
      else if VarIsType(Value, varInteger) then
        DataType:= ftInteger
      else if VarIsType(Value, varInt64) then
        DataType:= ftLargeint
      else if VarIsType(Value, varDouble) then
        DataType:= ftFloat
      else if VarIsType(Value, varCurrency) then
        DataType:= ftCurrency
      else if VarIsStr(Value) then
        DataType:= ftString
      else if VarIsType(Value, varDate) then
        DataType:= ftDateTime
      else
        DataType:= ftVariant;
    end;
  end;

  FLastQuery.Open;

  // Aplicar atributos visuais (DisplayLabel, DisplayFormat, DisplayWidth, etc)
  for P in FType.GetProperties do
  begin
    Fld:= FLastQuery.FindField(GetColumnName(P));

    if not Assigned(Fld) then
      Fld:= FLastQuery.FindField(P.Name);

    if Assigned(Fld) then
    begin
      for Attr in P.GetAttributes do
      begin
        if Attr is DisplayLabelAttribute then
          Fld.DisplayLabel:= DisplayLabelAttribute(Attr).LabelText;

        if Attr is DisplayWidthAttribute then
          Fld.DisplayWidth:= DisplayWidthAttribute(Attr).Width;

        if Attr is DisplayFormatAttribute then
        begin
          if Fld is TNumericField then
            TNumericField(Fld).DisplayFormat:= DisplayFormatAttribute(Attr).FormatText
          else if Fld is TDateTimeField then
            TDateTimeField(Fld).DisplayFormat:= DisplayFormatAttribute(Attr).FormatText;
        end;
      end;
    end;
  end;

  if Assigned(FDataSource) then
    FDataSource.DataSet:= FLastQuery;

  FSelect:= nil;
end;

end.
