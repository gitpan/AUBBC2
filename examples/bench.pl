#!/usr/bin/perl
use strict;
use warnings;
use Carp qw(carp croak);
use Data::Dumper;
use Benchmark;

# this bench is more accuret in showing the
# time it takes for the modules to load.

#use lib '.';
my %loaded;

my $code = <<'EOM';
[br][b]The Very common UBBC Tags[/b][br]
[[b]Bold[[/b] = [b]Bold[/b][br]
[[strong]Strong[[/strong] = [strong]Strong[/strong][br]
[[small]Small[[/small] = [small]Small[/small][br]
[[big]Big[[/big] = [big]Big[/big][br]
[[h1]Head 1[[/h1] = [h1]Head 1[/h1][br]
through.....[br]
[[h6]Head 6[[/h6] = [h6]Head 6[/h6][br]
[[i]Italic[[/i] = [i]Italic[/i][br]
[[u]Underline[[/u] = [u]Underline[/u][br]
[b]Bold[/b]
[[strike]Strike[[/strike] = [strike]Strike[/strike][br]
[left]]Left Align[[/left] = [left]Left Align[/left][br]
[[center]Center Align[[/center] = [center]Center Align[/center][br]
[right]]Right Align[[/right] = [right]Right Align[/right][br]
[[em]Emotion[/em]] = [em]Emotion[/em]
[sup]Sup[/sup][br]
[sub]Sub[/sub][br]
[pre]]Pre[[/pre] = [pre]Pre[/pre][br]
[b]Bold[/b]
[img]]http://www.google.com/intl/en/images/about_logo.gif[[/img] =
[img]http://www.google.com/intl/en/images/about_logo.gif[/img][br][br]
[b]Bold[/b]
[url=URL]]Name[[/url] = [url=http://www.google.com]http://www.google.com[/url][br]
http[utf://#58]//google.com = http://google.com[br]
[email]]Email[/email] = [email]some@email.com[/email] Recommended Not to Post your email in a public area[br]
[b]Bold[/b]
[code]]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[[/code] =
[code]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/code][br]
[b]Bold[/b]
[c]]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c]] =
[c]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c][br]
[[c=My Code]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c]] =
[c=My Code]# Some Code ......
my %hash = ( stuff => { '1' => 1, '2' => 2 }, );
print $hash{stuff}{'1'};[/c][br][br]
[b]Bold[/b]
[quote]]Quote[/quote]] = [quote]Quote[/quote][br]
[quote=Flex]]Quote[/quote]] = [quote=Flex]Quote[/quote][br]
[color=Red]]Color[/color]] = [color=Red]Color[/color][br]
[blockquote]]Your Text here[[/blockquote] = [blockquote]Your Text here[/blockquote]
[[hr] = [hr]
[list]
[*=1]stuff
[*]stuff2
[*]stuff3
[/list]

[ol]
[li=1].....[/li]
[li].....[/li]
[li].....[/li]
[/ol]

[b]Unicode Support[/b][br]
[utf://#x3A3]] = [utf://#x3A3][br]
[utf://#0931]] = [utf://#0931][br]
[utf://iquest]] = [utf://iquest][br]

[http://www.crap.com|dfsdff]
[http://www.crap.com]
[video width=120 height=90]http://www.www.com[/video] # good
[video width=120 height=190]http://www.www.com[/video] # bad
[video width=120 height=90 height=190]http://www.www.com[/video] # bad
[video width=5 height=60 controls=00]http://www.www.com[/video] # bad
[mp4=90 width=115]http://www.www.com[/mp4] # good
EOM



sub create_au2 {
use AUBBC2;
#use Memoize;
$loaded{AUBBC2} = AUBBC2->VERSION;
#$AUBBC2::MEMOIZE = 0;
my $au2 = AUBBC2->new();
return $au2;
}


#sub create_au {
#use AUBBC;
##use Memoize;
#$loaded{AUBBC} = AUBBC->VERSION;
##$AUBBC::MEMOIZE = 0;
#my $au = AUBBC->new();
#return $au;
#}

my $au2 = &create_au2;
#my $au = &create_au;

# un-commit below to see each modules output

my $rendered4 = $au2->do_all_ubbc($code);
print "AUBBC2\t$loaded{AUBBC2}\n$rendered4\n\n";

#my $rendered5 = $au->do_all_ubbc($code);
#print "AUBBC\t$loaded{AUBBC}\n$rendered5\n\n";
#print $au->aubbc_error();


timethese($ARGV[0] || -1, {
    $loaded{'AUBBC2'} ?  (
        'AU2::new' => \&create_au2,
        'AU2::x' => sub { my $out = $au2->do_all_ubbc($code); },
    ) : (),
#    $loaded{'AUBBC'} ?  (
#        'AU::new' => \&create_au,
#        'AU::x' => sub { my $out = $au->do_all_ubbc($code); },
#    ) : (),
});
