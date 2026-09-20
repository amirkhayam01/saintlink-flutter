/// Shared JSON conventions. Dates are converted to local time on the way in.
library;

DateTime localDateTime(String value) => DateTime.parse(value).toLocal();

DateTime? localDateTimeOrNull(String? value) =>
    value == null ? null : localDateTime(value);
