package SQL::Builder::Update;

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

    $sql .= 'UPDATE ';

    $sql .= $self->_quote($params{table});

    if ($params{values} || $params{set}) {
        my $set = $params{values} || $params{set};
        my @columns;

        if (ref $set eq 'HASH') {
            while (my ($key, $value) = each %$set) {
                push @columns, $key;
                push @bind,    $value;
            }
        }
        else {
            while (my ($key, $value) = splice @{$set}, 0, 2) {
                push @columns, $key;
                push @bind,    $value;
            }
        }

        $sql .= ' SET ';
        $sql .= join ',', map { $self->_quote($_) . " = ?" } @columns;
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
