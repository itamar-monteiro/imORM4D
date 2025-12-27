unit Orm4DExample;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  System.Generics.Collections,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Data.DB,
  Vcl.Grids,
  Vcl.DBGrids,
  imORM4D.Sample.Entidade.Produto,
  imOrm4D.Interfaces.Connection,
  imOrm4D.Interfaces.Repository;

type
  TFSample = class(TForm)
    Button1: TButton;
    Panel1: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Label4: TLabel;
    Edit4: TEdit;
    Label5: TLabel;
    Edit5: TEdit;
    Label6: TLabel;
    Edit6: TEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
  private
    FConn: IDatabaseConnection;
    FRepo: IRepository<TProduto>;
    FProduto: TProduto;
    FIdProduto: Integer;
    procedure LimparControles;
    procedure ListarProdutos;
    procedure AjustarColumnWidth;
  public
    { Public declarations }
  end;

var
  FSample: TFSample;

implementation

uses
  imOrm4D.Connection.Postgres,
  imOrm4D.Repository;

{$R *.dfm}

procedure TFSample.AjustarColumnWidth;
var
  Ltam: Integer;
  I: Integer;
begin
  for I:= 0 to Pred(DataSource1.DataSet.Fields.Count) do
  begin
    Ltam:= DataSource1.DataSet.Fields[i].DisplayWidth;
    DBGrid1.Columns[i].Width:= Ltam;
  end;
end;

procedure TFSample.Button10Click(Sender: TObject);
begin
  FRepo
    .Select
      .LessThan('cod_produto', 10)
      .OrderBy('cod_produto', false)
    .&End
  .DataSource(DataSource1)
  .List;
end;

procedure TFSample.Button11Click(Sender: TObject);
begin
  FRepo
    .Select
      .AddField('codigo1')
      .AddField('count(1) total')
      .GroupBy('codigo1')
      .OrderBy('count(1)', True)
    .&End
  .DataSource(DataSource1)
  .List;
end;

procedure TFSample.Button12Click(Sender: TObject);
const
  PAGE_SIZE = 10;
  PAGE = 2;
begin
  FRepo
    .Select
      .TableAlias('p')
      .AddField('p.cod_produto')
      .AddField('p.codigo1')
      .AddField('p.descricao')
      .AddField('p.marca')
      .AddField('p.qtd')
      .AddField('p.tipo_unidade')
      .AddField('p.preco_venda')
      .AddField('p.titulo')
      .AddField('g.descricao as nome_grupo')
      .LeftJoin('tbgrupo g', 'g.cod_grupo = p.titulo')
      .Skip((PAGE-1) * PAGE_SIZE)
      .Take(PAGE_SIZE)
      .OrderBy('p.cod_produto')
    .&End
  .DataSource(DataSource1)
  .List;
end;

procedure TFSample.Button1Click(Sender: TObject);
var
  I: Integer;
begin
  for I:= 0 to Pred(Panel1.ControlCount) do
  begin
    if (Panel1.Controls[i] is TEdit) and (TEdit(Panel1.Controls[i]).Text = EmptyStr) then
    begin
      ShowMessage('Preencha os campos');
      Exit;
    end;
  end;

  FProduto:= TProduto.New;
  try
    FProduto.Descricao := Trim(Edit1.Text);
    FProduto.Codigo    := Trim(Edit2.Text);
    FProduto.Marca     := Trim(Edit3.Text);
    FProduto.Quantidade:= StrToFloatDef(Trim(Edit4.Text), 1);
    FProduto.Tipo      := Trim(Edit5.Text);
    FProduto.PrecoVenda:= StrToCurrDef(Trim(Edit6.Text), 1);
    FRepo.Insert(FProduto);
    ShowMessage('Registro inserido com sucesso');
    Self.ListarProdutos;
    LimparControles;
    Edit1.SetFocus;
  finally
    FProduto.Free;
  end;
end;

