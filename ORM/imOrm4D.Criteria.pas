unit imOrm4D.Criteria;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.StrUtils,
  imOrm4D.Interfaces.Criteria;

type
  TCriteria<T: IInterface> = class(TInterfacedObject, ICriteria<T>)
  private
    FPredicates: TList<TPredicate>;
    FPredicate: TPredicate;
    FOrder: TOrder;
    FOrders: TList<TOrder>;
    FLimit: Integer;
    FOffset: Integer;
    FFields: TList<string>;
    FSelectFields: TArray<string>;
    FJoins: TList<TJoin>;
    FAliasName: string;
    [Weak] FRepository: T; // Referência para o IRepository
  public
    constructor Create(AOwner: T);
    destructor Destroy; override;

    function AddField(const AField: string): ICriteria<T>;
    function Equal(const AField: string; const AValue: Variant): ICriteria<T>;
    function Like(const AField, APattern: string): ICriteria<T>;
    function GreaterThan(const AField: string; const AValue: Integer): ICriteria<T>;
    function LessThan(const AField: string; const AValue: Integer): ICriteria<T>;
    function &In(const AField: string; const AValues: array of Integer): ICriteria<T>; overload;
    function &In(const AField: string; const AValues: array of string): ICriteria<T>; overload;
    function Between(const AField: string; const Value1, Value2: Integer): ICriteria<T>; overload;
    function Between(const AField: string; const Value1, Value2: TDateTime): ICriteria<T>; overload;
    function IsNull(const AField: string): ICriteria<T>;
    function IsNotNull(const AField: string): ICriteria<T>;
    function InnerJoin(const ATable, OnCondition: string): ICriteria<T>;
    function LeftJoin(const ATable, OnCondition: string): ICriteria<T>;
    function OrderBy(const AField: string; const Desc: Boolean = False): ICriteria<T>;
    function Limit(const ACount: Integer): ICriteria<T>;
    function Offset(const AOffset: Integer): ICriteria<T>;
    function ToSQL(const ATable: string; out Params: TArray<Variant>): string;
    function SelectedFields: TArray<string>;
    function TableAlias(const AliasName: string): ICriteria<T>;
    function &End: T;
  end;

implementation

uses
  System.Variants;

function TCriteria<T>.Between(const AField: string; const Value1, Value2: Integer): ICriteria<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opBetween;
  FPredicate.Value1:= Value1;
  FPredicate.Value2:= Value2;
  FPredicates.Add(FPredicate);
end;

function TCriteria<T>.&End: T;
begin
  Result:= FRepository;
end;

function TCriteria<T>.Between(const AField: string; const Value1, Value2: TDateTime): ICriteria<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opBetween;
  FPredicate.Value1:= Value1;
  FPredicate.Value2:= Value2;
  FPredicates.Add(FPredicate);
end;

function TCriteria<T>.&In(const AField: string; const AValues: array of string): ICriteria<T>;
var
  I: Integer;
begin
  Result:= Self;

  FPredicate.Field:= AField;
  FPredicate.Op   := opIn;
  SetLength(FPredicate.Values, Length(AValues));

  for I := 0 to High(AValues) do
    FPredicate.Values[I]:= AValues[I];

  FPredicates.Add(FPredicate);
end;

function TCriteria<T>.&In(const AField: string; const AValues: array of Integer): ICriteria<T>;
var
  I: Integer;
begin
  Result:= Self;

  FPredicate.Field:= AField;
  FPredicate.Op   := opIn;
  SetLength(FPredicate.Values, Length(AValues));

  for I:= 0 to High(AValues) do
    FPredicate.Values[I]:= AValues[I];

  FPredicates.Add(FPredicate);
end;

constructor TCriteria<T>.Create(AOwner: T);
begin
  FRepository:= AOwner;
  FPredicates:= TList<TPredicate>.Create;
  FOrders:= TList<TOrder>.Create;
  FJoins := TList<TJoin>.Create;
  FFields:= TList<string>.Create;
  FLimit := -1;
  FOffset:= -1;
