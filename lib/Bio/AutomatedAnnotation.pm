package Bio::AutomatedAnnotation;
# ABSTRACT: Automated annotation of assemblies

=head1 SYNOPSIS

Automated annotation of assemblies.
   use Bio::AutomatedAnnotation;
   
   my $obj = Bio::AutomatedAnnotation->new(
     assembly_file    => $assembly_file,
     annotation_tool  => $annotation_tool,
     sample_name      => $lane_name,
     accession_number => $accession,
     dbdir            => $dbdir,
     tmp_directory    => $tmp_directory
   );
  $obj->annotate;

=cut

use Moose;
use File::Basename;
use Cwd;
use Bio::AutomatedAnnotation::Prokka;

has 'sample_name'       => ( is => 'ro', isa => 'Str', required => 1 );
has 'dbdir'             => ( is => 'ro', isa => 'Str', required => 1 );
has 'assembly_file'     => ( is => 'ro', isa => 'Str', required => 1 );
has 'annotation_tool'   => ( is => 'ro', isa => 'Str', default  => 'Prokka' );
has 'outdir'            => ( is => 'ro', isa => 'Str', default  => 'annotation' );
has 'tmp_directory'     => ( is => 'ro', isa => 'Str', default  => '/tmp' );
has 'sequencing_centre' => ( is => 'ro', isa => 'Str', default  => 'SC' );
has 'genus'             => ( is => 'ro', isa => 'Maybe[Str]' );
has 'accession_number'  => ( is => 'ro', isa => 'Maybe[Str]' );

has '_annotation_pipeline_class' =>
  ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__annotation_pipeline_class' );

sub _contig_uniq_id {
    my ($self) = @_;
    if ( defined( $self->accession_number ) ) {
        return $self->accession_number;
    }
    else {
        return $self->sample_name;
    }
}

sub _build__annotation_pipeline_class {
    my ($self) = @_;
    my $annotation_pipeline_class = "Bio::AutomatedAnnotation::" . $self->annotation_tool;
    eval "require $annotation_pipeline_class";
    return $annotation_pipeline_class;
}

sub annotate {
    my ($self) = @_;
    
    # Run the annotation in the directory containing the assembly
    my $original_cwd = getcwd();
    my ( $filename, $directories, $suffix ) = fileparse( $self->assembly_file );
    chdir( $directories );

    my $annotation_pipeline = $self->_annotation_pipeline_class->new(
        assembly_file  => $self->assembly_file,
        tempdir        => $self->tmp_directory,
        centre         => $self->sequencing_centre,
        dbdir          => $self->dbdir,
        prefix         => $self->sample_name,
        locustag       => $self->sample_name,
        outdir         => $self->outdir,
        force          => 1,
        contig_uniq_id => $self->_contig_uniq_id
    );
    
    if(defined($self->genus))
    {
      $annotation_pipeline->genus($self->genus);
      $annotation_pipeline->usegenus(1);
    }
    
    $annotation_pipeline->annotate;
    
    chdir($original_cwd);
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
