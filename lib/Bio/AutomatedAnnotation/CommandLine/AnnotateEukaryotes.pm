package Bio::AutomatedAnnotation::CommandLine::AnnotateEukaryotes;

# ABSTRACT: provide a commandline interface to the annotation wrappers

=head1 SYNOPSIS

provide a commandline interface to the annotation wrappers

=cut

use Moose;
use Getopt::Long qw(GetOptionsFromArray);
use Bio::AutomatedAnnotation;

has 'args'        => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'script_name' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'help'        => ( is => 'rw', isa => 'Bool',     default  => 0 );
has 'cpus'        => ( is => 'rw', isa => 'Int',      default  => 1 );
has 'exec_script'        => ( is => 'rw', isa => 'Str',      default  => 'interproscan.sh' );
has 'proteins_input_file' => ( is => 'rw', isa => 'Str' );
has 'tmp_directory' => ( is => 'rw', isa => 'Str', default => '/tmp' );

sub BUILD {
    my ($self) = @_;
    my ( $proteins_file, $tmp_directory, $help, $exec_script,$cpus );

    GetOptionsFromArray(
        $self->args,
        'a|proteins_file=s' => \$proteins_file,
        't|tmp_directory=s' => \$tmp_directory,
        'e|exec_script=s'   => \$exec_script,
        'p|cpus=s'          => \$cpus,
        'h|help'            => \$help,
    );

    $self->proteins_file($proteins_file) if ( defined($proteins_file) );
    $self->tmp_directory($tmp_directory) if ( defined($tmp_directory) );
    $self->exec_script($exec_script)     if ( defined($exec_script) );
    $self->cpus($cpus)                   if ( defined($cpus) );
}

sub run {
    my ($self) = @_;
    ( ( -e $self->proteins_file ) && !$self->help ) or die $self->usage_text;

    my $obj = Bio::AutomatedAnnotation::InterProScan->new( 
      input_file     => $self->proteins_file,
      _tmp_directory => $self->tmp_directory,
      cpus           => $self->cpus,
      exec           => $self->exec_script
       );
    $obj->annotate;

}

sub usage_text {
    my ($self) = @_;
    my $script_name = $self->script_name;

    return <<USAGE;
    Usage: $script_name [options]
    Annotate eukaryotes
    
    $script_name -a proteins.faa

    # This help message
    annotate_eukaryotes -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
