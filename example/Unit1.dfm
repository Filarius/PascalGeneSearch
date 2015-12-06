object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 571
  ClientWidth = 1072
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 287
    Top = 1
    Width = 500
    Height = 500
  end
  object BtnInit: TButton
    Left = 0
    Top = 1
    Width = 75
    Height = 25
    Caption = 'BtnInit'
    TabOrder = 0
    OnClick = BtnInitClick
  end
  object BtnStep: TButton
    Left = 0
    Top = 32
    Width = 75
    Height = 25
    Caption = 'BtnStep'
    TabOrder = 1
    OnClick = BtnStepClick
  end
  object Memo1: TMemo
    Left = 81
    Top = 3
    Width = 200
    Height = 537
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssVertical
    TabOrder = 2
  end
  object BtnFree: TButton
    Left = 0
    Top = 94
    Width = 75
    Height = 25
    Caption = 'BtnFree'
    TabOrder = 3
    OnClick = BtnFreeClick
  end
  object BtnRadiation: TButton
    Left = 0
    Top = 63
    Width = 75
    Height = 25
    Caption = 'BtnRadiation'
    TabOrder = 4
    OnClick = BtnRadiationClick
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer1Timer
    Left = 8
    Top = 128
  end
end
