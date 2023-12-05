VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PowerQuery"
Attribute VB_Description = "Wrapper for a Workbookquery with some extended functionality."
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
' Copyright 2023 Sam Vanderslink
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
'   Class: PowerQuery
'   Wrapper for a Workbookquery with some extended functionality.
'-------------------------------------------------------------------------------

' Private Backing Store
'-------------------------------------------------------------------------------
Private QUOT As String
Private DBQUOT As String

Private mQuery As WorkbookQuery
Private mName As String
Private mDescription As String
Private mAncestors As Dictionary

Private mText As String
Private mTextDirty As Boolean

Private mFormula As String
Private mFormulaDirty As Boolean


' Properties
'-------------------------------------------------------------------------------
Public Property Let Name(var As String)
Attribute Name.VB_Description = "The name of the query."
'   The name of the query.
    mName = var
End Property

Public Property Get Name() As String
    Name = mName
End Property

Public Property Let Description(var As String)
Attribute Description.VB_Description = "The description of the query."
'   The description of the query.
    mDescription = var
End Property

Public Property Get Description() As String
    Description = mDescription
End Property

Public Property Let Text(var As String)
Attribute Text.VB_Description = "Serialise or deserialise the Query.Formula."
'   Serialise or deserialise the Query.Formula.
    mText = var
    mFormulaDirty = True
End Property

Public Property Get Text() As String
    If mTextDirty Then Serialise
    Text = mText
End Property

Public Property Let Formula(var As String)
Attribute Formula.VB_Description = "Represents the Query.Formula."
'   Represents the Query.Formula.
    mFormula = var
    mTextDirty = True
End Property

Public Property Get Formula() As String
    If mFormulaDirty Then Deserialise
    Formula = mFormula
End Property

Public Property Get Ancestors() As Dictionary
Attribute Ancestors.VB_Description = "Gets this query's dependencies."
'   Gets this query's dependencies.
    Set Ancestors = mAncestors
End Property

Private mNamespace As String
Public Property Let Namespace(var As String)
Attribute Namespace.VB_Description = "The query's folder path."
'   The query's folder path.
    mNamespace = var
End Property

Public Property Get Namespace() As String
    Namespace = mNamespace
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    QUOT = Chr(34)
    DBQUOT = String(2, QUOT)
    Set mAncestors = New Dictionary
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Sub Update()
Attribute Update.VB_Description = "Updates the query in the workbook."
'   Updates the query in the workbook.
'
'   Raises
'       TODO: Add some data validation to ensure we have a name.
'       TODO: Set the Formula to an empty query if the text returned nothing.

'   Try to get the query.
    If mQuery Is Nothing Then Set mQuery = GetQuery(Name)

'   Create a new query if we weren't able to get one.
    If mQuery Is Nothing Then
        Set mQuery = ActiveWorkbook.Queries.Add( _
            Name, _
            Formula, _
            Description)
        Exit Sub
    End If

'   Update the existing query.    
    With mQuery
        .Name = Name
        .Description = Description
        .Formula = Formula
    End With
End Sub


' Helpers
'-------------------------------------------------------------------------------
Private Function GetQuery(queryName As String) As WorkbookQuery
Attribute GetQuery.VB_Description = "Gets a query from WorkbookQueries."
'   Gets a query from WorkbookQueries.
'
'   Args:
'       queryName: The name of the query to return.
'
'   Returns:
'       A Workbookquery or Nothing if it doesn't exist.
'
    On Error Resume Next
    Set GetQuery = ActiveWorkbook.Queries(queryName)
End Function

Private Sub Serialise()
Attribute Serialise.VB_Description = "Generates the Text from the Formula."
'   Generates the Text from the Formula.

    mTextDirty = False
End Sub

Private Sub Deserialise()
Attribute Deserialise.VB_Description = "Parses the Formula into Text."
'   Parses the Text into a Formula.

'   Set the defaults if we have no Text.
    If mText = "" Then
        mFormula = DefaultQuery()
        mAncestors.RemoveAll()
        mFormulaDirty = False
        Exit Function
    End If

'   Parse the query text.
    Dim queryLines() As String
    queryLines = Text.Split(Text, vbNewLine)

    Dim i As Long
    For i = 0 To UBound(queryLine)
        Select Case True
            Case StartsWith(queryLines(i), "// Namespace: "):
            Case StartsWith(queryLines(i), "// QueryName: "):
            Case StartsWith(queryLines(i), "// Dependencies: "):
                i = i + 1
                Do While StartsWith(queryLines(i), "//  - /")
                    Dim q As PowerQuery
                    Set q = New PowerQuery
                    q.
                Loop
        End Select
    Next i

    mFormulaDirty = False
End Sub

