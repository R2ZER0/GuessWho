#!/usr/bin/perl

use strict;
use warnings;

#use lib "C:\\Users\\Giedrius\\Desktop\\GuessWho\\lib";
#use lib '/home/rikki/Projects/GWNN/lib';
use lib './lib';
use SDL;
use SDL::Event;
use SDL::Events;
use SDLx::App;
use SDLx::Surface;
use SDLx::Text;
use SDLx::Sprite;
use SDLx::Widget::Menu;
use GWNN::Entity;
#use SDL::Mixer::Music;
use Time::HiRes qw( usleep );

$| = 1;

our $SCRN_WIDTH = 512;
our $SCRN_HEIGHT = 512;
our $GAMEMODE;

our $TEAMSIZE = 30;

my $app = SDLx::App->new(
    title => 'Guess Who?',
    w => $SCRN_WIDTH,
    h => $SCRN_WIDTH,
    eoq => 1
);

my $handlers = {
    'test' => {
        'event' => \&test_event,
        'move' => \&test_move,
        'show' => \&test_show
    },

    'menu' => {
        'event' => \&menu_event,
        'show' => \&menu_show
    },
    
    'play' => {
        'show' => \&play_show,
        'move' => \&play_move,
        'event', => \&play_event
    },
    'text' => {
        'show' => \&text_show,
        'event' => \&text_event
    }
};

my $test = SDLx::Sprite->new( image => './data' . '/test.tif' );

$app->add_event_handler( sub {
   if( $handlers->{$GAMEMODE}->{'event'} )
   { &{$handlers->{$GAMEMODE}->{'event'}}(@_); }
   else{
    my $ev = shift;
    if($ev->type == SDL_KEYDOWN)
    {
        my $k = $ev->key_sym;
        if($k == SDLK_ESCAPE){ switchgm('menu'); }
    }
   }
});

$app->add_move_handler( sub {
    if( $handlers->{$GAMEMODE}->{'move'} )
    { &{$handlers->{$GAMEMODE}->{'move'}}(@_); }
});

$app->add_show_handler( sub {
    if( $handlers->{$GAMEMODE}->{'show'} )
    { &{$handlers->{$GAMEMODE}->{'show'}}(@_);
        SDLx::Surface::display()->update;
    }else{
        clear_screen();
        SDLx::Surface::display()->draw_gfx_text([0, 0], 0xFFFFFFFF, '$GAMEMODE = \'' .$GAMEMODE. '\'');
        SDLx::Surface::display()->update;
    }
    
});

my $player1;
my $player2;
my $p1score = 0;
my $p2score = 0;
my $menu;

my $curtext;
my $curtextline;

############## Music stuff ###############

# disabled music 'cause it crashed on windows

#my $music = SDL::Mixer::Music::load_MUS('./data/music.ogg');

#$music->data(
    #'game' => {
        #file => './data' . '/music.ogg',
     #   ***
     #  * 0 *
     #  * 0 *
    #}#   ***
#);   #    I
     #   \I/
     #    I
     

################ Game stuff ############

