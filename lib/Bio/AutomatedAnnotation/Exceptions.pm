package Bio::AutomatedAnnotation::Exceptions;
# ABSTRACT: Exceptions for input data 

=head1 SYNOPSIS

Exceptions for input data 

=cut


use Exception::Class (
    Bio::AutomatedAnnotation::Exceptions::FileNotFound   => { description => 'Couldnt open the file' },
    Bio::AutomatedAnnotation::Exceptions::CouldntWriteToFile   => { description => 'Couldnt open the file for writing' },
    Bio::AutomatedAnnotation::Exceptions::LSFJobFailed   => { description => 'Jobs failed' },
);  

1;
