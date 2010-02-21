use strict;
use warnings;
use Test::More;
use HTTP::Request::Common;

BEGIN {
    $ENV{METABASE_CLAIMID_WEB_CONFIG_LOCAL_SUFFIX} = 'test';
}

use Catalyst::Test 'Metabase::ClaimID::Web';

{
    my $res = request('/');
    ok($res->is_success, 'request to /');
    like($res->content, qr/<form/, 'it got the form');
}

{
    my $res = request(POST('/', [email => 'rafl@debian.org']));
    ok($res->is_success, 'POST for existing entry');
    like($res->content, qr/sent to/i, 'sent something');
}

{
    my $res = request(POST('/', [email => 'someone@nonexistanthost']));
    ok(!$res->is_success, 'POST for nonexistant entry');
    like($res->content, qr/no entry found/i, 'reports error');
}

{
    my $res = request(POST('/', [email => 'existingbut@missingfile.com']));
    ok(!$res->is_success, 'POST for nonexistant entry');
    like($res->content, qr/permanent error/i, 'reports error');
}

{
    no warnings 'redefine';
    local *Metabase::ClaimID::send_id = sub { die 42 };
    my $res = request(POST('/', [email => 'rafl@debian.org']));
    ok(!$res->is_success, 'POST for nonexistant entry');
    like($res->content, qr/temporary error/i, 'reports error');
}

{
    my $res = request('/foo');
    is($res->code, 404, 'got 404');
    like($res->content, qr/not found/i, 'says not found');
}

done_testing;
