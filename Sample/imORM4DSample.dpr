program imORM4DSample;

uses
  Vcl.Forms,
  Orm4DExample in 'Orm4DExample.pas' {FSample},
  imOrm4D.Attributes in '..\ORM\imOrm4D.Attributes.pas',
  imOrm4D.Attributes.Helper in '..\ORM\imOrm4D.Attributes.Helper.pas',
  imOrm4D.Interfaces.Criteria in '..\ORM\imOrm4D.Interfaces.Criteria.pas',
  imOrm4D.Criteria in '..\ORM\imOrm4D.Criteria.pas',
  imOrm4D.Interfaces.Repository in '..\ORM\imOrm4D.Interfaces.Repository.pas',
  imOrm4D.Repository in '..\ORM\imOrm4D.Repository.pas',
  imORM4D.Sample.Entidade.Produto in 'Entidades\imORM4D.Sample.Entidade.Produto.pas',
  imOrm4D.DisplayAttributes in '..\ORM\imOrm4D.DisplayAttributes.pas',
  imOrm4D.Connection.BaseConnection in '..\ORM\Drivers\imOrm4D.Connection.BaseConnection.pas',
  imOrm4D.Connection.Firebird in '..\ORM\Drivers\imOrm4D.Connection.Firebird.pas',
  imOrm4D.Connection.Postgres in '..\ORM\Drivers\imOrm4D.Connection.Postgres.pas',
  imOrm4D.Interfaces.Connection in '..\ORM\Drivers\imOrm4D.Interfaces.Connection.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFSample, FSample);
  Application.Run;
end.
