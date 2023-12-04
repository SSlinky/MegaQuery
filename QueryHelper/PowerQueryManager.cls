VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "PowerQueryManager"
Attribute VB_Description = "Adds some QoL to managing queries."
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
'   Class: PowerQueryManager
'   Adds some QoL to managing queries.
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------


' Events
'-------------------------------------------------------------------------------


' Private Backing Store
'-------------------------------------------------------------------------------
Private mRepositoryPath As String
Private mWorkbookQueries As Dictionary


' Properties
'-------------------------------------------------------------------------------
Public Property Let RepositoryPath(var As String)
Attribute RepositoryPath.VB_Description = "The file path to the head of the local query repository."
'   The file path to the head of the local query repository.
    mRepositoryPath = var
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    InitialiseWorkbookRegister
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Sub PruneQueries(ParamArray queryNames() As Variant)
Attribute PruneQueries.VB_Description = "Prunes all queries not an ancestor of the passed in queries."
'   Prunes all queries not an ancestor of the passed in queries.
'
'   Args:
'       queryNames: An array of queries to keep.
'
'   Deletes queries not explicitly lists, or an ancestor or a query explicitly
'   listed from the workbook. Passing no queries prunes all queries.
'   This action cannot be undone.
'
'   Raises:
'       QueryNotFound exception if a query name doesn't exist.
'
    Dim keepQueries As Dictionary
    Dim queryName As Variant
    Dim pq As PowerQuery
    For Each queryName In queryNames
        If Not mWorkbookQueries.Exists Then
            Err.Raise vbObjectError + 2, "Query not found: " & queryName
        End If
        Set pq = New PowerQuery
        pq.Formula = mWorkbookQueries(queryName).Formula
        AddAncestors pq, keepQueries
    Next queryName

    Dim q As WorkbookQuery
    For Each q In mWorkbookQueries
        If Not ancestors.Exists(q.Name) Then q.Delete
    Next q

    ' Maybe add some smarts to delete orphaned list objects / sheets.    
End Sub


' Helpers
'-------------------------------------------------------------------------------
Private Sub InitialiseWorkbookRegister()
Attribute InitialiseWorkbookRegister.VB_Description = "Initialises the workbook query tracking."
'   Initialises the workbook query tracking.
    Set mWorkbookQueries = New Dictionary
    Dim q As Query
    For Each q In ActiveWorkbook.Queries
        mWorkbookQueries.Add q.Name, q
    Next q
End Sub

Private Sub InitialiseRepositoryRegister()
Attribute InitialiseRepositoryRegister.VB_Description = "Initialises the local repository tracking."
'   Initialises the local repository tracking.

End Sub

Private Function ReadRepoQuery(filePath As String) As String
Attribute ReadRepoQuery.VB_Description = "Reads a query from a text file."
'   Reads a query from a text file.
'
'   Args:
'       filePath: The path to the query.
'
'   Returns:
'       The file text.
'
    Dim fileNum As Long
    fileNum = FreeFile()
    Open filePath For Input As fileNum
    On Error Resume Next
    ReadRepoQuery = Input$(LOF(fileNum), fileNum)
    Close fileNum
End Function

' Event Handlers
'-------------------------------------------------------------------------------


' Interface Implementation
'-------------------------------------------------------------------------------

