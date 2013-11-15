use strict;
use warnings;

use Test::More;

use SQL::Builder::Insert;

subtest 'build simple' => sub {
    my $expr =
      SQL::Builder::Insert->new(into => 'table', values => [foo => 'bar']);

    my $sql = $expr->to_sql;
    is $sql, 'INSERT INTO `table` (`foo`) VALUES (?)';

    my @bind = $expr->to_bind;
    is_deeply \@bind, ['bar'];
};

subtest 'build simple with as is' => sub {
    my $expr =
      SQL::Builder::Insert->new(into => 'table', values => [foo => \"'bar'"]);

    my $sql = $expr->to_sql;
    is $sql, q{INSERT INTO `table` (`foo`) VALUES ('bar')};

    my @bind = $expr->to_bind;
    is_deeply \@bind, [];
};

subtest 'build with as is and bind values' => sub {
    my $expr =
      SQL::Builder::Insert->new(into => 'table', values => [foo => \['NOW() + INTERVAL ?', 15]]);

    my $sql = $expr->to_sql;
    is $sql, q{INSERT INTO `table` (`foo`) VALUES (NOW() + INTERVAL ?)};

    my @bind = $expr->to_bind;
    is_deeply \@bind, [15];
};

done_testing;
