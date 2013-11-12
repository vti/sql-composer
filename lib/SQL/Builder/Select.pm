package SQL::Builder::Select;

use strict;
use warnings;

require Carp;
use SQL::Builder::Expression;
use SQL::Builder::Join;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    my $sql = '';
    my @bind;

    $sql .= 'SELECT ';

    if (my $columns = $params{columns}) {
        my @values;

        foreach my $column (@$columns) {
            if (ref $column eq 'SCALAR') {
                push @values, $$column;
            }
            elsif (ref $column eq 'HASH') {
                push @values, $column->{-col} . ' AS ' . $column->{-as};
            }
            else {
                push @values, $column;
            }
        }

        $sql .= join ',', @values;
    }

    $sql .= ' FROM ';
    $sql .= $params{from};

    if (my $joins = $params{join}) {
        foreach my $join_params (ref $joins eq 'ARRAY' ? @$joins : ($joins)) {

            my $join = SQL::Builder::Join->new(%$join_params);

            $sql .= ' ' . $join->to_sql;
            push @bind, $join->to_bind;
        }
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
