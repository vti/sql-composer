use strict;
use warnings;

use Test::More;

use SQL::Builder::Update;

subtest 'build simple' => sub {
    my $expr =
      SQL::Builder::Update->new(table => 'table', values => [a => 'b']);

    my $sql = $expr->to_sql;
    is $sql, 'UPDATE `table` SET `a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b'];
};

subtest 'build with where' => sub {
    my $expr = SQL::Builder::Update->new(
        table  => 'table',
        values => [a => 'b'],
        where  => [c => 'd']
    );

    my $sql = $expr->to_sql;
    is $sql, 'UPDATE `table` SET `a` = ? WHERE `c` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b', 'd'];
};

done_testing;