procedure TFSample.Button2Click(Sender: TObject);
begin
  FIdProduto:= StrToIntDef(InputBox('Digite o ID do produto', 'Id do Produto:', ''), 0);

  FRepo
    .Select
      .Equal('cod_produto', FIdProduto)
      .TableAlias('p')
      .AddField('p.cod_produto')
      .AddField('p.codigo1')
      .AddField('p.descricao')
      .AddField('p.marca')
      .AddField('p.qtd')
      .AddField('p.tipo_unidade')
      .AddField('p.preco_venda')
      .AddField('p.titulo')
      .AddField('g.descricao as nome_grupo')
      .LeftJoin('tbgrupo g', 'g.cod_grupo = p.titulo')
    .&End
  .DataSource(DataSource1)
  .List;

  AjustarColumnWidth;

  if not DataSource1.DataSet.IsEmpty then
  begin
    Edit1.Text:= DataSource1.DataSet.FieldByName('descricao').AsString;
    Edit2.Text:= DataSource1.DataSet.FieldByName('codigo1').AsString;
    Edit3.Text:= DataSource1.DataSet.FieldByName('marca').AsString;
    Edit4.Text:= DataSource1.DataSet.FieldByName('qtd').AsString;
    Edit5.Text:= DataSource1.DataSet.FieldByName('tipo_unidade').AsString;
    Edit6.Text:= FormatFloat(',0.00', DataSource1.DataSet.FieldByName('preco_venda').AsCurrency);
    Button3.Enabled:= True;
    Button4.Enabled:= True;
  end;

  { Pesquisa sem DataSet somente usando objetos  }
  {
  FProduto:= FRepo.GetById(FIdProduto);

  if Assigned(FProduto) then
  begin
    DataSource1.DataSet:= FRepo.QueryToDataSet(FCriteria);
    Edit1.Text:= FProduto.Descricao;
    Edit2.Text:= FProduto.Codigo;
    Edit3.Text:= FProduto.Marca;
    Edit4.Text:= FloatToStr(FProduto.Quantidade);
    Edit5.Text:= FProduto.Tipo;
    Edit6.Text:= CurrToStrF(FProduto.PrecoVenda, TFloatFormat.ffCurrency, 2);
    FProduto.Free;
    Button3.Enabled:= True;
    Button4.Enabled:= True;
  end;
  }
end;

procedure TFSample.Button3Click(Sender: TObject);
begin
  FProduto:= FRepo.GetById(FIdProduto);

  if Assigned(FProduto) then
  begin
    try
      FProduto.Descricao := Trim(Edit1.Text);
      FProduto.Codigo    := Trim(Edit2.Text);
      FProduto.Marca     := Trim(Edit3.Text);
      FProduto.Quantidade:= StrToFloatDef(Trim(Edit4.Text), 1);
      FProduto.Tipo      := Trim(Edit5.Text);
      FProduto.PrecoVenda:= StrToCurrDef(Trim(Edit6.Text), 1);
      FRepo.Update(FProduto);
      ShowMessage('Produto alterado com sucesso');
      Self.ListarProdutos;
      AjustarColumnWidth;
      Edit1.SetFocus;
    finally
      FProduto.Free;
    end;
  end;
end;

procedure TFSample.Button4Click(Sender: TObject);
begin
  FProduto:= FRepo.GetById(FIdProduto);
  if Assigned(FProduto) then
  begin
    try
      FRepo.Delete(FProduto);
      ShowMessage('Produto excluido com sucesso');
      Self.LimparControles;
      Button3.Enabled:= False;
      Button4.Enabled:= False;
      Self.ListarProdutos;
      AjustarColumnWidth;
      Edit1.SetFocus;
    finally
      FProduto.Free;
    end;
  end;
end;

procedure TFSample.Button5Click(Sender: TObject);
begin
  ListarProdutos;
  AjustarColumnWidth;
end;

procedure TFSample.Button6Click(Sender: TObject);
begin
  FRepo
    .Select
      .Like('descricao', 'SIMPLEX')
      .Like('codigo1', 'SAB')
      .OrderBy('cod_produto', false)
    .&End
  .DataSource(DataSource1)
  .List;

end;

procedure TFSample.Button7Click(Sender: TObject);
begin
  FRepo
    .Select
      .Between('cod_produto', 1, 5)
      .OrderBy('cod_produto', false)
    .&End
  .DataSource(DataSource1)
  .List;
end;

procedure TFSample.Button8Click(Sender: TObject);
begin
  FRepo
    .Select
      .&In('cod_produto', [1,3,5,10])
      .OrderBy('cod_produto', false)
    .&End
  .DataSource(DataSource1)
  .List;
end;

procedure TFSample.Button9Click(Sender: TObject);
begin
  FRepo
    .Select
      .GreaterThan('cod_produto', 10)
      .OrderBy('cod_produto', false)
    .&End
  .DataSource(DataSource1)
  .List;
end;

procedure TFSample.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown:= True;

  FConn:= TPostgresConnection.New('Localhost', 'estoque_db', 'postgres', 'masterkey', 5432);
  FConn.Connect;

  FRepo:= TRepository<TProduto>.Create(FConn);
  FIdProduto:= 0;
end;

procedure TFSample.LimparControles;
begin
  Edit1.Clear;
  Edit2.Clear;
  Edit3.Clear;
  Edit4.Text:= '1';
  Edit5.Text:= 'UND';
  Edit6.Text:= '1,00';
end;

procedure TFSample.ListarProdutos;
begin
  FRepo
    .Select
      .TableAlias('p')
      .AddField('p.cod_produto')
      .AddField('p.codigo1')
      .AddField('p.descricao')
      .AddField('p.marca')
      .AddField('p.qtd')
      .AddField('p.tipo_unidade')
      .AddField('p.preco_venda')
      .AddField('p.titulo')
      .AddField('g.descricao as nome_grupo')
      .LeftJoin('tbgrupo g', 'g.cod_grupo = p.titulo')
      .OrderBy('cod_produto', False)
    .&End
  .DataSource(DataSource1)
  .List;
end;

end.
