package SQL::Builder::Quoter;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{quote_char}     = $params{quote_char}     ||= '`';
    $self->{name_separator} = $params{name_separator} ||= '.';

    return $self;
}

sub quote {
    my $self = shift;
    my ($column) = @_;

    my @parts = split /\Q$self->{name_separator}\E/, $column;
    foreach my $part (@parts) {
        $part = $self->{quote_char} . $part . $self->{quote_char};
    }

    return join $self->{name_separator}, @parts;
}

sub split {
    my $self = shift;
    my ($quoted_column) = @_;

    my ($table, $column) = split /\Q$self->{name_separator}\E/, $quoted_column;
    ($column, $table) = ($table, '') unless $column;

    return
      map { s/^\Q$self->{quote_char}\E//; s/\Q$self->{quote_char}\E$//; $_ }
      ($table, $column);
}

1;
