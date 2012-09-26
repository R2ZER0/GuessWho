package GWNN::Entity;

#use Object::Tiny qw( imagename movedir x y sprites xs ys colour);
use Moose;
use Moose::Util::TypeConstraints;

use SDL;
use SDLx::App;
use SDLx::Surface;
use SDLx::Sprite;
use SDL::GFX::Rotozoom;
use SDL::Rect;
use GWNN::Rect;

our $EntityCount = 0;
our @Entities = ();
our %Collisions = ();

subtype 'Direction',
    as 'Str',
    where { ($_ eq 'up' or $_ eq 'down' or $_ eq 'left' or $_ eq 'right') };
    
subtype 'Colour',
    as 'Str',
    where { ($_ eq 'red' or $_ eq 'blue') };

has imagename => (is => 'rw', isa => 'Str', default => sub { 'guest_' . (int( rand 6 ) + 1) });
has movedir => (is => 'rw', isa => 'Direction', default => sub { ('up', 'down', 'left', 'right')[int(rand(4))] });
has ['x', 'y'] => (is => 'rw', isa => 'Num', default => 0);
has xs => (is => 'rw', isa => 'Int', default => 9);
has ys => (is => 'rw', isa => 'Int', default => 19);
has sprites => (is => 'rw', isa => 'HashRef[SDLx::Sprite]', default => sub {{}} );
has colour => (is => 'rw', isa => 'Colour', default => sub { 'blue' });
has nextcolour => (is => 'rw', isa => 'Colour', default => sub { $_[0]->colour });
has isplayer => (is => 'rw', isa => 'Bool', default => sub { 0 });
has iscolliding => (is => 'rw', isa => 'HashRef[Int]', default => sub {{}});
has id => (is => 'ro', isa => 'Int', default => sub {$EntityCount++});
has pid => (is => 'ro', isa => 'Int');

## SUBCLASS MUST SET 'imagename' AND 'xs'/'ys'

sub BUILD {
    my $self = shift;
    
    my %sprites;
    
    foreach( ('red_up', 'red_down', 'red_left', 'red_right', 'blue_up', 'blue_down', 'blue_left', 'blue_right') )
    {
        my $surf1 = SDLx::Surface->load( './data' . '/' . $self->imagename() . '_' . $_ . '.tif' );
        my $surf2 = SDL::GFX::Rotozoom::surface( $surf1, 0, 2, SMOOTHING_OFF );
        my $spr = SDLx::Sprite->new( surface => $surf2 );
        $sprites{ $_ } = $spr;
    }

    $self->sprites( \%sprites );
    
    push @Entities, $self;
    
    return $self;
};

sub clearall
{
    @Entities = ();
    %Collisions = ();
    $EntityCount = 0;
}

sub draw
{
    my ($self, $scrn) = @_;
    my $spr = $self->sprites()->{ $self->colour .'_'. $self->movedir };
    $spr->x( $self->x );
    $spr->y( $self->y );
    $spr->draw( $scrn );
};

our $MOVESPEED = 5;

our $CHANGEDIRPROB = 0.05;

our @Collisions = ();

sub domove
{
    my ($self, $step) = @_;
    
    if($self->x < 0){ $self->movedir('right'); }
    elsif($self->x > (512 - 9*2)){ $self->movedir('left'); }
    
    if($self->y < 0){ $self->movedir('down'); }
    elsif($self->y > (512 - 19*2)){ $self->movedir('up'); }
    
    my $movedir = $self->movedir;    
    if($movedir eq 'up')
    {
        $self->y( $self->y - $MOVESPEED*$step );
    }elsif($movedir eq 'down')
    {
        $self->y( $self->y + $MOVESPEED*$step );
    }elsif($movedir eq 'left')
    {
        $self->x( $self->x - $MOVESPEED*$step );
    }elsif($movedir eq 'right')
    {
        $self->x( $self->x + $MOVESPEED*$step );
    }else{
        die 'WTF JUST HAPPENED?!£';
    }
    
    if(not $self->isplayer)
    {
        my $ranint = int(rand(1/($CHANGEDIRPROB*$step)));
        if($ranint == 1){
            $self->randdir();
        }
    }
    
    my $iscol = $self->iscolliding;
    foreach my $g (@Entities)
    {
        if($self->test_collide($g) == 1){
            my $gid = $g->id;
            if(!defined($iscol->{$gid}) || $iscol->{$gid} == 0){
                #print "COLLIDE!";
                #$self->flipdir();
                #$self->randdir();
                my $lid;
                my $hid;
                if($self->id < $gid){ $lid = $self->id; $hid = $gid; }
                else{ $hid = $self->id; $lid = $gid; }
                
                $Collisions{$hid}->{$lid} = 1;
                
                
                $iscol->{$gid} = 1;
            }
        }else{
            $iscol->{$g->id} = 0;
        }
    }
    
       
}

