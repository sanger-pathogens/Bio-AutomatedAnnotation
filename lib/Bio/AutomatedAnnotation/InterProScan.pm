package Bio::AutomatedAnnotation::InterProScan;

# ABSTRACT: Take in a file of proteins and predict functions using interproscan

=head1 SYNOPSIS

Take in a file of proteins and predict functions using interproscan
   use Bio::AutomatedAnnotation::InterProScan;
   
   my $obj = Bio::AutomatedAnnotation::InterProScan->new(
     input_file   => 'input.faa'
   );
   $obj->annotate;
   
=cut

use Moose;
use File::Temp;
use Bio::SeqIO;
use Bio::AutomatedAnnotation::External::ParallelInterProScan;

has 'input_file'           => ( is => 'ro', isa => 'Str', required => 1 );
has 'cpus'                 => ( is => 'ro', isa => 'Int', default  => 1 );
has 'exec'                 => ( is => 'ro', isa => 'Str', required => 1 );
has '_protein_file_suffix' => ( is => 'ro', isa => 'Str', default  => '.seq' );
has '_tmp_directory'     => ( is => 'rw', isa => 'Str', default  => '/tmp' );
has '_protein_files_per_cpu'     => ( is => 'rw', isa => 'Int', default  => 10 );
has '_temp_directory_obj' =>
  ( is => 'ro', isa => 'File::Temp::Dir', lazy => 1, builder => '_build__temp_directory_obj' );
has '_temp_directory_name' => ( is => 'ro', isa => 'Str', lazy => 1, builder => '_build__temp_directory_name' );
has '_input_file_parser'   => ( is => 'ro', lazy => 1,    builder => '_build__input_file_parser' );

sub _build__temp_directory_obj {
    my ($self) = @_;
    return File::Temp->newdir( DIR => $self->_tmp_directory, CLEANUP => 1 );
}

sub _build__temp_directory_name {
    my ($self) = @_;
    return $self->_temp_directory_obj->dirname();
}

sub _build__input_file_parser {
    my ($self) = @_;
    return Bio::SeqIO->new(
        -format   => 'Fasta',
        -file     => $self->input_file,
        -alphabet => 'protein'
    );
}

sub _create_protein_file {
    my ( $self, $seq_io_protein, $counter ) = @_;
    my $output_filename = $self->_temp_directory_name . '/' . $counter . $self->_protein_file_suffix;
    my $fout = Bio::SeqIO->new( -file => ">" . $output_filename, -format => 'Fasta', -alphabet => 'protein' );
    $fout->write_seq($seq_io_protein);
    return $output_filename;
}

sub _create_a_number_of_protein_files {
    my ( $self, $files_to_create ) = @_;
    my @file_names;
    my $counter = 0;
    while ( my $seq = $self->_input_file_parser->next_seq ) {
        push( @file_names, $self->_create_protein_file( $seq, $counter ) );
        $counter++;
        last if($self->_protein_files_per_cpu == $counter);
    }
    return \@file_names;
}

sub _delete_list_of_files {
    my ( $self, $list_of_files ) = @_;
    for my $file ( @{$list_of_files} ) {
        unlink($file);
    }
    return $self;
}

sub annotate {
    my ($self) = @_;

    while ( my $protein_files = $self->_create_a_number_of_protein_files( $self->cpus ) ) {
        last if(@{$protein_files} == 0);
        my $obj = Bio::AutomatedAnnotation::External::ParallelInterProScan->new(
            input_files_path => join( '/', ( $self->_temp_directory_name, '*' . $self->_protein_file_suffix ) ),
            exec             => $self->exec,
            cpus             => $self->cpus,
        );
        $obj->run;

        $self->_delete_list_of_files($protein_files);
        # put output files together
    }
    return $self;
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;
