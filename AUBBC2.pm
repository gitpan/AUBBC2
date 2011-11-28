package AUBBC2;
use strict;
use warnings;

our $VERSION     = '1.00a6';
our $MEMOIZE     = 1; # Testing Speed
our @TAGS        = ();
our %regex       = ();
our $Config      = '';

my $aubbc_error  = '';
my %xlist        = ();
my $add_reg      = '';
my $mem_flag     = '';
# more settings can be # removed but are used in testing
my %AUBBC        = (
    script_escape       => 1,
    line_break          => '1',
    html_type           => ' /',
    icon_image          => 1,#
    image_hight         => '60',#
    image_width         => '90',#
    image_border        => '0',#
    image_wrap          => ' ',#
    href_target         => ' target="_blank"',#
    code_class          => '',#
    code_extra          => '',#
    href_class          => '',#
    quote_class         => '',#
    quote_extra         => '',#
    );

sub new {
 if ($MEMOIZE && ! $mem_flag) {
  $mem_flag = 1;
  eval 'use Memoize' if ! defined $Memoize::VERSION;
  unless ($@ || ! defined $Memoize::VERSION) {
   Memoize::memoize('AUBBC2::add_tag');
   Memoize::memoize('AUBBC2::parse_bbcode');
   Memoize::memoize('AUBBC2::add_settings');
  }
 }

 require $Config if $Config;
 return bless {};
}

sub DESTROY {

}

sub add_settings {
 my ($self,%s_hash) = @_;
 if (keys %s_hash) {
  $AUBBC{$_} = $s_hash{$_} foreach (keys %s_hash);
 }
# could be pre-set
$AUBBC{href_target} = ($AUBBC{href_target}) ? ' target="_blank"' : '';
$AUBBC{image_wrap} = ($AUBBC{image_wrap}) ? ' ' : '';
$AUBBC{image_border} = ($AUBBC{image_border}) ? 1 : 0;
$AUBBC{html_type} = ($AUBBC{html_type} eq 'xhtml' || $AUBBC{html_type} eq ' /') ? ' /' : '';
}

sub get_setting {
 my ($self,$name) = @_;
 return $AUBBC{$name}
  if defined $name && exists $AUBBC{$name};
}

sub remove_setting {
 my ($self,$name) = @_;
 delete $AUBBC{$name}
  if defined $name && exists $AUBBC{$name};
}

sub parse_bbcode {
 my ($self,$msg) = @_;
 $msg = defined $msg ? $msg : '';
 if ($msg) {
  $msg = $self->script_escape($msg,'') if $AUBBC{script_escape};
  
  foreach my $tag (@TAGS) {
  next unless defined $$tag{type};
  $$tag{parse} = $msg;
   if ($$tag{type} eq 'single') {
    $msg = $self->single(%$tag);
   }
    elsif ($$tag{type} eq 'balanced') {
    $msg = $self->balanced(%$tag);
   }
    elsif ($$tag{type} eq 'linktag') {
    $msg = $self->linktag(%$tag);
   }
    elsif ($$tag{type} eq 'strip') {
    $msg = $self->strip(%$tag);
   }
  }

 }
 return $msg;
}

sub single {
my ($self, %parse) = @_;
  # type single: [tag]
  $parse{parse} =~ s/(\[($parse{tag})\])/
   my $ret = set_tag($parse{type}, $2, '' , $parse{markup}, $parse{function}, '','' );
   $ret ? $ret : set_temp($1);
  /eg;
 return $parse{parse};
}

