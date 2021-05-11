%% Copyright (c) 2021 Bryan Frimin <bryan@frimin.fr>.
%%
%% Permission to use, copy, modify, and/or distribute this software for any
%% purpose with or without fee is hereby granted, provided that the above
%% copyright notice and this permission notice appear in all copies.
%%
%% THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
%% WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
%% MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
%% SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
%% WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
%% ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
%% IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

-module(imf_datetime_header_field).

-export([encode/2, format_datetime/0, format_datetime/1]).

-spec encode(binary(), iodata()) -> iodata().
encode(Name, Value) ->
  [Name, $:, $\s, Value].

-spec format_datetime() -> iodata().
format_datetime() ->
  format_datetime({localtime, calendar:local_time()}).

-spec format_datetime({iodata, iodata()} | {localtime, calendar:datetime()}) ->
        iodata().
format_datetime({iodata, Value}) ->
  Value;
format_datetime({localtime, Value}) ->
  {{Year, Month, Day}, {Hour, Minute, Second}} = Value,
  DayOfTheWeek = calendar:day_of_the_week(Year, Month, Day),
  DayName = lists:nth(DayOfTheWeek, days()),
  MonthName = lists:nth(Month, months()),
  TZOffset = timezone_offset(Value),
  io_lib:format("~s, ~b ~s ~b ~2..0b:~2..0b:~2..0b ~s",
                [DayName, Day, MonthName, Year, Hour, Minute, Second,
                 TZOffset]).

-spec days() -> iodata().
days() ->
  ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].

-spec months() -> iodata().
months() ->
 ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct",
  "Nov", "Dec"].

-spec timezone_offset(calendar:datetime()) -> iodata().
timezone_offset(Datetime) ->
  UniversalDatetime = calendar:local_time_to_universal_time(Datetime),
  case calendar:datetime_to_gregorian_seconds(Datetime) -
    calendar:datetime_to_gregorian_seconds(UniversalDatetime) of
    DiffSec when DiffSec < 0 ->
      io_lib:format("-~4..0w", [trunc(abs((DiffSec / 3600) * 100))]);
    DiffSec ->
      io_lib:format("+~4..0w", [trunc(abs((DiffSec / 3600) * 100))])
  end.
