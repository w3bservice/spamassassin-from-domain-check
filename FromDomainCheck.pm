#!/usr/bin/perl
use strict;
use warnings;

package FromDomainCheck;
use Mail::SpamAssassin::Plugin;
use Socket qw(inet_aton inet_ntoa);

my $MAIL_OK = 0;
my $MAIL_SPAM = 1;
my $ACTION_UNRESOLVABLE_HOSTNAME = $MAIL_OK; # if you want to drop these emails, set it to $MAIL_SPAM

my %IP_BLACKLIST = (
    "185.140.110.3" => 1,
    "185.207.8.14" => 1,
    "185.207.11.245" => 1,
    "185.207.8.246" => 1,
    "174.129.25.170" => 1
);

our @ISA = qw(Mail::SpamAssassin::Plugin);

sub new {
  my ($class, $mailsa) = @_;

  $class = ref($class) || $class;
  my $self = $class->SUPER::new($mailsa);
  bless ($self, $class);

  $self->register_eval_rule ("check_from_domain_ip");
  return $self;
}

sub check_from_domain_ip {
  my ($self, $msg) = @_;
  my $check_from = lc($msg->get('From:addr'));


  $check_from =~ /\@(.*)$/;
  my $from_domain = $1;

  gethostbyname($from_domain) or return $ACTION_UNRESOLVABLE_HOSTNAME;

  my $ip_address = inet_ntoa(inet_aton($from_domain));

  if ($IP_BLACKLIST{$ip_address}) {
    return $MAIL_SPAM;
  }

  return $MAIL_OK;
}

1;
