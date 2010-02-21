use strict;
use warnings;
use Test::More;
use Test::Exception;
use FindBin;

use Metabase::ClaimID;

my $claimer = Metabase::ClaimID->new({
    index_file => "$FindBin::Bin/share/data/test_index.json",
    data_root  => "$FindBin::Bin/share/data/test_ids",
});
isa_ok($claimer, 'Metabase::ClaimID');

lives_ok(sub {
    ok($claimer->resolve('rafl@debian.org'));
});

throws_ok(sub {
    $claimer->resolve('someone@nonexistanthost');
}, qr/No entry for someone\@nonexistanthost/);

throws_ok(sub {
    $claimer->resolve('existingbut@missingfile.com');
}, qr/No metabase id for existingbut\@missingfile\.com/);

done_testing;
