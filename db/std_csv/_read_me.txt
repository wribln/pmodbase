CSV files:


- use UTF-8 encoding (Excel can handle this when opening .txt files: specify 'Unicode (UTF-8)' as 'File origin' during import)

- use ; as separator - just to be on the safe side

- csv files must be ready for import using rake import, i.e. they must
  contain the correct attribute names in the first line

- when a text field contains line breaks, enclose the whole text field in double quotes "..."

- embedded double quotes: use double double quotes and enclose the whole text in double quotes: "This
  is a ""Test""."


Note: LibreOffice can help to transform from comma-SV to semicolon-SV
 formats plus it can create Excel files with correct formatting!
