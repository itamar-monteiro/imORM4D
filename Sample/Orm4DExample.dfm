object FSample: TFSample
  Left = 0
  Top = 0
  Caption = 'FSample'
  ClientHeight = 539
  ClientWidth = 964
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    964
    539)
  TextHeight = 15
  object Button1: TButton
    Left = 8
    Top = 127
    Width = 150
    Height = 35
    Caption = 'NOVO PRODUTO'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 8
    Top = 8
    Width = 621
    Height = 113
    BevelInner = bvLowered
    TabOrder = 1
    object Label1: TLabel
      Left = 18
      Top = 16
      Width = 51
      Height = 15
      Caption = 'Descri'#231#227'o'
    end
    object Label2: TLabel
      Left = 36
      Top = 45
      Width = 39
      Height = 15
      Caption = 'C'#243'digo'
    end
    object Label3: TLabel
      Left = 232
      Top = 45
      Width = 33
      Height = 15
      Caption = 'Marca'
    end
    object Label4: TLabel
      Left = 384
      Top = 45
      Width = 29
      Height = 15
      Caption = 'Qtde.'
    end
    object Label5: TLabel
      Left = 52
      Top = 72
      Width = 23
      Height = 15
      Caption = 'Tipo'
    end
    object Label6: TLabel
      Left = 291
      Top = 72
      Width = 81
      Height = 15
      Caption = 'Pre'#231'o de Venda'
    end
    object Edit1: TEdit
      Left = 91
      Top = 13
      Width = 384
      Height = 23
      CharCase = ecUpperCase
      TabOrder = 0
    end
    object Edit2: TEdit
      Left = 91
      Top = 40
      Width = 137
      Height = 23
      CharCase = ecUpperCase
      TabOrder = 1
    end
    object Edit3: TEdit
      Left = 267
      Top = 40
      Width = 111
      Height = 23
      CharCase = ecUpperCase
      TabOrder = 2
    end
    object Edit4: TEdit
      Left = 418
      Top = 40
      Width = 57
      Height = 23
      Alignment = taRightJustify
      CharCase = ecUpperCase
      NumbersOnly = True
      TabOrder = 3
    end
    object Edit5: TEdit
      Left = 91
      Top = 67
      Width = 97
      Height = 23
      CharCase = ecUpperCase
      TabOrder = 4
    end
    object Edit6: TEdit
      Left = 378
      Top = 67
      Width = 97
      Height = 23
      CharCase = ecUpperCase
      TabOrder = 5
    end
  end
  object Button2: TButton
    Left = 164
    Top = 127
    Width = 150
    Height = 35
    Caption = 'BUSCAR POR ID'
    TabOrder = 2
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 321
    Top = 127
    Width = 150
    Height = 35
    Caption = 'ALTERAR'
    Enabled = False
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 479
    Top = 127
    Width = 150
    Height = 35
    Caption = 'EXCLUIR'
    Enabled = False
    TabOrder = 4
    OnClick = Button4Click
  end
  object DBGrid1: TDBGrid
    Left = 8
    Top = 248
    Width = 944
    Height = 283
    Anchors = [akLeft, akTop, akRight, akBottom]
    DataSource = DataSource1
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgAlwaysShowSelection, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    TabOrder = 5
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
  end
  object Button5: TButton
    Left = 8
    Top = 168
    Width = 150
    Height = 35
    Caption = 'LISTAR TODOS'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 164
    Top = 168
    Width = 150
    Height = 35
    Caption = 'DESCRI'#199#195'O/CODIGO1'
    TabOrder = 7
    OnClick = Button6Click
  end
  object Button7: TButton
    Left = 320
    Top = 168
    Width = 150
    Height = 35
    Caption = 'ID BETWEEN 1-5'
    TabOrder = 8
    OnClick = Button7Click
  end
  object Button8: TButton
    Left = 479
    Top = 168
    Width = 150
    Height = 35
    Caption = 'ID IN [1,3,5,10]'
    TabOrder = 9
    OnClick = Button8Click
  end
  object Button9: TButton
    Left = 8
    Top = 209
    Width = 150
    Height = 35
    Caption = 'ID MAIOR QUE 10'
    TabOrder = 10
    OnClick = Button9Click
  end
  object Button10: TButton
    Left = 164
    Top = 207
    Width = 150
    Height = 35
    Caption = 'ID MENOR QUE 10'
    TabOrder = 11
    OnClick = Button10Click
  end
  object Button11: TButton
    Left = 320
    Top = 207
    Width = 150
    Height = 35
    Caption = 'COUNT'
    TabOrder = 12
    OnClick = Button11Click
  end
  object Button12: TButton
    Left = 479
    Top = 209
    Width = 150
    Height = 35
    Caption = 'PAGINA'#199#195'O'
    TabOrder = 13
    OnClick = Button12Click
  end
  object DataSource1: TDataSource
    Left = 64
    Top = 280
  end
end
