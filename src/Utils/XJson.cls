VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "XJson"
Attribute VB_Description = "Serialise and deserialise JSON."
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' Copyright 2024 Sam Vanderslink
' 
' Permission is hereby granted, free of charge, to any person obtaining a copy 
' of this software and associated documentation files (the "Software"), to deal 
' in the Software without restriction, including without limitation the rights 
' to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
' copies of the Software, and to permit persons to whom the Software is 
' furnished to do so, subject to the following conditions:
' 
' The above copyright notice and this permission notice shall be included in 
' all copies or substantial portions of the Software.
' 
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
' IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
' FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
' AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
' LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
' FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS 
' IN THE SOFTWARE.

Option Explicit

'-------------------------------------------------------------------------------
'   Class: XJson
'   Serialise and deserialise JSON.
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------
Public Enum XJsonMode
    ModeValue = 0
    ModeDictionary = 12
    ModeList = 18
End Enum


' Private Backing Store
'-------------------------------------------------------------------------------
Private QUOT As String
Private mMode As XJsonMode
Private mValue As Variant
Private mParent As XJson


' Properties
'-------------------------------------------------------------------------------
Public Property Let Mode(var As XJsonMode)
Attribute Mode.VB_Description = "The mode the obejct is in."
'   The mode the obejct is in.
    mMode = var
    Select Case mMode
        Case ModeDictionary:
            Set mValue = New Dictionary
        Case ModeList:
            Set mValue = New List
    End Select
End Property

Public Property Get Mode() As XJsonMode
    Mode = mMode
End Property

Public Property Get Self() As XJson
Attribute Self.VB_Description = "A reference to self for use in With blocks."
'   A reference to self for use in With blocks.
    Set Self = Me
End Property

Public Property Set Parent(var As XJson)
Attribute Parent.VB_Description = "A reference to the parent object."
'   A reference to the parent object.
    Set mParent = var
End Property

Public Property Get Parent() As XJson
    Set Parent = mParent
End Property

Public Property Get Value(Optional Index As Variant) As Variant
Attribute Number.VB_UserMemId = 0
Attribute Value.VB_Description = "The value of the object."
'   The value of the object.
    Select Case Mode
        Case Is = ModeValue:
            Value = mValue
        Case Is = ModeDictionary:
            Select Case True
                Case IsMissing(Index) And IsObject(mValue):
                    Set Value = mValue
                Case IsMissing(Index):
                    Value = mValue
                Case IsObject(mValue(Index)):
                    Set Value = mValue(Index)
                Case Else:
                    Value = mValue(Index)
            End Select
        Case Is = ModeList:
            Select Case True
                Case IsMissing(Index) And IsObject(mValue):
                    Set Value = mValue
                Case IsMissing(Index):
                    Value = mValue
                Case IsObject(mValue(CLng(Index))):
                    Set Value = mValue(CLng(Index))
                Case Else:
                    Value = mValue(CLng(Index))
            End Select
    End Select
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    QUOT = Chr(34)
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Function PushDictionary(Optional k As String) As XJson
Attribute PushDictionary.VB_Description = "Pushes and returns a new dictionary."
'   Pushes and returns a new dictionary.
'
    Set PushDictionary = CreateXJson(ModeDictionary, k)
End Function

Public Function PushList(Optional k As String) As XJson
Attribute PushList.VB_Description = "Pushes and returns a new list."
'   Pushes and returns a new list.
'
    Set PushList = CreateXJson(ModeList, k)
End Function

Public Function PushValue(Optional k As String) As XJson
Attribute PushValue.VB_Description = "Pushes and returns a new value."
'   Pushes and returns a new value.
'
    Set PushValue = CreateXJson(ModeValue, k)
End Function

Public Sub SetValue(v As Variant, Optional k As Variant)
Attribute SetValue.VB_Description = "Sets or adds a value."
'   Sets or adds a value.
'
'   Args:
'       v: The value.
'       k: The key (required for dictionaries)
'
    Select Case Mode
        Case ModeValue:
            mValue = v
        Case ModeDictionary:
            mValue.Add k, v
        Case ModeList:
            mValue.Push v
        Case Else:
        'throw?
    End Select
End Sub

Public Sub Parse(jText As String)
Attribute Parse.VB_Description = "Parses JSON text into an object hierarchy."
'   Parses JSON text into an object hierarchy.
'
'   Args:
'       jText: The raw JSON string.
'


    Dim j As XJson
    Set j = Me

    Dim s As Long
'   Store the parser state as bit flags.
'       1 = Quote
'       2 = List
'       4 = Dict
'       8 = Key
'      16 = Value
'      32 = Escape

'   Handle the first object
    Dim i As Long
    Dim c As String * 1

    For i = 1 To Len(jText)
        c = Mid(jText, i, 1)
        Select Case c
            Case " ", vbLf, vbCr:
                GoTo Continue
            Case "{":
                j.Mode = ModeDictionary
                s = 12
            Case "[":
                j.Mode = ModeList
                s = 18
            Case Else:
        End Select
        Exit For
