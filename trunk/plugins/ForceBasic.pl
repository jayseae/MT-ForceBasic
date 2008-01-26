# ===========================================================================
# Copyright Everitz Consulting.  Not for redistribution.
# ===========================================================================
package MT::Plugin::ForceBasic;

use base qw(MT::Plugin);
use strict;

use MT;

our $ForceBasic;
MT->add_plugin($ForceBasic = __PACKAGE__->new({
  name => 'MT-ForceBasic',
  description => 'Force limited authors to basic entry interface.',
  author_name => 'Everitz Consulting',
  author_link => 'http://www.everitz.com/',
  version => '0.2.0'
}));

# callback registration

use MT::Entry;
MT::Entry->add_callback('pre_save', 10, $ForceBasic, \&check_entry);

MT->add_callback('MT::App::CMS::AppTemplateParam.edit_entry', 1, $ForceBasic, \&force_basic);

sub instance { $ForceBasic }

sub check_entry {
  my ($err, $obj) = @_;
  return if ($obj->status);
  require MT::Entry;
  $obj->status(MT::Entry::HOLD());
}

sub force_basic {
  my ($cb, $app, $param) = @_;
  my $auth = $app->user;
  return unless ($auth);
  require MT::Permission;
  my $perm = MT::Permission->load({ author_id => $auth->id });
  return unless ($perm);
  $param->{'has_manage_label'} =
    $perm->can_edit_templates  || $perm->can_administer_blog ||
    $perm->can_edit_categories || $perm->can_edit_config;
  $param->{'disp_prefs_basic'} = 1 unless ($param->{'has_manage_label'});
}

1;
