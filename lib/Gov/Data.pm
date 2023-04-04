package Gov::Data;

use strict;
use warnings;

use LWP::UserAgent;
use JSON;
use XML::Simple;
use Data::Dumper;

sub new {
	my ($class, $info) = @_;

	my $me = { };

	$me->{verbose} = $info->{verbose};

	if ($me->{verbose}>0) {
		print Dumper($info);
	}

	foreach my $v (('ApiKey', 'Accept', 'UserAgent', 'format')) {
		if ($me->{verbose}>0) {
			if (!defined($info->{$v})) {
				print "me->{$v} = <undef>\n";
			} else {
				print "me->{$v} = ".$info->{$v}."\n";
			}
		}
		$me->{$v} = $info->{$v};
	}

	bless $me, $class;

	$me->{ua} = LWP::UserAgent->new;
	$me->inithead();

	$me->{xml} = XML::Simple->new();

	return $me;
}

sub inithead {
	my ($me) = @_;
	if (defined($me->{ApiKey})) {
		$me->{ua}->default_header('X-Api-Key' => $me->{ApiKey});
	}
	if (defined($me->{Accept})) {
		$me->{ua}->default_header('Accept' => $me->{Accept});
	}
	if (defined($me->{UserAgent})) {
		$me->{ua}->default_header('User-Agent' => $me->{UserAgent});
	}
	if (defined($me->{format})) {
		$me->{ua}->default_header('format' => $me->{format});
	}
}

sub getreq {
	my ($me, $url) = @_;

	if ($me->{verbose}>0) {
		printf "getreq ...ooOO( $url )OOoo...\n";
	}

	my $req = HTTP::Request->new(GET => $url);
	my $resp = $me->{ua}->request($req);

	my $retry = $resp->header('retry-after');
	if (defined($retry)) {
		print "Retry header found, pausing ${retry}s\n";
		sleep($retry+1);
		return $me->getreq($url);
	}

	$me->{lastheaders} = $resp->headers();

	my $thisrlim = $resp->header('x-ratelimit-limit');
	my $thisrlim_remain = $resp->header('x-ratelimit-remaining');
	if (defined($thisrlim)) {
		$me->{rlim} = $thisrlim;
	}
	if (defined($thisrlim_remain)) {
		$me->{rlim_remain} = $thisrlim_remain;
	}

	if (!$resp->is_success) {
		if ($me->{verbose}>0) {
			print STDERR "Request failed: " . $resp->status_line;
		}
		return $resp;
	}
	if ($me->{verbose}>0) {
		print Dumper($resp);
		print "\n";
	}
	return $resp;
}

sub get_info {
	my ($me, $url) = @_;

	my $r = $me->getreq( $url );
	if ($r->is_success) {
		my $data = decode_json($r->content);
		return $data;
	}
	return undef;
}

sub get_xml {
	my ($me, $url) = @_;

	my $r = $me->getreq( $url );
	if ($r->is_success) {
		my $data = $me->{xml}->XMLin($r->content);
		return $data;
	}
	return undef;
}
1;
