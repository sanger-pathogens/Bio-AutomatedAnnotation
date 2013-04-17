package Bio::AutomatedAnnotation::CombinedProteome;

# ABSTRACT: Take in multiple FASTA sequences containing proteomes and concat them together and output a FASTA file

=head1 SYNOPSIS

Take in multiple FASTA sequences containing proteomes and concat them together and output a FASTA file
   use Bio::AutomatedAnnotation::CombinedProteome;
   
   my $obj = Bio::AutomatedAnnotation::GeneNamesFromGFF->new(
     proteome_files   => ['abc.fa','efg.fa'],
     output_filename   => 'example_output.fa'
   );
   $obj->create_combined_proteome_file;

=cut

use Moose;
use Bio::AutomatedAnnotation::Exceptions;

has 'proteome_files'  => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'output_filename' => ( is => 'rw', isa => 'Str',      default  => 'combined_output.fa' );

sub BUILD {
    my ($self) = @_;

    for my $filename ( @{ $self->proteome_files } ) {
        Bio::AutomatedAnnotation::Exceptions::FileNotFound->throw( error => 'Cant open file: ' . $filename )
          unless ( -e $filename );
    }
}

sub create_combined_proteome_file {
    my ($self) = @_;
    my $list_of_files = join( ' ', @{ $self->proteome_files } );
    system( "cat $list_of_files > " . $self->output_filename );
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
