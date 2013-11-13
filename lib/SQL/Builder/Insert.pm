package SQL::Builder::Insert;

use strict;
use warnings;

require Carp;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    my $sql = '';
    my @bind;

    $sql .= 'INSERT INTO ';

    $sql .= $params{into};

    if ($params{values}) {
        my @columns;
        while (my ($key, $value) = splice @{$params{values}}, 0, 2) {
            push @columns, $key;
            push @bind, $value;
        }
        $sql .= ' (' . (join ',', @columns) . ')';
        $sql .= ' VALUES (';
        $sql .= join ',', split //, '?' x @columns;
        $sql .= ')';
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

1;
