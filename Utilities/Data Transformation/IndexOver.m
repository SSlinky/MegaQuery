(tbl as table, over as text, newColName as text, startAt as number) as table =>
let
    #"Grouped Rows" = Table.Group(tbl, {over}, {{"Rows", each _, type table [Rule Name=text, Base Object=text, Block=number]}}),
    #"Added Custom" = Table.AddColumn(#"Grouped Rows", "RowsIndexed", each Table.AddIndexColumn([Rows], newColName, startAt)),

    #"Removed Other Columns" = Table.SelectColumns(#"Added Custom",{"RowsIndexed"}),
    #"Expanded Index" = Table.ExpandTableColumn(
        #"Removed Other Columns",
        "RowsIndexed",
        Table.ColumnNames(Table.Transpose(#"Removed Other Columns")[Column1]{0}))
in
    #"Expanded Index"
