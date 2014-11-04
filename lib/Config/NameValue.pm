package Config::NameValue;

# ABSTRACT: Round trip simple name/value config file handling.

# VERSION

=head1 SYNOPSIS

  use Config::NameValue;
  my $c = Config::NameValue->new( 'config.file' );

=head1 DESCRIPTION

Load simple name=value pair configuration files and save them.

Blank lines and comments are ignored.

  # Begin config file

  # Everything up to here will be ignored but continued in saved file.

  name1=value1
  name2=value2 # everything after the octothorpe will be ignored but be saved in the file when changes are made

=cut

use strict;
use warnings;
use namespace::autoclean;

use Carp;
use File::Slurp qw( slurp );
use Scalar::Util qw( blessed );
use POSIX qw( strftime );

{ # Quick! Hide!

my $error;

=method new

Returns a Config::NameValue object.  Can optionally be passed a filename, which will be loaded via the C<load> command.

=cut

sub new {

  my ( $class, $file ) = @_;

  croak 'Calling new as a function is not supported'
    unless $class && $class ne '';

  my $self = bless {}, ref $class || $class;

  $self->load( $file )
    if $file && $file ne '';

  return $self;

}

=method load

Loads and parses the specified configuration file.

Leading and trailing whitespace are stripped.

  name1=value1
    name1=value1   # are equivalent

=cut

sub load {

  my ( $self, $file ) = @_;

  croak 'Calling load as a function is not supported'
    unless blessed $self;

  if ( ! $file || $file eq '' ) {

    croak 'No file to load'
      unless exists $self->{ file } && $self->{ file } ne '';

    $file = $self->{ file };

  }

  my @lines = slurp( $file, { chomp => 1 } );

  for ( my $i = 0 ; $i < @lines ; $i++ ) {

    my $line = $lines[$i];

    next if $line =~ /^\s*(#.*)?$/; # Ignore blank lines and comment lines
    $line =~ s/(?<!\\)#.*$//;       # Strip comment on a valid line, ignoring escaped #'s

    $line =~ s/^\s*(.*?)\s*$/$1/;   # Strip leading and trailing whitespace

    my @data = split /\s*=\s*/, $line, 2;
    $data[0] =~ s/^\s*(.*)/$1/;
    $data[1] =~ s/^(["'])(.*)\1$/$2/;
    $data[1] =~ s/\\#/#/g;

    $self->{ name }{ $data[0] } = { value => $data[1], line => $i, modified => 0 };

  }

  $self->{ file } = $file;
  $self->{ lines } = \@lines;
  $self->{ count } = scalar @lines;
  $self->{ modified } = 0;

  return 1;

}

=method save

Saves the configuration, with any changes, to a file.

If no filename is passed the original file is overwritten, otherwise a new file will be created.

As a special case, if the original filename is explicitly passed to save and there have been no changes an exception will be thrown.

=cut

sub save {

  my ( $self, $file ) = @_;

  croak 'Calling save as a function is not supported'
    unless blessed $self;

  if ( ! $file || $file eq '' ) {

    croak 'No file to save'
      unless exists $self->{ file } && $self->{ file } ne '';

    $file = $self->{ file };

  } elsif ( $file eq $self->{ file } ) {

    croak 'No changes, not saving'
      unless $self->{ modified };

  }

  if ( $self->{ modified } ) {

    my @modified = grep { $self->{ name }{ $_ }{ modified } } keys %{ $self->{ name } };

    for my $name ( @modified ) {

      my ( $value, $line ) = @{ $self->{ name }{ $name } }{qw( value line )};
      $self->{ lines }[$line] =~ s/^(\s*(["'])$name\2\s*=\s*)(["'])(?:.*)\3\s*$/$1$3$value$3/;

    }
  }

  my $work_file = "$file.work";

  require IO::Handle;

  open my $FH, '>', $work_file
    or croak "Unable to open $work_file: $!";

  print $FH "$_\n"
    for @{ $self->{ lines } };

  $FH->close
    or carp "Unable to close $work_file: $!\n"; # How do I test this to satisfy Devel::Cover?

  rename $work_file, $file
    or croak "Unable to rename $work_file to $file: $!";

}

=method get

Returns the value for the requested name, undef for nonexistent or empty names.

=cut

sub get {

  my ( $self, $name ) = @_;

  croak 'Calling get as a function is not supported'
    unless blessed $self;

  croak "Nothing loaded"
    if ! exists $self->{ count } || $self->{ count } == 0;

  croak "Can't get nothing (no name passed)"
    if $name eq '';

  do { $error = "$name does not exist" ; return }
    unless exists $self->{ name }{ $name };

  return $self->{ name }{ $name }{ value };

}

=method set

Modifies the requested name with the supplied value.

If the name does not exist it will be created and saved with a comment
indicating that it was added by this program

=cut

sub set {

  my ( $self, $name, $value ) = @_;

  croak 'Calling set as a function is not supported'
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

=method error

Returns the most recent error

=cut

sub error { $error }

} # You can come out now!

1;
