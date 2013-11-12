use strict;
use warnings;

use Test::More;

use SQL::Builder;

subtest 'accept bind params as hash ref' => sub {
    my $raw =
      SQL::Builder->new_raw('select * from table where id=:id and foo=:foo',
        {id => 1, foo => 'bar'});
    my $sql = $raw->to_sql;
    is "$sql", 'select * from table where id=? and foo=?';

    my $bind = $raw->to_bind;
    is_deeply $bind, [1, 'bar'];
};

subtest 'accept bind params as array ref' => sub {
    my $raw = SQL::Builder->new_raw('select * from table where id=?', [1]);
    my $sql = $raw->to_sql;
    is "$sql", 'select * from table where id=?';

    my $bind = $raw->to_bind;
    is_deeply $bind, [1];
};

done_testing;
