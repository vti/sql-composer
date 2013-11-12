use strict;
use warnings;

use Test::More;

use SQL::Builder::Insert;

subtest 'build simple' => sub {
    my $expr =
      SQL::Builder::Insert->new(into => 'table', values => [foo => 'bar']);

    my $sql = $expr->to_sql;
    is $sql, 'INSERT INTO table (foo) VALUES (?)';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['bar'];
};

done_testing;
