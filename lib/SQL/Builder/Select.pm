package SQL::Builder::Select;

use strict;
use warnings;

require Carp;
use SQL::Builder::Join;
use SQL::Builder::Expression;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{quoter} = $params{quoter} || SQL::Builder::Quoter->new;

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
                push @values,
                  (
                    ref($column->{-col})
                    ? ${$column->{-col}}
                    : $self->_quote($column->{-col})
                  )
                  . ' AS '
                  . $self->_quote($column->{-as});
            }
            else {
                push @values, $self->_quote($column);
            }
        }

        $sql .= join ',', @values;
    }

    $sql .= ' FROM ';
    $sql .= $self->_quote($params{from});

    if (my $joins = $params{join}) {
        foreach my $join_params (ref $joins eq 'ARRAY' ? @$joins : ($joins)) {
            my $join =
              SQL::Builder::Join->new(quoter => $self->{quoter}, %$join_params);

            $sql .= ' ' . $join->to_sql;
            push @bind, $join->to_bind;
        }
    }

    if ($params{where}) {
        my $expr = SQL::Builder::Expression->new(
            quoter => $self->{quoter},
            expr   => $params{where}
        );
        $sql .= ' WHERE ' . $expr->to_sql;
        push @bind, $expr->to_bind;
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

sub _quote {
    my $self = shift;
    my ($column) = @_;

    return $self->{quoter}->quote($column);
}

1;
