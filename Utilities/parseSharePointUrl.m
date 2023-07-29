// Copyright (C) 2023 Samuel Vanderslink
// Permission granted under the MIT Open Source licence.
// The above copyright notice shall be included in all
// copies or substantial portions of the Software.

// Dependencies:
//  - decodeUrl

// Parses a SharePoint URL, returning a list of parts.
// Args:
//  sharePointUrl: the full encoded url of the directory.
// Returns:
//  A list containing the Company, Team, and Folder Path.
(sharePointUrl as text) as list =>
let
    // Helper function to strip all args except RootFolder if it exists.
    StripUrlArgs = (url as text) => let
        base = Text.BeforeDelimiter(url, "?"),
        path = Text.BetweenDelimiters(url, "RootFolder=", "&")
        in if path = "" then base else base & "?RootFolder=" & path,

    // Helper function to parse the URL into its component parts.  
    parseUrlStaging = (url as text) as table = let
        // Create a table to work with the decoded URL.
        workingTable = #table({"baseUrl"}, {{decodeUrl(StripUrlArgs(url))}}),

        // Remove https:// from the start of the url.
        removeProtocol = Table.TransformColumns(
            workingTable,
            {{"baseUrl", each Text.AfterDelimiter(_, "//"),
            type text}}),

        // Split the URL and extract company.
        parseCompanyId = Table.TransformColumns(
            Table.SplitColumn(
                removeProtocol,
                "baseUrl",
                Splitter.SplitTextByEachDelimiter({"sites/"}, QuoteStyle.Csv, false),
                {"company", "path"}),
            {{"company", each Text.BeforeDelimiter(_, "."),
            type text}}),

        // Split the remainder into team and path.
        parseTeam = Table.SplitColumn(
            parseCompanyId,
            "path",
            Splitter.SplitTextByEachDelimiter({"/"}, QuoteStyle.Csv, false),
            {"team", "path"}),

        // Remove the team from the path.
        parsePath = Table.TransformColumns(
            parseTeam,
            {{"path", each Text.AfterDelimiter(_, parseTeam[team]{0}),
            type text}})
    in parsePath,

    // Parse the url into a staging table.
    urlParts = parseUrlStaging(sharePointUrl),

    // Return the results list.
    result = {
        urlParts[company]{0},
        urlParts[team]{0},
        Text.Format(
            "https://#{0}.sharepoint.com/sites/#{1}#{2}",
            {
                urlParts[company]{0},
                urlParts[team]{0},
                urlParts[path]{0} & "/"
            })
    }
in
    result