sub flipdir
{
    my $self = shift;
    $self->movedir( numtodir(dirtonum( $self->movedir ) + 2) );
}

sub randdir
{
    $_[0]->movedir(('up', 'down', 'left', 'right')[int(rand(4))]);
}

sub test_collide
{
    my ($self, $other) = @_;
    
    my ($x1, $x2, $y1, $y2, $xs, $ys) = ($self->x, $other->x, $self->y, $other->y, $self->xs, $self->ys);
    
    return 0 if( $x2 > ($x1 + $xs) );
    return 0 if( $y2 > ($y1 + $ys) );
    return 0 if( $x1 > ($x2 + $xs) );
    return 0 if( $y1 > ($y2 + $ys) );
    return 1;    
}

sub updatecolour
{
    my $self = shift;
    return if $self->isplayer;
    if( $self->colour ne $self->nextcolour )
    {
        $self->colour( $self->nextcolour );
    }
}

sub dirtonum
{
    my $dir = shift;
    return 0 if $dir eq 'up';
    return 1 if $dir eq 'left';
    return 2 if $dir eq 'down';
    return 3 if $dir eq 'right';
}

sub numtodir
{
    my $num = shift;
    $num %= 4;
    return ('up', 'left', 'down', 'right')[$num];
}

sub step
{
    #my $colcount = 0;
    foreach my $hid (keys(%Collisions))
    {
        my $a = $Entities[$hid];
        foreach my $lid (keys($Collisions{$hid}))
        {
            #++$colcount;
            my $b = $Entities[$lid];
            my $dnum = (dirtonum($a->movedir) + dirtonum($b->movedir)) % 4; # TODO maybe direction testing?
            
            if($a->isplayer and not $b->isplayer){
                $b->nextcolour( $a->colour); $b->flipdir;
            }
            elsif($b->isplayer and not $a->isplayer){
                $a->nextcolour( $b->colour); $a->flipdir;
            }
            elsif($b->isplayer and $a->isplayer){
                $a->flipdir; $b->flipdir;
            }
            else
            {
                my $i = int(rand 2.6);
                
                if($i == 0){ $a->nextcolour( $b->colour ); $a->flipdir; $b->randdir; }
                elsif($i == 1){ $b->nextcolour( $a->colour ); $b->flipdir; $a->randdir; }
                elsif($i == 2){ $a->nextcolour( $b->colour ); $b->nextcolour( $a->colour ); $a->randdir; $b->randdir; }
                #else{ $a->flipdir; $b->flipdir; }
            }
                
            
        }
    }
    
    %Collisions = ();

    foreach(@Entities)
    {
        $_->updatecolour;
    }
    
    ## do collision things
}

sub trigger
{
    my ($self, $player1, $player2) = @_;
    return unless $self->isplayer;
    
    my $rect = GWNN::Rect->new(x => $self->x - 9*2,'y' => $self->y - 19*2, xs => 9*2*3,ys => 19*2*3);
    my $md = $self->movedir;
    
#       if($md eq 'up'){ $rect->y( $rect->y - 19*2 ); }
    #elsif($md eq 'down'){ $rect->y( $rect->y + 19*2 ); }
    #elsif($md eq 'left'){ $rect->x( $rect->x - 9*2 ); }
    #elsif($md eq 'right'){ $rect->x( $rect->x + 9*2 ); }
    #else{ die 'AAAAHHHHHH!"!!'; }
    
    if($self->pid == 1)
    {
        if(test_collide($rect, $player2))
        {
            ::switchgm('p1win');
        }else{
            my $hascol = 0;
            foreach(@Entities)
            {
                next if ($_->id == $self->id);
                if(test_collide($rect, $_)){
                    $hascol = 1;
                    last;
                }
            }
            if($hascol)
            {
                ::switchgm('p1civ');
            }else{            
                ::switchgm('p1fail');
            }
        }
        
    }elsif($self->pid == 2)
    {
        if(test_collide($rect, $player1))
        {
            ::switchgm('p2win');
        }else{
            my $hascol = 0;
            foreach(@Entities)
            {
                next if ($_->id == $self->id);
                if(test_collide($rect, $_)){
                    $hascol = 1;
                    last;
                }
            }
            if($hascol)
            {
                ::switchgm('p2civ');
            }else{            
                ::switchgm('p2fail');
            }
        }
    }else{ die 'Who? What? How?'; }
}

no Moose;
__PACKAGE__->meta->make_immutable;