end;

destructor TCriteria<T>.Destroy;
begin
  FPredicates.Free;
  FOrders.Free;
  FJoins.Free;
  FFields.free;
  inherited;
end;

function TCriteria<T>.Equal(const AField: string; const AValue: Variant): ICriteria<T>;
begin
  FPredicate.Field:= AField;
  FPredicate.Op   := opEq;
  FPredicate.Value:= AValue;
  FPredicates.Add(FPredicate);
  Result:= Self;
end;

function TCriteria<T>.InnerJoin(const ATable, OnCondition: string): ICriteria<T>;
begin
  Result:= Self;
  FJoins.Add(TJoin.Make(jtInner, aTable, OnCondition));
end;

function TCriteria<T>.IsNotNull(const AField: string): ICriteria<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opIsNotNull;
  FPredicate.Value:= Null;

  FPredicates.Add(FPredicate);
end;

function TCriteria<T>.IsNull(const AField: string): ICriteria<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opIsNull;
  FPredicate.Value:= Null;

  FPredicates.Add(FPredicate);
end;

function TCriteria<T>.Like(const AField, APattern: string): ICriteria<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opLike;
  FPredicate.Value:= APattern;
  FPredicates.Add(FPredicate);
end;

function TCriteria<T>.GreaterThan(const AField: string; const AValue: Integer): ICriteria<T>;
begin
  FPredicate.Field:= AField;
  FPredicate.Op   := opGt;
  FPredicate.Value:= AValue;
  FPredicates.Add(FPredicate);
  Result := Self;
end;

function TCriteria<T>.LessThan(const AField: string; const AValue: Integer): ICriteria<T>;
begin
  FPredicate.Field:= AField;
  FPredicate.Op   := opLt;
  FPredicate.Value:= AValue;
  FPredicates.Add(FPredicate);
  Result:= Self;
end;

function TCriteria<T>.OrderBy(const AField: string; const Desc: Boolean): ICriteria<T>;
begin
  FOrder.Field:= AField;
  FOrder.Desc := Desc;
  FOrders.Add(FOrder);

  Result:= Self;
end;

function TCriteria<T>.LeftJoin(const ATable, OnCondition: string): ICriteria<T>;
begin
  Result:= Self;
  FJoins.Add(TJoin.Make(jtLeft, aTable, OnCondition));
end;

function TCriteria<T>.SelectedFields: TArray<string>;
begin
  Result:= FSelectFields;
end;

function TCriteria<T>.AddField(const AField: string): ICriteria<T>;
begin
  Result:= Self;
  FFields.Add(AField);
end;

function TCriteria<T>.Limit(const ACount: Integer): ICriteria<T>;
begin
  FLimit:= ACount;
  Result:= Self;
end;

function TCriteria<T>.Offset(const AOffset: Integer): ICriteria<T>;
begin
  FOffset:= AOffset;
  Result := Self;
end;

function TCriteria<T>.TableAlias(const AliasName: string): ICriteria<T>;
begin
  Result:= Self;
  FAliasName:= Trim(AliasName);
end;

function TCriteria<T>.ToSQL(const ATable: string; out Params: TArray<Variant>): string;
var
  WhereParts: TArray<string>;
  P: TPredicate;
  I, ParamIndex: Integer;
  Placeholders: string;
  SelectClause: string;
  J: TJoin;
