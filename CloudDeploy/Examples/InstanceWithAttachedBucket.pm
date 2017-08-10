use CCfn;

package CloudDeploy::Examples::InstanceWithAttachedBucketParams {
  use Moose;
  use CCfnX::Attachments;
  extends 'CCfnX::CommonArgs';

  has ami          => (is => 'ro', isa => 'Str', required => 1);
  has instancetype => (is => 'ro', isa => 'Str', default => 't2.nano');

  attachment Bucket => (type => 'CloudDeploy::Examples::Bucket', documentation => 'The attached Bucket', provides => {
    BucketName => 'bucket/name',
  });
};


package CloudDeploy::Examples::InstanceWithAttachedBucket {
  use Moose;
  extends 'CCfn';
  use CCfnX::Shortcuts;

  has params => (
    is  => 'ro',
    isa => 'CloudDeploy::Examples::InstanceWithAttachedBucketParams',
    default => sub {
      CloudDeploy::Examples::InstanceWithAttachedBucketParams->new_with_options()
  });


  resource MyInstance => 'AWS::EC2::Instance', {
    ImageId          => Parameter('ami'),
    InstanceType     => Parameter('instancetype'),
    SecurityGroupIds => [ Ref('MySG') ],
  };

  resource MySG => 'AWS::EC2::SecurityGroup', {
    GroupDescription     => "MyInstance SG",
    SecurityGroupIngress => [
      SGRule(80, '0.0.0.0/0'),
    ],
  };

  resource MyUser => 'AWS::IAM::User', {
  };

  resource MyUserAccessKey => 'AWS::IAM::AccessKey', {
    UserName => Ref('MyUser'),
  };

  resource MyUserPolicy => 'AWS::IAM::Policy', {
    PolicyName     => "AccessBucketObjects",
    PolicyDocument => {
      Statement => [
        {
          Effect   => 'Allow',
          Action   => [ 's3:GetObject' ],
          Resource => 'arn:aws:s3:::*',  # WATCH OUT! ALL S3 Buckets!
        },
      ],
    },
    Users => [ Ref('MyUser') ],
  };


  output 'bucket/name'           => Ref('BucketName');
  output 'bucket/user/accesskey' => Ref('MyUserAccessKey');
  output 'bucket/user/secretkey' => GetAtt('MyUserAccessKey', 'SecretAccessKey');
};


