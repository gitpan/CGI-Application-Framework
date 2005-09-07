use strict;
use Test::More 'no_plan';
use lib 't';
use CGI;

{
    package MyTestApp;

    use base 'TestApp';
    use TestCDBI;

    sub setup {
        my $self = shift;
        $self->run_modes([ qw(main_display) ]);
        $self->SUPER::setup();
    }

    sub main_display {
        my $self    = shift;
        my $stash = $self->stash;

        my $output = $self->template->fill({
            var1 => 'value_one',
            var2 => 'value_two',
            var3 => 'value_three',
        });

        $output = $$output if ref $output eq 'SCALAR';
        $stash->{'Template_Output'} = $output;
        $stash->{'Seen_Run_Mode'}{'main_display'} = 1;
        $stash->{'Final_Run_Mode'}                = 'main_display';
        '';
    }

}

# Set up query and app
my ($query, $app);
$query = new CGI;
$query->param('come_from_rm', 'login');
$query->param('current_rm',   'login');
$query->param('rm',           'main_display');


#######################################################################
# Fake that we've come from the login page with good parameters
$app   = MyTestApp->new(QUERY => $query);
$query->param('username',     'test');
$query->param('password',     'seekrit');
$app->run;

my $expected_output = <<'EOF';
--begin--
var1:value_one
var2:value_two
var3:value_three
--end--
EOF

ok($app->stash->{'User_OK'},                           '[login, good parms] valid user');
ok($app->stash->{'Password_OK'},                       '[login, good parms] valid password');
is($app->stash->{'Template_Output'}, $expected_output, 'template output good');




