use CCfn;

package CloudDeploy::Examples::InstanceWithBucketParams {
  use Moose;
  use CCfnX::Attachments;
  extends 'CCfnX::CommonArgs';

  has ami          => (is => 'ro', isa => 'Str', required => 1);
  has instancetype => (is => 'ro', isa => 'Str', default => 't2.nano');
};


package CloudDeploy::Examples::InstanceWithBucket {
  use Moose;
  extends 'CCfn';
  use CCfnX::Shortcuts;

  has params => (
    is  => 'ro',
    isa => 'CloudDeploy::Examples::InstanceWithBucketParams',
    default => sub {
      CloudDeploy::Examples::InstanceWithBucketParams->new_with_options()
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

  resource MyBucket => 'AWS::S3::Bucket', {
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

  output 'bucket/name' => Ref('MyBucket');
  output 'bucket/user/accesskey' => Ref('MyUserAccessKey');
  output 'bucket/user/secretkey' => GetAtt('MyUserAccessKey', 'SecretAccessKey');
};


