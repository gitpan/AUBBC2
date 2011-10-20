package AUBBC2;
use strict;
use warnings;

our $VERSION     = '1.00a4';
our $BAD_MESSAGE = 'Error';
our $DEBUG_AUBBC = 0; # not being worked on
our $MEMOIZE     = 1; # Testing Speed

my $mem_flag     = '';
my $aubbc_error  = '';
my $msg          = '';

# There maybe less settings than this
my %AUBBC        = (
    highlight           => 1,
    highlight_function  => \&code_highlight,
    aubbc_escape        => 1,
    icon_image          => 1,
    image_hight         => '60',
    image_width         => '90',
    image_border        => '0',
    image_wrap          => ' ',
    href_target         => ' target="_blank"',
    html_type           => ' /',
    fix_amp             => 1,
    line_break          => '1',
    code_class          => '',
    code_extra          => '',
    code_download       => '^Download above code^',
    href_class          => '',
    quote_class         => '',
    quote_extra         => '',
    script_escape       => 1,
    protect_email       => '0',
    email_message       => '&#67;&#111;&#110;&#116;&#97;&#99;&#116;&#32;&#69;&#109;&#97;&#105;&#108;',
    highlight_class1    => '',
    highlight_class2    => '',
    highlight_class3    => '',
    highlight_class4    => '',
    highlight_class5    => '',
    highlight_class6    => '',
    highlight_class7    => '',
    highlight_class8    => '',
    highlight_class9    => '',
    );

my @key64   = ('A'..'Z','a'..'z',0..9,'+','/'); # protect email tag