sub switchgm
{
    $GAMEMODE = shift;
    
    GWNN::Entity::clearall();
    
    #if($GAMEMODE eq 'play'){
        #SDL::Mixer::Music::volume_music(110);
        #unless(SDL::Mixer::Music::play_music($music, -1))
        #{
            #die("Something went wrong!\n");
        #}
    #}else{
        #SDL::Mixer::Music::halt_music();
    #}
    
    if($GAMEMODE eq 'play')
    {
        foreach(0..$TEAMSIZE-1){ spawn_guest((rand 494), (rand 474), 'red'); }
        foreach(0..$TEAMSIZE-1){ spawn_guest((rand 494), (rand 474), 'blue'); }

        $player1 = GWNN::Entity->new(isplayer => 1, colour => 'red',  x => (rand 494), 'y' => (rand 474), pid => 1);
        $player2 = GWNN::Entity->new(isplayer => 1, colour => 'blue', x => (rand 494), 'y' => (rand 474), pid => 2);
        
        #randomise it a bit
        if(int(rand 2) == 0)
        {
            my $t = $player1->colour;
            $player1->colour( $player2->colour );
            $player2->colour( $t );
        }
    }
    elsif($GAMEMODE eq 'menu')
    {
        $menu = new SDLx::Widget::Menu->new(
            topleft => [235, 100],
            spacing => 15
        )->items(
            'Introduction' => sub { text_load('intro_text'); switchgm('text'); },
            #'Instructions' => sub { text_load('instr_text'); switchgm('text'); },
            'Play (Easy)' => sub { $TEAMSIZE = 10; switchgm('play'); },
            'Play (Hard)' => sub { $TEAMSIZE = 25; switchgm('play'); },
            #'Test' => sub { switchgm('test'); },
            #'Text Test', => sub { text_load('test_text'); switchgm('text'); },
            'Exit' => sub { exit(0); }
        );
    }
    elsif($GAMEMODE eq 'p1win')
    {
        ++$p1score;
        text_load('p1win_text');
        switchgm('text');
    }
    elsif($GAMEMODE eq 'p2win')
    {
        ++$p2score;
        text_load('p2win_text');
        switchgm('text');
    }
    elsif($GAMEMODE eq 'p1civ')
    {
        text_load('p1civ_text');
        switchgm('text');
    }
    elsif($GAMEMODE eq 'p2civ')
    {
        text_load('p2civ_text');
        switchgm('text');
    }
    elsif($GAMEMODE eq 'p1fail')
    {
        text_load('p1fail_text');
        switchgm('text');
    }
    elsif($GAMEMODE eq 'p2fail')
    {
        text_load('p2fail_text');
        switchgm('text');
    }
}

my $scrn = SDLx::Surface::display();

sub clear_screen
{
    $scrn->draw_rect([0, 0, $SCRN_WIDTH, $SCRN_HEIGHT], 0x000000FF);
};

sub test_event
{
    my ($event, $app) = @_;
    
};

sub test_move
{
    my ($step, $app, $t) = @_;
};


sub test_show
{
    my ($delta, $app) = @_;
    
    return unless $GAMEMODE eq 'test';
    clear_screen();
    
    my $text = SDLx::Text->new(
        color => [0, 0, 0],
    );
    
    $text->write_to($scrn, "Hello!");
};


## Menu Gamemode  ######################################

my $mstext = SDLx::Text->new;

sub menu_event
{
    $menu->event_hook( $_[0] );
};

my $menubg = SDLx::Surface->load('./data' . '/title_page2.tif' );

sub menu_show
{
    my ($delta, $app) = @_;
    clear_screen();
    $menubg->blit($scrn);
    $menu->render( $scrn );
    $mstext->write_xy($scrn, 40, 450, 'Player1: '.$p1score.' | Player2: '.$p2score);
};

## Actual gameplay gamemode ################################

our @guests;

sub spawn_guest
{
    my ($x, $y, $col) = @_;
    my $g = new GWNN::Entity(x => $x, 'y' => $y, colour => $col);
    push @guests, $g;
}

my $background = SDLx::Surface->load( './data' . '/bg.tif' );

sub play_show
{
    my ($delta, $app) = @_;
    $background->blit($scrn);
    
    foreach(@GWNN::Entity::Entities)
    {
        # FIXME
        #$scrn->draw_rect([$_->x, $_->y, 9*2, 19*2], ($_->colour eq 'red') ? 0xFF0000FF : 0x0000FFFF) if $_->isplayer;
        $_->draw($scrn);
    }
}

sub play_move
{
    my ($step, $app, $t) = @_;
    foreach(@GWNN::Entity::Entities)
    {
        $_->domove($step);
    }
    
    GWNN::Entity::step();
}


