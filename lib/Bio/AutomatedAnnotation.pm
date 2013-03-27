package Bio::AutomatedAnnotation;

# ABSTRACT: A set of attributes common to all pipeline config files

=head1 SYNOPSIS

A set of attributes common to all pipeline config files. It is ment to be extended rather than used on its own.
   use Bio::AutomatedAnnotation;
   
   my $obj = Bio::AutomatedAnnotation->new(
     assembly         => $assembly_file,
     annotation_tool  => $annotation_tool,
     sample_name        => $lane_name,
     accession_number => $accession,
     dbdir            => $dbdir,
     tmp_directory    => $tmp_directory
   );
  $obj->annotate;

=cut

use Moose;


has 'sample_name'         => ( is => 'ro', isa => 'Str', required => 1 );
has 'dbdir'               => ( is => 'ro', isa => 'Str', required => 1 );
has 'assembly'            => ( is => 'ro', isa => 'Str', required => 1 );
has 'annotation_tool'     => ( is => 'ro', isa => 'Str', default  => 'prokka' );
has 'tmp_directory'       => ( is => 'ro', isa => 'Str', default  => '/tmp' );
has 'sequencing_centre'   => ( is => 'ro', isa => 'Str', default  => 'SC' );



no Moose;
__PACKAGE__->meta->make_immutable;

1;
