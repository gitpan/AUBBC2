package BBcode_sub;
use strict;
use warnings;

my @key64   = ('A'..'Z','a'..'z',0..9,'+','/'); # protect email tag

sub clean_msg {
 my ($type, $tag, $msg, $markup, $extra, $attrs) = @_;
 $msg =~ s/\r?\n?<br(?:\s?\/)?>//g;
 return ('', $msg);
}

sub protect_email {
 my ($type, $tag, $email, $markup, $extra, $attrs) = @_;
 my $option = 4;
 my ($email1, $email2, $ran_num, $protect_email, @letters) = ('', '', '', '', split (//, $email));
 $protect_email = '[' if $option eq 3 || $option eq 4;
 foreach my $character (@letters) {
  $protect_email .= '&#' . ord($character) . ';' if ($option eq 1 || $option eq 2);
  $protect_email .= ord($character) . ',' if $option eq 3;
  $ran_num = int(rand(64)) || 0 if $option eq 4;
  $protect_email .= '\'' . (ord($key64[$ran_num]) ^ ord($character)) . '\',\'' . $key64[$ran_num] . '\',' if $option eq 4;
 }
 return ("<a href=\"&#109;&#97;&#105;&#108;&#116;&#111;&#58;$protect_email\">$protect_email</a>",'') if $option eq 1;
 ($email1, $email2) = split ("&#64;", $protect_email) if $option eq 2;
 $protect_email = "'$email1' + '&#64;' + '$email2'" if $option eq 2;
 $protect_email =~ s/\,\z/]/ if $option eq 3 || $option eq 4;
 return ("
<a href=\"javascript:MyEmCode('$option',$protect_email);\">&#67;&#111;&#110;&#116;&#97;&#99;&#116;&#32;&#69;&#109;&#97;&#105;&#108;</a>
", '') if $option eq 2 || $option eq 3 || $option eq 4;
}

# will be moved
sub js_print {
my $self = shift;
print <<'JS';
Content-type: text/javascript

/*
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
my ($type, $tag, $txt, $markup, $extra, $attrs) = @_;
 $txt =~ s/:/&#58;/g;
 $txt =~ s/\[/&#91;/g;
 $txt =~ s/\]/&#93;/g;
 $txt =~ s/\000&#91;/&#91;&#91;/g;
 $txt =~ s/\000&#93;/&#93;&#93;/g;
 $txt =~ s/\{/&#123;/g;
 $txt =~ s/\}/&#125;/g;
 $txt =~ s/%/&#37;/g;
 $txt =~ s/(?<!>)\n/<br \/>\n/g;
 #if ($AUBBC{highlight}) {
#  $txt =~ s/\z/<br \/>/ if $txt !~ m/<br \/>\z/;
#  $txt =~ s/(&#60;&#60;(?:&#39;)?(\w+)(?:&#39;)?&#59;(?s)[^\2]+\b\2\b)/<span$AUBBC{highlight_class1}>$1<\/span>/g;
#  $txt =~ s/(?<![\&\$])(\#.*?(?:<br \/>))/<span$AUBBC{highlight_class2}>$1<\/span>/g;
#  $txt =~ s/(\bsub\b(?:\s+))(\w+)/$1<span$AUBBC{highlight_class8}>$2<\/span>/g;
#  $txt =~ s/(\w+(?:\-&#62;)?(?:\w+)?&#40;(?:.+?)?&#41;(?:&#59;)?)/<span$AUBBC{highlight_class9}>$1<\/span>/g;
#  $txt =~ s/((?:&amp;)\w+&#59;)/<span$AUBBC{highlight_class9}>$1<\/span>/g;
#  $txt =~ s/(&#39;(?s).*?(?<!&#92;)&#39;)/<span$AUBBC{highlight_class3}>$1<\/span>/g;
#  $txt =~ s/(&#34;(?s).*?(?<!&#92;)&#34;)/<span$AUBBC{highlight_class4}>$1<\/span>/g;
#  $txt =~ s/(?<![\#|\w])(\d+)(?!\w)/<span$AUBBC{highlight_class5}>$1<\/span>/g;
#  $txt =~
#s/(&#124;&#124;|&amp;&amp;|\b(?:strict|package|return|require|for|my|sub|if|eq|ne|lt|ge|le|gt|or|xor|use|while|foreach|next|last|unless|elsif|else|not|and|until|continue|do|goto)\b)/<span$AUBBC{highlight_class6}>$1<\/span>/g;
#  $txt =~ s/(?<!&#92;)((?:&#37;|\$|\@)\w+(?:(?:&#91;.+?&#93;|&#123;.+?&#125;)+|))/<span$AUBBC{highlight_class7}>$1<\/span>/g;
 #}
 return ($txt, $markup);
}

1;