begin
  SetLength(Params, 0);
  SetLength(WhereParts, 0);
  ParamIndex:= 0;

  // SELECT
  if FFields.Count > 0 then
    SelectClause:= 'SELECT ' + String.Join(', ', FFields.ToArray)
  else
    SelectClause:= 'SELECT *';

  if Trim(FAliasName) <> EmptyStr then
    Result:= SelectClause + ' FROM ' + ATable + ' ' + FAliasName
  else
    Result:= SelectClause + ' FROM ' + ATable;

  // JOINS
  for J in FJoins do
  begin
    case J.JoinType of
      jtInner: Result:= Result + ' INNER JOIN ' + J.Table + ' ON ' + J.OnCondition;
      jtLeft : Result:= Result + ' LEFT JOIN ' + J.Table + ' ON ' + J.OnCondition;
    end;
  end;

  for P in FPredicates do
  begin
    case P.Op of
      opEq:
        begin
          WhereParts:= WhereParts + [Format('%s = :p%d', [P.Field, ParamIndex])];
          Params    := Params + [P.Value];
          Inc(ParamIndex);
        end;

      opNe:
        begin
          WhereParts:= WhereParts + [Format('%s <> :p%d', [P.Field, ParamIndex])];
          Params    := Params + [P.Value];
          Inc(ParamIndex);
        end;

      opGt:
        begin
          WhereParts:= WhereParts + [Format('%s > :p%d', [P.Field, ParamIndex])];
          Params    := Params + [P.Value];
          Inc(ParamIndex);
        end;

      opGe:
        begin
          WhereParts:= WhereParts + [Format('%s >= :p%d', [P.Field, ParamIndex])];
          Params    := Params + [P.Value];
          Inc(ParamIndex);
        end;

      opLt:
        begin
          WhereParts:= WhereParts + [Format('%s < :p%d', [P.Field, ParamIndex])];
          Params    := Params + [P.Value];
          Inc(ParamIndex);
        end;

      opLe:
        begin
          WhereParts:= WhereParts + [Format('%s <= :p%d', [P.Field, ParamIndex])];
          Params    := Params + [P.Value];
          Inc(ParamIndex);
        end;

      opLike:
        begin
          WhereParts:= WhereParts + [' ' + P.Field + ' LIKE ' +  QuotedStr('%') + ' || ' + Format(':p%d', [ParamIndex]) + ' || ' + QuotedStr('%')];
          Params    := Params + [P.Value];
          Inc(ParamIndex);
        end;

      opBetween:
        begin
          WhereParts := WhereParts + [Format('%s BETWEEN :p%d AND :p%d', [P.Field, ParamIndex, ParamIndex + 1])];
          Params := Params + [P.Value1];
          Params := Params + [P.Value2];
          Inc(ParamIndex, 2);
        end;

      opIn:
        begin
          if Length(P.Values) = 0 then
            raise Exception.Create('IN clause requires at least one value');

          Placeholders:= '';

          for I:= 0 to High(P.Values) do
          begin
            Placeholders:= Placeholders + Format(':p%d', [ParamIndex]);
            Params      := Params + [P.Values[I]];
            Inc(ParamIndex);

            if I < High(P.Values) then
              Placeholders:= Placeholders + ', ';
          end;

          WhereParts:= WhereParts + [Format('%s IN (%s)', [P.Field, Placeholders])];
        end;

      opIsNull:
        WhereParts:= WhereParts + [Format('%s IS NULL', [P.Field])];

      opIsNotNull:
        WhereParts:= WhereParts + [Format('%s IS NOT NULL', [P.Field])];
    end;
  end;

  if Length(WhereParts) > 0 then
    Result:= Result + ' WHERE ' + String.Join(' AND ', WhereParts);

  // ORDER BY
  if FOrders.Count > 0 then
  begin
    Result:= Result + ' ORDER BY ';

    for I:= 0 to FOrders.Count - 1 do
    begin
      Result:= Result + FOrders[I].Field;

      if FOrders[I].Desc then
        Result:= Result + ' DESC'
      else
        Result:= Result + ' ASC';

      if I < FOrders.Count - 1 then
        Result := Result + ', ';
    end;
  end;

  if FLimit >= 0 then
    Result:= Result + Format(' LIMIT %d', [FLimit]);

  if FOffset >= 0 then
    Result:= Result + Format(' OFFSET %d', [FOffset]);
end;

end.

