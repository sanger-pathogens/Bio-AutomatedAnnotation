package Bio::AutomatedAnnotation::ParseGenesFromGFFs;

# ABSTRACT: Parse GFF files and efficiency extract the gene sequence.

=head1 SYNOPSIS

Automated annotation of assemblies.
   use Bio::AutomatedAnnotation::ParseGenesFromGFF;
   
   my $obj = Bio::AutomatedAnnotation::ParseGenesFromGFF->new(
     gff_files    => ['abc.gff','efg.gff'],
     search_query => 'mecA'
   );
  $obj->annotate;

=cut

use Moose;
use Bio::AutomatedAnnotation::ParseGenesFromGFF;
use Bio::SeqIO;

has 'gff_files'    => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has 'search_query' => ( is => 'ro', isa => 'Str',      required => 1 );
has 'output_file'  => ( is => 'ro', isa => 'Str',      lazy     => 1, builder => '_build_output_file' );

has 'search_qualifiers' => ( is => 'ro', isa => 'ArrayRef', required => 1 );

has '_parser_objects' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build__parser_objects' );

sub _build_output_file {
    my ($self) = @_;
    my $file_suffix = $self->search_query;
    $file_suffix =~ s!\W!!gi;
    return join( '.', ( 'output', $file_suffix, 'fa' ) );
}

sub _build__parser_objects {
    my ($self) = @_;
    my @parser_objects;
    for my $gff_file ( @{ $self->gff_files } ) {
        push(
            @parser_objects,
            Bio::AutomatedAnnotation::ParseGenesFromGFF->new(
                gff_file          => $gff_file,
                search_query      => $self->search_query,
                search_qualifiers => $self->search_qualifiers
            )
        );
    }
    return \@parser_objects;
}

sub create_fasta_file {
    my ($self) = @_;

    my $output_fh = Bio::SeqIO->new(
        -format => 'Fasta',
        -file   => ">" . $self->output_file
    );
    for my $parser_obj ( @{ $self->_parser_objects } ) {
      next if(!defined($parser_obj->_bio_seq_objects) ||@{$parser_obj->_bio_seq_objects} == 0 );
        for my $seq_obj ( @{ $parser_obj->_bio_seq_objects } ) {
          next if(!defined($seq_obj));
            $output_fh->write_seq($seq_obj);
        }
    }
    1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
