object Form1: TForm1
  Left = 1771
  Top = 200
  Caption = 'Shell Hook'
  ClientHeight = 411
  ClientWidth = 813
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  TextHeight = 14
  object ListView1: TListView
    Left = 0
    Top = 48
    Width = 813
    Height = 344
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'Message:'
        Width = 180
      end
      item
        Caption = 'Class Name:'
        Width = 130
      end
      item
        Caption = 'Exe Path:'
        Width = 350
      end
      item
        AutoSize = True
        Caption = 'Handle:'
      end>
    GridLines = True
    RowSelect = True
    PopupMenu = PopupMenu1
    SmallImages = ImageList1
    TabOrder = 0
    ViewStyle = vsReport
    OnChange = ListView1Change
    OnClick = ListView1Click
    OnCustomDrawItem = ListView1CustomDrawItem
    ExplicitWidth = 777
    ExplicitHeight = 343
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 813
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    ExplicitWidth = 777
    object Label1: TLabel
      Left = 22
      Top = 5
      Width = 137
      Height = 39
      Caption = 'Shell Hook'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -32
      Font.Name = 'Impact'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 169
      Top = 25
      Width = 150
      Height = 14
      Caption = 'Get Register Window Message'
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 392
    Width = 813
    Height = 19
    Panels = <
      item
        Text = 'Enties :'
        Width = 50
      end
      item
        Text = '0'
        Width = 70
      end
      item
        Text = 'Name :'
        Width = 50
      end
      item
        Width = 250
      end
      item
        Text = 'Size :'
        Width = 40
      end
      item
        Text = '0 Kb'
        Width = 100
      end
      item
        Text = 'mhShell :'
        Width = 60
      end
      item
        Width = 50
      end>
    ExplicitTop = 391
    ExplicitWidth = 777
  end
  object ImageList1: TImageList
    BlendColor = clWhite
    BkColor = clWhite
    DrawingStyle = dsTransparent
    Left = 68
    Top = 109
  end
  object PopupMenu1: TPopupMenu
    Left = 147
    Top = 111
    object StartHook1: TMenuItem
      Caption = 'Start Hook'
      OnClick = StartHook1Click
    end
    object StopHook1: TMenuItem
      Caption = 'Stop Hook'
      Enabled = False
      OnClick = StopHook1Click
    end
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object Properties1: TMenuItem
      Caption = 'Properties'
      Enabled = False
      OnClick = Properties1Click
    end
    object Browse1: TMenuItem
      Caption = 'Browse'
      Enabled = False
      OnClick = Browse1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Execute1: TMenuItem
      Caption = 'Execute'
      Enabled = False
      OnClick = Execute1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object StayTop1: TMenuItem
      AutoCheck = True
      Caption = 'Stay Top'
      OnClick = StayTop1Click
    end
    object Grid1: TMenuItem
      AutoCheck = True
      Caption = 'Grid'
      Checked = True
      OnClick = Grid1Click
    end
    object View1: TMenuItem
      Caption = 'View'
      object Report1: TMenuItem
        AutoCheck = True
        Caption = 'Report'
        Checked = True
        RadioItem = True
        OnClick = Report1Click
      end
      object List1: TMenuItem
        AutoCheck = True
        Caption = 'List'
        RadioItem = True
        OnClick = List1Click
      end
    end
    object ColorData1: TMenuItem
      AutoCheck = True
      Caption = 'Color Data'
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object erminate1: TMenuItem
      Caption = 'Terminate'
      OnClick = erminate1Click
    end
  end
end
