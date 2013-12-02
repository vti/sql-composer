package SQL::Builder::Insert;

use strict;
use warnings;

require Carp;
use SQL::Builder::Quoter;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{quoter} = $params{quoter} || SQL::Builder::Quoter->new;

    my $sql = '';
    my @bind;

    $sql .= 'INSERT INTO ';

    $sql .= $self->_quote($params{into});

    if ($params{values}) {
        my @columns;
        my @values;
        while (my ($key, $value) = splice @{$params{values}}, 0, 2) {
            push @columns, $key;

            if (ref $value) {
                if (ref $value eq 'SCALAR') {
                    push @values, $$value;
                }
                elsif (ref $value eq 'REF') {
                    if (ref $$value eq 'ARRAY') {
                        push @values, $$value->[0];
                        push @bind,   @$$value[1 .. $#{$$value}];
                    }
                    else {
                        Carp::croak('unexpected reference');
                    }
                }
                else {
                    Carp::croak('unexpected reference');
                }
            }
            else {
                push @values, '?';
                push @bind,   $value;
            }
        }

        $sql .= ' (' . (join ',', map { $self->_quote($_) } @columns) . ')';
        $sql .= ' VALUES (';
        $sql .= join ',', @values;
        $sql .= ')';
    }

    $self->{sql}  = $sql;
    $self->{bind} = \@bind;

    return $self;
}

sub to_sql { shift->{sql} }
sub to_bind { @{shift->{bind} || []} }

sub _quote {
    my $self = shift;
    my ($column, $prefix) = @_;

    return $self->{quoter}->quote($column, $prefix);
}

1;
__END__

=pod

=head1

SQL::Builder::Insert - INSERT statement

=head1 SYNOPSIS

    my $insert =
      SQL::Builder::Insert->new(into => 'table', values => [foo => 'bar']);

    my $sql = $insert->to_sql;   # 'INSERT INTO `table` (`foo`) VALUES (?)'
    my @bind = $insert->to_bind; # ['bar']

=cut
