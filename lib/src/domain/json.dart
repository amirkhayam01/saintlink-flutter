/// Shared JSON conventions for the API models.
///
/// The server sends ISO 8601 with an offset (Europe/London). Every date is
/// converted to local time on the way in, so a screen can format it without
/// remembering to — and so a UTC instant never leaks into a `DateTime.now()`
/// comparison as a different wall-clock hour.
library;

DateTime localDateTime(String value) => DateTime.parse(value).toLocal();

DateTime? localDateTimeOrNull(String? value) => value == null ? null : localDateTime(value);
