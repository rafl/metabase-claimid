use strict;
use warnings;
use Test::More;
use Test::Exception;
use Email::Sender::Transport::Test;
use FindBin;

use Metabase::ClaimID;

my $transport = Email::Sender::Transport::Test->new;

my $claimer = Metabase::ClaimID->new({
    index_file     => "$FindBin::Bin/share/data/test_index.json",
    data_root      => "$FindBin::Bin/share/data/test_ids",
    kit_source     => "$FindBin::Bin/../share/mkits/metabase_id.mkit",
    transport      => $transport,
    sender_address => 'metabase-claimid@ata.local',
});
isa_ok($claimer, 'Metabase::ClaimID');

lives_ok(sub {
    ok($claimer->resolve('rafl@debian.org'), 'resolving an existing entry');
}, 'no exception for existing entry');

throws_ok(sub {
    $claimer->resolve('someone@nonexistanthost');
}, qr/No entry for someone\@nonexistanthost/);

throws_ok(sub {
    $claimer->resolve('existingbut@missingfile.com');
}, qr/No metabase id for existingbut\@missingfile\.com/);

$claimer->send_id('rafl@debian.org');

my @sent = $transport->deliveries;
is(scalar @sent, 1, 'one mail sent');

my $msg = $sent[0];
is_deeply($msg->{successes}, ['rafl@debian.org'], 'sent to the right recipient');
is($msg->{envelope}->{from}, 'metabase-claimid@ata.local', 'right sender address');

my $mail = $msg->{email}->cast('Email::MIME');
is($mail->header('To'), 'rafl@debian.org', 'right To header');
is($mail->header('From'), 'Metabase ID Claimer <metabase-claimid@ata.local>', 'right From header');
is($mail->header('Subject'), 'Metabase ID for rafl@debian.org', 'right Subject header');

my @parts = $mail->parts;
is(scalar @parts, 2, 'a body and an attachment');
my ($body, $attachment) = @parts;

is($body->content_type, 'text/plain', 'plaintext body');
like($body->body, qr/rafl\@debian\.org/, 'body mentions recipient');

like($attachment->content_type, qr{^application/json;}, 'json attachment');
is($attachment->body, "moo\n", 'attachment contains content of id file');

done_testing;