sub balanced {
my ($self, %parse) = @_;
my $re_fix = '';
  # type balanced: [tag]message[/tag] or [tag=x]message[/tag]
  # or [tag=x attr2=x attr3=x attr4=x]message[/tag] or [tag attr1=x attr2=x attr3=x]message[/tag]
 if ($parse{extra} && $parse{extra} =~ s/\A\-\|//) {
  my @extra = split(/\,/, $parse{extra});
  $parse{extra} =~ s/\A/\-\|/;
  foreach (@extra) {
   my($aname, $rl) = split(/\//, $_);
   $xlist{$aname} = $rl;
   }
   $re_fix = '[= ].+?';
 }
  elsif ($parse{extra}) {
   $re_fix = '='.$parse{extra};
  }
   
  1 while $parse{parse} =~ s/(\[(($parse{tag})$re_fix)\](?s)($parse{message})\[\/\3\])/
   my $ret = set_tag($parse{type}, $3, $4 , $parse{markup}, $parse{function}, $parse{extra}, $2 );
   $ret ? $ret : set_temp($1);
  /egi;
  
 %xlist = ();
 return $parse{parse};
}

sub linktag {
my ($self, %parse) = @_;
my $re_fix = '';
  # type link: [tag://message] or [tag://message|extra]
  $re_fix = $parse{extra}
   ? '&#124;'.$parse{extra} : '';
  $parse{parse} =~ s/(\[($parse{tag})\:\/\/($parse{message})($re_fix)\])/
   my $ret = set_tag($parse{type}, $2, $3 , $parse{markup}, $parse{function}, $parse{extra},$4);
   $ret ? $ret : set_temp($1);
  /eg;
 return $parse{parse};
}

sub strip {
my ($self, %parse) = @_;
   # type strip: replace or remove
  $parse{parse} =~ s/($parse{message})/
   my $ret = set_tag($parse{type}, '', $1 , $parse{markup}, $parse{function}, $parse{extra},'');
   $ret ? $ret : '';
   /eg;
 return $parse{parse};
}

sub set_temp {
my $in = shift;
$in =~ s/\[/&#91;/;
return $in;
}

sub set_tag {
 my ($type,$tag,$message,$markup,$func,$extra,$attrs) = @_;
 # tag security here
 
 if ($func && $message) {
  # 2 variables allows the function to have a switch like abillity
  ($message,$markup) = $func->($type, $tag, $message, $markup, $extra, $attrs);
 }

 if ($markup) {
   if ($extra && $type eq 'balanced' && $extra =~ s/\A\-\|//) {
    $attrs =~ s/\A$tag\s//;
    my %list = ();
    my @attr = $attrs =~ /(?:\A| )(.+?)(?=(?: \w+=|\z))/g;
    foreach (@attr) {
     my ($name, $value) = split(/=/,$_);
     if (exists $xlist{$name} && match_range($xlist{$name}, $value)) {
      $list{$name} = 1;
      $markup =~ s/X{$name}/$value/g;
     }
      else {
       $markup = '';
       last;
       }
    }
    
   $markup = '' if $markup
    && scalar(keys %list) ne scalar(keys %xlist);
  }
   elsif ($extra && $attrs =~ s/\A(?:$tag=|&#124;)//
    && ($type eq 'balanced' || $type eq 'linktag')) {
    $extra = $attrs;
   }

 if ($markup =~ m/%/) {
  $markup =~ s/%$_%/$AUBBC{$_}/g foreach (keys %AUBBC);
  $markup =~ s/%{tag}/lc($tag);/eg;
  $markup =~ s/%{extra}/$extra/g;
  $markup =~ s/%{message}/$message/g;
  }
  
 }
  elsif ($type ne 'strip') {
   $markup = $message;
 }

 return $markup;
}

sub match_range {
my ($task, $limited) = @_;
 if ($limited =~ m/\A\d+\z/ && $task =~ m/\An{(\d+)\-(\d+)}\z/) {
   $limited >= $1 && $limited <= $2 ? return 1 : return 0;
 }
  elsif ($task =~ m/\Al{(\d+)}\z/) {
  length($limited) <= $1 ? return 1 : return 0;
 }
  elsif ($task =~ m/\Al{([a-z])\-([a-z])}\z/i) {
  $limited !~ m/\A[$1-$2]+\z/i ? return 0 : return 1;
 }
  elsif ($task =~ m/\Aw{(\d+)}\z/) {
   length($limited) <= $1
    && $limited =~ m/\A[\w\s\-\.\,\!\?]+\z/i ? return 1 : return 0;
 }
  elsif ($task =~ m/\Aw{(.+?)}\z/) {
  $limited =~ m/\A(?:$1)\z/i ? return 1 : return 0;
 }
  else {
  return 0;
 }
}

sub check_subroutine {
 my ($self, $name) = @_;
 defined $name && exists &{$name} && (ref $name eq 'CODE' || ref $name eq '')
   ? return \&{$name}
   : return '';
}

# one tag at a time
sub add_tag {
 my ($self,%NewTag) = @_;
 if (! $add_reg) {
  foreach (keys %regex) {
   $add_reg .= ! $add_reg ? $_ : '|'.$_;
  }
 }
 
 if (exists $NewTag{function} && $NewTag{function}) {
  my $fun_name = $NewTag{function};
  $NewTag{function} = $self->check_subroutine($NewTag{function});
  $self->error_message("Usage: add_tag - function 'Undefined subroutine' => $fun_name")
   if ! $NewTag{function};
 }

  $NewTag{message} =~ s/\A($add_reg)\z/$regex{$1}/;
  $NewTag{extra}   =~ s/\A($add_reg)\z/$regex{$1}/;
  push(@TAGS, {
   'tag'         => $NewTag{tag}     || '',
   'type'        => $NewTag{type}    || '',
   'function'    => $NewTag{function}|| '',
   'message'     => $NewTag{message} || '',
   'extra'       => $NewTag{extra}   || '',
   'markup'      => $NewTag{markup}  || '',
   });
}

sub remove_tag {
 my ($self,$id) = @_;
 delete $TAGS[$id]
  if defined $id && defined $TAGS[$id];
}

sub tag_list {
my ($self,$type) = @_;
 $type = '' unless defined $type && $type;
 my $text = '';
 # I dont like having to use this
 use B qw(svref_2object);

 foreach my $id (0 .. $#TAGS) {
  next unless defined $TAGS[$id]{type};
  my $fun = '';
  if (defined $TAGS[$id]{function} && $TAGS[$id]{function}) {
   my $cv = svref_2object ( $TAGS[$id]{function} );
   my $gv = $cv->GV;
   $fun = $gv->NAME;
   }
  $text .= <<TEXT;
ID:$id
tag:$TAGS[$id]{tag}
type:$TAGS[$id]{type}
function:$fun
message:$TAGS[$id]{message}
extra:$TAGS[$id]{extra}
markup:$TAGS[$id]{markup}
---:---
TEXT
 }
 
 $text = $self->script_escape($text, '')
  if $type eq 'html';
 return $text;
}

sub clear_tags {
 my $self = shift;
 @TAGS = ();
}

sub script_escape {
 my ($self, $text, $option) = @_;
 $text = '' unless defined $text;
 if ($text) {
  $text =~ s/(&|;)/$1 eq '&' ? '&amp;' : '&#59;'/ge;
  if (!$option) {
   $text =~ s/\t/ \&nbsp; \&nbsp; \&nbsp;/g;
   $text =~ s/  / \&nbsp;/g;
  }
  $text =~ s/"/&#34;/g;
  $text =~ s/</&#60;/g;
  $text =~ s/>/&#62;/g;
  $text =~ s/'/&#39;/g;
  $text =~ s/\)/&#41;/g;
  $text =~ s/\(/&#40;/g;
  $text =~ s/\\/&#92;/g;
  $text =~ s/\|/&#124;/g;
  ! $option && $AUBBC{line_break} eq '2'
   ? $text =~ s/\n/<br$AUBBC{html_type}>/g
   : $text =~ s/\n/<br$AUBBC{html_type}>\n/g if !$option && $AUBBC{line_break} eq '1';
  return $text;
 }
}

sub html_to_text {
 my ($self, $html, $option) = @_;
 $html = '' unless defined $html;
 if ($html) {
  $html =~ s/&amp;/&/g;
  $html =~ s/&#59;/;/g;
  if (!$option) {
   $html =~ s/ \&nbsp; \&nbsp; \&nbsp;/\t/g;
   $html =~ s/ \&nbsp;/  /g;
  }
  $html =~ s/&#34;/"/g;
  $html =~ s/&#60;/</g;
  $html =~ s/&#62;/>/g;
  $html =~ s/&#39;/'/g;
  $html =~ s/&#41;/\)/g;
  $html =~ s/&#40;/\(/g;
  $html =~ s/&#92;/\\/g;
  $html =~ s/&#124;/\|/g;
  $html =~ s/<br(?:\s?\/)?>\n?/\n/g if $AUBBC{line_break};
  return $html;
 }
}

sub version {
 my $self = shift;
 return $VERSION;
}

sub error_message {
 my ($self, $error) = @_;
 defined $error && $error
  ? $aubbc_error .= $error . "\n"
  : return $aubbc_error;
}

1; # AUBBC v4.06 ends at line 597

__END__

=pod

=head1 COPYLEFT

AUBBC2.pm, v1.00 alpha 6 11/28/2011 By: N.K.A.

------------------>^- Yes this is a test version and is subjected to changes.

shakaflex [at] gmail.com

http://search.cpan.org/~sflex/

Advanced Universal Bulletin Board Code 2

BBcode Placeholders with HTML Template

=head1 SYNOPSIS

      use AUBBC2;
      $AUBBC2::MEMOIZE     = 1; # Module Speed
      @AUBBC2::TAGS        = ();# Tags
      %AUBBC2::regex       = ();# regex for add_tag()
      $AUBBC2::Config      = '';# Path to configuration file

      my $aubbc = AUBBC2->new();
      
      $aubbc->add_tag(
          'tag' => 'b|i', # b or i
          'type' => 'balanced',
          'function' => '',
          'message' => 'any',
          'extra' => '',
          'markup' => '<%{tag}>%{message}</%{tag}>',
        );
        
      my $message = '[b]Foo[/b]'; # bold tag
      print  $aubbc->parse_bbcode($message);

=head1 ABSTRACT

BBcode Placeholders with HTML Template

=head1 DESCRIPTION

The main concept for this is to parse bbcode to markup and give a lot of
control over each tag designed through placeholders and templating the markup.
As it is now the BBcode tags end up being a big list that can be saved in a
back-end or configuration file to be parsed. The attributes syntax for 'extra'
should help to reduce the need to do regular-expressions to validate attributes.
Still under development so concept can change.

AUBBC vs AUBBC2

AUBBC = Has more time used in production and testing but does not fully support
Strict markup.

AUBBC2 = Is an alpha version meaning any part of the program is subjected
to changes and may not fully work or needs more testing.

This module can fully support BBcode to HTML/XHTML Strict.
Block in Inline and incorrectly nested tags do not exists if you switch to
CSS classes in DIV elements.

=head1 Testing

In this version all of the filters except for the script_escape and html_to_text
are in the config file and the strip parser works.
This list of methods are the focus of testing for this version. The methods
with * should be low in testing priority or will work well.

# Parser's

parse_bbcode()

        single(
         'tag'       => '',  # Tag
         'function'  => '',  # Function
         'message'   => '',  # Message area of the tag
         'extra'     => '',  # Extra areas of the tag
         'markup'    => '',  # Tag Temptlate
         'parse'     => '',  # Parse Content & must script_escape for security
         );

balanced()

linktag()

strip()

# Editing tags

add_tag()

remove_tag()

clear_tags()

tag_list()

# %AUBBC settings editing

add_settings()

get_setting()

remove_setting()

# Error Messages *

error_message()

# filters *

script_escape()

html_to_text()


# Module version *

version()

=head1 Adding Tags

        $aubbc->add_tag(
          'tag' => 'Tag',               # Tag name:
          'type' => 'X',                # Type name: tag style
          'function' => '',             # Function: subroutine to expand methods
          'message' => 'any',           # Message: of tag
          'extra' => '',                # Extra: of tag
          'markup' => '',               # Template: output
        );

Type name:              Tag style

single                  [tag]

balanced		[tag]message[/tag] or [tag=extra]message[/tag] or [tag attr=x...]message[/tag] or [tag=x attr=x...]message[/tag]

linktag			[tag://message] or [tag://message|extra]

strip                   replace or remove

Tag name:
This allows a single tag added to change many tags and supports more complex regex:

        # This is an example of bold and italic in the same add_tag()
        # Tags: [b]message[/b] or [i]message[/i]
        # Output: <b>message</b> or <i>message</i>
        $aubbc->add_tag(
          'tag' => 'b|i', # b or i
          'type' => 'balanced',
          'function' => '',
          'message' => 'any',
          'extra' => '',
          'markup' => '<%{tag}>%{message}</%{tag}>',
        );

Function:
The name gets check to make sure its a defined subroutine then gets passed these
variables of the tag.

        sub new_function {
        # $tag, $message, $attrs are the captured group of its place
         my ($type, $tag, $message, $markup, $extra, $attrs) = @_;

         # expand functions....

         # A) if there is a $message and blank $markup the $message will replace the tag.
         # B) if there is both $message and $markup, then $message can be inserted
         # into $markup if $markup has %{message} or any "Markup Template Tags",
         # then markup will replace the tag.
         # C) if both are blank the tag doesnt change.

         return ($message, $markup);
         # May have to return more so we have better/more control
        }

Message:
Allows regex or fast regex for 'any', 'href', 'src'

href->  protocal://location/web/path/or/file

src->  protocal://location/web/path/or/file or /local/web/path/or/file

Extra: supports -> any href src

Allows regex after tag= and message| or if negative pipe is in front will switch to the attribute
syntax for attribute range matching.

Attributes syntax and rules:

-Rules

-1) -|  must be at the beginning of 'extra'

-2) All attributes listed in 'extra' must be used at least one time for the tag to convert.

-3) The tag will not convert if an attribute is out of range

-4) Do not use extra delimiters like / and , in 'extra', use as needed.

