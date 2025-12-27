unit imOrm4D.Interfaces.Select;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Variants;

type
  TOperator = (opEq, opNe, opGt, opGe, opLt, opLe, opLike, opIn, opBetween, opIsNull, opIsNotNull);
  TJoinType = (jtInner, jtLeft);

  TPredicate = record
    Field: string;
    Op: TOperator;
    Value: Variant;
    Value1: Variant;
    Value2: Variant;
    Values: TArray<Variant>;

    constructor Create(const AField: string; AOp: TOperator; const AValue: Variant); overload;
    constructor Create(const AField: string; AOp: TOperator; const AValue1, AValue2: Variant); overload;
    constructor Create(const AField: string; AOp: TOperator; const AValues: array of Variant); overload;
  end;

  TOrder = record
    Field: string;
    Desc: Boolean;
  end;

  TJoin = record
    JoinType: TJoinType;
    Table: string;
    OnCondition: string;

    class function Make(AType: TJoinType; const ATable, AOn: string): TJoin; static;
  end;

  ISelect<T> = interface
    ['{DF2E963E-4727-4F8C-9F85-358F4A7267BD}']
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
    // Método para retornar ao IRepository
    function &End: T;
  end;

  implementation

{ TPredicate }

constructor TPredicate.Create(const AField: string; AOp: TOperator; const AValue: Variant);
begin
  Field:= AField;
  Op:= AOp;
  Value:= AValue;
end;

constructor TPredicate.Create(const AField: string; AOp: TOperator; const AValue1, AValue2: Variant);
begin
  Field:= AField;
  Op:= AOp;
  Value1:= AValue1;
  Value2:= AValue2;
end;

constructor TPredicate.Create(const AField: string; AOp: TOperator; const AValues: array of Variant);
var
  I: Integer;
begin
  Field:= AField;
  Op:= AOp;
  SetLength(Values, Length(AValues));
  for I:= 0 to High(AValues) do
    Values[I]:= AValues[I];
end;

{ TJoin }

class function TJoin.Make(AType: TJoinType; const ATable, AOn: string): TJoin;
begin
  Result.JoinType   := AType;
  Result.Table      := ATable;
  Result.OnCondition:= AOn;
end;

end.