Continue:
    Next i
    If i = Len(jText) Then Exit Sub


    Dim k As String
    Dim v As String
    Dim p As Long
    i = i + 1
    p = i

    For i = i To Len(jText)
        c = Mid(jText, i, 1)
        Select Case True
'           Is escaped in quote.
            Case (s And 33) = 33:
                s = s Xor 32
'           Escape character.
            Case c = "\" And IsQuote(s):
                s = s Xor 32
'           Close quote.
            Case c = QUOT And IsQuote(s):
                Select Case True
                    Case Is = IsKey(s):
                        k = GetWord(k, jText, p, i)
                    Case Is = IsValue(s):
                        v = GetWord(v, jText, p, i)
                    Case Else:
                End Select
                s = s Xor 1
'           Any other quoted character.
            Case IsQuote(s):
'           Open quote.
            Case c = QUOT:
                s = s Xor 1
'           Key:Value delimiter.
            Case IsKey(s) And Not IsQuote(s) And c = ":"
                k = GetWord(k, jText, p, i, 1)
                s = s + 8
'           Value separator.
            Case IsValue(s) And Not IsQuote(s) And c = ",":
                v = GetWord(v, jText, p, i, 1)
                j.SetValue v, k
                ResetStr v, k
                If IsDict(s) Then s = s - 8
'           New dictionary object.
            Case c = "{":
                Set j = j.PushDictionary(k)
                ResetStr k
                s = j.Mode
                p = i + 1
'           New list object.
            Case c = "[":
                Set j = j.PushList(k)
                ResetStr k
                s = j.Mode
                p = i + 1
'           Closing character.
            Case c = "}", c = "]":
                If IsValue(s) And Not v = "" Then
                    j.SetValue v, k
                    ResetStr v, k
                End If
                Set j = j.Parent
                If Not j Is Nothing Then s = j.Mode
            Case Else:
        End Select
    Next i
End Sub


' Helpers
'-------------------------------------------------------------------------------
Private Function CreateXJson(m As XJsonMode, Optional k As String) As XJson
Attribute CreateXJson.VB_Description = "Fatory method for an XJson."
'   Fatory method for an XJson.
'
    With New XJson
        .Mode = m
        SetValue .Self, k
        Set .Parent = Me
        Set CreateXJson = .Self
    End With
End Function

Private Function GetWord( _
    w As String, j As String, _
    p As Long, i As Long, _
    Optional o As Long = 0) As String
Attribute GetWord.VB_Description = "Returns a word and resets the variables."
'   Returns a word and resets the variables.
'
'   Args:
'       w: The word to resolve.
'       j: The JSON text.
'       p: Position variable.
'       i: Iteration variable.
'       o: Iteration offset.
'
'   Returns:
'       The word if w isn't already set.
'
    GetWord = Iif(w <> "", w, ExtraTrim(Mid(j, p, i - p - o + 1)))
    p = i + 1
End Function

Private Function ExtraTrim(var As String) As String
Attribute ExtraTrim.VB_Description = "Trims spaces and new line chars."
'   Trims spaces and new line chars.
'
    Dim result As String
    result = var
    
    Do While Len(result) > 0
        Select Case Left(result, 1)
            Case Is = " ", vbCr, vbLf:
                result = Right(result, Len(result) - 1)
                GoTo Continue
        End Select
        Select Case Right(result, 1)
            Case Is = " ", vbCr, vbLf:
                result = LEft(result, Len(result) - 1)
                GoTo Continue
        End Select
        Exit Do
Continue:        
    Loop
    ExtraTrim = QStrip(result)
End Function

Private Function QStrip(var As String) As String
Attribute QStrip.VB_Description = "Strips the quote marks on a value if they exist."
'   Strips the quote marks on a value if they exist.
'
    Select Case True
        Case Len(var) < 2:
            QStrip = var
        Case Left(var, 1) = QUOT And Right(var, 1) = QUOT:
            QStrip = Mid(var, 2, Len(var) - 2)
        Case Else:
            QStrip = var
    End Select
End Function

Private Sub ResetStr(a As String, Optional b As String)
Attribute ResetStr.VB_Description = "Clears the passed in strings."
'   Clears the passed in strings.
'
    a = ""
    If IsMissing(b) Then Exit Sub
    b = ""
End Sub

Private Function IsDict(s As Long) As Boolean
Attribute IsDict.VB_Description = "Returns true if state is Dictionary."
'   Returns true if state is Dictionary.
'
    IsDict = (s And 4) = 4
End Function

Private Function IsQuote(s As Long) As Boolean
Attribute IsQuote.VB_Description = "Returns true if state is Dictionary."
'   Returns true if state is Dictionary.
'
    IsQuote = (s And 1) = 1
End Function

Private Function IsKey(s As Long) As Boolean
Attribute IsKey.VB_Description = "Returns true if state is Dictionary."
'   Returns true if state is Dictionary.
'
    IsKey = (s And 8) = 8
End Function

Private Function IsValue(s As Long) As Boolean
Attribute IsValue.VB_Description = "Returns true if state is Dictionary."
'   Returns true if state is Dictionary.
'
    IsValue = (s And 16) = 16
End Function