Public Function GetDependencies(queryRegister As Dictionary) As Dictionary
Attribute GetDependencies.VB_Description = "Reads the Formula to resolve dependencies."
'   Reads the Formula to resolve dependencies.
'
'   Args:
'       queryRegister: A register of Repo and WBook queries.
'
'   Returns:
'       A dictionary of queries this query directly depends on.
'
    Dim result As New Dictionary
    result.Add "Repo", New Dictionary
    result.Add "WBook", New Dictionary

    Dim flagQuotes As Boolean
    Dim flagLabel As Boolean

    Dim queryLines As Variant
    queryLines = Split(Formula, vbNewLine)

    Dim queryLine As Variant
    For Each queryLine In queryLines
        Dim lineChars() As String
        lineChars = StringToCharArray(CStr(queryLine))

        Dim pStart As Long
        pStart = 0

        Dim i As Long
        For i = 0 To UBound(lineChars)
            Dim pLen As Long
            Dim checkLabel As String

            Select Case lineChars(i)
                Case Is = QUOT:
                    If flagQuotes And lineChars(i + 1) = QUOT Then
'                       Escaped quote.                    
                        i = i + 1
                    Else
'                       Unescaped quote, use bitwise Boolean toggle.
                        flagQuotes = flagQuotes Xor True
                        If flagLabel Then
'                           Just closed a label.
                            pLen = i - pStart + 1
                            checkLabel = Mid(queryLine, pStart, pLen)
                            CheckQueryLabel checkLabel, queryRegister, result
                            pStart = 0
                            flagLabel = False
                        End If
                    End If
                Case Is = "/"
'                   Double unquotes forward slash is a comment from there on.
                    If Not flagQuotes Then              
                        If lineChars(i + 1) = "/" Then Exit For
                    End If
                Case Is = "(", " ", ".", "=", ")"
'                   Unquoted chars that break a word.
                    If Not flagQuotes And pStart > 0 Then
                        pLen = i - pStart + 1
                        checkLabel = Mid(queryLine, pStart, pLen)
                        CheckQueryLabel checkLabel, queryRegister, result
                        pStart = 0
                    End If
                Case Is = "#"
'                   A label can use the format #"My Label"
                    If Not flagQuotes Then              
                        If lineChars(i + 1) = QUOT Then
                            flagLabel = True
                            i = i + 1
                            pStart = i + 1
                        End If
                    End If
                Case Else:
'                   Test any words not in a quoted block.
                    If pStart = 0 Then pStart = i + 1
            End Select
        Next i
        If pStart > 0 Then
            pLen = i - pStart + 1
            checkLabel = Mid(queryLine, pStart, pLen)
            CheckQueryLabel checkLabel, queryRegister, result
        End If
    Next queryLine
End Function

Private Sub CheckQueryLabel(n As String, q As Dictionary, d As Dictionary)
Attribute CheckQueryLabel.VB_Description = "Checks if the label is a query and adds to the dependencies."
'   Checks if the label is a query and adds to the dependencies.
'
'   Args:
'       n: The label name to check.
'       q: The queries register.
'       d: The dependencies register.
'
    Dim registers() As Variant
    registers = Array("Repo", "WBook")

    Dim register As Variant
    For Each register In registers
        If q(register).Exists(n) And Not d(register).Exists(n) Then
            d(register).Add n, q(register)(n)
        End If
    Next register
End Sub

Private Function StartsWith(str As String, subStr As String) As Boolean
Attribute StartsWith.VB_Description = "Checks str starts with subStr."
'   Checks str starts with subStr.
'
'   Args:
'       str: The string to check.
'       subStr: The string to check it starts with.
'
'   Returns:
'       True if str starts with subStr.
'
    StartsWith = Left(str, Len(subStr)) = subStr
End Function

Private Function StringToCharArray(str As String) As String()
Attribute StringToCharArray.VB_Description = "Converts a string into an array of single characters."
'   Converts a string into an array of single characters.
'
'   Args:
'       str: The string to convert.
'
'   Returns:
'       An array of single characters.
'
    If Len(str) = 0 Then
        StringToCharArray = Split("", "")
        Exit Function
    End If

    Dim result() As String
    ReDim result(Len(str) - 1)

    Dim i As Long
    For i = 1 To Len(str)
        result(i - 1) = Mid(str, i, 1)
    Next i

    StringToCharArray = result
End Function

Private Function TextAfter(str As String, subStr As String) As String
Attribute TextAfter.VB_Description = "Returns the substring after a string."
'   Returns the substring after a string.
'
'   Args:
'       str: The string to check.
'       subStr: The string to check it starts with.
'
'   Returns:
'       The part of the string after substring.
'
    Dim startPos As Long
    startPos = Instr(str, subStr)
    If startPos > 0 Then
        startPos = startPos + Len(subStr) + 1
        TextAfter = Mid(str, startPos, Len(str))
    End If
End Function

Private Function DefaultQuery() As String
Attribute DefaultQuery.VB_Description = "A default blank query."
'   A default blank query.
    DefaultQuery = _
        "let" & vbNewLine & _
        "    Source = " & DBQUOT & vbNewLine & _
        "in" & vbNewLine & _
        "    Source"
End Function

Private Function IsValid() As Boolean
Attribute IsValid.VB_Description = "Validates the query data."
'   Validates the query data.
'
    If Formula = "" Then Formula = _
        "let" & vbNewLine & _
        "    Source = " & DBQUOT & vbNewLine & _
        "in" & vbNewLine & _
        "    Source"
    IsValid = Name <> ""
End Function
