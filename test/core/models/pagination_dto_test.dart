import 'package:flutter_test/flutter_test.dart';
import 'package:vestie/core/models/pagination_dto.dart';

void main() {
  group('PaginationDto', () {
    test('fromJson parses metadata', () {
      final dto = PaginationDto.fromJson({
        'page': 2,
        'pageSize': 20,
        'totalCount': 45,
        'totalPages': 3,
      });

      expect(dto.page, 2);
      expect(dto.pageSize, 20);
      expect(dto.totalCount, 45);
      expect(dto.totalPages, 3);
    });

    test('fromJson falls back when pagination missing', () {
      final dto = PaginationDto.fromJson(null, fallbackItemCount: 5);

      expect(dto.page, 1);
      expect(dto.pageSize, 20);
      expect(dto.totalCount, 5);
      expect(dto.totalPages, 1);
    });
  });

  group('PaginatedListParser', () {
    test('parse handles items + pagination wrapper', () {
      final result = PaginatedListParser.parse<String>(
        {
          'items': [
            {'id': 'a'},
            {'id': 'b'},
          ],
          'pagination': {
            'page': 1,
            'pageSize': 20,
            'totalCount': 2,
            'totalPages': 1,
          },
        },
        (json) => json['id'] as String,
      );

      expect(result.items, ['a', 'b']);
      expect(result.pagination.totalCount, 2);
    });

    test('parse handles legacy bare array', () {
      final result = PaginatedListParser.parse<String>(
        [
          {'id': 'a'},
          {'id': 'b'},
        ],
        (json) => json['id'] as String,
      );

      expect(result.items, ['a', 'b']);
      expect(result.pagination.totalCount, 2);
    });

    test('parseKeyedList handles projects response', () {
      final result = PaginatedListParser.parseKeyedList(
        {
          'projects': [
            {'id': 'p1', 'name': 'Fund'},
          ],
          'pagination': {
            'page': 1,
            'pageSize': 20,
            'totalCount': 1,
            'totalPages': 1,
          },
        },
        'projects',
        (json) => json['name'] as String,
      );

      expect(result.items, ['Fund']);
      expect(result.pagination.totalCount, 1);
    });

    test('parsePagination reads legacy totalCount', () {
      final pagination = PaginatedListParser.parsePagination({
        'borrowRequests': [],
        'totalCount': 7,
      });

      expect(pagination.totalCount, 7);
    });
  });

  group('PaginationQuery', () {
    test('normalizePage clamps below 1', () {
      expect(PaginationQuery.normalizePage(0), 1);
      expect(PaginationQuery.normalizePage(-3), 1);
    });

    test('normalizePageSize clamps invalid values', () {
      expect(PaginationQuery.normalizePageSize(null), 20);
      expect(PaginationQuery.normalizePageSize(0), 20);
      expect(PaginationQuery.normalizePageSize(200), 100);
    });
  });
}
