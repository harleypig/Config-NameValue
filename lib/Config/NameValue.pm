package Vutil::Config;

# ABSTRACT:

# VERSION

use strict;
use warnings in test environment only

use Carp;

=head1 NAME

Vutil::Config - Read and save configuration files

=head1 VERSION

Version 0.01

=cut

our $VERSION = 0.01;

=head1 SYNOPSIS

Load simple name=value pair configuration files and save them.

Blank lines and comments are ignored.

  # Begin config file

  # Everything up to here will be ignored but continued in saved file.

  name1=value1
  name2=value2 # everything after the octothorpe will be ignored but be saved in the file when changes are made


=head1 METHODS

=head2 new

returns a blessed object

=head2 load

loads and parses the specified configuration file

=cut

{ # Begin data hiding

my $error;

sub new { my $class = shift; bless {}, ref $class || $class }

sub load {

  my ( $self, $file ) = @_;

  croak "No file to load"
    unless $file;

  open my $FH, '<', $file
    or croak "Unable to open $file: $!";

  $self->{ 'file' } = $file;

  chomp @{ $self->{ 'lines' } = [ <$FH> ] };

  $self->{ 'count' } = @{ $self->{ 'lines' } };

  for ( my $i = 0 ; $i < @{ $self->{ 'lines' } } ; $i++ ) {

    my $line = $self->{ 'lines' }[$i];

    next if $line =~ /^\s*(#.*)?$/; # Ignore blank lines and comment lines
    $line =~ s/(?<!\\)#.*$//;       # Strip comment on a valid line, ignoring escaped #'s

    my @data = split /=/, $line, 2;

    $data[1] =~ s/^(["'])(.*)\1$/$2/;

    $self->{ 'name' }{ $data[0] } = { 'value' => $data[1], 'line' => $i, 'modified' => 0 };

  }

  $self->{ 'modified' } = 0;

  return 1;
}

=head2 save

makes changes and saves the configuration file

If no filename is passed the original file is overwritten, otherwise a new file will be created.

=cut

sub save {

  my ( $self, $file ) = @_;

  return 1 unless $self->{ 'modified' };

  my @modified = grep { $self->{ 'name' }{ $_ }{ 'modified' } } keys %{ $self->{ 'name' } };

  for my $name ( @modified ) {

    my ( $value, $line ) = @{ $self->{ 'name' }{ $name } }{qw( value line )};

    $self->{ 'lines' }[$line] =~ s/^($name=")(?:.*)"\s*$/$1$value"/;

  }

  my $work_file = sprintf '%s.work', $file ||= $self->{ 'file' };

  open my $FH, '>', $work_file
    or croak "Unable to open $work_file: $!";

  print $FH "$_\n"
    for @{ $self->{ 'lines' } };

  rename $work_file, $file
    or croak "Unable to rename $work_file to $file: $!";

}

=head2 get

returns the value for the requested name, undef for nonexistant or empty names so check error

=cut

sub get {

  my ( $self, $name ) = @_;

  croak "Can't get nothing (no name passed)"
    if $name eq '';

  do { $error = "$name does not exist" ; return }
    unless exists $self->{ 'name' }{ $name };

  ( my $value = $self->{ 'name' }{ $name }{ 'value' } ) =~ s/\\#/#/;

  return $value;

}

=head2 set

modifies the requested name with the supplied value

if the name does not exist it will be created and saved with a comment
indicating that it was added by this program

=cut

sub set {

  my ( $self, $name, $value ) = @_;

  croak "Can't set nothing (no name passed)"
    if $name eq '';

  if ( ! exists $self->{ 'name' }{ $name } ) {

    my $date = do {

      my @d = localtime( time );
      $d[5] += 1900;
      $d[4]++;

      join '-', @d[4,3,5];

    };

    $value =~ s/#/\\#/;

    push @{ $self->{ 'lines' } }, "# $name added by Vutil::Config on $date";
    push @{ $self->{ 'lines' } }, "$name=\"$value\"";
    $self->{ 'count' }++;

    $self->{ 'name' }{ $name } = { 'value' => $value, 'line' => $self->{ 'count' }++, 'modified' => 0 };

  } else {

    @{ $self->{ 'name' }{ $name } }{qw( value modified )} = ( $value, 1 );

  }

  $self->{ 'modified' } = 1;

  return 1;
}

=head2 error

returns the most recent error

=cut

sub error { $error }

} # End  hiding data

1;