# moved out of sub for build and commen tags
my $href = '\w+\://[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+?)?';
my $src = '\w+\://[\w\.\/\-\~\@\:\;\=]+|\/[\w\.\/\-\~\@\:\;\=]+';
my $any = '.+?';
# some tags for testing
my @TAGS = (
 {
 'tag' => 'code|c',
  'type' => 'balanced',
  'function' => 'AUBBC2::code_highlight',
  'message' => $any,
  'extra' => '',
  'markup' => "<div$AUBBC{code_class}><code>
%{message}
</code></div>$AUBBC{code_extra}",
 },
  {
 'tag' => 'code|c',
  'type' => 'balanced',
  'function' => 'AUBBC2::code_highlight',
  'message' => $any,
  'extra' => $any,
  'markup' => "# %{extra}:<br$AUBBC{html_type}>
<div$AUBBC{code_class}><code>
%{message}
</code></div>$AUBBC{code_extra}",
 },
  {
 'tag' => 'url',
  'type' => 'balanced',
  'function' => 'AUBBC2::fix_message',
  'message' => $any,
  'extra' => $href,
  'markup' => "<a href=\"%{extra}\"$AUBBC{href_target}$AUBBC{href_class}>%{message}</a>",
 },
  {
 'tag' => 'color',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '[\w#]+',
  'markup' => "<div style=\"color:%{extra};\">%{message}</div>",
 },
  {
 'tag' => 'eamil',
  'type' => 'balanced',
  'function' => '',
  'message' => '(?![\w\.\-\&\+]+\@[\w\.\-]+).+?',
  'extra' => '',
  'markup' => "[<font color=red>$BAD_MESSAGE<\/font>\]email",
 },
  {
 'tag' => 'li',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '\d+',
  'markup' => '<li value="%{extra}">%{message}</li>',
 },
  {
 'tag' => 'u',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-decoration: underline;">%{message}</div>',
 },
  {
 'tag' => 'strike',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-decoration: line-through;">%{message}</div>',
 },
  {
 'tag' => 'center',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-align: center;">%{message}</div>',
 },
  {
 'tag' => 'right',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-align: right;">%{message}</div>',
 },
  {
 'tag' => 'left',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-align: left;">%{message}</div>',
 },
  {
 'tag' => 'quote',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '[\w\s]+',
  'markup' => "<div$AUBBC{quote_class}><small><strong>%{extra}:</strong></small><br$AUBBC{html_type}>
%{message}
</div>$AUBBC{quote_extra}",
 },
  {
 'tag' => 'quote',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => "<div$AUBBC{quote_class}>%{message}</div>$AUBBC{quote_extra}",
 },
  {
 'tag' => 'img',
  'type' => 'balanced',
  'function' => '',
  'message' => $src,
  'extra' => '',
  'markup' => "<a href=\"%{message}\"$AUBBC{href_target}$AUBBC{href_class}><img src=\"%{message}\" width=\"$AUBBC{image_width}\" height=\"$AUBBC{image_hight}\" alt=\"\" border=\"$AUBBC{image_border}\"$AUBBC{html_type}></a>$AUBBC{image_wrap}",
 },
  {
  'tag' => 'blockquote|big|h[123456]|[ou]l|li|em|pre|s(?:mall|trong|u[bp])|[bip]',
  'type' => 'balanced',
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<%{tag}>%{message}</%{tag}>',
 },
  {
  'tag' => 'br|hr',
  'type' => 'single',
  'function' => '',
  'message' => '',
  'extra' => '',
  'markup' => '<%{tag}%html_type%>',
 },
  {
  'tag' => 'video',
  'type' => 'balanced',
  'function' => '',
  'message' => $src,
  'extra' => '-|width/n{90-120},height/n{60-90}',
  'markup' => '<video width="X{width}" height="X{height}" controls="controls">
   <source src="%{message}" type="video/mp4" />
 Your browser does not support the video tag.
 </video>',
 },
  {
  'tag' => 'mp4',
  'type' => 'balanced',
  'function' => '',
  'message' => $src,
  'extra' => '-|mp4/n{90-120},width/n{90-120}',
  'markup' => '<video width="X{width}" height="X{mp4}" controls="controls">
   <source src="%{message}" type="video/mp4" />
 Your browser does not support the video tag.
 </video>',
 },
  {  # 1st
  'tag' => 'http',
  'type' => 'link',
  'function' => '',
  'message' => '(?!&#124;).+?',
  'extra' => $any,
  'markup' => "<a href=\"%{tag}://%{message}\"$AUBBC{href_target}$AUBBC{href_class}>%{extra}</a>",
 },
  {  # 2nt
  'tag' => 'http',
  'type' => 'link',
  'function' => '',
  'message' => '[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\&\,\$\-\+\!\*\?/\=\@\#\%]+?)?',
  'extra' => '',
  'markup' => "<a href=\"%{tag}://%{message}\"$AUBBC{href_target}$AUBBC{href_class}>%{tag}&#58;//%{message}</a>",
 },
  {
  'tag' => 'utf',
  'type' => 'link',
  'function' => '',
  'message' => '\#?\w+',
  'extra' => '',
  'markup' => '&%{message};',
 }
);

sub new {
warn 'CREATING AUBBC '.$VERSION if $DEBUG_AUBBC;
 if ($MEMOIZE && ! $mem_flag) {
  $mem_flag = 1;
  eval 'use Memoize' if ! defined $Memoize::VERSION;
  unless ($@ || ! defined $Memoize::VERSION) {
   Memoize::memoize('AUBBC2::add_tag');
   Memoize::memoize('AUBBC2::parse_bbcode');
   Memoize::memoize('AUBBC2::do_ubbc');
   Memoize::memoize('AUBBC2::add_settings');
  }
 }
return bless {};
}

sub DESTROY {
warn 'DESTROY AUBBC '.$VERSION if $DEBUG_AUBBC;
}


