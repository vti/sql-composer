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

    $sql .= $self->_quote($params{source}) . ' ';

    if (my $as = $params{as}) {
        $sql .= 'AS ' . $self->_quote($as) . ' ';
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
