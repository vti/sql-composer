package SQL::Builder;

use strict;
use warnings;

our $VERSION = '0.01';

require Carp;
use SQL::Builder::Select;
use SQL::Builder::Insert;
use SQL::Builder::Delete;
use SQL::Builder::Update;

$Carp::Internal{(__PACKAGE__)}++;
$Carp::Internal{"SQL::Builder::$_"}++ for qw/
  Select
  Insert
  Delete
  Update
  Expression
  Join
  Quoter
  /;

sub build {
    my $class = shift;
    my ($name) = shift;

    my $class_name = 'SQL::Builder::' . ucfirst($name);
    return $class_name->new(@_);
}

1;
__END__

=pod

=head1 NAME

SQL::Builder - sql builder

=head1 AUTHOR

Viacheslav Tykhanovskyi

=cut
