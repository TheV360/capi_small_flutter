const rowSeparator = '\r\n';
const fieldSeparator = ',';

bool quotesAreBalanced(String text) => '"'.allMatches(text).length.isEven;

List<List<String>> parseCsv(
  String text, {
  String rowSeparator = '\r\n',
  String fieldSeparator = ',',
}) {
  final needToRepair = text.contains('"');
  var rows = text
      .split(rowSeparator)
      .where((line) => line.isNotEmpty)
      .map((line) => line.split(fieldSeparator))
      .toList();

  if (needToRepair) {
    for (var row = 0; row < rows.length; row++) {
      for (var col = 0; col < rows[row].length; col++) {
        if (rows[row][col].startsWith('"')) {
          var corrected = rows[row][col];
          if (!quotesAreBalanced(corrected)) {
            var remRow = row, remCol = col;

            findMatchingQuote:
            while (true) {
              remCol++;
              if (remCol >= rows[remRow].length) {
                remCol = 0;
                remRow++;
                if (remRow >= rows.length) {
                  throw RangeError("couldn't find closing quote");
                }
                corrected += rowSeparator;
              } else {
                corrected += fieldSeparator;
              }
              corrected += rows[remRow][remCol];

              if (corrected.endsWith('"')) {
                if (quotesAreBalanced(corrected)) {
                  break findMatchingQuote;
                }
              }
            }

            if (row == remRow) {
              rows[row].removeRange(col + 1, remCol + 1);
            } else {
              // Erase the right half of the current row.
              rows[row].removeRange(col, rows[row].length);

              // Paste the right half of the remainder row
              // to the left half of the current row.
              rows[row] += rows[remRow].sublist(remCol);

              // Delete all rows between the current row
              // and the row after the remainder row.
              // (This includes the remainder row.)
              rows.removeRange(row + 1, remRow + 1);
            }
          }

          rows[row][col] = corrected
              .substring(1, corrected.length - 1)
              .replaceAll('""', '"');
        }
      }
    }
  }

  return rows;
}
