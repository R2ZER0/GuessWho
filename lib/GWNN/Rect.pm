package GWNN::Rect;
use Moose;

has ['x', 'y', 'xs', 'ys'] => (is => 'rw', isa => 'Num');

no Moose;
__PACKAGE__->meta->make_immutable;