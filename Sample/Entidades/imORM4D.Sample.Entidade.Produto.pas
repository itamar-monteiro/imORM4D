unit imORM4D.Sample.Entidade.Produto;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  System.Variants,
  Winapi.Messages,
  imOrm4D.Attributes,
  imOrm4D.DisplayAttributes;

type
  [Table('tbproduto')]
  TProduto = class
  private
    FId: Integer;
    FCodigo: string;
    FDescricao: string;
    FMarca: string;
    FTipo: string;
    FQuantidade: Double;
    FPrecoVenda: Currency;
    FidGrupo: Integer;
    FNomeGrupo: string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: TProduto;

    [Column('cod_produto')]
    [DisplayLabel('Id')]
    [PrimaryKey]
    [AutoInc]
    [DisplayWidth(50)]
    property Id: Integer read FId write FId;

    [Column('codigo1')]
    [DisplayLabel('Cód.Produto')]
    [DisplayWidth(100)]
    property Codigo: string read FCodigo write FCodigo;

    [Column('descricao')]
    [DisplayLabel('Descrição do Produto')]
    [DisplayWidth(300)]
    property Descricao: string read FDescricao write FDescricao;

    [Column('marca')]
    [DisplayLabel('Marca')]
    [DisplayWidth(130)]
    property Marca: string read FMarca write FMarca;

    [Column('tipo_unidade')]
    [DisplayLabel('Tipo')]
    [DisplayWidth(80)]
    property Tipo: string read FTipo write FTipo;

    [Column('qtd')]
    [DisplayLabel('Quant.')]
    [DisplayFormat('000#')]
    [DisplayWidth(70)]
    property Quantidade: Double read FQuantidade write FQuantidade;

    [Column('preco_venda')]
    [DisplayLabel('Preço Venda')]
    [DisplayFormat(',0.00')]
    [DisplayWidth(100)]
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;

    [Column('titulo')]
    [DisplayLabel('Grupo')]
    [DisplayWidth(50)]
    property idGrupo: Integer read FidGrupo write FidGrupo;

    [Column('nome_grupo')]
    [DisplayLabel('Nome do grupo')]
    [IgnoreMapping]
    [DisplayWidth(150)]
    property NomeGrupo: string read FNomeGrupo write FNomeGrupo;
  end;

implementation

{ TProduto }

constructor TProduto.Create;
begin

end;

destructor TProduto.Destroy;
begin
  inherited;
end;

class function TProduto.New: TProduto;
begin
  Result:= Self.Create;
end;

end.
