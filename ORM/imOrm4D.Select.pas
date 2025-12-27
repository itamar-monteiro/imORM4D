unit imOrm4D.Select;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.StrUtils,
  imOrm4D.Interfaces.Select;

type
  TSelect<T: IInterface> = class(TInterfacedObject, ISelect<T>)
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
    FGroupBy: TList<string>;
    FAliasName: string;
    [Weak] FRepository: T; // Referência para o IRepository
  public
    constructor Create(AOwner: T);
    destructor Destroy; override;

    function AddField(const AField: string): ISelect<T>;
    function Equal(const AField: string; const AValue: Variant): ISelect<T>;
    function Like(const AField, APattern: string): ISelect<T>;
    function GreaterThan(const AField: string; const AValue: Integer): ISelect<T>;
    function LessThan(const AField: string; const AValue: Integer): ISelect<T>;
    function &In(const AField: string; const AValues: array of Integer): ISelect<T>; overload;
    function &In(const AField: string; const AValues: array of string): ISelect<T>; overload;
    function Between(const AField: string; const Value1, Value2: Integer): ISelect<T>; overload;
    function Between(const AField: string; const Value1, Value2: TDateTime): ISelect<T>; overload;
    function IsNull(const AField: string): ISelect<T>;
    function IsNotNull(const AField: string): ISelect<T>;
    function InnerJoin(const ATable, OnCondition: string): ISelect<T>;
    function LeftJoin(const ATable, OnCondition: string): ISelect<T>;
    function OrderBy(const AField: string; const Desc: Boolean = False): ISelect<T>;
    function GroupBy(const AField: string): ISelect<T>;
    function Limit(const ACount: Integer): ISelect<T>; overload;
    function Offset(const AOffset: Integer): ISelect<T>; overload;
    function Limit: Integer; overload;
    function Offset: Integer; overload;
    function ToSQL(const ATable: string; out Params: TArray<Variant>): string;
    function SelectedFields: TArray<string>;
    function TableAlias(const AliasName: string): ISelect<T>;
    function Skip(const ACount: Integer): ISelect<T>;
    function Take(const ACount: Integer): ISelect<T>;
    function &End: T;
  end;

implementation

uses
  System.Variants;

function TSelect<T>.Between(const AField: string; const Value1, Value2: Integer): ISelect<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opBetween;
  FPredicate.Value1:= Value1;
  FPredicate.Value2:= Value2;
  FPredicates.Add(FPredicate);
end;

function TSelect<T>.&End: T;
begin
  Result:= FRepository;
end;

function TSelect<T>.Between(const AField: string; const Value1, Value2: TDateTime): ISelect<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opBetween;
  FPredicate.Value1:= Value1;
  FPredicate.Value2:= Value2;
  FPredicates.Add(FPredicate);
end;

function TSelect<T>.&In(const AField: string; const AValues: array of string): ISelect<T>;
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

function TSelect<T>.&In(const AField: string; const AValues: array of Integer): ISelect<T>;
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

constructor TSelect<T>.Create(AOwner: T);
begin
  FRepository:= AOwner;
  FPredicates:= TList<TPredicate>.Create;
  FOrders := TList<TOrder>.Create;
  FJoins  := TList<TJoin>.Create;
  FFields := TList<string>.Create;
  FGroupBy:= TList<string>.Create;
  FLimit  := -1;
  FOffset := -1;
end;

destructor TSelect<T>.Destroy;
begin
  FPredicates.Free;
  FOrders.Free;
  FJoins.Free;
  FFields.free;
  FGroupBy.Free;
  inherited;
end;

function TSelect<T>.Equal(const AField: string; const AValue: Variant): ISelect<T>;
begin
  FPredicate.Field:= AField;
  FPredicate.Op   := opEq;
  FPredicate.Value:= AValue;
  FPredicates.Add(FPredicate);
  Result:= Self;
end;

function TSelect<T>.InnerJoin(const ATable, OnCondition: string): ISelect<T>;
begin
  Result:= Self;
  FJoins.Add(TJoin.Make(jtInner, aTable, OnCondition));
end;

function TSelect<T>.IsNotNull(const AField: string): ISelect<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opIsNotNull;
  FPredicate.Value:= Null;

  FPredicates.Add(FPredicate);
end;

function TSelect<T>.IsNull(const AField: string): ISelect<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opIsNull;
  FPredicate.Value:= Null;

  FPredicates.Add(FPredicate);
end;

function TSelect<T>.Like(const AField, APattern: string): ISelect<T>;
begin
  Result:= Self;
  FPredicate.Field:= AField;
  FPredicate.Op   := opLike;
  FPredicate.Value:= APattern;
  FPredicates.Add(FPredicate);
end;

function TSelect<T>.Limit: Integer;
begin
  Result:= FLimit;
end;

function TSelect<T>.GreaterThan(const AField: string; const AValue: Integer): ISelect<T>;
begin
  FPredicate.Field:= AField;
  FPredicate.Op   := opGt;
  FPredicate.Value:= AValue;
  FPredicates.Add(FPredicate);
  Result := Self;
end;

function TSelect<T>.GroupBy(const AField: string): ISelect<T>;
begin
  Result:= Self;
  FGroupBy.Add(AField);
end;

function TSelect<T>.LessThan(const AField: string; const AValue: Integer): ISelect<T>;
begin
  FPredicate.Field:= AField;
  FPredicate.Op   := opLt;
  FPredicate.Value:= AValue;
  FPredicates.Add(FPredicate);
  Result:= Self;
end;

function TSelect<T>.Offset: Integer;
begin
  Result:= FOffset;
end;

function TSelect<T>.OrderBy(const AField: string; const Desc: Boolean): ISelect<T>;
begin
  FOrder.Field:= AField;
  FOrder.Desc := Desc;
  FOrders.Add(FOrder);

  Result:= Self;
end;

function TSelect<T>.LeftJoin(const ATable, OnCondition: string): ISelect<T>;
begin
  Result:= Self;
  FJoins.Add(TJoin.Make(jtLeft, aTable, OnCondition));
end;

function TSelect<T>.SelectedFields: TArray<string>;
begin
  Result:= FSelectFields;
end;

function TSelect<T>.Skip(const ACount: Integer): ISelect<T>;
begin
  Result:= Self;
  FOffset:= ACount;
end;

function TSelect<T>.AddField(const AField: string): ISelect<T>;
begin
  Result:= Self;
  FFields.Add(AField);
end;

function TSelect<T>.Limit(const ACount: Integer): ISelect<T>;
begin
  FLimit:= ACount;
  Result:= Self;
end;

function TSelect<T>.Offset(const AOffset: Integer): ISelect<T>;
begin
  FOffset:= AOffset;
  Result := Self;
end;

function TSelect<T>.TableAlias(const AliasName: string): ISelect<T>;
begin
  Result:= Self;
  FAliasName:= Trim(AliasName);
end;

function TSelect<T>.Take(const ACount: Integer): ISelect<T>;
begin
  Result:= Self;
  FLimit:= ACount;
end;

function TSelect<T>.ToSQL(const ATable: string; out Params: TArray<Variant>): string;
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

  // GROUP BY
  if FGroupBy.Count > 0 then
    Result:= Result + ' GROUP BY ' + String.Join(', ', FGroupBy.ToArray);

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

//  if FLimit >= 0 then
//    Result:= Result + Format(' LIMIT %d', [FLimit]);
//
//  if FOffset >= 0 then
//    Result:= Result + Format(' OFFSET %d', [FOffset]);
end;

end.

