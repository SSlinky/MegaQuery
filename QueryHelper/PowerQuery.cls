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
Private mQuery As WorkbookQuery
Private mName As String
Private mDescription As String

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
    Formula = mFormula
End Property


' Methods
'-------------------------------------------------------------------------------
Public Sub Update()
Attribute Update.VB_Description = "Updates the query in the workbook."
'   Updates the query in the workbook.
'
'   Raises
'       TODO: Add some data validation to ensure we have a name.
'       TODO: Set the Formula to an empty query if 

'   Try to get the query.
    If mQuery Is Nothing Then Set mQuery = GetQuery(Name)

'   Create a new query.
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
'   Parses the Formula into Text.

    mFormulaDirty = False
End Sub

Private Function IsValid() As Boolean
Attribute IsValid.VB_Description = "Validates the query data."
'   Validates the query data.
'
    If Formula = "" Then Formula = _
        "let" & vbNewLine & _
        "    Source = """" & vbNewLine & _
        "in" & vbNewLine & _
        "    Source"
    IsValid = Name <> ""
End Function