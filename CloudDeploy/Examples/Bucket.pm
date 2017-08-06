use CCfn;

package CloudDeploy::Examples::BucketParams {
  use Moose;
  use CCfnX::Attachments;
  extends 'CCfnX::CommonArgs';

};


package CloudDeploy::Examples::Bucket {
  use Moose;
  extends 'CCfn';
  use CCfnX::Shortcuts;

  has params => (
    is  => 'ro',
    isa => 'CloudDeploy::Examples::BucketParams',
    default => sub {
      CloudDeploy::Examples::InstanceInVPCWithBucketParams->new_with_options()
  });


  resource MyBucket => 'AWS::S3::Bucket', {
  };

  output 'bucket/name' => Ref('MyBucket');
};


