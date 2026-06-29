import 'package:equatable/equatable.dart';

import '../utils/safe_parser.dart';

/// Shared pagination metadata from Vestie list endpoints.
class PaginationDto extends Equatable {
  const PaginationDto({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  factory PaginationDto.fromJson(
    Map<String, dynamic>? json, {
    int fallbackItemCount = 0,
  }) {
    if (json == null || json.isEmpty) {
      final count = fallbackItemCount;
      final pages = count == 0
          ? 0
          : ((count + PaginationQuery.defaultPageSize - 1) ~/
                PaginationQuery.defaultPageSize);
      return PaginationDto(
        page: PaginationQuery.defaultPage,
        pageSize: PaginationQuery.defaultPageSize,
        totalCount: count,
        totalPages: pages,
      );
    }

    final page = PaginationQuery.normalizePage(
      json.safeInt('page', defaultValue: PaginationQuery.defaultPage),
    );
    final pageSize = PaginationQuery.normalizePageSize(
      json.safeInt('pageSize', defaultValue: PaginationQuery.defaultPageSize),
    );
    final totalCount = json.safeInt(
      'totalCount',
      defaultValue: fallbackItemCount,
    );
    final computedPages = totalCount == 0
        ? 0
        : ((totalCount + pageSize - 1) ~/ pageSize);
    final totalPages = json.safeInt(
      'totalPages',
      defaultValue: computedPages,
    );

    return PaginationDto(
      page: page,
      pageSize: pageSize,
      totalCount: totalCount,
      totalPages: totalPages,
    );
  }

  @override
  List<Object?> get props => [page, pageSize, totalCount, totalPages];
}

/// `{ items, pagination }` wrapper used by many Vestie list responses.
class PaginatedListModel<T> extends Equatable {
  const PaginatedListModel({
    required this.items,
    required this.pagination,
  });

  final List<T> items;
  final PaginationDto pagination;

  @override
  List<Object?> get props => [items, pagination];
}

/// Parses paginated API payloads and builds default query parameters.
abstract final class PaginatedListParser {
  static List<Map<String, dynamic>> parseItemMaps(
    dynamic raw, {
    List<String> legacyListKeys = const [
      'items',
      'data',
      'results',
      'value',
    ],
  }) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => m.cast<String, dynamic>())
          .toList(growable: false);
    }
    if (raw is Map) {
      final map = raw.cast<String, dynamic>();
      for (final key in legacyListKeys) {
        final nested = map[key];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map((m) => m.cast<String, dynamic>())
              .toList(growable: false);
        }
      }
    }
    return const [];
  }

  static PaginationDto parsePagination(
    dynamic raw, {
    int fallbackItemCount = 0,
  }) {
    if (raw is Map) {
      final map = raw.cast<String, dynamic>();
      final pagination = map['pagination'];
      if (pagination is Map) {
        return PaginationDto.fromJson(
          pagination.cast<String, dynamic>(),
          fallbackItemCount: fallbackItemCount,
        );
      }
      if (map.containsKey('totalCount')) {
        final count =
            (map['totalCount'] as num?)?.toInt() ?? fallbackItemCount;
        return PaginationDto.fromJson(null, fallbackItemCount: count);
      }
      final items = parseItemMaps(map);
      return PaginationDto.fromJson(null, fallbackItemCount: items.length);
    }
    if (raw is List) {
      return PaginationDto.fromJson(null, fallbackItemCount: raw.length);
    }
    return PaginationDto.fromJson(null, fallbackItemCount: fallbackItemCount);
  }

  static PaginatedListModel<T> parse<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson, {
    List<String> legacyListKeys = const [
      'items',
      'data',
      'results',
      'value',
    ],
  }) {
    final maps = parseItemMaps(raw, legacyListKeys: legacyListKeys);
    final pagination = parsePagination(raw, fallbackItemCount: maps.length);
    return PaginatedListModel(
      items: maps.map(fromJson).toList(growable: false),
      pagination: pagination,
    );
  }

  /// For responses like `{ projects: [...], pagination }`.
  static PaginatedListModel<T> parseKeyedList<T>(
    Map<String, dynamic> json,
    String listKey,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final listRaw = json[listKey];
    final maps = listRaw is List
        ? listRaw
              .whereType<Map>()
              .map((m) => m.cast<String, dynamic>())
              .toList(growable: false)
        : parseItemMaps(listRaw);
    final pagination = json['pagination'] is Map
        ? PaginationDto.fromJson(
            (json['pagination'] as Map).cast<String, dynamic>(),
            fallbackItemCount: maps.length,
          )
        : parsePagination(listRaw ?? json, fallbackItemCount: maps.length);
    return PaginatedListModel(
      items: maps.map(fromJson).toList(growable: false),
      pagination: pagination,
    );
  }
}

