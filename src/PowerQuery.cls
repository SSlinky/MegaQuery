VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PowerQuery"
Attribute VB_Description = "Extends functionality of a WorkbookQuery"
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
'   Class: PowerQuery
'   Extends functionality of a WorkbookQuery
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------


' Events
'-------------------------------------------------------------------------------


' Private Backing Store
'-------------------------------------------------------------------------------
Private QUOT As String
Private DBQUOT As String

Private mName As String
Private mFormula As String
Private mNamespace As String
Private mDescription As String
Private mSource As WorkbookQuery
Private mDependencies As Collection


' Properties
'-------------------------------------------------------------------------------
Public Property Let Formula(var As String)
Attribute Formula.VB_Description = "The query formula."
'   The query formula.
    Dim queryParts As Dictionary
    Set queryParts = Deserialise(var)

    mFormula = queryParts("formula")

End Property

Public Property Get Formula() As String
    Formula = mFormula
End Property

Public Property Get Dependencies() As Collection
Attribute Dependencies.VB_Description = "The names of the dependencies."
'   The names of the dependencies.
    Set Dependencies = mDependencies
End Property

Public Property Let Description(var As String)
Attribute Description.VB_Description = "The description of the query."
'   The description of the query.
    mDescription = var
End Property

Public Property Get Description() As String
    Description = mDescription
End Property

Public Property Set Source(var As WorkbookQuery)
Attribute Source.VB_Description = "The source workbook query."
'   The source workbook query.
'   Might turn this into a Variant so it can be used with all IRepository.
    Set mSource = var
End Property

Public Property Get Source() As WorkbookQuery
    Set Source = mSource
End Property

Public Property Let Name(var As String)
Attribute Name.VB_Description = "The name of the query."
'   The name of the query.
    mName = var
End Property

Public Property Get Name() As String
    Name = mName
End Property

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
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Sub SyncFromSource()
Attribute SyncFromSource.VB_Description = "Syncs properties from the source."
'   Syncs properties from the source.
'
    ParseFormula mSource.Formula
    Set mDependencies = Nothing
    Logger.Log LLDebug, "Resetting deps [" & Name & "]"
End Sub

Public Sub ParseFormula(var As String)
Attribute ParseFormula.VB_Description = "Parses a query formula into its components."
'   Parses a query formula into its components.
'
'   Args:
'       var: The query formula to parse.
'
    Dim queryParts As Dictionary
    Set queryParts = Deserialise(var)

    mName = queryParts("name")
    mFormula = queryParts("formula")
    mDescription = queryParts("description")
End Sub

Public Sub ResolveDependencies(names As Dictionary)
Attribute ResolveDependencies.VB_Description = "Parses the formula to resolve named dependencies."
'   Parses the formula to resolve named dependencies.
'
'   Args:
'       names: A dictionary of query names.
'
    Set mDependencies = New Collection
    If mFormula = "" Then Exit Sub
    
    Dim toks() As String
    toks = FormulaTokens()

    Dim tok As Variant
    For Each tok In toks
        If names.Exists(tok) Then mDependencies.Add tok
    Next tok
End Sub


' Helpers
'-------------------------------------------------------------------------------
Private Function Deserialise(fText As String) As Dictionary
Attribute Deserialise.VB_Description = "Deserialises the formula into properties."
'   Deserialises the formula into properties.
'
'   Args:
'       fText: The formula text.
'
'   Returns:
'       A dictionary of query components.
'
    Dim result As New Dictionary
    result.Add "formula", New Collection
    result.Add "description", New Collection

'   Parse the query text - try splitting on
'   the common line endings.
    Dim queryLines() As String
    queryLines = Split(fText, vbNewLine)
    If UBound(queryLines) = 0 Then
        queryLines = Split(fText, vbLf)
    End If
    If UBound(queryLines) = 0 Then
        queryLines = Split(fText, vbCr)
    End If

    Dim s As Long
'   Store the parser state as bit flags.
'       0 = Above formula.
'       1 = Inside formula section
'       2 = Inside description section
    
    Dim ql As New XString
    Dim queryLine As Variant
    For Each queryLine In queryLines
        ql = Trim(queryLine)
        Select Case True
'           Parse as formula.                
            Case s = 1:
                result("formula").Add CStr(queryLine)
'           Skip blank lines.        
            Case ql = "":
'           Detect namespace.            
            Case s = 0 And ql.StartsWith("// Namespace: "):
                result.Add "namespace", ql.AfterDelimiter("// Namespace: ")
