import 'package:freezed_annotation/freezed_annotation.dart';

part 'page_meta.freezed.dart';
part 'page_meta.g.dart';

/// Laravel's paginator summary, as the API's list endpoints send it.
@freezed
abstract class PageMeta with _$PageMeta {
  const PageMeta._();

  const factory PageMeta({
    required int currentPage,
    required int lastPage,
    required int total,
  }) = _PageMeta;

  factory PageMeta.fromJson(Map<String, dynamic> json) => _$PageMetaFromJson(json);

  bool get hasMore => currentPage < lastPage;
}

/// One page of results with the paginator's position.
@immutable
class Paginated<T> {
  const Paginated({required this.items, required this.meta});

  final List<T> items;
  final PageMeta meta;
}
