VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "GitHubPowerQueryRepository"
Attribute VB_Description = "A PowerQuery repository attached to a GitHub repo."
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
'   Class: GitHubPowerQueryRepository
'   A PowerQuery repository attached to a GitHub repo.
'-------------------------------------------------------------------------------

' Private Backing Store
'-------------------------------------------------------------------------------
Private mSource As String
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
    If Not IsGitRepo(var) Then
        Logger.Throw New InvalidSourceException
        Exit Property
    End If

    mSource = var
End Property

Public Property Get Source() As Variant
    Set Source = mSource
End Property

Public Property Set Source(var As Variant)
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
End Sub

Public Sub AddTree(queryTree As Dictionary, overwrite As Boolean)
Attribute AddTree.VB_Description = "Adds a query tree to the repository."
'   Adds a query to the repository.
End Sub

Public Function GetQueryTree(qNames As Variant) As Dictionary
Attribute GetQueryTree.VB_Description = "Returns queries and dependencies for the passed in queries."
'   Returns queries and dependencies for the passed in queries.
End Function


' Helpers
'-------------------------------------------------------------------------------
Private Function IsGitRepo(var As Variant) As Boolean
Attribute IsGitRepo.VB_Description = "Validates string is a GitHub repository."
'   Validates string is a GitHub repository.
'
'   https://github.com/SSlinky/MegaQuery/tree/master
'   TODO: Implement
    If Not TypeName(var) = "String" Then Exit Function
    IsGitRepo = True
End Function


' Interface Implementation
'-------------------------------------------------------------------------------
Public Property Get IPowerQueryRepository_Queries() As Dictionary
Attribute IPowerQueryRepository_Queries.VB_Description = "The queries in the attached source."
    Set IPowerQueryRepository_Queries = Queries
End Property

Public Property Let IPowerQueryRepository_Source(var As Variant)
Attribute Source.VB_Description = "The repository source."
    IPowerQueryRepository_Source = var
End Property

Public Property Get IPowerQueryRepository_Source() As Variant
    IPowerQueryRepository_Source = Source
End Property

Public Property Set IPowerQueryRepository_Source(var As Variant)
    Set IPowerQueryRepository_Source = var
End Property

Public Sub IPowerQueryRepository_Add(q As PowerQuery)
Attribute IPowerQueryRepository_Add.VB_Description = "Adds a query to the repository."
    Add q    
End Sub

Public Sub IPowerQueryRepository_AddTree(queryTree As Dictionary, overwrite As Boolean)
Attribute IPowerQueryRepository_AddTree.VB_Description = "Adds a query tree to the repository."
    AddTree queryTree, overwrite
End Sub

Public Function IPowerQueryRepository_GetQueryTree(qNames As Variant) As Dictionary
Attribute IPowerQueryRepository_GetQueryTree.VB_Description = "Returns queries and dependencies for the passed in queries."
    Set IPowerQueryRepository_GetQueryTree = GetQueryTree(qNames)
End Function
