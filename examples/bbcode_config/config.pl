#
# Configuration File for AUBBC2 alpha 5+
# - Customize internal regex and BBcode tags
# - This is one of the fast ways to add tags
# - The other way is with %AUBBC2::regex && @AUBBC2::TAGS
# - names of hash %regex is only used in add_tag() "if add_tag is used!"

# Directory path to BBcode_sub.pm
use lib './';
use BBcode_sub;

# Customize internal regex and names for message and extra add_tag()
%regex = (
 href => '\w+\://[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\,\$\-\+\!\*\?/\=\&\@\#\%]+?)?',
 src  => '\w+\://[\w\.\/\-\~\@\:\;\=]+|\/[\w\.\/\-\~\@\:\;\=]+',
 any  => '.+?',
 );
 
# Hardcoded BBcode tags
# The function will not be checked and
# message or extra will not change names like src to regex
#
@TAGS = (
 {
 'tag' => 'code|c',
  'type' => 'balanced',
  'function' => \&BBcode_sub::code_highlight,
  'message' => $regex{any},
  'extra' => '',
  'markup' => "<div%code_class%><code>
%{message}
</code></div>%code_extra%",
 },
  {
 'tag' => 'code|c',
  'type' => 'balanced',
  'function' => \&BBcode_sub::code_highlight,
  'message' => $regex{any},
  'extra' => $regex{any},
  'markup' => "# %{extra}:<br%html_type%>
<div%code_class%><code>
%{message}
</code></div>%code_extra%",
 },
  {
 'tag' => 'url',
  'type' => 'balanced',
  'function' => \&BBcode_sub::fix_message,
  'message' => $regex{any},
  'extra' => $regex{href},
  'markup' => "<a href=\"%{extra}\"%href_target%%href_class%>%{message}</a>",
 },
  {
 'tag' => 'color',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '[\w#]+',
  'markup' => "<div style=\"color:%{extra};\">%{message}</div>",
 },
  {
 'tag' => 'eamil',
  'type' => 'balanced',
  'function' => '',
  'message' => '(?![\w\.\-\&\+]+\@[\w\.\-]+).+?',
  'extra' => '',
  'markup' => "[<font color=red>Error<\/font>\]email",
 },
  {
 'tag' => 'li',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '\d+',
  'markup' => '<li value="%{extra}">%{message}</li>',
 },
  {
 'tag' => 'u',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '',
  'markup' => '<div style="text-decoration: underline;">%{message}</div>',
 },
  {
 'tag' => 'strike',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '',
  'markup' => '<div style="text-decoration: line-through;">%{message}</div>',
 },
  {
 'tag' => 'center',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '',
  'markup' => '<div style="text-align: center;">%{message}</div>',
 },
  {
 'tag' => 'right',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '',
  'markup' => '<div style="text-align: right;">%{message}</div>',
 },
  {
 'tag' => 'left',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '',
  'markup' => '<div style="text-align: left;">%{message}</div>',
 },
  {
 'tag' => 'quote',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '[\w\s]+',
  'markup' => "<div%quote_class%><small><strong>%{extra}:</strong></small><br%html_type%>
%{message}
</div>%quote_extra%",
 },
  {
 'tag' => 'quote',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
  'extra' => '',
  'markup' => "<div%quote_class%>%{message}</div>%quote_extra%",
 },
  {
 'tag' => 'img',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{src},
  'extra' => '',
  'markup' => "<a href=\"%{message}\"%href_target%%href_class%><img src=\"%{message}\" width=\"%image_width%\" height=\"%image_hight%\" alt=\"\" border=\"%image_border%\"%html_type%></a>%image_wrap%",
 },
  {
  'tag' => 'blockquote|big|h[123456]|[ou]l|li|em|pre|s(?:mall|trong|u[bp])|[bip]',
  'type' => 'balanced',
  'function' => '',
  'message' => $regex{any},
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
  'message' => $regex{src},
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
  'message' => $regex{src},
  'extra' => '-|mp4/n{90-120},width/n{90-120}',
  'markup' => '<video width="X{width}" height="X{mp4}" controls="controls">
<source src="%{message}" type="video/mp4" />
Your browser does not support the video tag.
</video>',
 },
  {  # 1st
  'tag' => 'http',
  'type' => 'linktag',
  'function' => '',
  'message' => '(?!&#124;).+?',
  'extra' => $regex{any},
  'markup' => "<a href=\"%{tag}://%{message}\"%href_target%%href_class%>%{extra}</a>",
 },
  {  # 2nt
  'tag' => 'http',
  'type' => 'linktag',
  'function' => '',
  'message' => '[\w\.\/\-\~\@\:\;\=]+(?:\?[\w\~\.\;\:\&\,\$\-\+\!\*\?/\=\@\#\%]+?)?',
  'extra' => '',
  'markup' => "<a href=\"%{tag}://%{message}\"%href_target%%href_class%>%{tag}&#58;//%{message}</a>",
 },
  {
  'tag' => 'utf',
  'type' => 'linktag',
  'function' => '',
  'message' => '\#?\w+',
  'extra' => '',
  'markup' => '&%{message};',
 },
  {
  'tag' => 'email',
  'type' => 'balanced',
  'function' => \&BBcode_sub::protect_email,
  'message' => '[\w\.\-\&\+]+\@[\w\.\-]+',
  'extra' => '',
  'markup' => '',
  }
);

