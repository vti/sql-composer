package SQL::Builder::Update;

use strict;
use warnings;

require Carp;
use SQL::Builder::Expression;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    my $sql = '';
    my @bind;

    $sql .= 'UPDATE ';

    $sql .= $params{table};

    if ($params{values}) {
        my @columns;
        while (my ($key, $value) = splice @{$params{values}}, 0, 2) {
            push @columns, $key;
            push @bind, $value;
        }

        $sql .= ' SET ';
        $sql .= join ',', map { "$_ = ?" } @columns
    }

    if ($params{where}) {
        my $expr = SQL::Builder::Expression->new(@{$params{where}});
        $sql .= ' WHERE ' . $expr->to_sql;
        push @bind, $expr->to_bind;
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

1;
