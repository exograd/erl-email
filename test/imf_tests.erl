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

-module(imf_tests).

-include_lib("eunit/include/eunit.hrl").

quote_test_() ->
  [?_assertEqual(<<"hello">>,
                 imf:quote(<<"hello">>, atom)),
   ?_assertEqual(<<"\"hello\\\"world\"">>,
                 imf:quote(<<"hello\"world">>, atom)),
   ?_assertEqual(<<"\"hello world\"">>,
                 imf:quote(<<"hello world">>, atom)),
   ?_assertEqual(<<"\"hello\\nworld\"">>,
                 imf:quote(<<"hello\nworld">>, atom)),
   ?_assertEqual(<<"\"hello.world\"">>,
                 imf:quote(<<"hello.world">>, atom)),
   ?_assertEqual(<<"hello.world">>,
                 imf:quote(<<"hello.world">>, dotatom)),
   ?_assertEqual(<<"\"hello\\\\world\"">>,
                 imf:quote(<<"hello\\world">>, atom))].

encode(Mail) ->
  iolist_to_binary(imf:encode(Mail)).

encode_test_() ->
  [?_assertEqual(
      <<>>,
      encode(#{header => [], body => <<>>})),

   %% Date header field
   ?_assertEqual(
      <<"Date: Fri, 21 May 2021 14:47:17 +0200\r\n">>,
      encode(#{header =>
                 [{date,
                   {localtime, {{2021,5,21},{14,47,17}}}}],
               body => <<>>})),

   %% From header field
   ?_assertEqual(
      <<"From: JohnDoe <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"JohnDoe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: \"John Doe\" <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"John Doe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: john.doe@example.com\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"John Doé">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"John Doé"/utf8>>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: \"Group 1\":;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group 1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group d'été">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group, #{name => <<"Group d'été"/utf8>>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:\"John Doe\" <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doe">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:=?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: Group1:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com,\r\n Person1 <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:john.doe@example.com,\r\n \"Person.1\" <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{from,
                   [{group,
                     #{name => <<"Group d'été"/utf8>>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person.1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: person1@example.com,\r\n person2@example.com,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox, #{address => <<"person1@example.com">>}},
                    {mailbox, #{address => <<"person2@example.com">>}},
                    {mailbox, #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"From: \"Person 1\" <person1@example.com>,\r\n \"Group 1\":;,\r\n \"Person 2\" <person2@example.com>,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{from,
                   [{mailbox,
                     #{name => <<"Person 1">>,
                       address => <<"person1@example.com">>}},
                    {group,
                     #{name => <<"Group 1">>}},
                    {mailbox,
                     #{name => <<"Person 2">>,
                       address => <<"person2@example.com">>}},
                    {mailbox,
                     #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   %% Sender header field
   ?_assertEqual(
      <<"Sender: \"John Doe\" <john.doe.example.com>\r\n">>,
      encode(#{header =>
                 [{sender,
                   {mailbox,
                    #{name => <<"John Doe">>,
                      address => <<"john.doe.example.com">>}}}],
               body => <<>>})),

   ?_assertEqual(
      <<"Sender: =?ISO-8859-1?Q?John_Do=E9?= <john.doe.example.com>\r\n">>,
      encode(#{header =>
                 [{sender,
                   {mailbox,
                    #{name => <<"John Doé">>,
                      address => <<"john.doe.example.com">>}}}],
               body => <<>>})),

   ?_assertEqual(
      <<"Sender: =?UTF-8?Q?John_Do=C3=A9?= <john.doe.example.com>\r\n">>,
      encode(#{header =>
                 [{sender,
                   {mailbox,
                    #{name => <<"John Doé"/utf8>>,
                      address => <<"john.doe.example.com">>}}}],
               body => <<>>})),

   ?_assertEqual(
      <<"Sender: john.doe.example.com\r\n">>,
      encode(#{header =>
                 [{sender,
                   {mailbox,
                    #{address => <<"john.doe.example.com">>}}}],
               body => <<>>})),

   %% Reply-To header field
   ?_assertEqual(
      <<"Reply-To: JohnDoe <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{mailbox,
                     #{name => <<"JohnDoe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: \"John Doe\" <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{mailbox,
                     #{name => <<"John Doe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: john.doe@example.com\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{mailbox,
                     #{address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{mailbox,
                     #{name => <<"John Doé">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{mailbox,
                     #{name => <<"John Doé"/utf8>>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: Group1:;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group, #{name => <<"Group1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: \"Group 1\":;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group, #{name => <<"Group 1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group, #{name => <<"Group d'été">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group, #{name => <<"Group d'été"/utf8>>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: Group1:\"John Doe\" <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doe">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: Group1:=?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: Group1:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com,\r\n Person1 <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:john.doe@example.com,\r\n \"Person.1\" <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{group,
                     #{name => <<"Group d'été"/utf8>>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person.1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: person1@example.com,\r\n person2@example.com,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{mailbox, #{address => <<"person1@example.com">>}},
                    {mailbox, #{address => <<"person2@example.com">>}},
                    {mailbox, #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Reply-To: \"Person 1\" <person1@example.com>,\r\n \"Group 1\":;,\r\n \"Person 2\" <person2@example.com>,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{reply_to,
                   [{mailbox,
                     #{name => <<"Person 1">>,
                       address => <<"person1@example.com">>}},
                    {group,
                     #{name => <<"Group 1">>}},
                    {mailbox,
                     #{name => <<"Person 2">>,
                       address => <<"person2@example.com">>}},
                    {mailbox,
                     #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   %% To header field
   ?_assertEqual(
      <<"To: JohnDoe <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{to,
                   [{mailbox,
                     #{name => <<"JohnDoe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: \"John Doe\" <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{to,
                   [{mailbox,
                     #{name => <<"John Doe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: john.doe@example.com\r\n">>,
      encode(#{header =>
                 [{to,
                   [{mailbox,
                     #{address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{to,
                   [{mailbox,
                     #{name => <<"John Doé">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{to,
                   [{mailbox,
                     #{name => <<"John Doé"/utf8>>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: Group1:;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group, #{name => <<"Group1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: \"Group 1\":;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group, #{name => <<"Group 1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group, #{name => <<"Group d'été">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group, #{name => <<"Group d'été"/utf8>>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: Group1:\"John Doe\" <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doe">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: Group1:=?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: Group1:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com,\r\n Person1 <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:john.doe@example.com,\r\n \"Person.1\" <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{to,
                   [{group,
                     #{name => <<"Group d'été"/utf8>>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person.1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: person1@example.com,\r\n person2@example.com,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{to,
                   [{mailbox, #{address => <<"person1@example.com">>}},
                    {mailbox, #{address => <<"person2@example.com">>}},
                    {mailbox, #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"To: \"Person 1\" <person1@example.com>,\r\n \"Group 1\":;,\r\n \"Person 2\" <person2@example.com>,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{to,
                   [{mailbox,
                     #{name => <<"Person 1">>,
                       address => <<"person1@example.com">>}},
                    {group,
                     #{name => <<"Group 1">>}},
                    {mailbox,
                     #{name => <<"Person 2">>,
                       address => <<"person2@example.com">>}},
                    {mailbox,
                     #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   %% Cc header field
   ?_assertEqual(
      <<"Cc: JohnDoe <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{mailbox,
                     #{name => <<"JohnDoe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: \"John Doe\" <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{mailbox,
                     #{name => <<"John Doe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: john.doe@example.com\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{mailbox,
                     #{address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{mailbox,
                     #{name => <<"John Doé">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{mailbox,
                     #{name => <<"John Doé"/utf8>>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: Group1:;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group, #{name => <<"Group1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: \"Group 1\":;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group, #{name => <<"Group 1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group, #{name => <<"Group d'été">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group, #{name => <<"Group d'été"/utf8>>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: Group1:\"John Doe\" <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doe">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: Group1:=?ISO-8859-1?Q?John_Do=E9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: Group1:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:=?UTF-8?Q?John_Do=C3=A9?= <john.doe@example.com>;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?ISO-8859-1?Q?Group_d'=E9t=E9?=:john.doe@example.com,\r\n Person1 <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: =?UTF-8?Q?Group_d'=C3=A9t=C3=A9?=:john.doe@example.com,\r\n \"Person.1\" <person1@example.com>;\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{group,
                     #{name => <<"Group d'été"/utf8>>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person.1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: person1@example.com,\r\n person2@example.com,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{mailbox, #{address => <<"person1@example.com">>}},
                    {mailbox, #{address => <<"person2@example.com">>}},
                    {mailbox, #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<"Cc: \"Person 1\" <person1@example.com>,\r\n \"Group 1\":;,\r\n \"Person 2\" <person2@example.com>,\r\n person3@example.com\r\n">>,
      encode(#{header =>
                 [{cc,
                   [{mailbox,
                     #{name => <<"Person 1">>,
                       address => <<"person1@example.com">>}},
                    {group,
                     #{name => <<"Group 1">>}},
                    {mailbox,
                     #{name => <<"Person 2">>,
                       address => <<"person2@example.com">>}},
                    {mailbox,
                     #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   %% Bcc header field
   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{mailbox,
                     #{name => <<"JohnDoe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{mailbox,
                     #{name => <<"John Doe">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{mailbox,
                     #{address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{mailbox,
                     #{name => <<"John Doé">>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{mailbox,
                     #{name => <<"John Doé"/utf8>>,
                       address => <<"john.doe@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group, #{name => <<"Group1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group, #{name => <<"Group 1">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group, #{name => <<"Group d'été">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group, #{name => <<"Group d'été"/utf8>>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doe">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé">>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group,
                     #{name => <<"Group1">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{name => <<"John Doé"/utf8>>,
                             address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group,
                     #{name => <<"Group d'été">>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{group,
                     #{name => <<"Group d'été"/utf8>>,
                       addresses =>
                         [{mailbox,
                           #{address => <<"john.doe@example.com">>}},
                          {mailbox,
                           #{name => <<"Person.1">>,
                             address => <<"person1@example.com">>}}]}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{mailbox, #{address => <<"person1@example.com">>}},
                    {mailbox, #{address => <<"person2@example.com">>}},
                    {mailbox, #{address => <<"person3@example.com">>}}]}],
               body => <<>>})),

   ?_assertEqual(
      <<>>,
      encode(#{header =>
                 [{bcc,
                   [{mailbox,
                     #{name => <<"Person 1">>,
                       address => <<"person1@example.com">>}},
                    {group,
                     #{name => <<"Group 1">>}},
                    {mailbox,
                     #{name => <<"Person 2">>,
                       address => <<"person2@example.com">>}},
                    {mailbox,
                     #{address => <<"person3@example.com">>}}]}],
               body => <<>>}))
].
