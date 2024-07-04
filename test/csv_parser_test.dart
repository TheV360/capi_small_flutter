import 'package:test/test.dart';

import 'package:capi_small_mvp/model/capi_small.dart';
import 'package:capi_small_mvp/csv_parser.dart';

void main() {
  group('Testing CSV Parser', () {
    test('Basics', () {
      {
        final r = parseCsv('\n');
        expect(r.isEmpty, true, reason: 'zero-field rows do not exist');
      }
      {
        final [r1, r2] = parseCsv('a,b,c\n"a","b","c"');
        expect(r1.length, 3);
        expect(r2.length, 3);
        expect(r1, r2,
            reason: 'the parser should unquote fields surrounded in quotes.');
      }
    });
    test('Not Basics', () {
      final texts = parseCsv(r'''
Home,braixen,"well, now i'm here",2024-06-30T22:41:01.245Z,,RP,1,2,1
Home,braixen,"and yet
i don't feel like much
has changed",2024-07-03T01:32:06.261Z,,RP,1,2,8
Home,braixen,"""what happens if ""i do this\"".""",2024-07-03T01:40:02.405Z,,RP,1,2,9
Home,braixen,"do you really want ""to parse this""",2024-07-03T01:54:30.053Z,,RP,1,2,10
Home,braixen,"wowwww
unit testing",2024-07-03T03:21:43.924Z,,RP,1,2,13
Home,braixen,"trailing newline
",2024-07-03T03:23:42.699Z,,RP,1,2,14
''');
      for (final row in texts) {
        expect(row.length, 9,
            reason: 'each line in this format requires 9 fields');
        // print([
        //   line.length,
        //   line.map((s) => s.replaceAll('\n', r'\n')).join(' | ')
        // ]);
        final parsed = CapiSmall.fromCsvRow(row);
        expect(parsed.userName, 'braixen', reason: 'im braixen');
      }
    });
  });
}
