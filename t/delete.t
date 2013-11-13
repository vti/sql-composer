use strict;
use warnings;

use Test::More;

use SQL::Builder::Delete;

subtest 'build simple' => sub {
    my $expr = SQL::Builder::Delete->new(from => 'table');

    my $sql = $expr->to_sql;
    is $sql, 'DELETE FROM `table`';

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with where' => sub {
    my $expr = SQL::Builder::Delete->new(from => 'table', where => [a => 'b']);

    my $sql = $expr->to_sql;
    is $sql, 'DELETE FROM `table` WHERE `a` = ?';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['b'];
};

done_testing;