sub play_event
{
    my $ev = shift;
    if($ev->type == SDL_KEYDOWN)
    {
        my $k = $ev->key_sym;
           if($k == SDLK_a){ $player1->movedir('left'); }
        elsif($k == SDLK_d){ $player1->movedir('right'); }
        elsif($k == SDLK_w){ $player1->movedir('up'); }
        elsif($k == SDLK_s){ $player1->movedir('down'); }
        elsif($k == SDLK_SPACE){ $player1->trigger($player1, $player2); }
        elsif($k == SDLK_LEFT){ $player2->movedir('left'); }
        elsif($k == SDLK_RIGHT){ $player2->movedir('right'); }
        elsif($k == SDLK_UP){ $player2->movedir('up'); }
        elsif($k == SDLK_DOWN){ $player2->movedir('down'); }
        elsif($k == SDLK_RETURN){ $player2->trigger($player1, $player2); }
        elsif($k == SDLK_ESCAPE){ switchgm('menu'); }
    }
}


############ Displaying Text ########

sub text_load
{
    my $filen = shift;
    my @ttext = do ('./data' . '/'. $filen .'.txt');
    $curtext = \@ttext;
    $curtextline = 0;
}

my $dttext = SDLx::Text->new(x=> 10, y=> 200);
my $dttextboxtext = '';

sub text_nextline
{
    my $item = $curtext->[$curtextline];
    if(defined($item->{next})){
        text_gotoline($item->{next} - 1);
    }else{
        text_gotoline($curtextline + 1);
    }
}

sub text_gotoline
{
    my $dowait = 0;
    #if(defined($curtext->[$curtextline]->{'wait'})){ $dowait = $curtext->[$curtextline]->{'wait'}; }
    $curtextline = shift;
    $dttextboxtext = '';
    my $item = $curtext->[$curtextline];    
    
    if($dowait > 0)
    {
        clear_screen();
        $scrn->update;
        usleep(1000*1000*$dowait);
    }
    
    if(!defined($item->{type}) or $item->{type} eq 'finish')
    {
        switchgm('menu');
    }
}

sub text_event
{
    my $ev = shift;
    my $item = $curtext->[$curtextline];
    
       
    if($item->{type} eq 'entertext')
    {
        if($ev->type == SDL_KEYDOWN)
        {
            if(($ev->key_sym >= SDLK_TAB and $ev->key_sym <= SDLK_z))
            {
                $dttextboxtext .= chr($ev->key_sym);
            }
            elsif($ev->key_sym eq SDLK_BACKSPACE)
            {
                chop($dttextboxtext);
            }
        }
    }
    elsif($item->{type} eq 'yn')
    {
        if($ev->type == SDL_KEYDOWN)
        {
            if($ev->key_sym == SDLK_y)
            {
                text_gotoline($item->{yes} - 1);
            }elsif($ev->key_sym == SDLK_n)
            {
                text_gotoline($item->{no} - 1);
            }
        }
    }
    
    if($ev->type == SDL_KEYDOWN)
    {
        if($ev->key_sym == SDLK_RETURN or ($item->{type} ne 'entertext' and $ev->key_sym == SDLK_SPACE))
        {
            text_nextline() unless $item->{type} eq 'yn';
        }
        elsif($ev->key_sym == SDLK_ESCAPE)
        {
            switchgm('menu');
        }
    }
}

sub text_show
{
    my ($delta, $app) = @_;
    clear_screen();
    
    my $item = $curtext->[$curtextline];
    
    if($item->{type} eq 'plain' or $item->{type} eq 'yn')
    {
        $dttext->text($item->{text});
        $dttext->write_xy($scrn, (512-$dttext->w)/2, (512-$dttext->h)/2);
    }
    elsif($item->{type} eq 'entertext')
    {
        $dttext->text($item->{text}.' '.$dttextboxtext.'_');
        $dttext->write_xy($scrn, (512-$dttext->w)/2, (512-$dttext->h)/2);
    }else{ die 'You fail!'; }
    
}

###### Initialise & Run ######
text_load('test_text');
#switchgm('text');
switchgm('menu');
$app->run;
