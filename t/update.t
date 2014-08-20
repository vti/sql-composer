use strict;
use warnings;

use Test::More;

use SQL::Composer::Update;

subtest 'build simple' => sub {
    my $expr =
      SQL::Composer::Update->new(table => 'table', values => [a => 'b']);

    my $sql = $expr->to_sql;
    is $sql, 'UPDATE `table` SET `a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b'];
};

subtest 'build simple with as is' => sub {
    my $expr =
      SQL::Composer::Update->new(table => 'table', values => [foo => \"'bar'"]);

    my $sql = $expr->to_sql;
    is $sql, q{UPDATE `table` SET `foo` = 'bar'};

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with as is and bind values' => sub {
    my $expr =
      SQL::Composer::Update->new(table => 'table', values => [foo => \['NOW() + INTERVAL ?', 15]]);

    my $sql = $expr->to_sql;
    is $sql, q{UPDATE `table` SET `foo` = NOW() + INTERVAL ?};

    my @bind = $expr->to_bind;
    is_deeply \@bind, [15];
};

subtest 'build with where' => sub {
    my $expr = SQL::Composer::Update->new(
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
