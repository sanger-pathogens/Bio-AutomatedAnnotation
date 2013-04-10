package Bio::AutomatedAnnotation::ParseGenesFromGFF;

# ABSTRACT: Parse a GFF file and efficiency extract the gene sequence.

=head1 SYNOPSIS

Automated annotation of assemblies.
   use Bio::AutomatedAnnotation::ParseGenesFromGFF;
   
   my $obj = Bio::AutomatedAnnotation::ParseGenesFromGFF->new(
     gff_file   => 'abc.gff',
     search_query => 'mecA'
   );
   $obj->matching_features;

=cut

use Moose;
use Bio::Tools::GFF;

has 'gff_file'     => ( is => 'ro', isa => 'Str', required => 1 );
has 'search_query' => ( is => 'ro', isa => 'Str', required => 1 );

has '_awk_filter' => ( is => 'ro', isa => 'Str',             lazy => 1, builder => '_build__awk_filter' );
has '_gff_parser' => ( is => 'ro', isa => 'Bio::Tools::GFF', lazy => 1, builder => '_build__gff_parser' );
has '_tags_to_filter' => ( is => 'ro', isa => 'Str', default => 'CDS|tRNA|rRNA|tmRNA' );

has 'matching_features' => ( is => 'ro', isa => 'ArrayRef', lazy => 1, builder => '_build_matching_features' );

sub _build_matching_features {
    my ($self) = @_;
    my @tag_names = ( 'gene', 'product' );
    my @matching_features;
    my $search_query = $self->search_query;

    while ( my $raw_feature = $self->_gff_parser->next_feature() ) {
        for my $tag_name (@tag_names) {
            if ( $raw_feature->has_tag($tag_name) ) {
                my @tag_values = $raw_feature->get_tag_values($tag_name);
                for my $tag_value (@tag_values) {
                    if ( $tag_value =~ /$search_query/ ) {
                        push( @matching_features, $raw_feature );
                        last;
                    }
                }
            }
            last if ( @matching_features > 0 && $raw_feature eq $matching_features[-1] );
        }
    }
    return \@matching_features;
}

sub _build__gff_parser {
    my ($self) = @_;
    open( my $fh, "-|", $self->_awk_filter . " " . $self->gff_file );
    return Bio::Tools::GFF->new( -gff_version => 3, -fh => $fh );
}

# Parsing a GFF file with perl is slow, so filter out the bits we dont need first
sub _build__awk_filter {
    my ($self) = @_;
    return
        'awk \'{IGNORECASE = 1; if ($3 ~/'
      . $self->_tags_to_filter
      . '/ && $9 ~ /'
      . $self->search_query
      . '/) print $0;else if ($3 ~/'
      . $self->_tags_to_filter
      . '/) ; else print $0;}\' ';
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