'           Detect query name.                
            Case s = 0 And ql.StartsWith("// QueryName: "):
                result.Add "name", ql.AfterDelimiter("// QueryName: ")
'           Ignore comments above query.
            Case s = 0 And ql.StartsWith("//"):
'           Detect start of forumula            
            Case s = 0:
                result("formula").Add CStr(queryLine)
                s = 2
            Case s = 2 And ql.StartsWith("//"):
'           Not a comment and not a blank line.
                result("description").Add CStr(queryLine)
'           Anything else means we're past the description.            
            Case Else:
                result("formula").Add CStr(queryLine)
                s = 1
        End Select
    Next queryLine

'   Repack the description (if we have one) and formula into string.
    ql.FromStringCollection result.GetValue("description"), vbNewLine
    result("description") = ql

    ql.FromStringCollection result.GetValue("formula"), vbNewLine
    result("formula") = ql

    Set Deserialise = result
End Function

Private Function FormulaTokens() As String()
Attribute FormulaTokens.VB_Description = "Returns the formula as a series of tokens."
'   Returns the formula as a series of tokens.
'
'   TODO: Smarter line endings (make it part of XString).
    Dim fLines() As String
    fLines = Split(mFormula, vbNewLine)

    Dim toks As New Collection
    Dim fLine As Variant
    For Each fLine In fLines
        Dim fWords() As String
        fWords = GetWords(CStr(fLine))

        Dim fWord As Variant
        For Each fWord In fWords
            toks.Add fWord
        Next fWord
    Next fLine

    Dim result() As String
    ReDim result(1 To toks.Count)
    Dim i As Long
    For i = 1 To toks.Count
        result(i) = toks(i)
    Next i
    FormulaTokens = result
End Function

Private Function GetWords(var As String) As String()
Attribute GetWords.VB_Description = "Converts a query line into a string array of words."
'   Converts a query line into a string array of words.
'
'   Args:
'       var: The query line to convert.
'
'   Returns:
'       An array of query words.
'
    Dim result() As String

    If Trim(var) = "" Then
        ReDim result(0)
        result(0) = var
        GetWords = result
        Exit Function
    End If

    Dim s As Long
'   Store the parser state as bit flags.
'       1 = Hash
'       2 = Quote
'       4 = Comment

    Dim p As Long
    Dim i As Long
    Dim c As String * 1
    Dim r As New Collection
    p = 1
    For i = 1 To Len(var)
        c = Mid(var, i, 1)
        Select Case True
'           Hash detected outside a string.        
            Case c = "#" And s = 0:
                s = 1
'           First slash detected outside a string.        
            Case c = "/" And ((s And 2) = 0) And ((s And 4) = 0):
                p = i
                s = 4
'           Second slash detected outside a string.        
            Case c = "/" And ((s And 2) = 0) And ((s And 4) = 4):
                i = i - 2
                AddWord var, r, p, i
                i = Len(var)
                Exit For
'           Quote detected while string.                
            Case c = QUOT And ((s And 2) = 2):
                s = 0
                AddWord var, r, p, i
'           Quote detected.                
            Case c = QUOT:
                s = s + 2
                i = i - 1 - (s And 1)
                AddWord var, r, p, i
                i = i + 1 + (s And 1)
'           Anything else while string.
            Case s And 2 = 2:
'           Space detected.
            Case c = " ":
                s = 0
                AddWord var, r, p, i
'           Delimiting character detected.
            Case CharIsDelimiter(c):
                s = 0
                i = i - 1
                AddWord var, r, p, i
                i = i + 1
                AddWord var, r, p, i
        End Select
    Next i

    If i > p Then AddWord var, r, p, i

    ReDim result(1 To r.Count)
    For i = 1 To r.Count
        result(i) = r(i)
    Next i

    GetWords = result
End Function

Private Sub AddWord(var As String, r As Collection, p As Long, i As Long)
Attribute AddWord.VB_Description = "Adds a word and resets the variables."
'   Adds a word and resets the variables.
'
    Dim w As String
    w = Trim(Mid(var, p, i - p + 1))
    If w <> "" Then r.Add w
    p = i + 1
End Sub

Private Function CharIsDelimiter(c As String) As Boolean
Attribute CharIsDelimiter.VB_Description = "True if the character is a delimiter."
'   True if the character is a delimiter.
'
    Dim d As Variant
    For Each d In Split("(\)\{\}\,", "\")
        If c = CStr(d) Then
            CharIsDelimiter = True
            Exit Function
        End If
    Next d
End Function


' Event Handlers
'-------------------------------------------------------------------------------


' Interface Implementation
'-------------------------------------------------------------------------------

