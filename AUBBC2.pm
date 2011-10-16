package AUBBC2;
use strict;
use warnings;

our $VERSION     = '1.00a3';
our $BAD_MESSAGE = 'Error';
our $DEBUG_AUBBC = 0; # not being worked on
our $MEMOIZE     = 1; # Testing Speed

my $serialize    = 20; # next tag ID
my $msg          = ''; # can try to take out

# will be removed
my %SMILEYS      = ();

# There maybe less settings than this
my %AUBBC        = (
    aubbc               => 1,
    utf                 => 1,
    smileys             => 1,
    highlight           => 1,
    highlight_function  => \&code_highlight,
    no_bypass           => 0,
    for_links           => 0,
    aubbc_escape        => 1,
    no_img              => 0,
    icon_image          => 1,
    image_hight         => '60',
    image_width         => '90',
    image_border        => '0',
    image_wrap          => ' ',
    href_target         => ' target="_blank"',
    images_url          => '',
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

my @do_flag = (1,1,1,1,1,0,0,0); # do switches for internal logic
my @key64   = ('A'..'Z','a'..'z',0..9,'+','/'); # protect email tag

# moved out of sub for build and commen tags
my $href = '\w+\://[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+?)?';
my $src = '\w+\://[\w\.\/\-\~\@\:\;\=]+|\/[\w\.\/\-\~\@\:\;\=]+';
my $any = '.+?';
# some tags for testing
my %TAGS = (
 1 => {
 'tag' => 'code|c',
  'type' => 2,
  'function' => 'AUBBC2::code_highlight',
  'message' => $any,
  'extra' => '',
  'markup' => "<div$AUBBC{code_class}><code>
%{message}
</code></div>$AUBBC{code_extra}",
 },
 2 => {
 'tag' => 'code|c',
  'type' => 2,
  'function' => 'AUBBC2::code_highlight',
  'message' => $any,
  'extra' => $any,
  'markup' => "# %{extra}:<br$AUBBC{html_type}>
<div$AUBBC{code_class}><code>
%{message}
</code></div>$AUBBC{code_extra}",
 },
 3 => {
 'tag' => 'url',
  'type' => 2,
  'function' => 'AUBBC2::fix_message',
  'message' => $any,
  'extra' => $href,
  'markup' => "<a href=\"%{extra}\"$AUBBC{href_target}$AUBBC{href_class}>%{message}</a>",
 },
 4 => {
 'tag' => 'color',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '[\w#]+',
  'markup' => "<div style=\"color:%{extra};\">%{message}</div>",
 },
 5 => {
 'tag' => 'eamil',
  'type' => 2,
  'function' => '',
  'message' => '(?![\w\.\-\&\+]+\@[\w\.\-]+).+?',
  'extra' => '',
  'markup' => "[<font color=red>$BAD_MESSAGE<\/font>\]email",
 },
 6 => {
 'tag' => 'li',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '\d+',
  'markup' => '<li value="%{extra}">%{message}</li>',
 },
 7 => {
 'tag' => 'u',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-decoration: underline;">%{message}</div>',
 },
 8 => {
 'tag' => 'strike',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-decoration: line-through;">%{message}</div>',
 },
 9 => {
 'tag' => 'center',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-align: center;">%{message}</div>',
 },
 10 => {
 'tag' => 'right',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-align: right;">%{message}</div>',
 },
 11 => {
 'tag' => 'left',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<div style="text-align: left;">%{message}</div>',
 },
 12 => {
 'tag' => 'quote',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '[\w\s]+',
  'markup' => "<div$AUBBC{quote_class}><small><strong>%{extra}:</strong></small><br$AUBBC{html_type}>
%{message}
</div>$AUBBC{quote_extra}",
 },
 13 => {
 'tag' => 'quote',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => "<div$AUBBC{quote_class}>%{message}</div>$AUBBC{quote_extra}",
 },
 14 => {
 'tag' => 'img',
  'type' => 2,
  'function' => '',
  'message' => $src,
  'extra' => '',
  'markup' => "<a href=\"%{message}\"$AUBBC{href_target}$AUBBC{href_class}><img src=\"%{message}\" width=\"$AUBBC{image_width}\" height=\"$AUBBC{image_hight}\" alt=\"\" border=\"$AUBBC{image_border}\"$AUBBC{html_type}></a>$AUBBC{image_wrap}",
 },
 15 => {  # ?
  'tag' => 'http',
  'type' => 3,
  'function' => '',
  'message' => '[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\,\$\-\+\!\*\?/\=\@\#\%]+?)?',
  'extra' => '',
  'markup' => "<a href=\"%{tag}://%{message}\"$AUBBC{href_target}$AUBBC{href_class}>%{tag}&#58;//%{message}</a>",
 },
 16 => {
  'tag' => 'blockquote|big|h[123456]|[ou]l|li|em|pre|s(?:mall|trong|u[bp])|[bip]',
  'type' => 2,
  'function' => '',
  'message' => $any,
  'extra' => '',
  'markup' => '<%{tag}>%{message}</%{tag}>',
 },
 17 => {
  'tag' => 'br|hr',
  'type' => 1,
  'function' => '',
  'message' => '',
  'extra' => '',
  'markup' => '<%{tag}%html_type%>',
 },
 18 => {
  'tag' => 'video',
  'type' => 2,
  'function' => '',
  'message' => $src,
  'extra' => '-|width/n{90-120},height/n{60-90}',
  'markup' => '<video width="X{width}" height="X{height}" controls="controls">
   <source src="%{message}" type="video/mp4" />
 Your browser does not support the video tag.
 </video>',
 },
 19 => {
  'tag' => 'mp4',
  'type' => 2,
  'function' => '',
  'message' => $src,
  'extra' => '-|mp4/n{90-120},width/n{90-120}',
  'markup' => '<video width="X{width}" height="X{mp4}" controls="controls">
   <source src="%{message}" type="video/mp4" />
 Your browser does not support the video tag.
 </video>',
 },
 20 => {  # ?
  'tag' => 'http',
  'type' => 3,
  'function' => '',
  'message' => '[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\,\$\-\+\!\*\?/\=\@\#\%]+?)?',
  'extra' => $any,
  'markup' => "<a href=\"%{tag}://%{message}\"$AUBBC{href_target}$AUBBC{href_class}>%{extra}</a>",
 },
);

sub new {
warn 'CREATING AUBBC '.$VERSION if $DEBUG_AUBBC;
 if ($MEMOIZE && ! $do_flag[7]) {
  $do_flag[7] = 1;
  eval 'use Memoize' if ! defined $Memoize::VERSION;
  unless ($@ || ! defined $Memoize::VERSION) {
   Memoize::memoize('AUBBC2::do_all_ubbc');
  }
 }
return bless {};
}

sub DESTROY {
warn 'DESTROY AUBBC '.$VERSION if $DEBUG_AUBBC;
}

sub settings {
 my ($self,%s_hash) = @_;
 if (keys %s_hash) {
  foreach (keys %s_hash) {
   $AUBBC{$_} = $s_hash{$_} if exists $AUBBC{$_};
  }
 }
 
$AUBBC{href_target} = ($AUBBC{href_target}) ? ' target="_blank"' : '';
$AUBBC{image_wrap} = ($AUBBC{image_wrap}) ? ' ' : '';
$AUBBC{image_border} = ($AUBBC{image_border}) ? 1 : 0;
$AUBBC{html_type} = ($AUBBC{html_type} eq 'xhtml' || $AUBBC{html_type} eq ' /') ? ' /' : '';

 if ($DEBUG_AUBBC) {
  my $uabbc_settings = '';
  foreach (keys %AUBBC) {
   $uabbc_settings .= $_ . ' =>' . $AUBBC{$_} . ', ';
  }
 warn "AUBBC Settings Change: $uabbc_settings";
 }
}

sub get_setting {
 my ($self,$name) = @_;
 return $AUBBC{$name} if exists $AUBBC{$name};
}

sub do_all_ubbc {
 my ($self,$message) = @_;
 warn 'ENTER do_all_ubbc' if $DEBUG_AUBBC;
 $msg = (defined $message) ? $message : '';
 if ($msg) {
  $msg = $self->script_escape($msg,'') if $AUBBC{script_escape};
  $msg =~ s/&(?!\#?[\d\w]+;)/&amp;/g if $AUBBC{fix_amp};
  if (!$AUBBC{no_bypass} && $msg =~ m/\A\#no/) {
   $do_flag[3] = 0 if $msg =~ s/\A\#none//;
   if ($do_flag[4]) {
   $do_flag[3] = 0 if $msg =~ s/\A\#none//;
   $do_flag[0] = 0 if $do_flag[3] && $msg =~ s/\A\#noubbc//;
   $do_flag[1] = 0 if $do_flag[3] && $msg =~ s/\A\#noutf//;
   $do_flag[2] = 0 if $do_flag[3] && $msg =~ s/\A\#nosmileys//;
   }
   warn 'START no_bypass' if $DEBUG_AUBBC && !$do_flag[4];
  }
  if ($do_flag[3]) {
   escape_aubbc($msg) if $AUBBC{aubbc_escape};
   do_ubbc($msg) if $do_flag[0] && !$AUBBC{for_links} && $AUBBC{aubbc};
   do_unicode($msg) if $do_flag[1] && $AUBBC{utf};
   # on its way out soon
   do_smileys($msg) if $do_flag[4] && $do_flag[2] && $AUBBC{smileys};
  }
 }
 return $msg;
}
sub do_ubbc {
 warn 'ENTER do_ubbc ' if $DEBUG_AUBBC;

 if ($AUBBC{protect_email}) {
 $serialize++;
 $TAGS{$serialize} = {
  'tag' => 'email',
  'type' => 2,
  'function' => 'AUBBC2::protect_email',
  'message' => '[\w\.\-\&\+]+\@[\w\.\-]+',
  'extra' => '',
  'markup' => '',
  };
 }
  else {
  $serialize++;
 $TAGS{$serialize} = {
  'tag' => 'email',
  'type' => 2,
  'function' => '',
  'message' => '[\w\.\-\&\+]+\@[\w\.\-]+',
  'extra' => '',
  'markup' => "<a href=\"mailto:%{message}\"$AUBBC{href_class}>%{message}</a>",
  };
 }
 
foreach my $num (keys %TAGS) {
 my $re_fix = '';
  if ($TAGS{$num}{type} eq 1) {
  # type 1: [tag]
  $msg =~ s/(\[($TAGS{$num}{tag})\])/
   my $ret = set_tag($TAGS{$num}{type}, $2, '' , $TAGS{$num}{markup}, $TAGS{$num}{function}, '','' );
   $ret ? $ret : set_temp($1);
  /eg;
  }
   elsif ($TAGS{$num}{type} eq 2) {
  # type 2: [tag]message[/tag] or [tag=x]message[/tag]
  # or [tag=x attr2=x attr3=x attr4=x]message[/tag] or [tag attr1=x attr2=x attr3=x]message[/tag]
  $re_fix = ($TAGS{$num}{extra} && $TAGS{$num}{extra} =~ m/\A\-\|/i)
   ? '[= ].+?' : '='.$TAGS{$num}{extra} if $TAGS{$num}{extra};
  1 while $msg =~ s/(\[(($TAGS{$num}{tag})$re_fix)\](?s)($TAGS{$num}{message})\[\/\3\])/
   my $ret = set_tag($TAGS{$num}{type}, $3, $4 , $TAGS{$num}{markup}, $TAGS{$num}{function}, $TAGS{$num}{extra}, $2 );
   $ret ? $ret : set_temp($1);
  /eg;
  }
   elsif ($TAGS{$num}{type} eq 3) {
  # type 3: [tag://message] or [tag://message|extra]
  $re_fix = $TAGS{$num}{extra}
   ? '&#124;'.$TAGS{$num}{extra} : '';
  $msg =~ s/(\[($TAGS{$num}{tag})\:\/\/($TAGS{$num}{message})($re_fix)\])/
   my $ret = set_tag($TAGS{$num}{type}, $2, $3 , $TAGS{$num}{markup}, $TAGS{$num}{function}, $TAGS{$num}{extra},$4);
   $ret ? $ret : set_temp($1);
  /eg;
  }
   elsif ($TAGS{$num}{type} eq 4) {
   # type 4: replace or remove
  $msg =~ s/($TAGS{$num}{message})/
   my $ret = set_tag($TAGS{$num}{type}, '', $1 , $TAGS{$num}{markup}, $TAGS{$num}{function}, $TAGS{$num}{extra},'');
   $ret ? $ret : '';
   /eg;
  }
 }
 # the pipe being added at set_temp is needed to stop a forever loop
 # if a tag was rejected. pipe gets removed here.
 $msg =~ s/\[\|/\[/g;
 return $msg;
}

sub set_temp {
my $in = shift;
$in =~ s/\[/\[\|/;
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
   if ($extra && $type eq 2 && $extra =~ s/\A\-\|//) {
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
    && ($type eq 2 || $type eq 3)) {
    $extra = $attrs;
   }

 if ($markup =~ m/%/) {
  $markup =~ s/%$_%/$AUBBC{$_}/g foreach (keys %AUBBC);
  $markup =~ s/%{tag}/$tag/g;
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
   $task =~ m/(\d+)\-(\d+)}\z/;
   $limited >= $1 && $limited <= $2 ? return 1 : return 0;
 }
  elsif (defined $limited && $task =~ m/\Al/) {
  if ($task =~ m/{(\d+)}\z/) {
   length($limited) <= $1 ? return 1 : return 0;
  }
   elsif ($task =~ m/(\w+)\-(\w+)}\z/) {
   $limited !~ m/\A[$1-$2]+\z/i ? return 0 : return 1;
   }
 }
  elsif (defined $limited && $task =~ m/\Aw/) {
  if ($task =~ m/{(\d+)}\z/) {
   length($limited) <= $1
    && $limited =~ m/\A[\w\s\-\.\,\!\?]+\z/i ? return 1 : return 0;
   }
    elsif ($task =~ m/{(.+?)}\z/) {
     $limited =~ m/\A(?:$1)\z/i ? return 1 : return 0;
    }
 }
  else {
  # safe fail
   return 0;
  }
}

# this needs some changes!
sub add_tag {
 my ($self,%NewTag) = @_;
 warn "ENTER add_ubbc_tag $self" if $DEBUG_AUBBC;

 foreach (keys %NewTag) {
  if (exists $NewTag{$_}{function} && $NewTag{$_}{function}) {
   unless (exists &{$NewTag{$_}{function}} && (ref $NewTag{$_}{function} eq 'CODE' || ref $NewTag{$_}{function} eq '')) {
    die "Usage: add_ubbc_tag - function 'Undefined subroutine' => '$NewTag{$_}{function}'";
   }
  }
 $NewTag{$_}{message} = $href if $NewTag{$_}{message} eq 'href';
 $NewTag{$_}{message} = $src if $NewTag{$_}{message} eq 'src';
 $NewTag{$_}{message} = $any if $NewTag{$_}{message} eq 'any';
 $NewTag{$_}{extra} = $href if $NewTag{$_}{extra} eq 'href';
 $NewTag{$_}{extra} = $src if $NewTag{$_}{extra} eq 'src';
 $NewTag{$_}{extra} = $any if $NewTag{$_}{extra} eq 'any';
  $serialize++;
 $TAGS{$serialize} = {
  'tag' => $NewTag{$_}{tag},
  'type' => $NewTag{$_}{type},
  'function' => $NewTag{$_}{function},
  'message' => $NewTag{$_}{message},
  'extra' => $NewTag{$_}{extra},
  'markup' => $NewTag{$_}{markup},
  };
  warn "Added add_ubbc_tag ".$TAGS{$serialize}{tag} if $DEBUG_AUBBC && $TAGS{$serialize}{tag};

 }
 warn "END add_ubbc_tag $self" if $DEBUG_AUBBC;
}

sub remove_ubbc_tag {
 my ($self,$name) = @_;
 delete $TAGS{$name} if defined $name && exists $TAGS{$name};
 warn "ENTER remove_ubbc_tag $self" if $DEBUG_AUBBC;
}

sub tag_list {
my ($self,$type) = shift;
$type = '' unless defined $type && $type;
my $text = '';
 foreach (keys %TAGS) {
  $text .= <<TEXT;
ID:$_
tage:$TAGS{$_}{tag}
type:$TAGS{$_}{type}
function:$TAGS{$_}{function}
message:$TAGS{$_}{message}
extra:$TAGS{$_}{extra}
markup:$TAGS{$_}{markup}
---:---
TEXT
 }
 
 $text =~ s/\n/<br$AUBBC{html_type}>\n/g if $type eq 'html';
 return $text;
}

sub clear_ubbc_tags {
 my ($self) = @_;
 %TAGS = ();
 warn "ENTER clear_ubbc_tags $self" if $DEBUG_AUBBC;
}

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

sub do_smileys {
warn 'ENTER do_smileys' if $DEBUG_AUBBC;
$msg =~ s/\[$_\]/<img src="$AUBBC{images_url}\/smilies\/$SMILEYS{$_}" alt="$_" border="$AUBBC{image_border}"$AUBBC{html_type}>$AUBBC{image_wrap}/gi foreach (keys %SMILEYS);
}

sub smiley_hash {
 my ($self,%s_hash) = @_;
 warn 'ENTER smiley_hash' if $DEBUG_AUBBC;
 if (keys %s_hash) {
 %SMILEYS = %s_hash;
 $do_flag[4] = 1 if !$do_flag[4];
 }
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

sub do_unicode{
 warn 'ENTER do_unicode' if $DEBUG_AUBBC;
 $msg =~ s/\[utf:\/\/(\#?\w+)\]/&$1;/g;
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

1;

__END__

=pod

=head1 COPYLEFT

AUBBC2.pm, v1.00 alpha 3 10/16/2011 By: N.K.A.
------------------>^- Yes this is a test version and is subjected to changes.
                   
shakaflex [at] gmail.com
http://search.cpan.org/~sflex/

Advanced Universal Bulletin Board Code 2 - Engine for BBcode to HTML

BBcode Placeholders with HTML Template

AUBBC vs AUBBC2

AUBBC = Has more time used in production and testing but does not fully support
Strict markup.

AUBBC2 = Is an alpha version meaning any part of the program is subjected
to changes and may not fully work or needs more testing.

This module can fully support BBcode to HTML/XHTML Strict.
Block in Inline and incorrectly nested tags do not exsits if you switch to
CSS classes in DIV elements or we will find out soon enough.

      use AUBBC2;
      my $aubbc = AUBBC2->new();
      my $message = '[b]stuf[/b]';
      print  $aubbc->do_all_ubbc($message);
      
      
=head1 Adding Tags

        $aubbc->add_tag(
          'tag' => 'Tag',               # Tag name:
          'type' => '#',                # Type number: tag style
          'function' => '',             # Function: subroutine to expand methods
          'message' => 'any',           # Message: of tag
          'extra' => '',                # Extra: of tag
          'markup' => '',               # Template: output
        );

Type number:              Tag style

1                       [tag]

2			[tag]message[/tag] or [tag=extra]message[/tag] or [tag attr=x...]message[/tag] or [tag=x attr=x...]message[/tag]

3			[tag://message] or [tag://message|extra]

4                       replace or remove

Tag name:
This allows a single tag added to change many tags and supports more complex regex:

        # This is an example of bold and italic in the same add_tag()
        # Tags: [b]message[/b] or [i]message[/i]
        # Output: <b>message</b> or <i>message</i>
        $aubbc->add_tag(
          'tag' => 'b|i', # b or i
          'type' => '2',
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
          'type' => '2',
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
          'type' => '2',
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

Tag             Info
%setting%       Any setting name in AUBBC2's main setting hash %AUBBC
%{tag}          Tag value
%{message}      Message value
%{extra}        Extra value for non-attribute syntax
X{attribute}    Attribute names for values of attribute syntax


http://www.youtube.com/watch?v=cfOa1a8hYP8

=cut