sub add_settings {
 my ($self,%s_hash) = @_;
 if (keys %s_hash) {
  $AUBBC{$_} = $s_hash{$_} foreach (keys %s_hash);
 }
 
$AUBBC{href_target} = ($AUBBC{href_target}) ? ' target="_blank"' : '';
$AUBBC{image_wrap} = ($AUBBC{image_wrap}) ? ' ' : '';
$AUBBC{image_border} = ($AUBBC{image_border}) ? 1 : 0;
$AUBBC{html_type} = ($AUBBC{html_type} eq 'xhtml' || $AUBBC{html_type} eq ' /') ? ' /' : '';

 if ($DEBUG_AUBBC) {
  my $uabbc_settings = '';
  $uabbc_settings .= "$_ => $AUBBC{$_} , "
   foreach (keys %AUBBC);
 warn "AUBBC Settings Change: $uabbc_settings";
 }
 
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
 my ($self,$message) = @_;
 warn 'ENTER do_all_ubbc' if $DEBUG_AUBBC;
 $msg = defined $message ? $message : '';
 if ($msg) {
  $msg = $self->script_escape($msg,'') if $AUBBC{script_escape};
  $msg =~ s/&(?!\#?[\d\w]+;)/&amp;/g if $AUBBC{fix_amp};
   escape_aubbc() if $AUBBC{aubbc_escape};
   do_ubbc();
 }
 return $msg;
}

sub do_ubbc {
 warn 'ENTER do_ubbc ' if $DEBUG_AUBBC;
foreach my $tag (@TAGS) {
 my $re_fix = '';
  if ($$tag{type} eq 'single') {
  # type single: [tag]
  $msg =~ s/(\[($$tag{tag})\])/
   my $ret = set_tag($$tag{type}, $2, '' , $$tag{markup}, $$tag{function}, '','' );
   $ret ? $ret : set_temp($1);
  /eg;
  }
   elsif ($$tag{type} eq 'balanced') {
  # type balanced: [tag]message[/tag] or [tag=x]message[/tag]
  # or [tag=x attr2=x attr3=x attr4=x]message[/tag] or [tag attr1=x attr2=x attr3=x]message[/tag]
  $re_fix = ($$tag{extra} && $$tag{extra} =~ m/\A\-\|/i)
   ? '[= ].+?' : '='.$$tag{extra} if $$tag{extra};
  1 while $msg =~ s/(\[(($$tag{tag})$re_fix)\](?s)($$tag{message})\[\/\3\])/
   my $ret = set_tag($$tag{type}, $3, $4 , $$tag{markup}, $$tag{function}, $$tag{extra}, $2 );
   $ret ? $ret : set_temp($1);
  /egi;
  }
   elsif ($$tag{type} eq 'link') {
  # type link: [tag://message] or [tag://message|extra]
  $re_fix = $$tag{extra}
   ? '&#124;'.$$tag{extra} : '';
  $msg =~ s/(\[($$tag{tag})\:\/\/($$tag{message})($re_fix)\])/
   my $ret = set_tag($$tag{type}, $2, $3 , $$tag{markup}, $$tag{function}, $$tag{extra},$4);
   $ret ? $ret : set_temp($1);
  /eg;
  }
   elsif ($$tag{type} eq 'strip') {
   # type strip: replace or remove
  $msg =~ s/($$tag{message})/
   my $ret = set_tag($$tag{type}, '', $1 , $$tag{markup}, $$tag{function}, $$tag{extra},'');
   $ret ? $ret : '';
   /eg;
  }
 }
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
  $func = \&{$func};
  # 2 variables allows the function to have a switch like abillity
  ($message,$markup) = $func->($type, $tag, $message, $markup, $extra, $attrs);
 }

 if ($markup) {
   if ($extra && $type eq 'balanced' && $extra =~ s/\A\-\|//) {
    $attrs =~ s/\A$tag\s//;
    my ($count, %list) = (0,());
    my %xlist = ();
    my @attr = $attrs =~ /(?:\A| )(.+?)(?=(?: \w+=|\z))/g;
    my @extra = split(/\,/, $extra);
    foreach (@extra) {
    my($aname, $rl) = split(/\//, $_);
    $xlist{$aname} = $rl;
    }
    foreach (@attr) {
     my ($ok, ($name, $value)) = (0, split(/=/,$_));
      if (exists $xlist{$name} && match_range($xlist{$name}, $value)) {
      $list{$name}++;
      $ok = 1;
      }

     if ($ok) {
      $markup =~ s/X{$name}/$value/g;
     }
      else {
       $markup = '';
       last;
       }
    }
    
   if ($markup) {
   $count++ foreach (keys %list);
   $markup = '' if $count ne scalar(@extra);
   }
   
  }
   elsif ($extra && $attrs =~ s/\A(?:$tag=|&#124;)//
    && ($type eq 'balanced' || $type eq 'link')) {
    $extra = $attrs;
   }

 if ($markup =~ m/%/) {
  $markup =~ s/%$_%/$AUBBC{$_}/g foreach (keys %AUBBC);
  $markup =~ s/%{tag}/lc($tag);/eg;
  $markup =~ s/%{extra}/$extra/g;
  $markup =~ s/%{message}/$message/g;
  }
  
 }
  else {
   $markup = $message;
 }

 return $markup;
}

sub match_range {
my ($task, $limited) = @_;
 if (defined $limited && $task =~ m/\An/ && $limited =~ m/\A\d+\z/) {
   $task =~ m/{(\d+)\-(\d+)}\z/;
   $limited >= $1 && $limited <= $2 ? return 1 : return 0;
 }
  elsif (defined $limited && $task =~ m/\Al/) {
  if ($task =~ m/{(\d+)}\z/) {
   length($limited) <= $1 ? return 1 : return 0;
  }
   elsif ($task =~ m/{(\w+)\-(\w+)}\z/) {
   $limited !~ m/\A[$1-$2]+\z/i ? return 0 : return 1;
   } else { return 0; }
 }
  elsif (defined $limited && $task =~ m/\Aw/) {
  if ($task =~ m/{(\d+)}\z/) {
   length($limited) <= $1
    && $limited =~ m/\A[\w\s\-\.\,\!\?]+\z/i ? return 1 : return 0;
   }
    elsif ($task =~ m/{(.+?)}\z/) {
     $limited =~ m/\A(?:$1)\z/i ? return 1 : return 0;
    } else { return 0; }
 }
  else {
  # safe fail
   return 0;
  }
}

sub check_subroutine {
 my $name = shift;
 defined $name && exists &{$name} && (ref $name eq 'CODE' || ref $name eq '')
   ? return \&{$name}
   : return '';
}

# one tag at a time
sub add_tag {
 my ($self,%NewTag) = @_;
 warn 'ENTER add_tag' if $DEBUG_AUBBC;
 my $ok = 1;

 if (exists $NewTag{function} && $NewTag{function}
  && ! check_subroutine($NewTag{function})) {
   $self->error_message("Usage: add_tag - function 'Undefined subroutine' => '$NewTag{function}'");
   $ok = 0;
 }
 
 if ($ok) {
 $NewTag{message} = $href if $NewTag{message} eq 'href';
 $NewTag{message} = $src if $NewTag{message} eq 'src';
 $NewTag{message} = $any if $NewTag{message} eq 'any';
 $NewTag{extra} = $href if $NewTag{extra} eq 'href';
 $NewTag{extra} = $src if $NewTag{extra} eq 'src';
 $NewTag{extra} = $any if $NewTag{extra} eq 'any';
 
 @TAGS = (@TAGS,{
  'tag'         => $NewTag{tag} || '',
  'type'        => $NewTag{type},
  'function'    => $NewTag{function} || '',
  'message'     => $NewTag{message} || '',
  'extra'       => $NewTag{extra} || '',
  'markup'      => $NewTag{markup} || '',
  });
  
  if ($DEBUG_AUBBC) {
   $ok = scalar(@TAGS) - 1;
   warn 'Added add_tag ID: '.$ok;
  }
  
 }
 
 warn 'END add_tag' if $DEBUG_AUBBC;
}

sub remove_tag {
 my ($self,$id) = @_;
 my @temp = ();
 foreach my $index (0 .. $#TAGS) {
 push(@temp, $TAGS[$index]) if $id ne $index;
 }
 @TAGS = @temp;
 warn 'ENTER remove_tag' if $DEBUG_AUBBC;
}

sub tag_list {
my ($self,$type) = shift;
$type = '' unless defined $type && $type;
my ($text, $ct) = ('', 0);
foreach my $tag (@TAGS) {
  $text .= <<TEXT;
ID:$ct
tag:$$tag{tag}
type:$$tag{type}
function:$$tag{function}
message:$$tag{message}
extra:$$tag{extra}
markup:$$tag{markup}
---:---
TEXT
$ct++
 }
 
 $text =~ s/\n/<br$AUBBC{html_type}>\n/g if $type eq 'html';
 return $text;
}

sub clear_tags {
 my ($self) = @_;
 @TAGS = ();
 warn 'ENTER clear_tags' if $DEBUG_AUBBC;
}

sub escape_aubbc {
 warn 'ENTER escape_aubbc' if $DEBUG_AUBBC;
 $msg =~ s/\[\[/\000&#91;/g;
 $msg =~ s/\]\]/\000&#93;/g;
}

sub script_escape {
 my ($self, $text, $option) = @_;
 warn 'ENTER html_escape' if $DEBUG_AUBBC;
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
 warn 'ENTER html_to_text' if $DEBUG_AUBBC;
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
 my ($self) = @_;
 return $VERSION;
}

sub error_message {
 my ($self, $error) = @_;
 defined $error && $error
  ? $aubbc_error .= $error . "\n"
  : return $aubbc_error;
}

# ----Moving to Add-On's Module----
sub protect_email {
# my ($tag, $email) = @_;
 my ($type, $tag, $email, $markup, $extra, $attrs) = @_;
 my $option = $AUBBC{protect_email};
 my ($email1, $email2, $ran_num, $protect_email, @letters) = ('', '', '', '', split (//, $email));
 $protect_email = '[' if $option eq 3 || $option eq 4;
 foreach my $character (@letters) {
  $protect_email .= '&#' . ord($character) . ';' if ($option eq 1 || $option eq 2);
  $protect_email .= ord($character) . ',' if $option eq 3;
  $ran_num = int(rand(64)) || 0 if $option eq 4;
  $protect_email .= '\'' . (ord($key64[$ran_num]) ^ ord($character)) . '\',\'' . $key64[$ran_num] . '\',' if $option eq 4;
 }
 return ("<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;$protect_email\"$AUBBC{href_class}>$protect_email</a>",'') if $option eq 1;
 ($email1, $email2) = split ("&#64;", $protect_email) if $option eq 2;
 $protect_email = "'$email1' + '&#64;' + '$email2'" if $option eq 2;
 $protect_email =~ s/\,\z/]/ if $option eq 3 || $option eq 4;
 return ("
<a href=\"javascript:MyEmCode('$option',$protect_email);\"$AUBBC{href_class}>$AUBBC{email_message}</a>
", '') if $option eq 2 || $option eq 3 || $option eq 4;
}

sub js_print {
my $self = shift;
print <<JS;
Content-type: text/javascript

/*
AUBBC v$VERSION
Fully supports dynamic view in XHTML.
*/
function MyEmCode (type, content) {
 var returner = false;
 if (type == 4) {
 var farray= new Array(content.length,1);
  for(farray[1];farray[1]<farray[0];farray[1]++) {
   returner+=String.fromCharCode(content[farray[1]].charCodeAt(0)^content[farray[1]-1]);farray[1]++;
  }
 } else if (type == 3) {
  for (i = 0; i < content.length; i++) { returner+=String.fromCharCode(content[i]); }
 } else if (type == 2) { returner=content; }
 if (returner) { window.location='mailto:'+returner; }
}
JS
exit(0);
}

sub fix_message {
 my ($type, $tag, $txt, $markup, $extra, $attrs) = @_;
 $txt =~ s/\./&#46;/g;
 $txt =~ s/\:/&#58;/g;
 return ($txt, $markup);
}

sub code_highlight {
# my $txt = shift;
my ($type, $tag, $txt, $markup, $extra, $attrs) = @_;
 warn 'ENTER code_highlight' if $DEBUG_AUBBC;
 $txt =~ s/:/&#58;/g;
 $txt =~ s/\[/&#91;/g;
 $txt =~ s/\]/&#93;/g;
 $txt =~ s/\000&#91;/&#91;&#91;/g;
 $txt =~ s/\000&#93;/&#93;&#93;/g;
 $txt =~ s/\{/&#123;/g;
 $txt =~ s/\}/&#125;/g;
 $txt =~ s/%/&#37;/g;
 $txt =~ s/(?<!>)\n/<br$AUBBC{html_type}>\n/g;
 if ($AUBBC{highlight}) {
  warn 'ENTER block highlight' if $DEBUG_AUBBC;
  $txt =~ s/\z/<br$AUBBC{html_type}>/ if $txt !~ m/<br$AUBBC{html_type}>\z/;
  $txt =~ s/(&#60;&#60;(?:&#39;)?(\w+)(?:&#39;)?&#59;(?s)[^\2]+\b\2\b)/<span$AUBBC{highlight_class1}>$1<\/span>/g;
  $txt =~ s/(?<![\&\$])(\#.*?(?:<br$AUBBC{html_type}>))/<span$AUBBC{highlight_class2}>$1<\/span>/g;
  $txt =~ s/(\bsub\b(?:\s+))(\w+)/$1<span$AUBBC{highlight_class8}>$2<\/span>/g;
  $txt =~ s/(\w+(?:\-&#62;)?(?:\w+)?&#40;(?:.+?)?&#41;(?:&#59;)?)/<span$AUBBC{highlight_class9}>$1<\/span>/g;
  $txt =~ s/((?:&amp;)\w+&#59;)/<span$AUBBC{highlight_class9}>$1<\/span>/g;
  $txt =~ s/(&#39;(?s).*?(?<!&#92;)&#39;)/<span$AUBBC{highlight_class3}>$1<\/span>/g;
  $txt =~ s/(&#34;(?s).*?(?<!&#92;)&#34;)/<span$AUBBC{highlight_class4}>$1<\/span>/g;
  $txt =~ s/(?<![\#|\w])(\d+)(?!\w)/<span$AUBBC{highlight_class5}>$1<\/span>/g;
  $txt =~
s/(&#124;&#124;|&amp;&amp;|\b(?:strict|package|return|require|for|my|sub|if|eq|ne|lt|ge|le|gt|or|xor|use|while|foreach|next|last|unless|elsif|else|not|and|until|continue|do|goto)\b)/<span$AUBBC{highlight_class6}>$1<\/span>/g;
  $txt =~ s/(?<!&#92;)((?:&#37;|\$|\@)\w+(?:(?:&#91;.+?&#93;|&#123;.+?&#125;)+|))/<span$AUBBC{highlight_class7}>$1<\/span>/g;
 }
 return ($txt, $markup);
}

1;

__END__

=pod

=head1 COPYLEFT

AUBBC2.pm, v1.00 alpha 4 10/20/2011 By: N.K.A.

------------------>^- Yes this is a test version and is subjected to changes.

shakaflex [at] gmail.com

http://search.cpan.org/~sflex/

Advanced Universal Bulletin Board Code 2

BBcode Placeholders with HTML Template

=head1 SYNOPSIS

      use AUBBC2;
      my $aubbc = AUBBC2->new();
      my $message = '[b]stuf[/b]';
      print  $aubbc->parse_bbcode($message);

=head1 ABSTRACT

BBcode Placeholders with HTML Template

=head1 DESCRIPTION

The main consept for this is to prase bbcode to markup and give a lot of
controle over each tag designed through templating the markup. The attributes
syntax for 'extra' should help to reduce the need to do reguler-expretions to
validate attributes. Still under development so consept can change.

AUBBC vs AUBBC2

AUBBC = Has more time used in production and testing but does not fully support
Strict markup.

AUBBC2 = Is an alpha version meaning any part of the program is subjected
to changes and may not fully work or needs more testing.

This module can fully support BBcode to HTML/XHTML Strict.
Block in Inline and incorrectly nested tags do not exsits if you switch to
CSS classes in DIV elements and disable nested tags by escaping the bracket's
after the first tag was parsed or using HTML::Tidy but thats over board.

=head1 Testing

This list of methods are the focuse of testing for this version. The methods
with * should be low in testing priority or will work well.

# Main parser

parse_bbcode()

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

escape_aubbc()

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

link			[tag://message] or [tag://message|extra]

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
         # May have to return more so we have better/more controle
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

-2) All attributes listed in 'extra' must be used atleast one time for the tag to convert.

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

This is the template of the tag and has tags of its own giving you more controle

Markup Template Tags:

Tag:            Info

%setting%       Any setting name in AUBBC2's main setting hash %AUBBC

%{tag}          Tag value

%{message}      Message value

%{extra}        Extra value for non-attribute syntax

X{attribute}    Attribute names for values of attribute syntax


=cut