/// Default pagination query parameters for Vestie GET list endpoints.
abstract final class PaginationQuery {
  static const int defaultPage = 1;
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int defaultMembersPageSize = 50;

  static int normalizePage(int page) =>
      page < defaultPage ? defaultPage : page;

  static int normalizePageSize(int? pageSize) {
    final size = pageSize ?? defaultPageSize;
    if (size < 1) return defaultPageSize;
    if (size > maxPageSize) return maxPageSize;
    return size;
  }

  static Map<String, dynamic> pageAndSize({
    int page = defaultPage,
    int? pageSize,
  }) =>
      {
        'page': normalizePage(page),
        'pageSize': normalizePageSize(pageSize),
      };

  static Map<String, dynamic> projectDetailSections({
    int membersPage = defaultPage,
    int? membersPageSize,
    int announcementsPage = defaultPage,
    int? announcementsPageSize,
    int invitesPage = defaultPage,
    int? invitesPageSize,
  }) =>
      {
        'membersPage': normalizePage(membersPage),
        'membersPageSize': normalizePageSize(
          membersPageSize ?? defaultMembersPageSize,
        ),
        'announcementsPage': normalizePage(announcementsPage),
        'announcementsPageSize': normalizePageSize(announcementsPageSize),
        'invitesPage': normalizePage(invitesPage),
        'invitesPageSize': normalizePageSize(invitesPageSize),
      };

  static Map<String, dynamic> historyPage({
    int page = defaultPage,
    int? pageSize,
  }) =>
      {
        'historyPage': normalizePage(page),
        'historyPageSize': normalizePageSize(pageSize),
      };

  static Map<String, dynamic> projectsPage({
    int page = defaultPage,
    int? pageSize,
  }) =>
      {
        'projectsPage': normalizePage(page),
        'projectsPageSize': normalizePageSize(pageSize),
      };

  static Map<String, dynamic> inboxReceived({
    int vffRequestsPage = defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = defaultPage,
    int? projectInvitesPageSize,
  }) =>
      {
        'vffRequestsPage': normalizePage(vffRequestsPage),
        'vffRequestsPageSize': normalizePageSize(vffRequestsPageSize),
        'projectInvitesPage': normalizePage(projectInvitesPage),
        'projectInvitesPageSize': normalizePageSize(projectInvitesPageSize),
      };

  static Map<String, dynamic> inboxSent({
    int vffRequestsPage = defaultPage,
    int? vffRequestsPageSize,
    int projectInvitesPage = defaultPage,
    int? projectInvitesPageSize,
    int joinRequestsPage = defaultPage,
    int? joinRequestsPageSize,
  }) =>
      {
        'vffRequestsPage': normalizePage(vffRequestsPage),
        'vffRequestsPageSize': normalizePageSize(vffRequestsPageSize),
        'projectInvitesPage': normalizePage(projectInvitesPage),
        'projectInvitesPageSize': normalizePageSize(projectInvitesPageSize),
        'joinRequestsPage': normalizePage(joinRequestsPage),
        'joinRequestsPageSize': normalizePageSize(joinRequestsPageSize),
      };
}
