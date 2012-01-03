package Config::NameValue;

# ABSTRACT: Round trip simple name/value config file handling.

# VERSION

use strict;
use warnings;
use namespace::autoclean;

use Carp;
use File::Slurp qw( slurp );
use Scalar::Util qw( blessed );
use POSIX qw( strftime );

=head1 NAME

Config::NameValue - Read and save configuration files

=head1 VERSION

Version 1.00

=cut

our $VERSION = 1.00;

=head1 SYNOPSIS

  use Config::NameValue;
  my $c = Config::NameValue->new( 'config.file' );

=head1 OVERVIEW

Load simple name=value pair configuration files and save them.

Blank lines and comments are ignored.

  # Begin config file

  # Everything up to here will be ignored but continued in saved file.

  name1=value1
  name2=value2 # everything after the octothorpe will be ignored but be saved in the file when changes are made


=head1 METHODS

=head2 new

Returns a blessed object.  Can optionally be passed a filename, which will be loaded via the C<load> command.

=head2 load

Loads and parses the specified configuration file.

=cut

{ # Quick! Hide!

my $error;

sub new {

  my ( $class, $file ) = @_;

  croak 'Invalid call to new'
    unless $class && $class ne '';

  my $self = bless {}, ref $class || $class;

  $self->load( $file )
    if $file && $file ne '';

  return $self;

}

sub load {

  my ( $self, $file ) = @_;

  croak "Can't call load as a non-blessed object"
    unless blessed $self;

  if ( ! $file || $file eq '' ) {

    croak 'No file to load'
      unless exists $self->{ file } && $self->{ file } ne '';

    $file = $self->{ file };

  }

#  croak "No file to load"
#    unless $file;
#
#  open my $FH, '<', $file
#    or croak "Unable to open $file: $!";
#
#  chomp @{ $self->{ lines } = [ <$FH> ] };
#
#  $self->{ count } = @{ $self->{ lines } };

  my @lines = slurp( $file, { chomp => 1 } );

  for ( my $i = 0 ; $i < @lines ; $i++ ) {

    my $line = $self->{ lines }[$i];

    next if $line =~ /^\s*(#.*)?$/; # Ignore blank lines and comment lines
    $line =~ s/(?<!\\)#.*$//;       # Strip comment on a valid line, ignoring escaped #'s

#    my @data = split /\s*=\s*/, $line, 2;
#    $data[1] =~ s/^\s*(["'])(.*)\1$/$2/;
#    $self->{ name }{ $data[0] } = { value => $data[1], line => $i, modified => 0 };

    my ( undef, $name, $value ) = $line =~ /^\s*(["'])?(.*?)\1\s*=\s*(.*?)\s*$/;
    $self->{ name }{ $name } = { value => $value, line => $i, modified => 0 };

  }

  $self->{ file } = $file;
  $self->{ lines } = \@lines;
  $self->{ count } = scalar @lines;
  $self->{ modified } = 0;

  return 1;

}

=head2 save

Saves the configuration, with any changes, to a file.

If no filename is passed the original file is overwritten, otherwise a new file will be created.

=cut

sub save {

  my ( $self, $file ) = @_;

  croak "Can't call save as a non-blessed object"
    unless blessed $self;

  if ( ! $file || $file eq '' ) {

    croak 'No file to save'
      unless exists $self->{ file } && $self->{ file } ne '';

    $file = $self->{ file };

  }

  return 1 unless $self->{ modified };

  my @modified = grep { $self->{ name }{ $_ }{ modified } } keys %{ $self->{ name } };

  for my $name ( @modified ) {

    my ( $value, $line ) = @{ $self->{ name }{ $name } }{qw( value line )};

    $self->{ lines }[$line] =~ s/^(\s*(["'])$name\2\s*=\s*)(["'])(?:.*)\3\s*$/$1$3$value$3/;

  }

  my $work_file = sprintf '%s.work', $file ||= $self->{ file };

  open my $FH, '>', $work_file
    or croak "Unable to open $work_file: $!";

  print $FH "$_\n"
    for @{ $self->{ lines } };

  $FH->close
    or carp "Unable to close $work_file: $!\n";

  rename $work_file, $file
    or croak "Unable to rename $work_file to $file: $!";

}

=head2 get

Returns the value for the requested name, undef for nonexistant or empty names.

=cut

sub get {

  my ( $self, $name ) = @_;

  croak "Can't call get as a non-blessed object"
    unless blessed $self;

  croak "Nothing loaded"
    if ! exists $self->{ count } || $self->{ count } == 0;

  croak "Can't get nothing (no name passed)"
    if $name eq '';

  do { $error = "$name does not exist" ; return }
    unless exists $self->{ name }{ $name };

  ( my $value = $self->{ name }{ $name }{ value } ) =~ s/\\#/#/;

  return $value;

}

=head2 set

Modifies the requested name with the supplied value.

If the name does not exist it will be created and saved with a comment
indicating that it was added by this program

=cut

sub set {

  my ( $self, $name, $value ) = @_;

  croak "Can't call set as a non-blessed object"
    unless blessed $self;

  croak "Nothing loaded"
    if ! exists $self->{ count } || $self->{ count } == 0;

  croak "Can't set nothing (no name passed)"
    if $name eq '';

  if ( ! exists $self->{ name }{ $name } ) {

#    my $date = do {
#
#      my @d = localtime( time );
#      $d[5] += 1900;
#      $d[4]++;
#
#      join '-', @d[4,3,5];
#
#    };

    $value =~ s/#/\\#/;

    my $comment = sprintf '# %s added by %s on %s', $name, __PACKAGE__, strftime( '%F', gmtime );

    push @{ $self->{ lines } }, $comment;
    push @{ $self->{ lines } }, "$name=\"$value\"";

    $self->{ count }++;
    $self->{ name }{ $name } = {
      value    => $value,
      line     => $self->{ count }++,
      modified => 0,
    };

  } else {

    @{ $self->{ name }{ $name } }{qw( value modified )} = ( $value, 1 );

  }

  $self->{ modified } = 1;

  return 1;

}

=head2 error

Returns the most recent error

=cut

sub error { $error }

} # You can come out now!

1;
