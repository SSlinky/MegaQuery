VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "WorkbookPowerQueryRepository"
Attribute VB_Description = "A PowerQuery repository attached to an Excel workbook."
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
Implements IPowerQueryRepository

'-------------------------------------------------------------------------------
'   Class: WorkbookPowerQueryRepository
'   A PowerQuery repository attached to an Excel workbook.
'-------------------------------------------------------------------------------

' Enums
'-------------------------------------------------------------------------------


' Events
'-------------------------------------------------------------------------------


' Private Backing Store
'-------------------------------------------------------------------------------
Private mSource As Workbook
Private mQueries As Dictionary


' Properties
'-------------------------------------------------------------------------------
Public Property Get Queries() As Dictionary
Attribute Queries.VB_Description = "The queries in the attached workbook."
'   The queries in the attached workbook.
    Set Queries = mQueries
End Property

Public Property Let Source(var As Variant)
Attribute Source.VB_Description = "The repository source."
'   The repository source.
End Property

Public Property Get Source() As Variant
    Set Source = mSource
End Property

Public Property Set Source(var As Variant)
' if not a workbook, throw.
    Set mSource = var
End Property


' Constructor
'-------------------------------------------------------------------------------
Private Sub Class_Initialize()
    Set mQueries = New Dictionary
End Sub


' Methods
'-------------------------------------------------------------------------------
Public Sub Add(q As PowerQuery)
Attribute Add.VB_Description = "Adds a query to the repository."
'   Adds a query to the repository.
'
'   Args:
'       q: The query to add.
'
    Queries(q.Name) = q
End Sub

Public Sub Prune(Index As Variant)
Attribute Prune.VB_Description = "Removes unrelated queries from the hierarchy."
'   Removes unrelated queries from the hierarchy.
'
'   Prune starts with a query or queries and removes all queries that
'   are not related. This can be useful for cleaning a large repository.
'
'   Args:
'       Index: A query name or array of names.
'
'   Raises:
'       Query not found, I guess? TODO implement.
'
'   Determine which queries to keep.
    Dim baseQueries As Variant
    baseQueries = Iif(TypeName(Index) = "String", Array(Index), Index)

    Dim keepQueries As Dictionary
    Set keepQueries = New Dictionary
    
    Dim queryName As Variant
    For Each queryName In baseQueries
        AddAncestors keepQueries, queryName
    Next queryName

'   Prune the queries we aren't keeping.
'   There's no need to check if the query we're deleting has any child
'   queries as that check is not performed when deleting from VBA.
    Set mQueries = keepQueries
    Dim q As WorkbookQuery
    For Each q In mSource.Queries
        If Not keepQueries.Exists(q.Name) Then
            q.Delete
        End If
    Next q
End Sub


' Helpers
'-------------------------------------------------------------------------------
Private Sub AddAncestors(d As Dictionary, queryName As String)
Attribute AddAncestors.VB_Description = "Recursively adds ancestors to the dictionary."
'   Recursively adds ancestors to the dictionary.
'
'   Args:
'       d: The ancestors.
'       queryName: The query to get ancestors for.
'
    Dim q As PowerQuery
    Set q = Queries(queryName)

    Dim queryDependency As Variant
    For Each queryDependency In q.Ancestors
        If Not d.Exists(queryDependency) Then
            d.Add queryDependency, Queries(queryDependency)
            AddAncestors d, queryDependency
        End If
    Next queryDependency
End Sub


' Event Handlers
'-------------------------------------------------------------------------------


' Interface Implementation
'-------------------------------------------------------------------------------