Attribute syntax:

    -|attribute_name/switch{range},attribute_name2/switch{range}

Switches:

n{0-0000} = Number range n{1-10} means any number from 1 to 10

w{0000}   = Word range character pre-set limit is '\w,.!?- ' w{5} means text 5 in length or less

w{xx|xx}  = Word match w{This|That} will match 'This' or 'That' and supports regex in w{regex}

l{x-y}    = Letter range with no length check l{a-c} means any letters from a to c

l{0000}   = Length check l{5} means text 5 in length or less

note: usage of X{attribute_name} in the markup will be replaced with the value
if everything is correct.

        # tag: [dd=Stuff 7 attr=33]stuff[/dd]
        # output: <dd attr="33" alt="Stuff 7">stuff</dd>
        $aubbc->add_tag(
          'tag' => 'dd',
          'type' => 'balanced',
          'function' => '',
          'message' => 'any',
          'extra' => '-|attr/n{20-100},dd/w{7}',
          'markup' => '<%{tag} attr="X{attr}" alt="X{dd}">%{message}</%{tag}>',
        );

        # tag: [video height=90 width=115]http://www.video.com/video.mp4[/video]
        # output: <video width="115" height="90" controls="controls">
        #<source src="http://www.video.com/video.mp4" type="video/mp4" />
        #Your browser does not support the video tag.
        #</video>
        $aubbc->add_tag(
          'tag' => 'video',
          'type' => 'balanced',
          'function' => '',
          'message' => 'src',
          'extra' => '-|width/n{90-120},height/n{60-90}',
          'markup' => '<video width="X{width}" height="X{height}" controls="controls">
        <source src="%{message}" type="video/mp4" />
        Your browser does not support the video tag.
        </video>',
        );

Markup:

This is the template of the tag and has tags of its own giving you more control

Markup Template Tags:

Tag:            Info

%setting%       Any setting name in AUBBC2's main setting hash %AUBBC

%{tag}          Tag value

%{message}      Message value

%{extra}        Extra value for non-attribute syntax

X{attribute}    Attribute names for values of attribute syntax

=head1 Development Guidance

http://www.perlmonks.com/

http://perldoc.perl.org/

=cut
