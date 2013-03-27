package Bio::AutomatedAnnotation::CommandLine;

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

has 'sample_name'       => ( is => 'rw', isa => 'Str'  );
has 'dbdir'             => ( is => 'rw', isa => 'Str'  );
has 'assembly_file'     => ( is => 'rw', isa => 'Str'  );
has 'annotation_tool'   => ( is => 'rw', isa => 'Str', default  => 'Prokka' );
has 'tmp_directory'     => ( is => 'rw', isa => 'Str', default  => '/tmp' );
has 'sequencing_centre' => ( is => 'rw', isa => 'Str', default  => 'SC' );
has 'accession_number'  => ( is => 'rw', isa => 'Maybe[Str]' );

sub BUILD {
    my ($self) = @_;

    my ( $sample_name, $dbdir, $assembly_file, $annotation_tool, $tmp_directory, $sequencing_centre, $accession_number,
        $help );

    GetOptionsFromArray(
        $self->args,
        's|sample_name=s'       => \$sample_name,
        'd|dbdir=s'             => \$dbdir,
        'a|assembly_file=s'     => \$assembly_file,
        't|tmp_directory=s'     => \$tmp_directory,
        'p|annotation_tool=s'   => \$annotation_tool,
        'c|sequencing_centre=s' => \$sequencing_centre,
        'n|accession_number=s'  => \$accession_number,
        'h|help'                => \$help,
    );

    $self->sample_name($sample_name)             if ( defined($sample_name) );
    $self->dbdir($dbdir)                         if ( defined($dbdir) );
    $self->assembly_file($assembly_file)         if ( defined($assembly_file) );
    $self->annotation_tool($annotation_tool)     if ( defined($annotation_tool) );
    $self->tmp_directory($tmp_directory)         if ( defined($tmp_directory) );
    $self->sequencing_centre($sequencing_centre) if ( defined($sequencing_centre) );
    $self->accession_number($accession_number)   if ( defined($accession_number) );

}

sub run {
    my ($self) = @_;
    (( -e $self->assembly_file ) && ! $self->help ) or die $self->usage_text;

    my $obj = Bio::AutomatedAnnotation->new(
          assembly_file    => $self->assembly_file,
          annotation_tool  => $self->annotation_tool,
          sample_name      => $self->sample_name,
          accession_number => $self->accession_number,
          dbdir            => $self->dbdir,
          tmp_directory    => $self->tmp_directory
    );
    $obj->annotate;

}

sub usage_text {
      my ($self) = @_;
      my $script_name = $self->script_name;

      return <<USAGE;
    Usage: $script_name [options]
    Annotate bacteria

    $script_name -a contigs.fa --dbdir /path/to/dbs  --sample_name Sample123

    # This help message
    eukaryote_mapping -h

USAGE
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;
