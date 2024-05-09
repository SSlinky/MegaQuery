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
    If Not TypeName(var) = "Workbook" Then
        Logger.Throw New InvalidSourceException
        Exit Property
    End If
    Set mSource = var
    SyncFromSource
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

Public Sub AddTree(queryTree As Dictionary, overwrite As Boolean)
Attribute AddTree.VB_Description = "Adds a query tree to the repository."
'   Adds a query tree to the repository.
'
'   Args:
'       queryTree: a dictionary of queries to add.
'       overwrite: whether the incoming queries should overwrite existing.
'
    Dim v As Variant
    Dim q As PowerQuery
    For Each v In queryTree
        Set q = v
        If Not Queries.Exists(q.Name) Or overwrite Then
            Queries(q.Name) = q
        End If
    Next v
End Sub

Public Sub Prune(qNames As Variant)
Attribute Prune.VB_Description = "Removes unrelated queries from the hierarchy."
'   Removes unrelated queries from the hierarchy.
'
'   Prune starts with a query or queries and removes all queries that
'   are not related. This can be useful for cleaning a large repository.
'
'   Args:
'       qNames: A query name, or array of names, to keep.
'
'   Raises:
'       Query not found, I guess? TODO implement.
'
'   Determine which queries to keep.
    Logger.Catching = Array( _
        New DepsNotResolvedException,
        New QueryNotFoundException)

    Dim keepQueries As Dictionary
    Set keepQueries = GetQueryTree(qNames)
    If Not Logger.Caught Is Nothing Then Exit Sub
    Logger.EndCatching

'   Prune the queries we aren't keeping.
'   There's no need to check if the query we're deleting has any child
'   queries as that check is not performed when deleting from VBA.
    Set mQueries = keepQueries
    Dim q As WorkbookQuery
    For Each q In mSource.Queries
        If Not keepQueries.Exists(q.Name) Then
            Logger.Info "Deleting [" & q.Name & "]"
            ' q.Delete
        End If
    Next q
End Sub

Public Function GetQueryTree(qNames As Variant) As Dictionary
Attribute GetQueryTree.VB_Description = "Returns queries and dependencies for the passed in query names."
'   Returns queries and dependencies for the passed in query names.
'
'   Args:
'       qNames: A query name, or array of names, to keep.
'
'   Returns:
'       A dictionary of PowerQuery
'
    Dim result As New Dictionary

    Dim baseQueries As Variant
    baseQueries = Iif(TypeName(qNames) = "String", Array(qNames), qNames)
    Logger.Info "Pruning queries from [" & Join(baseQueries, ",") & "]"

    Dim qn As Variant
    For Each qn In baseQueries
        If Not result.Exists(qn) Then result.Add qn, Queries(qn)
        ResolveDependencies result, qn
    Next qn
    If Not Logger.Caught Is Nothing Then Exit Function

    Set GetQueryTree = result
End Function


' Helpers
'-------------------------------------------------------------------------------
Private Sub ResolveDependencies(d As Dictionary, queryName As Variant)
Attribute ResolveDependencies.VB_Description = "Recursively adds ancestors to the dictionary."
'   Recursively adds ancestors to the dictionary.
'
'   Args:
'       d: The ancestors.
'       queryName: The query to get ancestors for.
'
    Dim q As PowerQuery
    Set q = Queries(queryName)

    If q.Dependencies Is Nothing Then
        With New DepsNotResolvedException
            .Context = q.Name
            Logger.Throw .Self
        End With
        Exit Sub
    End If

    Dim queryDependency As Variant
    For Each queryDependency In q.Dependencies
        If Not d.Exists(queryDependency) Then
            d.Add queryDependency, Queries(queryDependency)
            ResolveDependencies d, queryDependency
        End If
    Next queryDependency
End Sub

Private Sub SyncFromSource()
Attribute SyncFromSource.VB_Description = "Sets up the queries from the source."
'   Sets up the queries from the source.
'
    Logger.Info "Synchronising to source [" & Source.Name & "]"
    Set mQueries = New Dictionary

    Dim pq As PowerQuery
    Dim wq As WorkbookQuery

    For Each wq In mSource.Queries
        Set pq = New PowerQuery
        Set pq.Source = wq
        pq.SyncFromSource
        mQueries.Add wq.Name, pq
    Next wq

    Dim v As Variant
    For Each v In Queries.Items
        Set pq = v
        pq.ResolveDependencies mQueries
    Next v
End Sub


' Event Handlers
'-------------------------------------------------------------------------------


' Interface Implementation
'-------------------------------------------------------------------------------

