package SQL::Builder::Join;

use strict;
use warnings;

require Carp;
use SQL::Builder::Quoter;
use SQL::Builder::Expression;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{quoter} = $params{quoter} || SQL::Builder::Quoter->new;

    my $sql = '';
    my @bind;

    $sql .= uc($params{op}) . ' ' if $params{op};
    $sql .= 'JOIN ';

    if (ref $params{source} eq 'HASH') {
        my ($source)  = keys %{$params{source}};
        my ($options) = values %{$params{source}};

        $sql .= $self->_quote($source);

        if (ref $options eq 'HASH') {
            my ($key)   = keys %{$options};
            my ($value) = values %{$options};

            if ($key eq '-as') {
                $sql .= ' AS ' . $self->_quote($value) . ' ';
            }
            else {
                Carp::croak('unknown option');
            }
        }
        else {
            Carp::croak('unknown reference');
        }
    }
    else {
        $sql .= $self->_quote($params{source}) . ' ';
    }

    if (my $constraint = $params{on}) {
        my $expr = SQL::Builder::Expression->new(
            quoter => $self->{quoter},
            expr   => $constraint
        );
        $sql .= 'ON ' . $expr->to_sql;
        push @bind, $expr->to_bind;
    }
    elsif (my $column = $params{using}) {
        $sql .= 'USING ' . $self->_quote($column);
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
