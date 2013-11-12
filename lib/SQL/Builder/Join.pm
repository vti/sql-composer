package SQL::Builder::Join;

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

    $sql .= uc($params{op}) . ' ' if $params{op};
    $sql .= 'JOIN ';

    if (ref $params{source} eq 'HASH') {
        my ($source) = keys %{$params{source}};
        my ($options) = values %{$params{source}};

        $sql .= $source;

        if (ref $options eq 'HASH') {
            my ($key) = keys %{$options};
            my ($value) = values %{$options};

            if ($key eq '-as') {
                $sql .= ' AS ' . $value . ' ';
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
        $sql .= $params{source} . ' ';
    }

    if ($params{on}) {
        my $expr = SQL::Builder::Expression->new(@{$params{on}});
        $sql .= 'ON ' . $expr->to_sql;
        push @bind, $expr->to_bind;
    }
    elsif (my $column = $params{using}) {
        $sql .= 'USING ' . $column;
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

1;
