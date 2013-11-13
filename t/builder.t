use strict;
use warnings;

use Test::More;

use SQL::Builder;

subtest 'build' => sub {
    my $delete = SQL::Builder->build('delete', from => 'table');

    my $sql = $delete->to_sql;
    is $sql, 'DELETE FROM `table`';

    my @bind = $delete->to_bind;
    is_deeply \@bind, [];
};

done_testing;
