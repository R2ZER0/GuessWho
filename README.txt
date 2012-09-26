#### Guess Who? ###

Created in a weekend for Edinburgh GameDevSoc GameJam, 22/23rd Sep 2012
by Rikki Guy, Giedrius Zebrauskas, Lewis Brown

To Launch game, on linux make sure you chmod +x GuessWho.pl and then
./GuessWho.pl
should do the trick, otherwise on windows just double-click on GuessWho.pl

Everything is under the GPLv3 license.

### Requirements ###

Required Perl modules (from CPAN):
  * Alien::SDL
  * SDL
  * SDLx::Widget
  * Moose
  * SDL::GFX::Rotozoom

Use cpanm (or cpan if you really have to) to install these, e.g:

cpanm --sudo --verbose <module name>

(omit the --sudo if on windows, just make sure you are running
in a command prompt as administrator)

Install Alien::SDL BEFORE SDL.

On linux, you will definately have to use --verbose when installing Alien::SDL,
so you can choose to use your existing SDL installation. I HIGHLY
RECCOMMEND you install SDL from package manager and use that instead
of building from source - also you will need all components of SDL:
SDL SDL_image SDL_gfx SDL_ttf SDL_mixer and libtiff.

If on windows installing Alien::SDL should download binaries for you.

  
Random picture of a flower:  
  
         ***
        * 0 *
        * 0 *
         ***
          I
         \I/
          I