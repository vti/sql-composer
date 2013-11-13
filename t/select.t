use strict;
use warnings;

use Test::More;

use SQL::Builder::Select;

subtest 'build simple' => sub {
    my $expr =
      SQL::Builder::Select->new(from => 'table', columns => ['a', 'b']);

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `a`,`b` FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build column as' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => [{-col => 'foo' => -as => 'bar'}]
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `foo` AS `bar` FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build column as is' => sub {
    my $expr =
      SQL::Builder::Select->new(from => 'table', columns => [\'COUNT(*)']);

    my $sql = $expr->to_sql;
    is $sql, 'SELECT COUNT(*) FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build column as with as is' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => [{-col => \'COUNT(*)', -as => 'count'}]
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT COUNT(*) AS `count` FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with where' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        where   => [a => 'b']
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `a`,`b` FROM `table` WHERE `a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b'];
};

subtest 'build with join' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        join    => {source => 'table', on => [a => 'b']}
    );

    my $sql = $expr->to_sql;
    is $sql, 'SELECT `a`,`b` FROM `table` JOIN `table` ON `a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b'];
};

subtest 'build with multiple joins' => sub {
    my $expr = SQL::Builder::Select->new(
        from    => 'table',
        columns => ['a', 'b'],
        join    => [
            {source => 'table', on => [a => 'b']},
            {source => 'table', on => [c => 'd']}
        ]
    );

    my $sql = $expr->to_sql;
    is $sql,
'SELECT `a`,`b` FROM `table` JOIN `table` ON `a` = ? JOIN `table` ON `c` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b', 'd'];
};

done_testing;
