object Form1: TForm1
  Left = 1771
  Top = 200
  Caption = 'Shell Hook'
  ClientHeight = 468
  ClientWidth = 874
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
    Width = 704
    Height = 401
    Align = alClient
    BevelOuter = bvNone
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'Message:'
        Width = 150
      end
      item
        Caption = 'Name:'
        Width = 100
      end
      item
        Caption = 'Exe Path:'
        Width = 280
      end
      item
        Caption = 'Handle:'
        Width = 60
      end
      item
        Caption = 'Class Name :'
        Width = 80
      end
      item
        Caption = 'PID'
      end
      item
        Caption = 'Memory Usage:'
        Width = 100
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
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 874
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 1
    ExplicitWidth = 870
    DesignSize = (
      874
      48)
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
      Top = 26
      Width = 150
      Height = 14
      Caption = 'Get Register Window Message'
    end
    object Label3: TLabel
      Left = 169
      Top = 10
      Width = 440
      Height = 14
      Caption = 
        'Listing 32-bit programs. For a 64-bit version, you must build a ' +
        '64 bit driver "ShellHook64.dll".'
    end
    object Button1: TButton
      Left = 792
      Top = 15
      Width = 75
      Height = 20
      Anchors = [akTop, akRight]
      Caption = 'Update'
      TabOrder = 0
      TabStop = False
      OnClick = Button1Click
      ExplicitLeft = 788
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 449
    Width = 874
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
    ExplicitTop = 448
    ExplicitWidth = 870
  end
  object Panel2: TPanel
    Left = 704
    Top = 48
    Width = 170
    Height = 401
    Align = alRight
    TabOrder = 3
    ExplicitLeft = 700
    ExplicitHeight = 400
    object ListBox1: TListBox
      Left = 1
      Top = 17
      Width = 168
      Height = 383
      Style = lbOwnerDrawFixed
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      ItemHeight = 14
      TabOrder = 0
      OnDrawItem = ListBox1DrawItem
      ExplicitHeight = 382
    end
    object Panel3: TPanel
      Left = 1
      Top = 1
      Width = 168
      Height = 16
      Align = alTop
      BevelOuter = bvNone
      Caption = 'Tasklist :'
      TabOrder = 1
    end
  end
  object ImageList1: TImageList
    BlendColor = clWhite
    BkColor = clWhite
    DrawingStyle = dsTransparent
    Left = 60
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
    object asklist1: TMenuItem
      AutoCheck = True
      Caption = 'Tasklist'
      Checked = True
      OnClick = asklist1Click
    end
    object ColorData1: TMenuItem
      AutoCheck = True
      Caption = 'Color Data'
      Checked = True
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object erminate1: TMenuItem
      Caption = 'Terminate'
      OnClick = erminate1Click
    end
  end
  object Timer1: TTimer
    Left = 232
    Top = 112
  end
end
