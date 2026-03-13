package CtrlNest::Helper::UploadFile;
use Mojo::Base -base;

use CtrlNest::Helper::Constants;

use Exporter 'import';
our @EXPORT = qw(
  upload_avatar
);

################################################################################

# !!!
# This function should not be used in production as it lacks security measures
# like sanitizing file names, checking for malicious content, and storing files
# securely. It is only intended for demonstration purposes.
# !!!
sub upload_avatar {
  my $c = shift;

  my $upload = $c->req->upload('avatar');

  return $c->render(text => 'No file uploaded', status => 400)
    unless $upload;

  # Validate MIME type
  return $c->render(text => 'Only images allowed', status => 400)
    unless $upload->headers->content_type =~ /^image\//;

  # Validate size (max 2MB)
  return $c->render(text => 'File too large (max 2MB)', status => 400)
    if $upload->size > 2 * 1024 * 1024;

  # Generate unique filename
  my $ext      = ($upload->filename =~ /(\.[a-zA-Z0-9]+)$/)[0] // '.jpg';
  my $unique   = md5_sum(time . rand() . $upload->filename);
  my $filename = "$unique$ext";

  my $path = "public/uploads/avatars/$filename";

  # Move uploaded file
  $upload->move_to($path);

  # Normally you'd store this in PostgreSQL
  $c->session(avatar => "/uploads/avatars/$filename");

  $c->redirect_to('/user/profile/' . $c->session('username'));
}

################################################################################

1;
