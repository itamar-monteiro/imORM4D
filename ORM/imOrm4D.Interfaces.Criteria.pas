unit imOrm4D.Interfaces.Criteria;

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

  ICriteria<T> = interface
    ['{DF2E963E-4727-4F8C-9F85-358F4A7267BD}']
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

